global kbd.init, kbd.readCode
extern idt.setGate, pic.unmask, pic.eoiMaster, diag.printMem
%include "core.mac"
%include "text.mac"

section .bss
kbd.buffer: resb 40h
.#: equ $ - kbd.buffer

section .data
kbd.bufRead: dd kbd.buffer
kbd.bufWrite: dd kbd.buffer + 1

kbd.modifier: db 0

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

  .ret:
  call pic.eoiMaster
  popad
  iret

kbd.readCode: ; : al : esi
  mov esi, [kbd.bufRead]
  inc esi
  and esi, ~kbd.buffer.#

  .wait:
    cmp esi, [kbd.bufWrite]
    jne .break
    hlt
  jmp .wait
  .break:

  mov al, [esi]
  mov [kbd.bufRead], esi
  ret
