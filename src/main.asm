global main.main
extern vga.cursorShape, kbd.readLine, str.shittyHash, fmt.hex
extern core.halt, vga.blank, diag.printEflags, diag.printRegs, diag.printStack, mboot.printInfo
%include "macro.mac"
%include "core.mac"
%include "text.mac"

section .text
main.main:
  xor al, al
  call vga.cursorShape

  %macro _cmd 2
    cmp edx, %1
    jne %%cmdElse
    call %2
    jmp .next
    %%cmdElse:
  %endmacro

  .loop:
    call kbd.readLine
    call str.shittyHash

    _cmd 68656C70h, main.help
    _cmd 6C656111h, vga.blank ; clear
    _cmd 68616C74h, core.halt
    _cmd 616E6913h, main.panic
    _cmd 6C610215h, main.eflags
    _cmd 72656773h, main.regs
    _cmd 74616318h, diag.printStack ; stack
    _cmd 626F6F19h, mboot.printInfo ; mboot

    mov eax, edx
    call fmt.hex
    text.write

    .next:
    text.writeChar `\n`
  jmp .loop
  ret

main.help:
  string 'help clear halt panic eflags regs stack mboot'
  text.write
  ret

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
