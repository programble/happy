global boot, halt
extern mboot.boot, main

section .bss
boot.~stack: resb 0x1000
boot.$stack:

section .text
boot:
  mov esp, boot.$stack
  call mboot.boot
  push halt
  jmp main

halt:
  hlt
  jmp halt
