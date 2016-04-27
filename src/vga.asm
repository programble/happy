global vga.clear

%include "vga.mac"

%define vga.BUF 0xB8000

vga.clear:
  movzx eax, ax
  mov edx, eax
  shl eax, 16
  or eax, edx
  mov edi, vga.BUF
  mov ecx, vga.COLS * vga.ROWS / 2
  rep stosd
  ret
