global tty.push, tty.pop, tty.reset, tty.print
extern vga.~buf, vga.$buf, vga.blank, vga.scroll
%include "vga.mac"

section .bss
tty.~stack: resb 0x100
tty.$stack:

section .data
tty.@buf: dd vga.~buf
tty.@stack: dd tty.~stack

section .text
tty.push: ; : : eax edx
  mov eax, [tty.@stack]
  sub eax, 4
  mov edx, [tty.@buf]
  mov [eax], edx
  mov [tty.@stack], eax
  ret

tty.pop: ; : : eax edx
  mov eax, [tty.@stack]
  mov edx, [eax]
  mov [tty.@buf], edx
  add eax, 4
  mov [tty.@stack], eax
  ret

tty.reset: ; : : ax ecx edi
  mov ax, vga.GRY << vga.FG
  call vga.blank
  mov dword [tty.@buf], vga.~buf
  mov dword [tty.@stack], tty.~stack
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
  .b:
    cmp al, `\b`
    jne .t
    sub edi, 2
    mov byte [edi], ' '
    jmp .loop
  .t:
    cmp al, `\t`
    jne .n
    add edi, 0x10
    and edi, -0x0F
    jmp .loop
  .n:
    cmp al, `\n`
    jne .r
    add edi, vga.COLS
    mov al, `\r`
  .r:
    cmp al, `\r`
    jne .stos
    lea eax, [edi - vga.BUF]
    xor edx, edx
    mov ebx, vga.COLS
    div ebx
    sub edi, edx
    jmp .loop
  .stos:
    stosb
    inc edi
  .loop:
  loop .rep
  mov [tty.@buf], edi
  ret
