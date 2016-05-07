global diag.printEflags, diag.printRegs, diag.printStack, diag.printMem
extern core.boundLower, core.boundUpper, core.stack.$
extern fmt.hex, elf.symbolString, elf.symbolStringOffset
%include "macro.mac"
%include "text.mac"

Eflags:
  .CF: equ 0000_0000_0000_0000_0000_0000_0000_0001b
  .PF: equ 0000_0000_0000_0000_0000_0000_0000_0100b
  .AF: equ 0000_0000_0000_0000_0000_0000_0001_0000b
  .ZF: equ 0000_0000_0000_0000_0000_0000_0100_0000b
  .SF: equ 0000_0000_0000_0000_0000_0000_1000_0000b
  .TF: equ 0000_0000_0000_0000_0000_0001_0000_0000b
  .IF: equ 0000_0000_0000_0000_0000_0010_0000_0000b
  .DF: equ 0000_0000_0000_0000_0000_0100_0000_0000b
  .OF: equ 0000_0000_0000_0000_0000_1000_0000_0000b
  ; TODO: IOPL
  .NT: equ 0000_0000_0000_0000_0100_0000_0000_0000b
  .RF: equ 0000_0000_0000_0001_0000_0000_0000_0000b
  .VM: equ 0000_0000_0000_0010_0000_0000_0000_0000b
  .AC: equ 0000_0000_0000_0100_0000_0000_0000_0000b
  .VIF: equ 0000_0000_0000_1000_0000_0000_0000_0000b
  .VIP: equ 0000_0000_0001_0000_0000_0000_0000_0000b
  .ID: equ 0000_0000_0010_0000_0000_0000_0000_0000b

struc Pushad
  .edi: resd 1
  .esi: resd 1
  .ebp: resd 1
  .esp: resd 1
  .ebx: resd 1
  .edx: resd 1
  .ecx: resd 1
  .eax: resd 1
endstruc

section .text
diag.printEflags: ; [esp+4](pushfd) : : eax ecx edx ebx esi edi
  mov eax, [esp + 4]
  call fmt.hex
  text.write

  %macro _flag 2
    test dword [esp + 4], Eflags.%1
    jz %%flagElse
    text.write %2
    %%flagElse:
  %endmacro

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

  ret

diag.printRegs: ; [esp+4](pushad) : : eax ecx edx ebx esi edi
  %macro _reg 2
    text.write %1
    mov eax, [esp + 4 + Pushad.%2]
    call fmt.hex
    text.write
  %endmacro

  _reg 'eax ', eax
  _reg ' ecx ', ecx
  _reg ' edx ', edx
  _reg ' ebx ', ebx
  _reg `\nesp `, esp
  _reg ' ebp ', ebp
  _reg ' esi ', esi
  _reg ' edi ', edi

  ret

diag.printStack: ; esp : : eax ecx edx ebx ebp esi edi
  mov ebp, esp
  .while:
    mov eax, ebp
    call fmt.hex
    text.write
    text.writeChar ' '

    mov eax, [ebp]
    call fmt.hex
    text.write
    text.writeChar ' '

    mov eax, [ebp]
    cmp eax, core.boundLower
    jb .next
    cmp eax, core.boundUpper
    ja .next
    call elf.symbolStringOffset
    test esi, esi
    jz .next
    push esi
    mov eax, ecx
    call fmt.hex
    text.write
    text.writeChar '+'
    pop esi
    text.write

    .next:
    text.writeChar `\n`
    add ebp, 4
  cmp ebp, core.stack.$
  jb .while

  ret

diag.printMem: ; esi(mem) ecx(count) : : eax ecx edx esi edi
  push ecx
  test esi, 0Fh
  jnz .printDword

  .printAddr:
  mov eax, esi
  push esi
  call fmt.hex
  text.write
  text.write ': '
  pop esi

  .printDword:
  lodsd
  push esi
  call fmt.hex
  text.write
  text.writeChar ' '
  pop esi

  test esi, 0Fh
  jnz .next

  .printAscii:
  mov ecx, 10h
  sub esi, ecx
  .for:
    lodsb
    test al, 1110_0000b
    js .nonPrintable
    jnz .printable

    .nonPrintable:
    mov al, '.'
    .printable:
    mpush esi, ecx
    text.writeChar
    mpop esi, ecx
  loop .for

  push esi
  text.writeChar `\n`
  pop esi

  .next:
  pop ecx
  dec ecx
  jnz diag.printMem
  ret
