global main.main
extern fmt.dec
extern vga.attribute, vga.blank, vga.cursorShape
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "text.mac"

section .text
main.main:
  xor al, al
  call vga.cursorShape
  text.write `Hello, world!\n`
  mov eax, 90
  call fmt.dec
  text.write
  ret
