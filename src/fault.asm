global fault.init
extern idt.int
%include "macro.mac"

%macro _fault 2
  mov eax, %1
  mov edx, fault.%2
  call idt.int
%endmacro

section .text
fault.init: ; : : eax edx
  _fault 0x00, de
  _fault 0x01, db
  _fault 0x05, br
  _fault 0x06, ud
  _fault 0x07, nm
  _fault 0x0A, ts
  _fault 0x0B, np
  _fault 0x0C, ss
  _fault 0x0D, gp
  _fault 0x0E, pf
  _fault 0x10, mf
  _fault 0x11, ac
  _fault 0x13, xm
  _fault 0x14, ve
  ret

fault.de: panic 'divide error'
fault.db: panic 'debug exception'
fault.br: panic 'BOUND range exceeded'
fault.ud: panic 'invalid opcode'
fault.nm: panic 'device not available'
fault.ts: panic 'invalid TSS'
fault.np: panic 'segment not present'
fault.ss: panic 'stack-segment fault'
fault.gp: panic 'general protection'
fault.pf: panic 'page fault'
fault.mf: panic 'x87 FPU floating-point error'
fault.ac: panic 'alignment check'
fault.xm: panic 'SIMD floating-point exception'
fault.ve: panic 'virtualization exception'
