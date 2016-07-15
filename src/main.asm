;;; The main loop and debugging functions.

global main.main, main.clear, main.panic, main.eflags, main.regs

extern text.writeNl, text.write, text.writeLn, text.writeFmt
extern vga.attribute, kbd.readLine
extern elf.stringSymbol
extern vga.blank, diag.printEflags, diag.printRegs, diag.printStack

%include "core.mac"
%include "dev/vga.mac"

section .text

;;; The main loop, which calls functions by looking up symbols in the ELF
;;; table.
;;; : : *
main.main:
  _string `You'll never be %hd0 %hd1.\n`
  _rpush 0DEADBEEFh, 0CAFEBABEh
  call text.writeFmt
  add esp, 8

  .prompt:
    _string '> '
    call text.write
    mov byte [vga.attribute], vga.Color.GRAY | vga.Color.BRIGHT

    call kbd.readLine
    mov byte [vga.attribute], vga.Color.GRAY

    call elf.stringSymbol
    test eax, eax
    jnz .call
    _string '?'
    call text.writeLn
    jmp .prompt

    .call:
    call eax
    call text.writeNl
  jmp .prompt

;;; Clear the screen and skip the newline of the main loop.
;;; : : *
main.clear:
  call vga.blank
  add esp, 4
jmp main.main.prompt

;;; Panic for testing.
;;; : : *
main.panic:
_panic 'panic command'

;;; Print eflags.
;;; : : *
main.eflags:
  pushfd
  pop eax
jmp diag.printEflags

;;; Print registers.
;;; : : *
main.regs:
  pushad
  mov ebx, esp
  call diag.printRegs
  add esp, 20h
ret
