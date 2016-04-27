global main
extern vga.~buf, vga.blank, vga.putq, vga.puts, vga.putn
%include "vga.mac"

section .rodata
main.~hello db 'orld!', 0
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
  mov esi, main.~hello
  call vga.putn
  ret
