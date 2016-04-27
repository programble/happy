global main
extern vga.clear, vga.test

main:
  xor ax, ax
  call vga.clear
  call vga.test
  ret
