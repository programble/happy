global vga.~buf, vga.$buf, vga.#buf
global vga._blank, vga._putq, vga._puts, vga.aputs, vga.curs
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

vga.aputs: ; ah(attr) ecx(len) esi(str) edi(buf) : edi(buf) : al ecx esi
  lodsb
  stosw
  loop vga.aputs
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
