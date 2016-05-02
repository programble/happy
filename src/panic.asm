global _panic
extern boot.$stack, elf.sym, fmt.bin, fmt.dec, fmt.hex, vga.attr, vga.print
%include "vga.mac"

Eflags.CF equ 1
Eflags.PF equ 4
Eflags.AF equ 0x10
Eflags.ZF equ 0x40
Eflags.SF equ 0x80
Eflags.TF equ 0x100
Eflags.IF equ 0x200
Eflags.DF equ 0x400
Eflags.OF equ 0x800
; TODO: IOPL
Eflags.NT equ 0x4000
Eflags.RF equ 0x10000
Eflags.VM equ 0x20000
Eflags.AC equ 0x40000
Eflags.VIF equ 0x80000
Eflags.VIP equ 0x100000
Eflags.ID equ 0x200000

struc Pushad, -0x1C
  .eax: resd 1
  .ecx: resd 1
  .edx: resd 1
  .ebx: resd 1
  .esp: resd 1
  .ebp: resd 1
  .esi: resd 1
  .edi: resd 1
endstruc

; Including macro.mac would conflict.
%macro string 1
  [section .rodata]
  %%str: db %1, 0
  __SECT__
  mov esi, %%str
%endmacro

%macro _flag 2
  test dword [esp], Eflags.%1
  jz %%else
  string %2
  call vga.print
  %%else:
%endmacro

%macro _reg 2
  string %1
  call vga.print
  mov eax, [esp - Pushad.%2]
  call fmt.hex
  call vga.print
%endmacro

section .text
_panic: ; eax(eip) ecx(line) edx(file) esi(msg) : :
  push ecx
  push edx
  push eax
  push esi
  mov word [vga.attr], vga.RED << vga.FG
  string `\n== PANIC ==\n`
  call vga.print
  pop esi
  call vga.print
  pop eax
  call fmt.hex
  call vga.print
  pop esi
  call vga.print
  pop eax
  call fmt.dec
  call vga.print

  string `\neflags `
  call vga.print
  mov eax, [esp]
  call fmt.hex
  call vga.print
  _flag CF, ' CF'
  _flag PF, ' PF'
  _flag AF, ' AF'
  _flag ZF, ' ZF'
  _flag SF, ' SF'
  _flag TF, ' TF'
  _flag IF, ' IF'
  _flag DF, ' DF'
  _flag OF, ' OF'
  _flag NT, ' NT'
  _flag RF, ' RF'
  _flag VM, ' VM'
  _flag AC, ' AC'
  _flag VIF, ' VIF'
  _flag VIP, ' VIP'
  _flag ID, ' ID'
  add esp, 4

  _reg `\neax `, eax
  _reg ' ecx ', ecx
  _reg ' edx ', edx
  _reg ' ebx ', ebx
  _reg `\nesp `, esp
  _reg ' ebp ', ebp
  _reg ' esi ', esi
  _reg ' edi ', edi
  add esp, 0x20

  and esp, -4
  .while:
    string `\n`
    call vga.print

    mov eax, esp
    call fmt.hex
    call vga.print
    string ' '
    call vga.print

    mov eax, [esp]
    call fmt.hex
    call vga.print
    string ' '
    call vga.print

    mov eax, [esp]
    cmp eax, 0x00100000
    jb .next
    call elf.sym
    test esi, esi
    jz .next
    push esi
    mov eax, ecx
    call fmt.hex
    call vga.print
    string '+'
    call vga.print
    pop esi
    call vga.print

    .next:
    add esp, 4
  cmp esp, boot.$stack
  jb .while

  .halt:
  hlt
  jmp .halt
