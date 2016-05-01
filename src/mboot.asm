global mboot.boot, mboot.print
extern fmt.bin, fmt.hex, vga.print
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

section .rodata
mboot.?info: db `mboot.@info\t\t`, 0
mboot.?flags: db `\nflags\t\t\t`, 0
mboot.?mem_lower: db `\nmem_lower\t\t`, 0
mboot.?mem_upper: db `\nmem_upper\t\t`, 0
mboot.?boot_device: db `\nboot_device\t\t`, 0
mboot.?cmdline: db `\ncmdline\t\t\t`, 0
mboot.?mods_count: db `\nmods_count\t\t`, 0
mboot.?mods_addr: db `\nmods_addr\t\t`, 0
mboot.?shdr_num: db `\nshdr_num\t\t`, 0
mboot.?shdr_size: db `\nshdr_size\t\t`, 0
mboot.?shdr_addr: db `\nshdr_addr\t\t`, 0
mboot.?shdr_shndx: db `\nshdr_shndx\t\t`, 0
mboot.?mmap_length: db `\nmmap_length\t\t`, 0
mboot.?mmap_addr: db `\nmmap_addr\t\t`, 0
mboot.?drives_length: db `\ndrives_length\t\t`, 0
mboot.?drives_addr: db `\ndrives_addr\t\t`, 0
mboot.?config_table: db `\nconfig_table\t\t`, 0
mboot.?boot_loader_name: db `\nboot_loader_name\t`, 0
mboot.?apm_table: db `\napm_table\t\t`, 0
mboot.?vbe_control_info: db `\nvbe_control_info\t`, 0
mboot.?vbe_mode_info: db `\nvbe_mode_info\t`, 0
mboot.?vbe_mode: db `\nvbe_mode\t\t`, 0
mboot.?vbe_interface_seg: db `\nvbe_interface_seg\t`, 0
mboot.?vbe_interface_off: db `\nvbe_interface_off\t`, 0
mboot.?vbe_interface_len: db `\nvbe_interface_len\t`, 0

section .text
mboot.boot:
  cmp eax, 0x2BADB002
  jne .ret
  mov [mboot.@info], ebx
  .ret: ret

%macro _print 2
  mov esi, %1
  call vga.print
  mov eax, [ebp + %2]
  call fmt.hex
  call vga.print
%endmacro

mboot.print: ; : : eax ecx edx ebx esi edi
  mov ebp, [mboot.@info]
  mov esi, mboot.?info
  call vga.print
  mov eax, ebp
  call fmt.hex
  call vga.print

  mov esi, mboot.?flags
  call vga.print
  mov eax, [ebp + Info.flags]
  push eax
  call fmt.bin
  call vga.print

  .mem:
  test dword [esp], Flags.MEM
  jz .boot
  _print mboot.?mem_lower, Info.mem_lower
  _print mboot.?mem_upper, Info.mem_upper

  .boot:
  test dword [esp], Flags.BOOT_DEVICE
  jz .cmdline
  _print mboot.?boot_device, Info.boot_device

  .cmdline:
  test dword [esp], Flags.CMDLINE
  jz .mods
  mov esi, mboot.?cmdline
  call vga.print
  mov esi, [ebp + Info.cmdline]
  call vga.print

  .mods:
  test dword [esp], Flags.MODS
  jz .shdr
  _print mboot.?mods_count, Info.mods_count
  _print mboot.?mods_addr, Info.mods_addr

  .shdr:
  test dword [esp], Flags.SHDR
  jz .mmap
  _print mboot.?shdr_num, Info.shdr_num
  _print mboot.?shdr_size, Info.shdr_size
  _print mboot.?shdr_addr, Info.shdr_addr
  _print mboot.?shdr_shndx, Info.shdr_shndx

  .mmap:
  test dword [esp], Flags.MMAP
  jz .drives
  _print mboot.?mmap_length, Info.mmap_length
  _print mboot.?mmap_addr, Info.mmap_addr

  .drives:
  test dword [esp], Flags.DRIVES
  jz .config
  _print mboot.?drives_length, Info.drives_length
  _print mboot.?drives_addr, Info.drives_addr

  .config:
  test dword [esp], Flags.CONFIG_TABLE
  jz .bootloader
  _print mboot.?config_table, Info.config_table

  .bootloader:
  test dword [esp], Flags.BOOT_LOADER_NAME
  jz .apm
  mov esi, mboot.?boot_loader_name
  call vga.print
  mov esi, [ebp + Info.boot_loader_name]
  call vga.print

  .apm:
  test dword [esp], Flags.APM_TABLE
  jz .vbe
  _print mboot.?apm_table, Info.apm_table

  .vbe:
  test dword [esp], Flags.VBE
  jz .ret
  _print mboot.?vbe_control_info, Info.vbe_control_info
  _print mboot.?vbe_mode_info, Info.vbe_mode_info
  _print mboot.?vbe_mode, Info.vbe_mode
  _print mboot.?vbe_interface_seg, Info.vbe_interface_seg
  _print mboot.?vbe_interface_off, Info.vbe_interface_off
  _print mboot.?vbe_interface_len, Info.vbe_interface_len

  .ret:
  add esp, 4
  ret
