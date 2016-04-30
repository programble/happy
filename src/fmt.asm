global fmt.bin, fmt.hex

section .rodata
fmt.dig: db '0123456789ABCDEF'

section .data
fmt.~out: db '00000000000000000000000000000000', 0
fmt.$out:

section .text
fmt.bin: ; eax : esi : al ecx edi
  mov esi, eax
  mov ecx, 0x20
  mov edi, fmt.$out - 1
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

fmt.hex: ; eax : esi : eax ecx edx ebx
  mov ebx, 0x10
  mov ecx, 8
  mov esi, fmt.$out
  .for:
    xor edx, edx
    div ebx
    mov edx, [fmt.dig + edx]
    dec esi
    mov [esi], dl
  loop .for
  ret
