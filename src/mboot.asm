global mboot.boot, mboot.print
extern fmt.bin, fmt.hex, tty.print, tty.lf
%include "vga.mac"

MAGIC equ 0x1BADB002
FLAGS equ 0x0
CHECKSUM equ -(MAGIC + FLAGS)

section .mboot
dd MAGIC
dd FLAGS
dd CHECKSUM

struc mboot.info
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
mboot.?info:        db 'mboot.@info       '
mboot.?flags:       db 'flags             '
mboot.?mem_lower:   db 'mem_lower         '
mboot.?mem_upper:   db 'mem_upper         '
mboot.?boot_device: db 'boot_device       '
mboot.?cmdline:     db 'cmdline           '
mboot.?mods_count:  db 'mods_count        '
mboot.?mods_addr:   db 'mods_addr         '
mboot.?syms_num:    db 'syms_num          '
mboot.?syms_size:   db 'syms_size         '
mboot.?syms_addr:   db 'syms_addr         '
mboot.?syms_shndx:  db 'syms_shndx        '
mboot.?mmap_length: db 'mmap_length       '
mboot.?mmap_addr:   db 'mmap_addr         '

section .text
mboot.boot:
  cmp eax, 0x2BADB002
  jne .ret
  mov [mboot.@info], ebx
  .ret: ret

mboot.print:
  mov ebp, [mboot.@info]
  mov ecx, 0x12
  mov esi, mboot.?info
  call tty.print
  mov eax, ebp
  call fmt.hex
  call tty.print
  call tty.lf

  mov ecx, 0x12
  mov esi, mboot.?flags
  call tty.print
  mov eax, [ebp + mboot.info.flags]
  push eax
  call fmt.bin
  call tty.print
  call tty.lf

  .mem:
    test dword [esp], 1
    jz .boot

    mov ecx, 0x12
    mov esi, mboot.?mem_lower
    call tty.print
    mov eax, [ebp + mboot.info.mem_lower]
    call fmt.hex
    call tty.print
    call tty.lf

    mov ecx, 0x12
    mov esi, mboot.?mem_upper
    call tty.print
    mov eax, [ebp + mboot.info.mem_upper]
    call fmt.hex
    call tty.print
    call tty.lf

  .boot:
    test dword [esp], 2
    jz .cmdline
    mov ecx, 0x12
    mov esi, mboot.?boot_device
    call tty.print
    mov eax, [ebp + mboot.info.boot_device]
    call fmt.hex
    call tty.print
    call tty.lf

  .cmdline:
    test dword [esp], 4
    jz .mods
    mov ecx, 0x12
    mov esi, mboot.?cmdline
    call tty.print
    mov ecx, vga.COLS / 2 - 0x13
    mov esi, [ebp + mboot.info.cmdline]
    call tty.print
    call tty.lf

  .mods:
    test dword [esp], 8
    jz .syms

    mov ecx, 0x12
    mov esi, mboot.?mods_count
    call tty.print
    mov eax, [ebp + mboot.info.mods_count]
    call fmt.hex
    call tty.print
    call tty.lf

    mov ecx, 0x12
    mov esi, mboot.?mods_addr
    call tty.print
    mov eax, [ebp + mboot.info.mods_addr]
    call fmt.hex
    call tty.print
    call tty.lf

  .syms:
    test dword [esp], 0x20
    jz .mmap

    mov ecx, 0x12
    mov esi, mboot.?syms_num
    call tty.print
    mov eax, [ebp + mboot.info.syms_num]
    call fmt.hex
    call tty.print
    call tty.lf

    mov ecx, 0x12
    mov esi, mboot.?syms_size
    call tty.print
    mov eax, [ebp + mboot.info.syms_size]
    call fmt.hex
    call tty.print
    call tty.lf

    mov ecx, 0x12
    mov esi, mboot.?syms_addr
    call tty.print
    mov eax, [ebp + mboot.info.syms_addr]
    call fmt.hex
    call tty.print
    call tty.lf

    mov ecx, 0x12
    mov esi, mboot.?syms_shndx
    call tty.print
    mov eax, [ebp + mboot.info.syms_shndx]
    call fmt.hex
    call tty.print
    call tty.lf

  .mmap:
    test dword [esp], 0x40
    jz .drives

    mov ecx, 0x12
    mov esi, mboot.?mmap_length
    call tty.print
    mov eax, [ebp + mboot.info.mmap_length]
    call fmt.hex
    call tty.print
    call tty.lf

    mov ecx, 0x12
    mov esi, mboot.?mmap_addr
    call tty.print
    mov eax, [ebp + mboot.info.mmap_addr]
    call fmt.hex
    call tty.print
    call tty.lf

  .drives:

  add esp, 4
  ret
