;;; The main loop and debugging functions.

global main.main, main.clear, main.panic, main.eflags, main.regs

extern vga.attribute, kbd.readLine
extern elf.stringSymbol
extern vga.blank, diag.printEflags, diag.printRegs, diag.printStack

%include "core.mac"
%include "dev/vga.mac"
%include "lib/fmt.mac"
%include "write.mac"

section .text

;;; The main loop, which calls functions by looking up symbols in the ELF
;;; table.
;;; : : *
main.main:
  _write `You'll never be %hd0 %hd1.\n`, 0DEADBEEFh, 0CAFEBABEh

  .prompt:
    _writeChar '>'
    mov byte [vga.attribute], vga.Color.GRAY | vga.Color.BRIGHT
    _writeChar ' '
    call kbd.readLine
    mov byte [vga.attribute], vga.Color.GRAY

    call elf.stringSymbol
    test eax, eax
    jnz .call
    _write `?\n`
    jmp .prompt

    .call:
    call eax
    _writeChar `\n`
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
