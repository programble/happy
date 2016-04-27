global boot, halt
extern main

section .bss
stack~ resb 0x1000
stack$

section .text
boot:
  mov esp, stack$
  push halt
  jmp main

halt:
  hlt
  jmp halt
