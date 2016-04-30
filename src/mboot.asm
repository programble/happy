global mboot.boot, mboot.print
extern fmt.bin, fmt.hex, vga.print
%include "vga.mac"

mboot.MAGIC equ 0x1BADB002
mboot.FLAGS equ 0x0
mboot.CHECKSUM equ -(mboot.MAGIC + mboot.FLAGS)

section .mboot
dd mboot.MAGIC
dd mboot.FLAGS
dd mboot.CHECKSUM

struc mboot.Info
  .flags: resd 1
  .mem_lower: resd 1
  .mem_upper: resd 1
  .boot_device: resd 1
  .cmdline: resd 1
  .mods_count: resd 1
  .mods_addr: resd 1
  .syms_num: resd 1
  .syms_size: resd 1
  .syms_addr: resd 1
  .syms_shndx: resd 1
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
mboot.?syms_num: db `\nsyms_num\t\t`, 0
mboot.?syms_size: db `\nsyms_size\t\t`, 0
mboot.?syms_addr: db `\nsyms_addr\t\t`, 0
mboot.?syms_shndx: db `\nsyms_shndx\t\t`, 0
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

%macro mboot._print 2
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
  mov eax, [ebp + mboot.Info.flags]
  push eax
  call fmt.bin
  call vga.print

  .mem:
  test dword [esp], 1
  jz .boot
  mboot._print mboot.?mem_lower, mboot.Info.mem_lower
  mboot._print mboot.?mem_upper, mboot.Info.mem_upper

  .boot:
  test dword [esp], 2
  jz .cmdline
  mboot._print mboot.?boot_device, mboot.Info.boot_device

  .cmdline:
  test dword [esp], 4
  jz .mods
  mov esi, mboot.?cmdline
  call vga.print
  mov esi, [ebp + mboot.Info.cmdline]
  call vga.print

  .mods:
  test dword [esp], 8
  jz .syms
  mboot._print mboot.?mods_count, mboot.Info.mods_count
  mboot._print mboot.?mods_addr, mboot.Info.mods_addr

  .syms:
  test dword [esp], 0x20
  jz .mmap
  mboot._print mboot.?syms_num, mboot.Info.syms_num
  mboot._print mboot.?syms_size, mboot.Info.syms_size
  mboot._print mboot.?syms_addr, mboot.Info.syms_addr
  mboot._print mboot.?syms_shndx, mboot.Info.syms_shndx

  .mmap:
  test dword [esp], 0x40
  jz .drives
  mboot._print mboot.?mmap_length, mboot.Info.mmap_length
  mboot._print mboot.?mmap_addr, mboot.Info.mmap_addr

  .drives:
  test dword [esp], 0x80
  jz .config
  mboot._print mboot.?drives_length, mboot.Info.drives_length
  mboot._print mboot.?drives_addr, mboot.Info.drives_addr

  .config:
  test dword [esp], 0x100
  jz .bootloader
  mboot._print mboot.?config_table, mboot.Info.config_table

  .bootloader:
  test dword [esp], 0x200
  jz .apm
  mov esi, mboot.?boot_loader_name
  call vga.print
  mov esi, [ebp + mboot.Info.boot_loader_name]
  call vga.print

  .apm:
  test dword [esp], 0x400
  jz .vbe
  mboot._print mboot.?apm_table, mboot.Info.apm_table

  .vbe:
  test dword [esp], 0x800
  jz .ret
  mboot._print mboot.?vbe_control_info, mboot.Info.vbe_control_info
  mboot._print mboot.?vbe_mode_info, mboot.Info.vbe_mode_info
  mboot._print mboot.?vbe_mode, mboot.Info.vbe_mode
  mboot._print mboot.?vbe_interface_seg, mboot.Info.vbe_interface_seg
  mboot._print mboot.?vbe_interface_off, mboot.Info.vbe_interface_off
  mboot._print mboot.?vbe_interface_len, mboot.Info.vbe_interface_len

  .ret:
  add esp, 4
  ret
