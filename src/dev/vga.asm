global vga.init, vga.blank, vga.writeChar, vga.write
global vga.buffer, vga.buffer.$, vga.pointer, vga.attribute
%include "dev/vga.mac"

absolute vga.BUFFER
vga.buffer: resb vga.WIDTH * vga.HEIGHT
.$:

section .data
vga.pointer: dd vga.buffer
vga.attribute: db vga.Color.GRAY << vga.Color.FG

section .text
vga.init: ; : : eax ecx(0) dx edi
  _out 3D4h, 0Ah
  _out 3D5h, 0FFh
jmp vga.blank

vga.blank: ; : : eax ecx(0) edi
  xor eax, eax
  mov ah, [vga.attribute]
  shl eax, 10h
  mov ah, [vga.attribute]

  mov edi, vga.buffer
  mov ecx, vga.WIDTH * vga.HEIGHT / 4
  rep stosd

  mov edi, vga.buffer
  rol ah, 4
  mov [edi + 1], ah

  mov [vga.pointer], edi
ret

vga.writeChar: ; al(char) : : ax ecx(0) edx esi edi
  push eax
  mov ecx, 1
  mov esi, esp
  call vga.write
  add esp, 4
ret

vga.write: ; ecx(strLen) esi(str) : : ax ecx(0) edx esi edi
  test ecx, ecx
  jnz .clearCursor
  ret

  .clearCursor:
  mov edi, [vga.pointer]
  mov ah, [vga.attribute]
  mov [edi + 1], ah

  .for:
    cmp edi, vga.buffer.$
    jb .lods
    _push eax, ecx, esi, edi
    call vga.scroll
    _pop eax, ecx, esi, edi
    sub edi, vga.WIDTH

    .lods:
    lodsb

    .caseBS:
    cmp al, `\b`
    jne .caseHT
    sub edi, 2
    mov byte [edi], ' '
    jmp .next

    .caseHT:
    cmp al, `\t`
    jne .caseLF
    add edi, 10h
    and edi, -0Fh
    jmp .next

    .caseLF:
    cmp al, `\n`
    jne .caseCR
    add edi, vga.WIDTH
    jmp .CR

    .caseCR:
    cmp al, `\r`
    jne .caseElse
    .CR:
    _push eax, ecx
    lea eax, [edi - vga.buffer]
    xor edx, edx
    mov ecx, vga.WIDTH
    div ecx
    mul ecx
    lea edi, [eax + vga.buffer]
    _pop eax, ecx
    jmp .next

    .caseElse:
    stosw

    .next:
  loop .for

  rol ah, 4
  mov [edi + 1], ah

  mov [vga.pointer], edi
ret

vga.scroll: ; : : eax ecx(0) esi edi
  mov edi, vga.buffer
  mov esi, vga.buffer + vga.WIDTH
  mov ecx, (vga.HEIGHT - 1) * vga.WIDTH / 4
  rep movsd

  xor eax, eax
  mov ah, [vga.attribute]
  shl eax, 10h
  mov ah, [vga.attribute]
  mov ecx, vga.WIDTH / 4
  rep stosd
ret
