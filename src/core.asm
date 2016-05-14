global core.boot, core.halt, core.panic
global core.stack, core.stack.$
extern mboot.init, com.init, vga.init, gdt.init, idt.init, pic.init, kbd.init
extern main.main, fmt.dec, diag.printEflags, diag.printRegs, diag.printStack
extern vga.attribute
%define _CORE_ASM
%include "macro.mac"
%include "core.mac"
%include "write.mac"
%include "vga.mac"

Flags:
  .PAGE_ALIGN_MODS: equ 0000_0001b
  .MEM: equ 0000_0010b
  .VBE: equ 0000_0100b

HEADER:
  .MAGIC: equ 1BADB002h
  .FLAGS: equ 0
  .CHECKSUM: equ -(.MAGIC + .FLAGS)

section .mboot
dd HEADER.MAGIC
dd HEADER.FLAGS
dd HEADER.CHECKSUM

section .bss
core.stack: resb 1000h
.$:

section .text
core.boot: ; eax(magic) ebx(info) : : *
  mov esp, core.stack.$
  push dword 0DEADBEEFh
  call mboot.init
  call com.init
  call vga.init
  call gdt.init
  call idt.init
  call pic.init
  call kbd.init
  sti
  call main.main
_panic 'return from main'

core.halt: ; : : *
  cli
  hlt
jmp core.halt

core.panic: ; eax(line) ecx(msgLen) edx(fileLen) esi(msg) edi(file) [esp+8](pushad) [esp+4](pushfd) : : *
  _push eax, edx, edi, ecx, esi

  mov byte [vga.attribute], vga.Color.RED << vga.Color.FG
  _write `\n== PANIC ==\n`

  _pop ecx, esi
  _write

  _pop ecx, esi
  _write

  pop eax
  call fmt.dec
  _write

  _write `\neflags `
  mov eax, [esp + 4]
  call diag.printEflags
  _writeChar `\n`

  lea ebx, [esp + 8]
  call diag.printRegs
  _writeChar `\n`

  pop eax
  add esp, 24h
  push eax
  call diag.printStack
jmp core.halt
