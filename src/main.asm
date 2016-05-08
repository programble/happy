global main.main
extern vga.cursorShape, kbd.readCode, fmt.hex
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
    xor eax, eax
    call kbd.readCode
    call fmt.hex
    add esi, 6
    text.write
    text.writeChar ' '
  jmp .loop
  ret
