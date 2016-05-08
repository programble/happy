global main.main
extern vga.cursorShape, kbd.readCode, qwerty.map
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
    test al, al
    js .loop
    add eax, qwerty.map
    mov al, [eax]
    test al, al
    js .loop
    text.writeChar
  jmp .loop
  ret
