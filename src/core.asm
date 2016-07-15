;;; The beginning and end of the kernel.

global core.boot, core.halt, core.panic
global core.stack, core.stack.$

extern mboot.init, com.init, vga.init, gdt.init, idt.init, pic.init, kbd.init
extern main.main, text.writeNl, text.write, text.writeFmt
extern diag.printEflags, diag.printRegs, diag.printStack
extern kbd.poll, kbd.reset
extern vga.attribute

%define _CORE_ASM
%include "core.mac"
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
  _string `\n== PANIC ==\n`
  call text.write

  _rpop ecx, esi ; message
  call text.write

  _rpop ecx, esi ; file
  call text.write

  _string '%dd0' ; line
  call text.writeFmt
  add esp, 4

  _string `\neflags `
  call text.write
  mov eax, [esp + 4]
  call diag.printEflags
  call text.writeNl

  lea ebx, [esp + 8]
  call diag.printRegs
  call text.writeNl

  pop eax
  add esp, 24h
  push eax
  call diag.printStack

  call kbd.poll
  call kbd.poll
jmp kbd.reset
