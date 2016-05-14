global fmt.binByte, fmt.binWord, fmt.binDword
global fmt.hexByte, fmt.hexWord, fmt.hexDword
global fmt.dec

section .rodata
fmt.hexDigits: db '0123456789ABCDEF'

section .data
fmt.string: db '00000000000000000000000000000000'
.$:

section .text
fmt.binByte: ; al(byte) : ecx(fmtLen) esi(fmt) : al
  mov esi, fmt.string.$
  mov ecx, 8
  .for:
    dec esi
    shr al, 1
    setc [esi]
    add byte [esi], '0'
  loop .for
  mov ecx, 8
ret

fmt.binWord: ; ax(word) : ecx(fmtLen) esi(fmt) : ax
  mov esi, fmt.string.$
  mov ecx, 10h
  .for:
    dec esi
    shr ax, 1
    setc [esi]
    add byte [esi], '0'
  loop .for
  mov ecx, 10h
ret

fmt.binDword: ; eax(dword) : ecx(fmtLen) esi(fmt) : eax
  mov esi, fmt.string.$
  mov ecx, 20h
  .for:
    dec esi
    shr eax, 1
    setc [esi]
    add byte [esi], '0'
  loop .for
  mov ecx, 20h
ret

fmt.hexByte: ; al(byte) : ecx(fmtLen) esi(fmt) :
  movzx esi, al
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 1], cl

  movzx esi, al
  shr esi, 4
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov esi, fmt.string.$ - 2
  mov [esi], cl

  mov ecx, 2
ret

fmt.hexWord: ; ax(word) : ecx(fmtLen) esi(fmt) :
  movzx esi, ax
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 1], cl

  movzx esi, ax
  shr esi, 4
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 2], cl

  movzx esi, ax
  shr esi, 8
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 3], cl

  movzx esi, ax
  shr esi, 0Ch
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov esi, fmt.string.$ - 4
  mov [esi], cl

  mov ecx, 4
ret

fmt.hexDword: ; eax(dword) : ecx(fmtLen) esi(fmt) :
  mov esi, eax
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 1], cl

  mov esi, eax
  shr esi, 4
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 2], cl

  mov esi, eax
  shr esi, 8
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 3], cl

  mov esi, eax
  shr esi, 0Ch
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 4], cl

  mov esi, eax
  shr esi, 10h
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 5], cl

  mov esi, eax
  shr esi, 14h
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 6], cl

  mov esi, eax
  shr esi, 18h
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.string.$ - 7], cl

  mov esi, eax
  shr esi, 1Ch
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov esi, fmt.string.$ - 8
  mov [esi], cl

  mov ecx, 8
ret

fmt.dec: ; eax(dword) : ecx(fmtLen) esi(fmt) : eax(0) edx(0)
  test eax, eax
  jnz .nonZero
  mov esi, fmt.string.$ - 1
  mov byte [esi], '0'
  mov ecx, 1
  ret

  .nonZero:
  mov ecx, 0Ah
  mov esi, fmt.string.$

  .while:
    xor edx, edx
    div ecx

    test al, al
    jnz .else
    test dl, dl
    jz .break
    .else:

    add dl, '0'
    dec esi
    mov [esi], dl
  jmp .while

  .break:
  mov ecx, fmt.string.$
  sub ecx, esi
ret
