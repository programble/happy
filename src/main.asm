global main
extern tty.reset, tty.print, mboot.print
%include "vga.mac"

section .rodata
main.~hello: db `Hello, world!\na\tb\naa\tbb\nfoo\rbar\bz\n`
main.#hello equ $ - main.~hello

section .text
main:
  call tty.reset
  mov ecx, main.#hello
  mov esi, main.~hello
  call tty.print
  call mboot.print
  ret
