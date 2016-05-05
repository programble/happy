global main.main
extern vga.attribute, vga.blank, vga.cursorShape, vga.write
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
  call vga.write
  call mboot.printInfo
  int 3
  ret
