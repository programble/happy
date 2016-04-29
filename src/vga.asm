global vga.~buf, vga.$buf, vga.#buf, vga.@buf, vga.attr
global vga.blank, vga.scroll, vga.print
%include "vga.mac"

absolute vga.BUF
vga.~buf: resb vga.COLS * vga.ROWS
vga.$buf:
vga.#buf equ $ - vga.~buf

section .data
vga.@buf: dd vga.~buf
vga.attr: dw 0

section .text
vga.blank: ; : : eax ecx edi
  mov ax, [vga.attr]
  shl eax, 0x10
  mov ax, [vga.attr]
  mov edi, vga.~buf
  mov [vga.@buf], edi
  mov ecx, vga.#buf / 4
  rep stosd
  ret

vga.scroll: ; : : eax ecx esi edi
  mov edi, vga.~buf
  mov esi, vga.~buf + vga.COLS
  mov ecx, (vga.ROWS - 1) * vga.COLS / 4
  rep movsd
  mov ax, [vga.attr]
  shl eax, 0x10
  mov ax, [vga.attr]
  mov ecx, vga.COLS / 4
  rep stosd
  sub dword [vga.@buf], vga.COLS
  ret

vga.print: ; esi(str) : : ax esi edi
  mov edi, [vga.@buf]
  mov ax, [vga.attr]
  .while:
    lodsb
    test al, al
    jz .break
    stosw
  jmp .while
  .break:
  mov [vga.@buf], edi
  ret
