global _panic
extern fmt.dec, fmt.hex, vga.attr, vga.print
extern diag.printEflags, diag.printRegs, diag.printStack
%include "vga.mac"

; Including macro.mac would conflict.
%macro string 1
  [section .rodata]
  %%str: db %1, 0
  __SECT__
  mov esi, %%str
%endmacro

section .text
_panic: ; eax(eip) ecx(line) edx(file) esi(msg) : :
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

  .halt:
  hlt
  jmp .halt
