global main
extern vga.attr, vga.blank, vga.cursor, vga.print
%include "vga.mac"

section .text
main:
  mov word [vga.attr], vga.GRY << vga.FG
  call vga.blank
  xor al, al
  call vga.cursor
  string `Hello, world!\n`
  call vga.print
  int 3
  ret
