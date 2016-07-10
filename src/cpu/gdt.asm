global gdt.init
global gdt.table, gdt.table.null, gdt.table.code, gdt.table.data, gdt.table.#

Type:
  .DATA: equ 0000_0000b
  .CODE: equ 0000_1000b
  .A: equ 0000_0001b
  .W: equ 0000_0010b
  .E: equ 0000_0100b
  .R: equ 0000_0010b
  .C: equ 0000_0100b

Access:
  .S: equ 0001_0000b
  .DPL0: equ 0000_0000b
  .DPL1: equ 0010_0000b
  .DPL2: equ 0100_0000b
  .DPL3: equ 0110_0000b
  .P: equ 1000_0000b

Flags:
  .L: equ 0010_0000b
  .D: equ 0100_0000b
  .B: equ 0100_0000b
  .G: equ 1000_0000b

struc SegmentDescriptor
  .limitLow: resw 1
  .baseLow: resw 1
  .baseMid: resb 1
  .typeAccess: resb 1
  .limitHighFlags: resb 1
  .baseHigh: resb 1
endstruc

struc Gdt
  .limit: resw 1
  .base: resd 1
endstruc

section .data
gdt.table:
  .null:
    dq 0
  .code:
    istruc SegmentDescriptor
      at SegmentDescriptor.limitLow, dw 0FFFFh
      at SegmentDescriptor.baseLow, dw 0
      at SegmentDescriptor.baseMid, db 0
      at SegmentDescriptor.typeAccess, db Type.CODE | Type.R | Access.S | Access.DPL0 | Access.P
      at SegmentDescriptor.limitHighFlags, db 0Fh | Flags.D | Flags.G
      at SegmentDescriptor.baseHigh, db 0
    iend
  .data:
    istruc SegmentDescriptor
      at SegmentDescriptor.limitLow, dw 0FFFFh
      at SegmentDescriptor.baseLow, dw 0
      at SegmentDescriptor.baseMid, db 0
      at SegmentDescriptor.typeAccess, db Type.DATA | Type.W | Access.S | Access.DPL0 | Access.P
      at SegmentDescriptor.limitHighFlags, db 0Fh | Flags.B | Flags.G
      at SegmentDescriptor.baseHigh, db 0
    iend
  .#: equ $ - gdt.table
gdt.gdt:
  istruc Gdt
    at Gdt.limit, dw gdt.table.# - 1
    at Gdt.base, dd gdt.table
  iend

section .text
gdt.init: ; : : ax
  lgdt [gdt.gdt]
  mov ax, gdt.table.data - gdt.table
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  jmp (gdt.table.code - gdt.table):.ret
  .ret:
ret
