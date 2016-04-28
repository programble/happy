global main
extern tty.reset, tty.print
%include "vga.mac"

section .rodata
main.~hello: db `Hello, world!\na\tb\naa\tbb\nfoo\rbar\bz`
main.#hello equ $ - main.~hello

section .text
main:
  call tty.reset
  .rep:
  mov ecx, main.#hello
  mov esi, main.~hello
  call tty.print
  jmp .rep
  ret
