global mboot.init, mboot.printInfo, mboot.printMmap
extern elf.init, str.fromCStr, text.write, text.writeFmt
%include "core.mac"

HeaderFlags:
  .PAGE_ALIGN_MODS: equ 0000_0001b
  .MEM: equ 0000_0010b
  .VBE: equ 0000_0100b

HEADER:
  .MAGIC: equ 1BADB002h
  .FLAGS: equ 0
  .CHECKSUM: equ -(.MAGIC + .FLAGS)

Flags:
  .MEM: equ 1
  .BOOT_DEVICE: equ 2
  .CMDLINE: equ 4
  .MODS: equ 8
  .SYMS: equ 10h
  .SHDR: equ 20h
  .MMAP: equ 40h
  .DRIVES: equ 80h
  .CONFIG_TABLE: equ 100h
  .BOOT_LOADER_NAME: equ 200h
  .APM_TABLE: equ 400h
  .VBE: equ 800h

struc Info
  .flags: resd 1
  .memLower: resd 1
  .memUpper: resd 1
  .bootDevice: resd 1
  .cmdline: resd 1
  .modsCount: resd 1
  .modsAddr: resd 1
  .shdrNum: resd 1
  .shdrSize: resd 1
  .shdrAddr: resd 1
  .shdrShndx: resd 1
  .mmapLength: resd 1
  .mmapAddr: resd 1
  .drivesLength: resd 1
  .drivesAddr: resd 1
  .configTable: resd 1
  .bootLoaderName: resd 1
  .apmTable: resd 1
  .vbeControlInfo: resd 1
  .vbeModeInfo: resd 1
  .vbeMode: resd 1
  .vbeInterfaceSeg: resd 1
  .vbeInterfaceOff: resd 1
  .vbeInterfaceLen: resd 1
endstruc

struc Mmap
  .size: resd 1
  .baseAddr: resq 1
  .length: resq 1
  .type: resd 1
endstruc

section .mboot
dd HEADER.MAGIC
dd HEADER.FLAGS
dd HEADER.CHECKSUM

section .data
mboot.info: dd 0

section .text
mboot.init: ; eax(magic) ebx(info) : : eax ecx edx(0) ebx
  cmp eax, 2BADB002h
  _panicc ne, 'invalid multiboot magic'
  mov [mboot.info], ebx

  test dword [ebx + Info.flags], Flags.SHDR
  jnz .elf
  ret

  .elf:
  mov ecx, [ebx + Info.shdrNum]
  mov ebx, [ebx + Info.shdrAddr]
jmp elf.init

mboot.printInfo: ; : : eax ecx(0) edx ebx ebp esi edi
  mov ebp, [mboot.info]

  _string `flags\t\t%bd0`
  mov eax, [ebp + Info.flags]
  push eax
  call text.writeFmt

  %macro _field 2
    _string {%1, '%hd0'}
    push dword [ebp + Info.%2]
    call text.writeFmt
    add esp, 4
  %endmacro

  .mem:
  test dword [esp], Flags.MEM
  jz .bootDevice
  _field `\nmemLower\t`, memLower
  _field `\nmemUpper\t`, memUpper

  .bootDevice:
  test dword [esp], Flags.BOOT_DEVICE
  jz .cmdline
  _field `\nbootDevice\t`, bootDevice

  .cmdline:
  test dword [esp], Flags.CMDLINE
  jz .mods
  _string `\ncmdline\t\t`
  call text.write
  mov esi, [ebp + Info.cmdline]
  call str.fromCStr
  call text.write

  .mods:
  test dword [esp], Flags.MODS
  jz .shdr
  _field `\nmodsCount\t`, modsCount
  _field `\nmodsAddr\t`, modsAddr

  .shdr:
  test dword [esp], Flags.SHDR
  jz .mmap
  _field `\nshdrNum\t\t`, shdrNum
  _field `\nshdrSize\t`, shdrSize
  _field `\nshdrAddr\t`, shdrAddr
  _field `\nshdrShndx\t`, shdrShndx

  .mmap:
  test dword [esp], Flags.MMAP
  jz .drives
  _field `\nmmapLength\t`, mmapLength
  _field `\nmmapAddr\t`, mmapAddr

  .drives:
  test dword [esp], Flags.DRIVES
  jz .configTable
  _field `\ndrivesLength\t`, drivesLength
  _field `\ndrivesAddr\t`, drivesAddr

  .configTable:
  test dword [esp], Flags.CONFIG_TABLE
  jz .bootLoaderName
  _field `\nconfigTable\t`, configTable

  .bootLoaderName:
  test dword [esp], Flags.BOOT_LOADER_NAME
  jz .apmTable
  _string `\nbootLoaderName\t`
  call text.write
  mov esi, [ebp + Info.bootLoaderName]
  call str.fromCStr
  call text.write

  .apmTable:
  test dword [esp], Flags.APM_TABLE
  jz .vbe
  _field `\napmTable\t`, apmTable

  .vbe:
  test dword [esp], Flags.VBE
  jz .ret
  _field `\nvbeControlInfo\t`, vbeControlInfo
  _field `\nvbeModeInfo\t`, vbeModeInfo
  _field `\nvbeMode\t\t`, vbeMode
  _field `\nvbeInterfaceSeg\t`, vbeInterfaceSeg
  _field `\nvbeInterfaceOff\t`, vbeInterfaceOff
  _field `\nvbeInterfaceLen\t`, vbeInterfaceLen

  .ret:
  add esp, 4
ret

mboot.printMmap: ; : : eax ecx(0) edx ebx ebp esi edi
  mov ebp, [mboot.info]
  test dword [ebp + Info.flags], Flags.MMAP
  jz .ret

  mov eax, [ebp + Info.mmapAddr]
  add eax, [ebp + Info.mmapLength]
  push eax
  mov ebp, [ebp + Info.mmapAddr]

  _string `baseAddr\t\tlength\t\t\ttype\n`
  call text.write
  .while:
    _string `%hd0%hd1\t%hd2%hd3\t%hd4\n`
    _rpush dword [ebp + Mmap.baseAddr + 4], \
      dword [ebp + Mmap.baseAddr], \
      dword [ebp + Mmap.length + 4], \
      dword [ebp + Mmap.length], \
      dword [ebp + Mmap.type]
    call text.writeFmt
    add esp, 14h
    add ebp, [ebp + Mmap.size]
    add ebp, 4
  cmp ebp, [esp]
  jb .while

  add esp, 4

  .ret:
ret
