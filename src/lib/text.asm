;;; Text output to serial and VGA.

global text.writeChar, text.writeNl, text.write, text.writeLn, text.writeFmt

extern com.writeChar, com.write
extern vga.writeChar, vga.write
extern fmt.fmt

section .text

;;; Write a character.
;;; al : : ax ecx(0) edx esi edi
text.writeChar:
  call com.writeChar
jmp vga.writeChar

;;; Write a newline.
;;; : : ax ecx(0) edx esi edi
text.writeNl:
  mov al, `\n`
jmp text.writeChar

;;; Write a string.
;;; ecx(strLen) esi(str) : : ax ecx(0) edx esi edi
text.write:
  _push ecx, esi
  call com.write
  _rpop ecx, esi
jmp vga.write

;;; Write a string, followed by a newline.
;;; ecx(strLen) esi(str) : : ax ecx(0) edx esi edi
text.writeLn:
  call text.write
jmp text.writeNl

;;; Format and write a string.
;;; ecx(strLen) esi(str) [esp+4...] : : eax ecx(0) edx ebx esi edi
text.writeFmt:
  pop ebx
  call fmt.fmt
  push ebx
jmp text.write
