global main.main
extern vga.attr, vga.blank, vga.cursor, vga.print
extern mboot.printInfo
%include "macro.mac"
%include "core.mac"
%include "vga.mac"

section .text
main.main:
  mov word [vga.attr], vga.GRY << vga.FG
  call vga.blank
  xor al, al
  call vga.cursor
  string `Hello, world!\n`
  call vga.print
  call mboot.printInfo
  panic 'ayyyyy lmao'
  ret
