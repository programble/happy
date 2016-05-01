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

section .rodata
panic.?panic: db `\n== PANIC ==\n`, 0
panic.?file: db ':', 0
panic.?eflags: db `\neflags `, 0
panic.?eax: db `\neax `, 0
panic.?ecx: db ' ecx ', 0
panic.?edx: db ' edx ', 0
panic.?ebx: db ' ebx ', 0
panic.?esp: db `\nesp `, 0
panic.?ebp: db ' ebp ', 0
panic.?esi: db ' esi ', 0
panic.?edi: db ' edi ', 0
panic.?space: db ' ', 0
panic.?newline: db `\n`, 0

%macro _reg 1
  mov esi, panic.?%1
  call vga.print
  mov eax, [esp - Pushad.%1]
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
  mov esi, panic.?panic
  call vga.print
  pop esi
  call vga.print
  pop eax
  call fmt.hex
  call vga.print
  mov esi, panic.?file
  call vga.print
  pop esi
  call vga.print
  pop eax
  call fmt.dec
  call vga.print

  mov esi, panic.?eflags
  call vga.print
  mov eax, [esp]
  call fmt.bin
  call vga.print
  add esp, 4

  _reg eax
  _reg ecx
  _reg edx
  _reg ebx
  _reg esp
  _reg ebp
  _reg esi
  _reg edi
  add esp, 0x20

  mov esi, panic.?newline
  call vga.print
  and esp, -4
  .while:
    mov eax, esp
    call fmt.hex
    call vga.print
    mov esi, panic.?space
    call vga.print
    mov eax, [esp]
    call fmt.hex
    call vga.print
    mov esi, panic.?newline
    call vga.print
    add esp, 4
  cmp esp, boot.$stack
  jb .while

  .halt:
  hlt
  jmp .halt
