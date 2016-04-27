global main
extern vga.char, vga.offs, vga.clear, vga.putc

%include "vga.mac"

main:
  mov byte [vga.char], 'A'
  call vga.clear
  vga.pos 1, 3
  mov al, 'B'
  call vga.putc
  ret
