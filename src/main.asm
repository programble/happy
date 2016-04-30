global main
extern vga.attr, vga.blank, vga.cursor, vga.print
extern fmt.bin, fmt.hex
%include "vga.mac"

section .rodata
main.~hello: db 'Hello, world! ', 0

section .text
main:
  mov word [vga.attr], vga.GRY << vga.FG | vga.BLU << vga.BG
  call vga.blank
  xor al, al
  call vga.cursor
  .loop:
    mov esi, main.~hello
    call vga.print
  jmp .loop
  ret
