global mboot.boot

MAGIC equ 0x1BADB002
FLAGS equ 0x0
CHECKSUM equ -(MAGIC + FLAGS)

section .mboot
dd MAGIC
dd FLAGS
dd CHECKSUM

section .bss
mboot.magic: resd 1
mboot.@header: resd 1

section .text
mboot.boot:
  mov [mboot.magic], eax
  mov [mboot.@header], ebx
  ret
