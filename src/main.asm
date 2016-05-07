global main.main
extern vga.attribute, vga.blank, vga.cursorShape
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "text.mac"

section .text
main.main:
  cli
  xor al, al
  call vga.cursorShape
  text.write `Hello, world!\n`
  extern diag.printMem
  mov esi, 00103000h
  mov ecx, 60h
  call diag.printMem
  ret
