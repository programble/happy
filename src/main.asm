global main
extern vga.attr, vga.blank, vga.print
%include "vga.mac"

section .rodata
main.~hello: db 'Hello, world!', 0

section .text
main:
  mov word [vga.attr], vga.GRY << vga.FG | vga.BLU << vga.BG
  call vga.blank
  mov esi, main.~hello
  call vga.print
  ret
