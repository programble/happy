global vga.~buf, vga.$buf, vga.#buf, vga.@buf, vga.attr
global vga.blank, vga.cursor, vga.print
%include "macro.mac"
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

%macro vga._cc 1
  %%bs:
    cmp al, `\b`
    jne %%ht
    sub edi, 2
    mov byte [edi], ' '
    jmp %1
  %%ht:
    cmp al, `\t`
    jne %%lf
    add edi, 0x10
    and edi, -0xF
    jmp %1
  %%lf:
    cmp al, `\n`
    jne %%cr
    add edi, vga.COLS
    jmp %%_cr
  %%cr:
    cmp al, `\r`
    jne %%else
    %%_cr:
    push eax
    lea eax, [edi - vga.~buf]
    xor edx, edx
    mov edi, vga.COLS
    div edi
    mul edi
    lea edi, [eax + vga.~buf]
    pop eax
    jmp %1
  %%else:
%endmacro

vga.print: ; esi(str) : : ax ecx edx esi edi
  mov edi, [vga.@buf]
  mov ax, [vga.attr]

  .while:
    cmp edi, vga.$buf
    jb .lods

    .asdf:
    mpush eax, esi, edi
    mov edi, vga.~buf
    mov esi, vga.~buf + vga.COLS
    mov ecx, (vga.ROWS - 1) * vga.COLS / 4
    rep movsd
    mov ax, [vga.attr]
    shl eax, 0x10
    mov ax, [vga.attr]
    mov ecx, vga.COLS / 4
    rep stosd
    pop edi
    sub edi, vga.COLS
    mpop eax, esi

    .lods:
    lodsb
    test al, al
    jz .break
    stosw
  jmp .while

  .break:
  mov [vga.@buf], edi
  jmp vga._cursor
