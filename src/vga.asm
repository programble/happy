global vga.~buf, vga.$buf, vga.#buf
global vga.blank, vga.puts, vga.putz
%include "vga.mac"

absolute vga.BUF
vga.~buf: resb vga.COLS * vga.ROWS * 2
vga.$buf:
vga.#buf equ $ - vga.~buf

section .text
vga.blank: ; ax : : ecx edi
  mov edi, vga.~buf
  mov ecx, vga.#buf
  rep stosw
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
