global vga.clear, vga.test

%include "vga.mac"
%define vga.BUF 0xB8000

section .bss
vga.~stack: resb 0x100
vga.$stack:

section .data
vga.@stack: dd vga.$stack
vga.state:
  vga.char: db ' '
  vga.attr: db vga.GRY
  vga.offs: dw 0

section .text
; : : eax
vga.push:
  mov eax, esp
  mov esp, [vga.@stack]
  push dword [vga.state]
  mov [vga.@stack], esp
  mov esp, eax
  ret

; : : eax
vga.pop:
  mov eax, esp
  mov esp, [vga.@stack]
  pop dword [vga.state]
  mov [vga.@stack], esp
  mov esp, eax
  ret

; : : ax ecx edi
vga.clear:
  mov ax, [vga.char]
  mov edi, vga.BUF
  mov ecx, vga.COLS * vga.ROWS
  rep stosd
  ret

; : : ax ecx edi
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
