global main
extern vga.attr, vga.blank, vga.printc, vga.prints
%include "vga.mac"

section .rodata
main.~hello: db 'ello, world', 0

section .text
main:
  mov word [vga.attr], vga.GRY << vga.FG | vga.BLU << vga.BG
  call vga.blank
  mov al, 'H'
  call vga.printc
  mov esi, main.~hello
  call vga.prints
  mov al, '!'
  call vga.printc
  ret
