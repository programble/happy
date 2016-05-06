global main.main
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
  extern diag.printMem
  mov esi, vga.BUFFER
  mov ecx, vga.WIDTH / 4
  call diag.printMem
  ret
