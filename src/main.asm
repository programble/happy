global main
extern vga.attr, vga.blank, vga.cursor, vga.printc, vga.prints
extern fmt.bin, fmt.hex
%include "vga.mac"

section .rodata
main.~hello: db `Hello, world!\na\tb\naa\tbb\nfoo\rbar\bz\n`, 0

section .text
main:
  mov word [vga.attr], vga.GRY << vga.FG | vga.BLU << vga.BG
  call vga.blank
  xor al, al
  call vga.cursor
  mov esi, main.~hello
  call vga.prints
  ret
