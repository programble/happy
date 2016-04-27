global main
extern vga.~buf, vga._blank, vga._putq, vga._puts
%include "vga.mac"

section .rodata
main.~hello db 'orld!'
main.#hello equ $ - main.~hello

section .text
main:
  vga.blank vga.GRY << vga.FG
  vga.putq vga.~buf, 'Hell', 'o, w'
  vga.puts edi, main.#hello, main.~hello
  ret
