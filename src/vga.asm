global vga.~buf, vga.$buf, vga.#buf
global vga.blank, vga.puts
%include "vga.mac"

vga.~buf equ 0xB8000
vga.#buf equ vga.COLS * vga.ROWS * 2
vga.$buf equ vga.~buf + vga.#buf

vga.blank: ; ax : : ecx edi
  mov edi, vga.~buf
  mov ecx, vga.#buf
  rep stosw
  ret

vga.puts: ; ah(attr) ecx(len) esi(str) edi(buf) : edi(buf) : al ecx esi
  lodsb
  stosw
  loop vga.puts
  ret
