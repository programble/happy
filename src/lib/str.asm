global str.fromCStr, str.equal?

section .text
str.fromCStr: ; esi(str) : ecx(strLen) esi(str) :
  mov ecx, esi
  .while:
    cmp byte [ecx], 0
    je .break
    inc ecx
  jmp .while

  .break:
  sub ecx, esi
ret

str.equal?: ; ecx(lhsLen) edx(rhsLen) esi(lhs) edi(lhs) : ZF : ecx(0) esi edi
  cmp ecx, edx
  jne .ret

  .for:
    cmpsb
    jne .ret
  loop .for

  .ret:
ret
