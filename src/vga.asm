global vga.~buf, vga.$buf, vga.#buf
global vga.blank, vga.puts, vga.curs
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

vga.curs: ; ah(shape) edi(buf) : : al dx
  mov dx, 0x3D4
  mov al, 0x0A
  out dx, al
  inc dx
  xchg al, ah
  out dx, al
  lea ecx, [edi - vga.~buf]
  shr ecx, 1
  dec dx
  mov al, 0x0F
  out dx, al
  inc dx
  xchg ax, cx
  out dx, al
  xchg cx, ax
  dec dx
  dec al
  out dx, al
  inc dx
  xchg ax, cx
  shr ax, 8
  out dx, al
  ret
