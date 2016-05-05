global main.main
extern vga.attribute, vga.blank, vga.cursorShape, mboot.printInfo
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "text.mac"

section .text
main.main:
  xor al, al
  call vga.cursorShape
  text.write `Hello, world!\n`
  call mboot.printInfo
  ret
