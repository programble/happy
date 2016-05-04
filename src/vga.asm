global vga.blank, vga.print, vga.cursorShape
global vga.buffer, vga.buffer.$, vga.pointer, vga.attribute
%include "macro.mac"
%include "vga.mac"

absolute vga.BUFFER
vga.buffer: resb vga.WIDTH * vga.HEIGHT
.$:

section .data
vga.pointer: dd vga.buffer
vga.attribute: dw vga.Color.GRAY << vga.Color.FG

section .text
vga.blank: ; : : eax ecx edx edi
  mov ax, [vga.attribute]
  shl eax, 10h
  mov ax, [vga.attribute]

  mov edi, vga.buffer
  mov ecx, vga.WIDTH * vga.HEIGHT / 4
  rep stosd

  mov edi, vga.buffer
  mov [vga.pointer], edi
  jmp vga._cursorMove

vga.print: ; esi(string) : : eax ecx edx esi edi
  mov edi, [vga.pointer]
  mov ax, [vga.attribute]

  .while:
    cmp edi, vga.buffer.$
    jb .else
    mpush eax, esi, edi
    call vga._scroll
    mpop eax, esi, edi
    sub edi, vga.WIDTH

    .else:
    lodsb
    test al, al
    jz .break

    .caseBS:
    cmp al, `\b`
    jne .caseHT
    sub edi, 2
    mov byte [edi], ' '
    jmp .else

    .caseHT:
    cmp al, `\t`
    jne .caseLF
    add edi, 10h
    and edi, -0Fh
    jmp .while

    .caseLF:
    cmp al, `\n`
    jne .caseCR
    add edi, vga.WIDTH
    jmp .CR

    .caseCR:
    cmp al, `\r`
    jne .caseElse
    .CR:
    push eax
    lea eax, [edi - vga.buffer]
    xor edx, edx
    mov ecx, vga.WIDTH
    div ecx
    mul ecx
    lea edi, [eax + vga.buffer]
    pop eax
    jmp .while

    .caseElse:
    stosw
  jmp .while

  .break:
  mov [vga.pointer], edi
  jmp vga._cursorMove

vga._scroll: ; : : eax ecx esi edi
  mov edi, vga.buffer
  mov esi, vga.buffer + vga.WIDTH
  mov ecx, (vga.HEIGHT - 1) * vga.WIDTH / 4
  rep movsd

  mov ax, [vga.attribute]
  shl eax, 10h
  mov ax, [vga.attribute]
  mov ecx, vga.WIDTH / 4
  rep stosd

  ret

vga.cursorShape: ; al : : ah dx
  mov ah, al
  mov dx, 3D4h
  mov al, 0Ah
  out dx, al
  inc dx
  mov al, ah
  out dx, al
  ret

vga._cursorMove: ; edi(pointer) : :
  sub edi, vga.buffer
  shr di, 1

  mov dx, 3D4h
  mov al, 0Eh
  out dx, al

  inc dx
  mov ax, di
  shr ax, 8
  out dx, al

  dec dx
  mov al, 0Fh
  out dx, al

  inc dx
  mov ax, di
  out dx, al

  ret
