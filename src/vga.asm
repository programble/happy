global vga.~buf, vga.$buf, vga.#buf
global vga._blank, vga._putq, vga._puts
%include "vga.mac"

vga.~buf equ 0xB8000
vga.#buf equ vga.COLS * vga.ROWS * 2
vga.$buf equ vga.~buf + vga.#buf

vga._blank: ; ax : : ecx edi
  mov edi, vga.~buf
  mov ecx, vga.#buf
  rep stosw
  ret

vga._putq: ; eax(str) edx(str) edi(buf) : edi(buf) : eax
  %rep 4
  stosb
  inc edi
  shr eax, 8
  %endrep
  mov eax, edx
  %rep 4
  stosb
  inc edi
  shr eax, 8
  %endrep
  ret

vga._puts: ; ecx(len) esi(str) edi(buf) : edi(buf) : ecx esi
  movsb
  inc edi
  loop vga._puts
  ret
