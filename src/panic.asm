global _panic
extern boot.$stack, fmt.bin, fmt.dec, fmt.hex, vga.attr, vga.print
%include "vga.mac"

struc Pushad, -0x1C
  .eax: resd 1
  .ecx: resd 1
  .edx: resd 1
  .ebx: resd 1
  .esp: resd 1
  .ebp: resd 1
  .esi: resd 1
  .edi: resd 1
endstruc

; Including macro.mac would conflict.
%macro string 1
  [section .rodata]
  %%str: db %1, 0
  __SECT__
  mov esi, %%str
%endmacro

%macro _reg 2
  string %1
  call vga.print
  mov eax, [esp - Pushad.%2]
  call fmt.hex
  call vga.print
%endmacro

section .text
_panic: ; eax(eip) ecx(line) edx(file) esi(msg) : :
  push ecx
  push edx
  push eax
  push esi
  mov word [vga.attr], vga.RED << vga.FG
  string `\n== PANIC ==\n`
  call vga.print
  pop esi
  call vga.print
  pop eax
  call fmt.hex
  call vga.print
  string ':'
  call vga.print
  pop esi
  call vga.print
  pop eax
  call fmt.dec
  call vga.print

  string `\neflags `
  call vga.print
  mov eax, [esp]
  call fmt.bin
  call vga.print
  add esp, 4

  _reg `\neax `, eax
  _reg ' ecx ', ecx
  _reg ' edx ', edx
  _reg ' ebx ', ebx
  _reg `\nesp `, esp
  _reg ' ebp ', ebp
  _reg ' esi ', esi
  _reg ' edi ', edi
  add esp, 0x20

  string `\n`
  call vga.print
  and esp, -4
  .while:
    mov eax, esp
    call fmt.hex
    call vga.print
    string ' '
    call vga.print
    mov eax, [esp]
    call fmt.hex
    call vga.print
    string `\n`
    call vga.print
    add esp, 4
  cmp esp, boot.$stack
  jb .while

  .halt:
  hlt
  jmp .halt
