global core.boot, core.halt, core.panic
global core.stack, core.stack.$
extern mboot.boot, gdt.init, idt.init, abort.init, fault.init, trap.init, main.main
extern fmt.dec, fmt.hex, vga.attr, vga.print
extern diag.printEflags, diag.printRegs, diag.printStack
%include "macro.mac"
%include "vga.mac"

Flags:
  .PAGE_ALIGN_MODS: equ 1
  .MEM: equ 2
  .VBE: equ 4

HEADER:
  .MAGIC: equ 1BADB002h
  .FLAGS: equ 0
  .CHECKSUM: equ -(.MAGIC + .FLAGS)

section .mboot
dd HEADER.MAGIC
dd HEADER.FLAGS
dd HEADER.CHECKSUM

section .bss
core.stack:
  resb 1000h
.$:

section .text
core.boot:
  mov esp, core.stack.$
  push dword 0DEADBEEFh
  call mboot.boot
  call gdt.init
  call idt.init
  call abort.init
  call fault.init
  call trap.init
  sti
  call main.main

core.halt:
  cli
  hlt
  jmp core.halt

core.panic: ; eax(eip) ecx(line) edx(file) esi(msg) [esp+4](pushfd) [esp+8](pushad) : :
  push ecx
  push edx
  push eax
  push esi

  mov word [vga.attr], vga.RED << vga.FG
  string `\n== PANIC ==\n`
  call vga.print

  pop esi
  call vga.print

  pop eax
  call fmt.hex
  call vga.print

  pop esi
  call vga.print

  pop eax
  call fmt.dec
  call vga.print

  string `\neflags `
  call vga.print
  call diag.printEflags
  add esp, 4
  string `\n`
  call vga.print

  call diag.printRegs
  add esp, 20h
  string `\n`
  call vga.print

  call diag.printStack

  jmp core.halt