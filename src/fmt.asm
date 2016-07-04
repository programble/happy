global fmt.binByte, fmt.binWord, fmt.binDword
global fmt.hexByte, fmt.hexWord, fmt.hexDword
global fmt.dec
global fmt.fmt
%include "macro.mac"
%include "core.mac"

section .rodata
fmt.hexDigits: db '0123456789ABCDEF'

section .data
fmt.intString: db '00000000000000000000000000000000'
.$:

section .bss
fmt.string: resb 100h
.$:

section .text
fmt.binByte: ; al(byte) : ecx(fmtLen) esi(fmt) : al
  mov esi, fmt.intString.$
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
  mov esi, fmt.intString.$
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
  mov esi, fmt.intString.$
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
  mov [fmt.intString.$ - 1], cl

  movzx esi, al
  shr esi, 4
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov esi, fmt.intString.$ - 2
  mov [esi], cl

  mov ecx, 2
ret

fmt.hexWord: ; ax(word) : ecx(fmtLen) esi(fmt) :
  movzx esi, ax
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 1], cl

  movzx esi, ax
  shr esi, 4
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 2], cl

  movzx esi, ax
  shr esi, 8
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 3], cl

  movzx esi, ax
  shr esi, 0Ch
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov esi, fmt.intString.$ - 4
  mov [esi], cl

  mov ecx, 4
ret

fmt.hexDword: ; eax(dword) : ecx(fmtLen) esi(fmt) :
  mov esi, eax
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 1], cl

  mov esi, eax
  shr esi, 4
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 2], cl

  mov esi, eax
  shr esi, 8
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 3], cl

  mov esi, eax
  shr esi, 0Ch
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 4], cl

  mov esi, eax
  shr esi, 10h
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 5], cl

  mov esi, eax
  shr esi, 14h
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 6], cl

  mov esi, eax
  shr esi, 18h
  and esi, 0Fh
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov [fmt.intString.$ - 7], cl

  mov esi, eax
  shr esi, 1Ch
  add esi, fmt.hexDigits
  mov cl, [esi]
  mov esi, fmt.intString.$ - 8
  mov [esi], cl

  mov ecx, 8
ret

fmt.dec: ; eax(dword) : ecx(fmtLen) esi(fmt) : eax(0) edx(0)
  test eax, eax
  jnz .nonZero
  mov esi, fmt.intString.$ - 1
  mov byte [esi], '0'
  mov ecx, 1
  ret

  .nonZero:
  mov ecx, 0Ah
  mov esi, fmt.intString.$

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
  mov ecx, fmt.intString.$
  sub ecx, esi
ret

fmt.fmt: ; ecx(strLen) esi(str) [esp+4...] : ecx(fmtLen) esi(fmt) : edi eax edx
  mov edi, fmt.string

  .for:
    lodsb
    cmp al, '%'
    je .parse

    stosb
    jmp .next

    .parse:
    lodsb
    cmp al, '%'
    je .escape

    mov ah, al
    lodsb
    mov dx, ax

    xor eax, eax
    lodsb
    sub al, '0'
    mov eax, [esp + eax * 4 + 4]

    %macro _case 3
      cmp dx, %1 << 8 | %2
      jne %%fmtCaseElse
      jmp %3
      %%fmtCaseElse:
    %endmacro

    _push ecx, esi
    push .copy
    _case 'b', 'b', fmt.binByte
    _case 'b', 'w', fmt.binWord
    _case 'b', 'd', fmt.binDword
    _case 'd', 'b', fmt.dec
    _case 'd', 'w', fmt.dec
    _case 'd', 'd', fmt.dec
    _case 'h', 'b', fmt.hexByte
    _case 'h', 'w', fmt.hexWord
    _case 'h', 'd', fmt.hexDword
    _panic 'invalid format string'

    .escape:
    stosb
    dec ecx
    jmp .next

    .copy:
    rep movsb
    _pop ecx, esi
    sub ecx, 3

    .next:
  dec ecx
  jnz .for

  mov ecx, edi
  sub ecx, fmt.string
  mov esi, fmt.string
ret
