global main
extern vga.~buf, vga.blank
%include "vga.mac"

section .text
main:
  mov ax, vga.GRY << vga.FG
  call vga.blank
  ret
