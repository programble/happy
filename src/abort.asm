global abort.init
extern idt.int
%include "macro.mac"

section .text
abort.init:
  mov eax, 8
  mov edx, abort.df
  call idt.int
  mov eax, 0x12
  mov edx, abort.mc
  call idt.int
  ret

abort.df: panic 'double fault'
abort.mc: panic 'machine check'