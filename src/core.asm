global core.boot, core.halt, core.panic
global core.stack, core.stack.$
extern mboot.init, gdt.init, idt.init, main.main
extern fmt.dec, fmt.hex, vga.attribute, vga.writeChar, vga.write
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
  call mboot.init
  call gdt.init
  call idt.init
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

  mov word [vga.attribute], vga.Color.RED << vga.Color.FG
  string `\n== PANIC ==\n`
  call vga.write

  pop esi
  call vga.write

  pop eax
  call fmt.hex
  call vga.write

  pop esi
  call vga.write

  pop eax
  call fmt.dec
  call vga.write

  string `\neflags `
  call vga.write
  call diag.printEflags
  add esp, 4
  mov al, `\n`
  call vga.writeChar

  call diag.printRegs
  add esp, 20h
  mov al, `\n`
  call vga.writeChar

  call diag.printStack

  jmp core.halt
