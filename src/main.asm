global main
extern vga.~buf, vga.blank, vga.putq
%include "vga.mac"

section .rodata
main.~hello db 'Hello, world!'
main.#hello equ $ - main.~hello

section .text
main:
  xor ax, ax
  mov ah, vga.GRY
  call vga.blank
  mov edi, vga.~buf
  mov eax, 'Hell'
  mov edx, 'o, w'
  call vga.putq
  ret
