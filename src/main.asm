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
  call main.foo
  ret

main.foo:
  call main.bar
  ret
main.bar:
  call main.baz
  ret
main.baz:
  panic 'stack symbol lookup test'
