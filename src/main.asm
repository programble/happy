global main
extern vga.~buf, vga.clear, vga.puts

%include "vga.mac"

section .rodata
main.~hello db 'Hello, world!'
main.#hello equ $ - main.~hello

section .text
main:
  xor ax, ax
  call vga.clear
  mov ah, vga.RED
  mov ecx, main.#hello
  mov esi, main.~hello
  mov edi, vga.~buf
  call vga.puts
  ret
