global vga.~buf, vga.$buf, vga.#buf
global vga.blank, vga.scroll, vga.puts, vga.putz
%include "vga.mac"

absolute vga.BUF
vga.~buf: resb vga.COLS * vga.ROWS
vga.$buf:
vga.#buf equ $ - vga.~buf

section .text
vga.blank: ; ax : : ecx edi
  mov edi, vga.~buf
  mov ecx, vga.#buf
  rep stosw
  ret

vga.scroll: ; : : al ecx esi edi
  mov edi, vga.~buf
  mov esi, vga.~buf + vga.COLS
  mov ecx, (vga.ROWS - 1) * vga.COLS / 4
  rep movsd
  xor al, al
  mov ecx, vga.COLS / 2
  .rep:
    stosb
    inc edi
  loop .rep
  ret

vga.puts: ; ecx(len) esi(str) edi(buf) : edi(buf) : ecx esi
  movsb
  inc edi
  loop vga.puts
  ret

vga.putz: ; esi(str) edi(buf) : edi(buf) : esi
  lodsb
  test al, al
  jz .ret
  stosb
  inc edi
  jmp vga.putz
  .ret: ret
