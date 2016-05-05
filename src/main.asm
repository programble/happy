global main.main
extern vga.attribute, vga.blank, vga.cursorShape
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "text.mac"

section .text
main.main:
  mov word [vga.attribute], vga.Color.GRAY << vga.Color.FG
  call vga.blank
  xor al, al
  call vga.cursorShape
  string `Hello, world!\n`
  text.write
  panic 'this was a triumph'
  ret
