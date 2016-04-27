global main
extern vga.~buf, vga.blank, vga.puts, vga.curs
extern mboot.print
%include "vga.mac"

section .rodata
main.~hello db 'Hello, world!'
main.#hello equ $ - main.~hello

section .text
main:
  xor ax, ax
  mov ah, vga.RED
  call vga.blank
  mov ah, vga.RED
  mov ecx, main.#hello
  mov esi, main.~hello
  mov edi, vga.~buf
  call vga.puts
  call mboot.print
  mov ah, 0x0D
  call vga.curs
  ret
