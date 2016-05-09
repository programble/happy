global main.main
extern vga.cursorShape, kbd.readLine
%include "text.mac"

section .text
main.main:
  xor al, al
  call vga.cursorShape
  .loop:
    call kbd.readLine
    text.write
    text.writeChar `\n`
  jmp .loop
  ret
