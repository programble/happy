global vga.reg, vga.char, vga.attr, vga.offs
global vga.push, vga.pop, vga.clear, vga.putc, vga.test

%include "vga.mac"
%define vga.BUF 0xB8000

section .bss
vga.stack~ resb 0x100
vga.stack$:

section .data
vga.stack@ dd vga.stack$
vga.reg:
  vga.char db 0
  vga.attr db vga.GRY
  vga.offs dw 0

section .text
vga.push:
  mov ebp, esp
  mov esp, [vga.stack@]
  push dword [vga.reg]
  mov [vga.stack@], esp
  mov esp, ebp
  ret

vga.pop:
  mov ebp, esp
  mov esp, [vga.stack@]
  pop dword [vga.reg]
  mov [vga.stack@], esp
  mov esp, ebp
  ret

vga.clear:
  movzx eax, word [vga.char]
  mov edx, eax
  shl eax, 16
  or eax, edx
  mov edi, vga.BUF
  mov ecx, vga.COLS * vga.ROWS / 2
  rep stosd
  ret

vga.putc:
  mov ah, [vga.attr]
  mov ebx, [vga.offs]
  mov [vga.BUF + ebx], ax
  ret

vga.test:
  mov ax, 0xB0
  mov edi, vga.BUF
  mov ecx, 0x100
  .rep1:
    stosw
    inc ah
  loop .rep1
  mov ax, vga.GRY << vga.FG
  mov ecx, 0x100
  .rep2:
    stosw
    inc ax
  loop .rep2
  ret
