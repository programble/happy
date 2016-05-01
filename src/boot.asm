global boot.~stack, boot.$stack, boot
extern mboot.boot, gdt.init, idt.init, main
%include "macro.mac"
%include "vga.mac"

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
  call idt.init
  push dword 0xDEADBEEF
  call main
  panic 'return from main'
