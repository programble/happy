global mboot.boot, mboot.print
extern fmt.hex, vga.puts
%include "vga.mac"

MAGIC equ 0x1BADB002
FLAGS equ 0x0
CHECKSUM equ -(MAGIC + FLAGS)

section .mboot
dd MAGIC
dd FLAGS
dd CHECKSUM

section .data
mboot.@info: dd 0

section .text
mboot.boot:
  cmp eax, 0x2BADB002
  jne .ret
  mov [mboot.@info], ebx
  .ret: ret

mboot.print: ; edi(buf) : edi(buf) : eax ecx edx ebx esi
  mov eax, [mboot.@info]
  call fmt.hex
  mov ah, vga.GRY | vga.BRI
  call vga.puts
  ret
