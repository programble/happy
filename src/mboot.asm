global mboot.boot
%include "vga.mac"

MAGIC equ 0x1BADB002
FLAGS equ 0x0
CHECKSUM equ -(MAGIC + FLAGS)

section .mboot
dd MAGIC
dd FLAGS
dd CHECKSUM

section .data
mboot.@info: dd 0

section .text
mboot.boot:
  cmp eax, 0x2BADB002
  jne .ret
  mov [mboot.@info], ebx
  .ret: ret
