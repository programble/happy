global fmt.binByte, fmt.binWord, fmt.binDword
global fmt.hexByte, fmt.hexWord, fmt.hexDword
global fmt.dec
global fmt.fmt
%include "macro.mac"
%include "core.mac"

section .rodata
fmt.hexDigits: db '0123456789ABCDEF'

section .bss
fmt.intStr: resb 20h
.$:
fmt.fmtStr: resb 100h
.$:

%macro _bin 2
  mov esi, fmt.intStr.$
  mov ecx, %2
  .for:
    dec esi
    shr %1, 1
    setc [esi]
    add byte [esi], '0'
  loop .for
  mov ecx, %2
%endmacro

section .text
fmt.binByte: ; al : ecx(strLen) esi(str) : al
  _bin al, 8
ret

fmt.binWord: ; ax : ecx(strLen) esi(str) : ax
  _bin ax, 10h
ret

fmt.binDword: ; eax : ecx(strLen) esi(str) : eax
  _bin eax, 20h
ret

fmt.hexByte: ; al : ecx(strLen) esi(str) :
  movzx esi, al
  and esi, 0Fh
  mov ch, [fmt.hexDigits + esi]

  movzx esi, al
  shr esi, 4
  mov cl, [fmt.hexDigits + esi]

  mov esi, fmt.intStr.$ - 2
  mov [esi], cx
  mov ecx, 2
ret

fmt.hexWord: ; ax : ecx(strLen) esi(str) :
  movzx esi, al
  and esi, 0Fh
  mov ch, [fmt.hexDigits + esi]

  movzx esi, al
  shr esi, 4
  mov cl, [fmt.hexDigits + esi]
  mov [fmt.intStr.$ - 2], cx

  movzx esi, ah
  and esi, 0Fh
  mov ch, [fmt.hexDigits + esi]

  movzx esi, ah
  shr esi, 4
  mov cl, [fmt.hexDigits + esi]

  mov esi, fmt.intStr.$ - 4
  mov [esi], cx
  mov ecx, 4
ret

fmt.hexDword: ; eax : ecx(strLen) esi(str) :
  movzx esi, al
  and esi, 0Fh
  mov ch, [fmt.hexDigits + esi]

  movzx esi, al
  shr esi, 4
  mov cl, [fmt.hexDigits + esi]
  mov [fmt.intStr.$ - 2], cx

  movzx esi, ah
  and esi, 0Fh
  mov ch, [fmt.hexDigits + esi]

  movzx esi, ah
  shr esi, 4
  mov cl, [fmt.hexDigits + esi]
  mov [fmt.intStr.$ - 4], cx

  mov esi, eax
  shr esi, 10h
  and esi, 0Fh
  mov ch, [fmt.hexDigits + esi]

  mov esi, eax
  shr esi, 14h
  and esi, 0Fh
  mov cl, [fmt.hexDigits + esi]
  mov [fmt.intStr.$ - 6], cx

  mov esi, eax
  shr esi, 18h
  and esi, 0Fh
  mov ch, [fmt.hexDigits + esi]

  mov esi, eax
  shr esi, 1Ch
  mov cl, [fmt.hexDigits + esi]

  mov esi, fmt.intStr.$ - 8
  mov [esi], cx
  mov ecx, 8
ret

fmt.dec: ; eax : ecx(strLen) esi(str) : eax(0) edx(0)
  test eax, eax
  jnz .nz
  mov ecx, 1
  mov esi, fmt.intStr.$ - 1
  mov byte [esi], '0'
  ret

  .nz:
  mov ecx, 0Ah
  mov esi, fmt.intStr.$

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
  mov ecx, fmt.intStr.$
  sub ecx, esi
ret

fmt.fmt: ; ecx(fmtLen) esi(fmt) [esp+4...] : ecx(strLen) esi(str) : eax edx edi
  mov edi, fmt.fmtStr

  .for:
    lodsb
    cmp al, '%'
    je .spec

    .stosb:
    stosb
    loop .for
    jmp .break

    .spec:
    dec ecx
    lodsb
    cmp al, '%'
    je .stosb

    cmp ecx, 3
    _panicc b, 'incomplete format specifier'

    mov dl, al
    lodsb
    mov dh, al

    xor eax, eax
    lodsb
    sub al, '0'
    mov eax, [esp + eax * 4 + 4]

    %macro _case 2
      cmp dx, %1
      jne %%fmtCaseElse
      jmp %2
      %%fmtCaseElse:
    %endmacro

    _push ecx, esi, .copy
    _case 'bb', fmt.binByte
    _case 'bw', fmt.binWord
    _case 'bd', fmt.binDword
    _case 'hb', fmt.hexByte
    _case 'hw', fmt.hexWord
    _case 'hd', fmt.hexDword
    _case 'db', fmt.dec
    _case 'dw', fmt.dec
    _case 'dd', fmt.dec
    _panic 'invalid format specifier'

    .copy:
    rep movsb
    _pop ecx, esi
  sub ecx, 3
  jnz .for

  .break:
  mov ecx, edi
  mov esi, fmt.fmtStr
  sub ecx, esi
ret
