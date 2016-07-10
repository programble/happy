global idt.init, idt.setGate
extern gdt.table, gdt.table.code
%include "core.mac"

Gate:
  .TASK: equ 0000_0101b
  .INTERRUPT: equ 0000_0110b
  .TRAP: equ 0000_0111b

Flags:
  .D: equ 0000_1000b
  .DPL0: equ 0000_0000b
  .DPL1: equ 0010_0000b
  .DPL2: equ 0100_0000b
  .DPL3: equ 0110_0000b
  .P: equ 1000_0000b

struc GateDescriptor
  .offsetLow: resw 1
  .segmentSelector: resw 1
  .zero: resb 1
  .flags: resb 1
  .offsetHigh: resw 1
endstruc

struc Idt
  .limit: resw 1
  .base: resd 1
endstruc

section .data
idt.table:
  times 256 * GateDescriptor_size db 0
  .#: equ $ - idt.table
idt.idt:
  istruc Idt
    at Idt.limit, dw idt.table.# - 1
    at Idt.base, dd idt.table
  iend

section .text
idt.init: ; : : eax edx
  %macro _unhandled 2
    mov eax, %1
    mov edx, idt.unhandled.%2
    call idt.setGate
  %endmacro

  _unhandled 0, DE
  _unhandled 1, DB
  _unhandled 3, BP
  _unhandled 4, OF
  _unhandled 5, BR
  _unhandled 6, UD
  _unhandled 7, NM
  _unhandled 8, DF
  _unhandled 0Ah, TS
  _unhandled 0Bh, NP
  _unhandled 0Ch, SS
  _unhandled 0Dh, GP
  _unhandled 0Eh, PF
  _unhandled 10h, MF
  _unhandled 11h, AC
  _unhandled 12h, MC
  _unhandled 13h, XM
  _unhandled 14h, VE

  lidt [idt.idt]
ret

idt.setGate: ; eax(vector) edx(handler) : : eax edx
  lea eax, [idt.table + eax * GateDescriptor_size]
  and byte [eax + GateDescriptor.flags], ~Flags.P
  mov [eax + GateDescriptor.offsetLow], dx
  shr edx, 10h
  mov [eax + GateDescriptor.offsetHigh], dx
  mov [eax + GateDescriptor.segmentSelector], cs
  mov byte [eax + GateDescriptor.flags], Gate.INTERRUPT | Flags.D | Flags.DPL0 | Flags.P
ret

idt.unhandled:
  .DE: _panic 'divide error'
  .DB: _panic 'debug exception'
  .BP: _panic 'breakpoint'
  .OF: _panic 'overflow'
  .BR: _panic 'BOUND range exceeded'
  .UD: _panic 'invalid opcode'
  .NM: _panic 'device not available'
  .DF: _panic 'double fault'
  .TS: _panic 'invalid TSS'
  .NP: _panic 'segment not present'
  .SS: _panic 'stack-segment fault'
  .GP: _panic 'general protection'
  .PF: _panic 'page fault'
  .MF: _panic 'x87 FPU floating-point error'
  .AC: _panic 'alignment check'
  .MC: _panic 'machine check'
  .XM: _panic 'SIMD floating-point exception'
  .VE: _panic 'virtualization exception'
