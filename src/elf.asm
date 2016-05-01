global elf.init, elf.sym
%include "macro.mac"

ShType.NULL equ 0
ShType.PROGBITS equ 1
ShType.SYMTAB equ 2
ShType.STRTAB equ 3
ShType.RELA equ 4
ShType.HASH equ 5
ShType.DYNAMIC equ 6
ShType.NOTE equ 7
ShType.NOBITS equ 8
ShType.REL equ 9
ShType.SHLIB equ 0xA
ShType.DYNSYM equ 0xB
ShType.LOPROC equ 0x70000000
ShType.HIPROC equ 0x7FFFFFFF
ShType.LOUSER equ 0x80000000
ShType.HIUSER equ 0xFFFFFFFF

ShFlags.WRITE equ 1
ShFlags.ALLOC equ 2
ShFlags.EXECINSTR equ 4
ShFlags.MASKPROC equ 0xF0000000

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

SymType.NOTYPE equ 0
SymType.OBJECT equ 1
SymType.FUNC equ 2
SymType.SECTION equ 3
SymType.FILE equ 4
SymType.LOPROC equ 0xD
SymType.HIPROC equ 0xF

SymBind.LOCAL equ 0
SymBind.GLOBAL equ 1
SymBind.WEAK equ 2
SymBind.LOPROC equ 0xD
SymBind.HIPROC equ 0xF

struc Sym
  .name: resd 1
  .value: resd 1
  .size: resd 1
  .info: resb 1
  .other: resb 1
  .shndx: resw 1
endstruc

section .data
elf.@symtab: dd 0
elf.$symtab: dd 0
elf.@strtab: dd 0

section .text
elf.init: ; ecx(shdr_num) ebx(shdr_addr) : : eax ecx ebx
  .for:
    cmp dword [ebx + Shdr.type], ShType.SYMTAB
    jne .strtab
    mov eax, [ebx + Shdr.addr]
    mov [elf.@symtab], eax
    add eax, [ebx + Shdr.size]
    mov [elf.$symtab], eax
    .strtab:
    cmp dword [ebx + Shdr.type], ShType.STRTAB
    jne .next
    mov eax, [ebx + Shdr.addr]
    mov [elf.@strtab], eax
    .next:
    add ebx, Shdr_size
  loop .for
  ret

elf.sym: ; eax(val) : ecx(offset) esi(name) : eax
  cmp dword [elf.$symtab], 0
  je .null
  .owhile:
    mov ebx, [elf.@symtab]
    .swhile:
      cmp dword [ebx + Sym.value], eax
      je .break
      add ebx, Sym_size
    cmp ebx, [elf.$symtab]
    jb .swhile
    dec eax
    inc ecx
  cmp ecx, 0x100
  je .null
  jmp .owhile
  .null:
  xor esi, esi
  ret
  .break:
  mov esi, [ebx + Sym.name]
  add esi, [elf.@strtab]
  ret
