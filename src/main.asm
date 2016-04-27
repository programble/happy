global main
extern vga.~buf, vga.blank, vga.putq, vga.puts
%include "vga.mac"

section .rodata
main.~hello db 'orld!'
main.#hello equ $ - main.~hello

section .text
main:
  mov ax, vga.GRY << vga.FG
  call vga.blank
  mov edi, vga.~buf
  mov eax, 'Hell'
  mov edx, 'o, w'
  call vga.putq
  mov ecx, main.#hello
  mov esi, main.~hello
  call vga.puts
  ret
