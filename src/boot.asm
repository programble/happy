global boot.~stack, boot.$stack, boot
extern mboot.boot, gdt.init, idt.init, abort.init, fault.init, main
%include "macro.mac"
%include "vga.mac"

Flags.PAGE_ALIGN_MODS equ 1
Flags.MEM equ 2
Flags.VBE equ 4

MAGIC equ 0x1BADB002
FLAGS equ 0
CHECKSUM equ -(MAGIC + FLAGS)

section .mboot
dd MAGIC
dd FLAGS
dd CHECKSUM

section .bss
boot.~stack: resb 0x1000
boot.$stack:

section .text
boot:
  mov esp, boot.$stack
  push dword 0xDEADBEEF
  call mboot.boot
  call gdt.init
  call idt.init
  call abort.init
  call fault.init
  sti
  call main
  panic 'return from main'
