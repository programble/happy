global main.main
extern vga.attribute, kbd.readLine, str.equal?
extern vga.blank, core.halt, kbd.reset
extern diag.printEflags, diag.printRegs, diag.printStack
extern mboot.printInfo, mboot.printMmap
extern kbd.printBuffers
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "write.mac"

section .rodata
main.cmd:
  %macro _cmdString 2
    .%1: db %2
    .%1.#: equ $ - .%1
    db ' '
  %endmacro

  _cmdString help, 'help'
  _cmdString clear, 'clear'

  _cmdString halt, 'halt'
  _cmdString panic, 'panic'
  _cmdString reset, 'reset'

  _cmdString eflags, 'eflags'
  _cmdString regs, 'regs'
  _cmdString stack, 'stack'

  _cmdString mboot, 'mboot'
  _cmdString mmap, 'mmap'

  _cmdString kbd, 'kbd'

  .#: equ $ - main.cmd

section .text
main.main: ; : : *
  _write `You'll never be happy.\n`

  %macro _cmd 2
    mov edx, main.cmd.%1.#
    mov edi, main.cmd.%1
    _push ecx, esi
    call str.equal?
    _pop ecx, esi
    jne %%cmdElse
    call %2
    jmp .next
    %%cmdElse:
  %endmacro

  .prompt:
    _writeChar '>'
    mov byte [vga.attribute], vga.Color.GRAY | vga.Color.BRIGHT
    _writeChar ' '
    call kbd.readLine
    mov byte [vga.attribute], vga.Color.GRAY

    _cmd help, main.help
    _cmd clear, main.clear

    _cmd halt, core.halt
    _cmd panic, main.panic
    _cmd reset, kbd.reset

    _cmd eflags, main.eflags
    _cmd regs, main.regs
    _cmd stack, main.stack

    _cmd mboot, mboot.printInfo
    _cmd mmap, mboot.printMmap

    _cmd kbd, kbd.printBuffers

    _writeChar '?'

    .next:
    _writeChar `\n`
  jmp .prompt

main.help:
  mov ecx, main.cmd.#
  mov esi, main.cmd
  _write
ret

main.clear:
  call vga.blank
  add esp, 4
jmp main.main.prompt

main.panic:
_panic 'panic command'

main.eflags:
  pushfd
  mov eax, [esp]
  add esp, 4
jmp diag.printEflags

main.regs:
  pushad
  mov ebx, esp
  call diag.printRegs
  add esp, 20h
ret

main.stack:
  call diag.printStack
ret
