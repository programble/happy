global elf.init, elf.symbolString, elf.symbolStringOffset, elf.stringSymbol
global elf.printGlobals
extern str.fromCStr, str.equal?
extern text.writeFmt

ShType:
  .NULL: equ 0
  .PROGBITS: equ 1
  .SYMTAB: equ 2
  .STRTAB: equ 3
  .RELA: equ 4
  .HASH: equ 5
  .DYNAMIC: equ 6
  .NOTE: equ 7
  .NOBITS: equ 8
  .REL: equ 9
  .SHLIB: equ 0Ah
  .DYNSYM: equ 0Bh
  .LOPROC: equ 70000000h
  .HIPROC: equ 7FFFFFFFh
  .LOUSER: equ 80000000h
  .HIUSER: equ 0FFFFFFFFh

ShFlags:
  .WRITE: equ 1
  .ALLOC: equ 2
  .EXECINSTR: equ 4
  .MASKPROC: equ 0F0000000h

struc Shdr
  .name: resd 1
  .type: resd 1
  .flags: resd 1
  .addr: resd 1
  .offset: resd 1
  .size: resd 1
  .link: resd 1
  .info: resd 1
  .addralign: resd 1
  .entsize: resd 1
endstruc

SymType:
  .NOTYPE: equ 0
  .OBJECT: equ 1
  .FUNC: equ 2
  .SECTION: equ 3
  .FILE: equ 4
  .LOPROC: equ 0Dh
  .HIPROC: equ 0Fh

SymBind:
  .LOCAL: equ 0
  .GLOBAL: equ 1
  .WEAK: equ 2
  .LOPROC: equ 0Dh
  .HIPROC: equ 0Fh

struc Sym
  .name: resd 1
  .value: resd 1
  .size: resd 1
  .info: resb 1
  .other: resb 1
  .shndx: resw 1
endstruc

section .data
elf.symtab: dd 0
.$: dd 0
elf.strtab: dd 0

section .text
elf.init: ; ecx(shdrNum) ebx(shdrAddr) : : eax ecx edx(0) ebx
  push ebx

  .for:
    cmp dword [ebx + Shdr.type], ShType.SYMTAB
    je .break
    add ebx, Shdr_size
  loop .for

  add esp, 4
  ret

  .break:
  mov eax, [ebx + Shdr.addr]
  mov [elf.symtab], eax
  add eax, [ebx + Shdr.size]
  mov [elf.symtab.$], eax

  mov eax, [ebx + Shdr.link]
  mov ecx, Shdr_size
  mul ecx
  pop ebx
  add ebx, eax
  mov eax, [ebx + Shdr.addr]
  mov [elf.strtab], eax
ret

elf.symbolString: ; eax(value) : ecx(nameLen) esi(name) :
  xor ecx, ecx
  cmp dword [elf.symtab], 0
  jne .skipCheck
  ret
  .skipCheck:

  mov esi, [elf.symtab]
  .while:
    cmp dword [esi + Sym.value], eax
    je .break
    add esi, Sym_size
  cmp esi, [elf.symtab.$]
  jb .while
  ret

  .break:
  mov esi, [esi + Sym.name]
  add esi, [elf.strtab]
jmp str.fromCStr

elf.symbolStringOffset: ; eax(value) : eax(offset) ecx(nameLen) esi(name) : edx
  xor ecx, ecx
  cmp dword [elf.symtab], 0
  je .ret

  xor edx, edx
  .while:
    call elf.symbolString.skipCheck
    test ecx, ecx
    jnz .break
    dec eax
    inc edx
  cmp edx, 100h
  jb .while

  .break:
  mov eax, edx

  .ret:
ret

elf.stringSymbol: ; ecx(strLen) esi(str) : eax(value) : ecx ebx edx esi edi
  xor eax, eax
  mov ebx, [elf.symtab]
  test ebx, ebx
  jz .ret

  mov edx, ecx
  mov edi, esi

  .while:
    mov si, [ebx + Sym.info]
    shr si, 4
    and si, 0Fh
    cmp si, SymBind.GLOBAL
    jne .next

    mov esi, [ebx + Sym.name]
    add esi, [elf.strtab]
    call str.fromCStr
    push edi
    call str.equal?
    pop edi
    je .break

    .next:
    add ebx, Sym_size
  cmp ebx, [elf.symtab.$]
  jb .while
  ret

  .break:
  mov eax, [ebx + Sym.value]

  .ret:
ret

elf.printGlobals: ; : : eax ecx(0) edx ebx esi edi ebp
  mov ebp, [elf.symtab]
  test ebp, ebp
  jz .ret

  .while:
    mov al, [ebp + Sym.info]
    shr al, 4
    cmp al, SymBind.GLOBAL
    jne .next

    mov esi, [ebp + Sym.name]
    add esi, [elf.strtab]
    push esi
    _string '%cs0 '
    call text.writeFmt
    add esp, 4

    .next:
    add ebp, Sym_size
  cmp ebp, [elf.symtab.$]
  jb .while

  .ret:
ret
