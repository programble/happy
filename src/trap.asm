global trap.init
extern idt.int
%include "macro.mac"
%include "core.mac"

section .text
trap.init: ; : : eax edx
  mov eax, 3
  mov edx, trap.bp
  call idt.int
  mov eax, 4
  mov edx, trap.of
  call idt.int
  ret

trap.bp: panic 'breakpoint'
trap.of: panic 'overflow'
