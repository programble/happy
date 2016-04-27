global boot, halt
extern main

section .bss
%define stack.SIZE 0x1000
stack resb stack.SIZE

section .text
boot:
  mov esp, stack + stack.SIZE
  push halt
  jmp main

halt:
  hlt
  jmp halt
