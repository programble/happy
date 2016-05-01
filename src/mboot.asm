global mboot.boot, mboot.print
extern fmt.bin, fmt.hex, vga.print
%include "macro.mac"
%include "vga.mac"

Flags.MEM equ 1
Flags.BOOT_DEVICE equ 2
Flags.CMDLINE equ 4
Flags.MODS equ 8
Flags.SHDR equ 0x20
Flags.MMAP equ 0x40
Flags.DRIVES equ 0x80
Flags.CONFIG_TABLE equ 0x100
Flags.BOOT_LOADER_NAME equ 0x200
Flags.APM_TABLE equ 0x400
Flags.VBE equ 0x800

struc Info
  .flags: resd 1
  .mem_lower: resd 1
  .mem_upper: resd 1
  .boot_device: resd 1
  .cmdline: resd 1
  .mods_count: resd 1
  .mods_addr: resd 1
  .shdr_num: resd 1
  .shdr_size: resd 1
  .shdr_addr: resd 1
  .shdr_shndx: resd 1
  .mmap_length: resd 1
  .mmap_addr: resd 1
  .drives_length: resd 1
  .drives_addr: resd 1
  .config_table: resd 1
  .boot_loader_name: resd 1
  .apm_table: resd 1
  .vbe_control_info: resd 1
  .vbe_mode_info: resd 1
  .vbe_mode: resd 1
  .vbe_interface_seg: resd 1
  .vbe_interface_off: resd 1
  .vbe_interface_len: resd 1
endstruc

section .data
mboot.@info: dd 0

section .text
mboot.boot:
  cmp eax, 0x2BADB002
  jne .ret
  mov [mboot.@info], ebx
  .ret: ret

%macro _print 2
  string %1
  call vga.print
  mov eax, [ebp + %2]
  call fmt.hex
  call vga.print
%endmacro

mboot.print: ; : : eax ecx edx ebx ebp esi edi
  mov ebp, [mboot.@info]
  string `mboot.?info\t\t`
  call vga.print
  mov eax, ebp
  call fmt.hex
  call vga.print

  string `\nflags\t\t\t`
  call vga.print
  mov eax, [ebp + Info.flags]
  push eax
  call fmt.bin
  call vga.print

  .mem:
  test dword [esp], Flags.MEM
  jz .boot
  _print `\nmem_lower\t\t`, Info.mem_lower
  _print `\nmem_upper\t\t`, Info.mem_upper

  .boot:
  test dword [esp], Flags.BOOT_DEVICE
  jz .cmdline
  _print `\nboot_device\t\t`, Info.boot_device

  .cmdline:
  test dword [esp], Flags.CMDLINE
  jz .mods
  string `\ncmdline\t\t\t`
  call vga.print
  mov esi, [ebp + Info.cmdline]
  call vga.print

  .mods:
  test dword [esp], Flags.MODS
  jz .shdr
  _print `\nmods_count\t\t`, Info.mods_count
  _print `\nmods_addr\t\t`, Info.mods_addr

  .shdr:
  test dword [esp], Flags.SHDR
  jz .mmap
  _print `\nshdr_num\t\t`, Info.shdr_num
  _print `\nshdr_size\t\t`, Info.shdr_size
  _print `\nshdr_addr\t\t`, Info.shdr_addr
  _print `\nshdr_shndx\t\t`, Info.shdr_shndx

  .mmap:
  test dword [esp], Flags.MMAP
  jz .drives
  _print `\nmmap_length\t\t`, Info.mmap_length
  _print `\nmmap_addr\t\t`, Info.mmap_addr

  .drives:
  test dword [esp], Flags.DRIVES
  jz .config
  _print `\ndrives_length\t\t`, Info.drives_length
  _print `\ndrives_addr\t\t`, Info.drives_addr

  .config:
  test dword [esp], Flags.CONFIG_TABLE
  jz .bootloader
  _print `\nconfig_table\t\t`, Info.config_table

  .bootloader:
  test dword [esp], Flags.BOOT_LOADER_NAME
  jz .apm
  string `\nboot_loader_name\t`
  call vga.print
  mov esi, [ebp + Info.boot_loader_name]
  call vga.print

  .apm:
  test dword [esp], Flags.APM_TABLE
  jz .vbe
  _print `\napm_table\t\t`, Info.apm_table

  .vbe:
  test dword [esp], Flags.VBE
  jz .ret
  _print `\nvbe_control_info\t`, Info.vbe_control_info
  _print `\nvbe_mode_info\t`, Info.vbe_mode_info
  _print `\nvbe_mode\t\t`, Info.vbe_mode
  _print `\nvbe_interface_seg\t`, Info.vbe_interface_seg
  _print `\nvbe_interface_off\t`, Info.vbe_interface_off
  _print `\nvbe_interface_len\t`, Info.vbe_interface_len

  .ret:
  add esp, 4
  ret
