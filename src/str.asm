global str.shittyHash

str.shittyHash: ; esi : edx : al(0) esi
  xor edx, edx
  .while:
    lodsb
    test al, al
    jnz .xor
    ret
    .xor:
    xor dl, al
    rol edx, 8
  jmp .while
