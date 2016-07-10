;;; The beginning and end of the kernel.

global core.boot, core.halt, core.panic
global core.stack, core.stack.$

extern mboot.init, com.init, vga.init, gdt.init, idt.init, pic.init, kbd.init
extern main.main, fmt.dec, diag.printEflags, diag.printRegs, diag.printStack
extern kbd.poll, kbd.reset
extern vga.attribute

%define _CORE_ASM
%include "core.mac"
%include "write.mac"
%include "dev/vga.mac"

section .bss

;;; The stack.
core.stack: resb 1000h
  .$:

section .text

;;; Kernel entry point.
;;; eax(mbootMagic) ebx(mbootInfo) : : *
core.boot:
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

  .main:
  call main.main
_panic 'return from main'

;;; Halt forever.
;;; : : *
core.halt:
  cli
  hlt
jmp core.halt

;;; Display debug information from _panic macro and reset on keypress.
;;; eax(line) ecx(msgLen) edx(fileLen) esi(msg) edi(file) [esp+8](pushad) [esp+4](pushfd) : : *
core.panic:
  _push eax, edx, edi, ecx, esi

  mov byte [vga.attribute], vga.Color.RED << vga.Color.FG
  _write `\n== PANIC ==\n`

  _pop ecx, esi ; message
  _write

  _pop ecx, esi ; file
  _write

  pop eax ; line
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

  call kbd.poll
  call kbd.poll
jmp kbd.reset
