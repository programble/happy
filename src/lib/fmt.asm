;;; Number and string formatting.

global fmt.binByte, fmt.binWord, fmt.binDword
global fmt.hexByte, fmt.hexWord, fmt.hexDword
global fmt.dec
global fmt.fmt
global fmt.printBuffers

extern str.fromCStr
extern diag.printMem, text.writeNl

%include "core.mac"

section .rodata

;;; Hexadecimal digits.
fmt.hexDigits: db '0123456789ABCDEF'

section .bss

;;; Buffer for number formatting.
fmt.intStr: resb 20h
  .$:

;;; Buffer for string formatting.
fmt.fmtStr: resb 100h
  .$:

section .text

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

;;; Format a byte in binary.
;;; al : ecx(strLen) esi(str) : al(0)
fmt.binByte:
  _bin al, 8
ret

;;; Format a word in binary.
;;; ax : ecx(strLen) esi(str) : ax(0)
fmt.binWord:
  _bin ax, 10h
ret

;;; Format a double-word in binary.
;;; eax : ecx(strLen) esi(str) : eax(0)
fmt.binDword:
  _bin eax, 20h
ret

;;; Format a byte in hexadecimal.
;;; al : ecx(strLen) esi(str) :
fmt.hexByte:
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

;;; Format a word in hexadecimal.
;;; ax : ecx(strLen) esi(str) :
fmt.hexWord:
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

;;; Format a double-word in hexadecimal.
;;; eax : ecx(strLen) esi(str) :
fmt.hexDword:
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

;;; Format a double-word in decimal.
;;; eax : ecx(strLen) esi(str) : eax(0) edx(0)
fmt.dec:
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

;;; Format a string with values from the stack.
;;; Format specifiers are of the form "%rsn", where "r" is the radix one of
;;; "bhd", "s" is the size one of "bwd", and "n" is the position from the top
;;; of the stack 0-9. The format specifier "cs" can be used for C strings, and
;;; "ss" for sized strings. "%" can be escaped with "%%".
;;; ecx(fmtLen) esi(fmt) [esp+4...] : ecx(strLen) esi(str) : eax edx edi
fmt.fmt:
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
    _case 'ss', .str
    _case 'cs', .cStr
    _case 'hd', fmt.hexDword
    _case 'dd', fmt.dec
    _case 'bd', fmt.binDword
    _case 'hb', fmt.hexByte
    _case 'bb', fmt.binByte
    _case 'hw', fmt.hexWord
    _case 'bw', fmt.binWord
    _case 'db', fmt.dec
    _case 'dw', fmt.dec
    _panic 'invalid format specifier'

    .copy:
    rep movsb
    _rpop ecx, esi
  sub ecx, 3
  jnz .for

  .break:
  mov ecx, edi
  mov esi, fmt.fmtStr
  sub ecx, esi
ret

.cStr:
  mov esi, eax
jmp str.fromCStr

.str:
  xor ecx, ecx
  mov cl, [esi - 1]
  sub cl, '/'
  mov ecx, [esp + ecx * 4 + 10h]
  mov esi, eax
ret

;;; Print the formatting buffers.
;;; : : ax ecx(0) edx esi edi
fmt.printBuffers:
  mov esi, fmt.intStr
  mov ecx, (fmt.intStr.$ - fmt.intStr) / 4
  call diag.printMem
  call text.writeNl

  mov esi, fmt.fmtStr
  mov ecx, (fmt.fmtStr.$ - fmt.fmtStr) / 4
jmp diag.printMem
