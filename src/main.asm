global main.main
extern vga.attribute, vga.blank, vga.cursorShape, vga.print
extern mboot.printInfo
%include "macro.mac"
%include "core.mac"
%include "vga.mac"

section .text
main.main:
  mov word [vga.attribute], vga.Color.GRAY << vga.Color.FG
  call vga.blank
  xor al, al
  call vga.cursorShape
  string `Hello, world!\n`
  call vga.print
  call mboot.printInfo
  panic 'ayyyyy lmao'
  ret
