global tty.reset, tty.lf, tty.cr, tty.print
extern vga.~buf, vga.$buf, vga.blank, vga.scroll
%include "vga.mac"

section .data
tty.@buf: dd vga.~buf

section .text
tty.reset: ; : : ax ecx edi
  mov ax, vga.GRY << vga.FG
  call vga.blank
  mov dword [tty.@buf], vga.~buf
  ret

tty._lf:
  add edi, vga.COLS
tty._cr:
  lea eax, [edi - vga.BUF]
  xor edx, edx
  mov ebx, vga.COLS
  div ebx
  sub edi, edx
  ret

tty.lf: ; : : eax edx ebx edi
  mov edi, [tty.@buf]
  call tty._lf
  mov [tty.@buf], edi
  ret

tty.cr: ; : : eax edx ebx edi
  mov edi, [tty.@buf]
  call tty._cr
  mov [tty.@buf], edi
  ret

tty.print: ; ecx(len) esi(str) : : eax ecx edx ebx esi edi
  mov edi, [tty.@buf]
  .rep:
    cmp edi, vga.$buf
    jb .lods
    pushad
    call vga.scroll
    popad
    mov edi, vga.$buf - vga.COLS
    .lods:
      lodsb
    .bs:
      cmp al, `\b`
      jne .ht
      sub edi, 2
      mov byte [edi], ' '
      jmp .loop
    .ht:
      cmp al, `\t`
      jne .lf
      add edi, 0x10
      and edi, -0x0F
      jmp .loop
    .lf:
      cmp al, `\n`
      jne .cr
      call tty._lf
      jmp .loop
    .cr:
      cmp al, `\r`
      jne .stos
      call tty._cr
      jmp .loop
    .stos:
      stosb
      inc edi
  .loop: loop .rep
  mov [tty.@buf], edi
  ret
