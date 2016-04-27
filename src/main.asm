global main
extern vga.clear, vga.test

%include "vga.mac"

main:
  call vga.clear
  call vga.test
  ret
