global main
extern vga.attr, vga.blank
%include "vga.mac"

section .text
main:
  mov word [vga.attr], vga.BLU << vga.BG
  call vga.blank
  ret
