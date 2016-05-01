global main
extern vga.attr, vga.blank, vga.cursor, vga.print
extern mboot.print, elf.sym, fmt.dec
%include "macro.mac"
%include "vga.mac"

section .text
main:
  mov word [vga.attr], vga.GRY << vga.FG | vga.BLU << vga.BG
  call vga.blank
  xor al, al
  call vga.cursor
  string `Hello, world!\n`
  call vga.print
  mov eax, $
  call elf.sym
  push ecx
  call vga.print
  string '+'
  call vga.print
  pop eax
  call fmt.dec
  call vga.print
  ret
