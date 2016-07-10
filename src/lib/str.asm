;;; String functions.

global str.fromCStr, str.equal?

section .text

;;; Determine the length of a C-style null-terminated string.
;;; esi(cStr) : ecx(strLen) esi(str) :
str.fromCStr:
  mov ecx, esi
  .while:
    cmp byte [ecx], 0
    je .break
    inc ecx
  jmp .while

  .break:
  sub ecx, esi
ret

;;; Compare two strings for equality.
;;; ecx(lhsLen) edx(rhsLen) esi(lhs) edi(lhs) : ZF : ecx(0) esi edi
str.equal?:
  cmp ecx, edx
  jne .ret

  .for:
    cmpsb
    jne .ret
  loop .for

  .ret:
ret
