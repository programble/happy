global main.main
extern vga.cursorShape, kbd.readLine, str.shittyHash, fmt.hex
%include "text.mac"

section .text
main.main:
  xor al, al
  call vga.cursorShape
  .loop:
    call kbd.readLine
    call str.shittyHash
    mov eax, edx
    call fmt.hex
    text.write
    text.writeChar `\n`
  jmp .loop
  ret
