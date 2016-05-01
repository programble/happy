global idt.init

Gate.INTERRUPT equ 0b0000_0110
Gate.TRAP equ 0b0000_0111

Flags.D equ 0b0000_1000
Flags.DPL0 equ 0b0000_0000
Flags.DPL1 equ 0b0010_0000
Flags.DPL2 equ 0b0100_0000
Flags.DPL3 equ 0b0110_0000
Flags.P equ 0b1000_0000

struc Gate
  .offset_lo: resw 1
  .segment: resw 1
  .zero: resb 1
  .flags: resb 1
  .offset_hi: resw 1
endstruc

struc Idt
  .limit: resw 1
  .base: resd 1
endstruc

section .rodata
idt.~gates:
  %rep 256
    istruc Gate
      at Gate.offset_lo, dw 0
      at Gate.segment, dw 0
      at Gate.zero, db 0
      at Gate.flags, db 0
      at Gate.offset_hi, dw 0
    iend
  %endrep
idt.#gates equ $ - idt.~gates
idt.idt:
  istruc Idt
    at Idt.limit, dw idt.#gates - 1
    at Idt.base, dd idt.~gates
  iend

section .text
idt.init: ; : :
  lidt [idt.idt]
  ret
