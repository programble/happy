global main.main
extern vga.attribute, kbd.readLine, str.shittyHash, fmt.hex
extern vga.blank, core.halt, kbd.reset, diag.printEflags, diag.printRegs, diag.printStack
extern mboot.printInfo, kbd.printBuffers
%include "macro.mac"
%include "core.mac"
%include "vga.mac"
%include "text.mac"

section .text
main.main:
  %macro _cmd 2
    cmp edx, %1
    jne %%cmdElse
    call %2
    jmp .next
    %%cmdElse:
  %endmacro

  .prompt:
    text.writeChar '>'
    mov word [vga.attribute], (vga.Color.GRAY | vga.Color.BRIGHT) << vga.Color.FG
    text.writeChar ' '
    call kbd.readLine
    mov word [vga.attribute], vga.Color.GRAY << vga.Color.FG

    call str.shittyHash

    _cmd 68656C70h, main.help
    _cmd 6C656111h, main.clear

    _cmd 68616C74h, core.halt
    _cmd 616E6913h, main.panic
    _cmd 65736506h, kbd.reset

    _cmd 6C610215h, main.eflags
    _cmd 72656773h, main.regs
    _cmd 74616318h, main.stack

    _cmd 626F6F19h, mboot.printInfo ; mboot
    _cmd 006B6264h, kbd.printBuffers ; kbd

    .unknown:
    push edx
    text.write 'unknown command '
    pop eax
    call fmt.hex
    text.write

    .next:
    text.writeChar `\n`
  jmp .prompt

main.help:
  text.write 'help clear halt panic reset eflags regs stack mboot kbd'
  ret

main.clear:
  call vga.blank
  add esp, 4
  jmp main.main.prompt

main.panic:
  panic 'panic command'

main.eflags:
  pushfd
  call diag.printEflags
  add esp, 4
  ret

main.regs:
  pushad
  call diag.printRegs
  add esp, 20h
  ret

main.stack:
  call diag.printStack
  ret
