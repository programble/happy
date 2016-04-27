global boot, halt
extern main

section .bss
boot.~stack: resb 0x1000
boot.$stack:

section .text
boot:
  mov esp, boot.$stack
  push halt
  jmp main

halt:
  hlt
  jmp halt
