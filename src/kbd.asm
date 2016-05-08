global kbd.init
extern idt.setGate, pic.unmask, pic.eoiMaster, diag.printMem
%include "core.mac"
%include "text.mac"

section .bss
kbd.buffer: resb 40h
.#: equ $ - kbd.buffer

section .data
kbd.bufRead: dd kbd.buffer
kbd.bufWrite: dd kbd.buffer + 1

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

  in al, 60h

  mov edi, [kbd.bufWrite]
  cmp edi, [kbd.bufRead]
  je .ret

  stosb
  and edi, ~kbd.buffer.#
  mov [kbd.bufWrite], edi

  mov esi, kbd.buffer
  mov ecx, kbd.buffer.# / 4
  call diag.printMem
  text.writeChar `\n`

  .ret:
  call pic.eoiMaster
  popad
  iret
