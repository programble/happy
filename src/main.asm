global main
extern vga.attr, vga.blank, vga.cursor
extern mboot.print
%include "macro.mac"
%include "vga.mac"

section .text
main:
  mov word [vga.attr], vga.GRY << vga.FG | vga.BLU << vga.BG
  call vga.blank
  xor al, al
  call vga.cursor
  call mboot.print
  panic 'Help me'
  ret
