global core.boot, core.halt, core.panic
global core.stack, core.stack.$
extern mboot.init, com.init, vga.init, gdt.init, idt.init, main.main
extern fmt.dec, fmt.hex, vga.attribute
extern diag.printEflags, diag.printRegs, diag.printStack
%include "macro.mac"
%include "vga.mac"
%include "text.mac"

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
  call com.init
  call vga.init
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
  text.write `\n== PANIC ==\n`

  pop esi
  text.write

  pop eax
  call fmt.hex
  text.write

  pop esi
  text.write

  pop eax
  call fmt.dec
  text.write

  text.write `\neflags `
  call diag.printEflags
  add esp, 4
  text.writeChar `\n`

  call diag.printRegs
  add esp, 20h
  text.writeChar `\n`

  call diag.printStack

  jmp core.halt
