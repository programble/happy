global elf.init, elf.symbolString

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
elf.init: ; ecx(shdr_num) ebx(shdr_addr) : : eax ecx ebx
  cmp dword [ebx + Shdr.type], ShType.SYMTAB
  jne .strtab
  mov eax, [ebx + Shdr.addr]
  mov [elf.symtab], eax
  add eax, [ebx + Shdr.size]
  mov [elf.symtab.$], eax

  .strtab:
  cmp dword [ebx + Shdr.type], ShType.STRTAB
  jne .next
  mov eax, [ebx + Shdr.addr]
  mov [elf.strtab], eax

  .next:
  add ebx, Shdr_size
  loop elf.init
  ret

elf.symbolString: ; eax(val) : ecx(offset) esi(name) : eax
  cmp dword [elf.symtab], 0
  je .null

  xor ecx, ecx
  .whileOffset:
    mov esi, [elf.symtab]
    .whileSym:
      cmp dword [esi + Sym.value], eax
      je .break
      add esi, Sym_size
    cmp esi, [elf.symtab.$]
    jb .whileSym

    dec eax
    inc ecx
  cmp ecx, 100h
  jne .whileOffset

  .null:
  xor esi, esi
  ret

  .break:
  mov esi, [esi + Sym.name]
  add esi, [elf.strtab]
  ret
