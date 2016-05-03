global fmt.bin, fmt.dec, fmt.hex

section .rodata
fmt.hexDigits: db '0123456789ABCDEF'

section .data
fmt.output: db '00000000000000000000000000000000', 0
.$:

section .text
fmt.bin: ; eax : esi : eax ecx edi
  mov esi, eax
  mov ecx, 20h
  mov edi, fmt.output.$ - 1
  std
  .for:
    shr esi, 1
    setc al
    add al, '0'
    stosb
  loop .for
  cld
  mov esi, edi
  ret

fmt.dec: ; eax : esi : eax edx ebx
  test eax, eax
  jz .zero

  mov ebx, 0Ah
  mov esi, fmt.output.$
  .for:
    xor edx, edx
    div ebx
    test dl, dl
    jz .break
    add dl, '0'
    dec esi
    mov [esi], dl
  jmp .for

  .zero:
  mov esi, fmt.output.$ - 1
  mov byte [esi], '0'

  .break:
  ret

fmt.hex: ; eax : esi : eax ecx edx ebx
  mov ebx, 10h
  mov esi, fmt.output.$
  mov ecx, 8
  .for:
    xor edx, edx
    div ebx
    mov edx, [fmt.hexDigits + edx]
    dec esi
    mov [esi], dl
  loop .for
  ret
