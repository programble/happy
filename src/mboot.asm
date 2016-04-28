global mboot.boot, mboot.print
extern fmt.bin, fmt.hex, tty.print, tty.lf
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

section .rodata
mboot.?flags: db 'flags             '

section .text
mboot.boot:
  cmp eax, 0x2BADB002
  jne .ret
  mov [mboot.@info], ebx
  .ret: ret

mboot.print:
  mov ebp, [mboot.@info]
  mov ecx, 0x12
  mov esi, mboot.?flags
  call tty.print
  mov eax, [ebp]
  call fmt.bin
  call tty.print
  ret
