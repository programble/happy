global main.main, main.clear, main.panic, main.eflags, main.regs, main.stack
extern vga.attribute, kbd.readLine
extern elf.stringSymbol
extern vga.blank, diag.printEflags, diag.printRegs, diag.printStack
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "fmt.mac"
%include "write.mac"

section .text
main.main: ; : : *
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

main.clear: ; : : *
  call vga.blank
  add esp, 4
jmp main.main.prompt

main.panic: ; : : *
_panic 'panic command'

main.eflags: ; : : *
  pushfd
  pop eax
jmp diag.printEflags

main.regs: ; : : *
  pushad
  mov ebx, esp
  call diag.printRegs
  add esp, 20h
ret

main.stack: ; : : *
  call diag.printStack
ret
