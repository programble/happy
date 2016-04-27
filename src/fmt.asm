global fmt.hex

section .rodata
fmt.dig: db '0123456789ABCDEF'

section .data
fmt.~out: db '00000000'
fmt.$out:

section .text
fmt.hex: ; eax : ecx esi : edx ebx
  mov ebx, 0x10
  mov ecx, 8
  mov esi, fmt.$out
  .loop:
    xor edx, edx
    div ebx
    mov edx, [fmt.dig + edx]
    dec esi
    mov [esi], dl
  loop .loop
  mov cl, 8
  ret
