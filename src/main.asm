global main.main
extern vga.attribute, kbd.readLine, str.equal?
extern vga.blank, core.halt, kbd.reset
extern diag.printEflags, diag.printRegs, diag.printStack
extern mboot.printInfo, mboot.printMmap
extern fmt.printBuffers, kbd.printBuffers
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "fmt.mac"
%include "write.mac"

section .text
main.main: ; : : *
  _write `You'll never be %hd0 %hd1.\n`, 0DEADBEEFh, 0CAFEBABEh

  %macro _cmdStart 0
    [section .rodata]
    %%cmdString:
    %define _CMD_STRING %%cmdString
    __SECT__
  %endmacro

  %macro _cmd 2
    _string edx, edi, %1
    [section .rodata]
    db ' '
    __SECT__
    _push ecx, esi
    call str.equal?
    _pop ecx, esi
    jne %%cmdElse
    push .next
    jmp %2
    %%cmdElse:
  %endmacro

  %macro _cmdEnd 0
    [section .rodata]
    %%cmdString.#: equ $ - _CMD_STRING
    %define _CMD_STRING_LEN %%cmdString.#
    __SECT__
  %endmacro

  .prompt:
    _writeChar '>'
    mov byte [vga.attribute], vga.Color.GRAY | vga.Color.BRIGHT
    _writeChar ' '
    call kbd.readLine
    mov byte [vga.attribute], vga.Color.GRAY

    _cmdStart
      _cmd 'help', main.help
      _cmd 'clear', main.clear

      _cmd 'halt', core.halt
      _cmd 'panic', main.panic
      _cmd 'reset', kbd.reset

      _cmd 'eflags', main.eflags
      _cmd 'regs', main.regs
      _cmd 'stack', main.stack

      _cmd 'mboot', mboot.printInfo
      _cmd 'mmap', mboot.printMmap

      _cmd 'fmt', fmt.printBuffers
      _cmd 'kbd', kbd.printBuffers
    _cmdEnd

    _writeChar '?'

    .next:
    _writeChar `\n`
  jmp .prompt

main.help: ; : : *
  mov ecx, _CMD_STRING_LEN
  mov esi, _CMD_STRING
  _write
ret

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
