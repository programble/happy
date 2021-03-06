;;; Diagnostic functions.

global diag.printEflags, diag.printRegs, diag.printSymbol, diag.printStack, diag.printMem

extern fmt.hexDword
extern elf.symbolStringOffset
extern text.writeChar, text.writeNl, text.write, text.writeFmt
extern core.boundLower, core.boundUpper, core.stack.$

;;; Processor flags.
;;; TODO: Citation.
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

;;; Order in which register values are pushed with PUSHAD.
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

;;; Print flags from PUSHFD.
;;; eax(pushfd) : : eax ecx(0) edx esi edi
diag.printEflags:
  push eax
  _string '%hd0'
  call text.writeFmt

  %macro _flag 2
    test dword [esp], Eflags.%1
    jz %%flagElse
    _string %2
    call text.write
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

  add esp, 4
ret

;;; Print registers from PUSHAD.
;;; ebx(pushad) : : eax ecx(0) edx esi edi
diag.printRegs:
  %macro _reg 2
    push dword [ebx + Pushad.%2]
    _string {%1, '%hd0'}
    call text.writeFmt
    add esp, 4
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

;;; Look up and print the ELF symbol associated with a value.
;;; eax(value) : : eax ecx(0) edx esi edi
diag.printSymbol:
  push eax
  _string '%hd0 '
  call text.writeFmt

  pop eax
  cmp eax, core.boundLower
  jb .ret
  cmp eax, core.boundUpper
  ja .ret

  call elf.symbolStringOffset
  test ecx, ecx
  jz .ret

  _push ecx, esi, eax
  _string '%hd0+%ss1'
  call text.writeFmt
  add esp, 0Ch

  .ret:
ret

;;; Print the values on the stack with corresponding ELF symbols.
;;; esp(stack) : : eax ecx(0) edx esi edi
diag.printStack:
  mov ebp, esp

  .while:
    push ebp
    _string '%hd0 '
    call text.writeFmt
    add esp, 4

    mov eax, [ebp]
    call diag.printSymbol

    call text.writeNl
    add ebp, 4
  cmp ebp, core.stack.$
  jb .while
ret

;;; Print a hexdump of a region of memory.
;;; esi(mem) ecx(memLen) : : eax ecx(0) edx esi edi
diag.printMem:
  push ecx
  test esi, 0Fh
  jnz .printDword

  .printAddr:
  push esi
  _string '%hd0: '
  call text.writeFmt
  pop esi

  .printDword:
  lodsd
  push esi
  push eax
  _string '%hd0 '
  call text.writeFmt
  add esp, 4
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
    _push ecx, esi
    call text.writeChar
    _rpop ecx, esi
  loop .for

  push esi
  call text.writeNl
  pop esi

  .next:
  pop ecx
  dec ecx
  jnz diag.printMem
ret
