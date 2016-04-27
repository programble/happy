global vga.clear, vga.test

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
