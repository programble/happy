global main
extern gdt.init
extern vga.attr, vga.blank, vga.cursor
extern mboot.print
%include "vga.mac"

section .text
main:
  call gdt.init
  mov word [vga.attr], vga.GRY << vga.FG | vga.BLU << vga.BG
  call vga.blank
  xor al, al
  call vga.cursor
  call mboot.print
  ret
