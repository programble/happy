global gdt.init

Type.A equ 0b0000_0001
Type.W equ 0b0000_0010
Type.E equ 0b0000_0100
Type.R equ 0b0000_0010
Type.C equ 0b0000_0100
Type.DATA equ 0b0000_0000
Type.CODE equ 0b0000_1000

Access.S equ 0b0001_0000
Access.DPL0 equ 0b0000_0000
Access.DPL1 equ 0b0010_0000
Access.DPL2 equ 0b0100_0000
Access.DPL3 equ 0b0110_0000
Access.P equ 0b1000_0000

Flags.L equ 0b0010_0000
Flags.D equ 0b0100_0000
Flags.B equ 0b0100_0000
Flags.G equ 0b1000_0000

struc Entry
  .limit_lo: resw 1
  .base_lo: resw 1
  .base_mi: resb 1
  .type_access: resb 1
  .limit_hi_flags: resb 1
  .base_hi: resb 1
endstruc

struc Gdt
  .limit: resw 1
  .base: resd 1
endstruc

section .rodata
gdt.~entries:
  .null: dq 0
  .code:
    istruc Entry
      at Entry.limit_lo, dw 0xFFFF
      at Entry.base_lo, dw 0
      at Entry.base_mi, db 0
      at Entry.type_access, db Type.CODE | Type.R | Access.S | Access.DPL0 | Access.P
      at Entry.limit_hi_flags, db 0xF | Flags.D | Flags.G
      at Entry.base_hi, db 0
    iend
  .data:
    istruc Entry
      at Entry.limit_lo, dw 0xFFFF
      at Entry.base_lo, dw 0
      at Entry.base_mi, db 0
      at Entry.type_access, db Type.DATA | Type.W | Access.S | Access.DPL0 | Access.P
      at Entry.limit_hi_flags, db 0xF | Flags.B | Flags.G
      at Entry.base_hi, db 0
    iend
gdt.#entries equ $ - gdt.~entries
gdt.gdt:
  istruc Gdt
    at Gdt.limit, dw gdt.#entries - 1
    at Gdt.base, dd gdt.~entries
  iend

section .text
gdt.init: ; : : ax
  lgdt [gdt.gdt]
  mov eax, gdt.~entries.data - gdt.~entries
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  jmp (gdt.~entries.code - gdt.~entries):.ret
  .ret: ret
