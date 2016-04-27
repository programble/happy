global vga.~buf, vga.$buf, vga.#buf
global vga.clear, vga.test

%include "vga.mac"
vga.~buf equ 0xB8000
vga.#buf equ vga.COLS * vga.ROWS * 2
vga.$buf equ vga.~buf + vga.#buf

vga.clear: ; ax : : ecx edi
  mov edi, vga.~buf
  mov ecx, vga.#buf
  rep stosw
  ret

vga.test: ; : : ax ecx edi
  mov ax, 0xB0
  mov edi, vga.~buf
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
