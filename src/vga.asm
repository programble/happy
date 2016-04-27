global vga.~buf, vga.$buf, vga.#buf
global vga.blank, vga.putq, vga.puts, vga.putn
%include "vga.mac"

vga.~buf equ 0xB8000
vga.#buf equ vga.COLS * vga.ROWS * 2
vga.$buf equ vga.~buf + vga.#buf

vga.blank: ; ax : : ecx edi
  mov edi, vga.~buf
  mov ecx, vga.#buf
  rep stosw
  ret

vga.putq: ; eax(str) edx(str) edi(buf) : edi(buf) : eax
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

vga.puts: ; ecx(len) esi(str) edi(buf) : edi(buf) : ecx esi
  movsb
  inc edi
  loop vga.puts
  ret

vga.putn: ; esi(str) edi(buf) : edi(buf) : esi
  lodsb
  test al, al
  jz .ret
  stosb
  inc edi
  jmp vga.putn
  .ret: ret
