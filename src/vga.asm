global vga.~buf, vga.$buf, vga.#buf, vga.@buf, vga.attr
global vga.blank, vga.cursor, vga.printc, vga.prints
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
  mov edi, vga.~buf
  jmp vga._cursor

vga._scroll: ; : : eax ecx esi edi
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

vga.cursor: ; al : : ah dx
  mov dx, 0x3D4
  mov ah, al
  mov al, 0x0A
  out dx, al
  inc dx
  mov al, ah
  out dx, al
  ret

vga._cursor: ; edi : : ax dx edi
  sub edi, vga.~buf
  shr di, 1
  mov dx, 0x3D4
  mov al, 0xE
  out dx, al
  inc dx
  mov ax, di
  shr ax, 8
  out dx, al
  dec dx
  mov al, 0xF
  out dx, al
  inc dx
  mov ax, di
  out dx, al
  ret

vga.printc: ; al : : ax dx edi
  xor ah, ah
  or ax, [vga.attr]
  mov edi, [vga.@buf]
  stosw
  mov [vga.@buf], edi
  jmp vga._cursor

vga.prints: ; esi(str) : : ax dx esi edi
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
  jmp vga._cursor
