global kbd.init
extern idt.setGate, pic.unmask, pic.eoiMaster, diag.printMem
%include "core.mac"
%include "text.mac"

section .bss
kbd.buffer: resb 100h
.$:

section .data
kbd.bufRead: dd kbd.buffer
kbd.bufWrite: dd kbd.buffer

section .text
kbd.init: ; : : eax edx
  mov eax, 21h
  mov edx, kbd.interrupt
  call idt.setGate
  mov eax, 0000_0000_0000_00010b
  call pic.unmask
  ret

kbd.interrupt: ; : :
  pushad

  mov edi, [kbd.bufWrite]
  in al, 60h
  stosb

  cmp edi, kbd.buffer.$
  jb .else
  mov edi, kbd.buffer
  .else:
  mov [kbd.bufWrite], edi

  mov esi, kbd.buffer
  mov ecx, 40h
  call diag.printMem
  text.writeChar `\n`

  call pic.eoiMaster
  popad
  iret
