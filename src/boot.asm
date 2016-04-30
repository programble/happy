global boot, halt
extern mboot.boot, gdt.init, main

MAGIC equ 0x1BADB002
FLAGS equ 0x0
CHECKSUM equ -(MAGIC + FLAGS)

section .mboot
dd MAGIC
dd FLAGS
dd CHECKSUM

section .bss
boot.~stack: resb 0x1000
boot.$stack:

section .text
boot:
  mov esp, boot.$stack
  call mboot.boot
  call gdt.init
  push halt
  jmp main

halt:
  hlt
  jmp halt
