global main.main
extern vga.cursorShape, kbd.readChar
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "text.mac"

section .text
main.main:
  xor al, al
  call vga.cursorShape
  text.write `Hello, world!\n`
  .loop:
    call kbd.readChar
    text.writeChar
  jmp .loop
  ret
