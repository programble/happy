global main
extern fmt.hex
extern vga.~buf, vga.blank, vga.puts, vga.curs
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
  mov eax, 0x1A2B3C4D
  call fmt.hex
  mov ah, vga.GRN
  call vga.puts
  mov ah, 0x0D
  call vga.curs
  ret
