global main
extern vga.~buf, vga.blank, vga.puts
%include "vga.mac"

section .rodata
main.~hello db 'Hello, world!'
main.#hello equ $ - main.~hello

section .text
main:
  xor ax, ax
  call vga.blank
  mov ah, vga.RED
  mov ecx, main.#hello
  mov esi, main.~hello
  mov edi, vga.~buf
  call vga.puts
  ret
