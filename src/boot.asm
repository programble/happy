global boot, halt, _panic
extern mboot.boot, gdt.init, idt.init, main
extern vga.attr, vga.print, fmt.dec
%include "vga.mac"

MAGIC equ 0x1BADB002
FLAGS equ 0x0
CHECKSUM equ -(MAGIC + FLAGS)

section .mboot
dd MAGIC
dd FLAGS
dd CHECKSUM

section .bss
boot.~stack: resb 0x1000
boot.$stack:

section .rodata
boot.?panic: db `\n== PANIC ==\n`, 0

section .text
boot:
  mov esp, boot.$stack
  call mboot.boot
  call gdt.init
  call idt.init
  push halt
  jmp main

halt:
  hlt
  jmp halt

_panic: ; eax(msg) ecx(line) edx(file) : :
  push ecx
  push edx
  push eax
  mov word [vga.attr], vga.GRY << vga.FG | vga.RED << vga.BG
  mov esi, boot.?panic
  call vga.print
  pop esi
  call vga.print
  pop esi
  call vga.print
  pop eax
  call fmt.dec
  call vga.print
  jmp halt
