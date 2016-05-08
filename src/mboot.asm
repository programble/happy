global mboot.init, mboot.printInfo
extern elf.init, fmt.bin, fmt.hex, vga.write
%include "macro.mac"
%include "core.mac"
%include "text.mac"

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

section .data
mboot.info: dd 0

section .text
mboot.init: ; eax(magic) ebx(info) : : eax ecx edx(0) ebx
  cmp eax, 2BADB002h
  panicc ne, 'invalid multiboot magic'
  mov [mboot.info], ebx

  test dword [ebx + Info.flags], Flags.SHDR
  jz .ret
  mov ecx, [ebx + Info.shdrNum]
  mov ebx, [ebx + Info.shdrAddr]
  call elf.init

  .ret:
  ret

mboot.printInfo: ; : : eax ecx edx ebp esi edi
  mov ebp, [mboot.info]

  text.write `flags\t\t`
  mov eax, [ebp + Info.flags]
  push eax
  call fmt.bin
  text.write

  %macro _field 2
    text.write %1
    mov eax, [ebp + Info.%2]
    call fmt.hex
    text.write
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
  text.write `\ncmdline\t\t`
  mov esi, [ebp + Info.cmdline]
  text.write

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
  text.write `\nbootLoaderName\t`
  mov esi, [ebp + Info.bootLoaderName]
  text.write

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
