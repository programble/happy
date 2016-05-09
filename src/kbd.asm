global kbd.init, kbd.readCode
extern idt.setGate, pic.unmask, pic.eoiMaster, diag.printMem
%include "macro.mac"
%include "core.mac"
%include "text.mac"

ScanCode:
  .SHIFT_LEFT: equ 2Ah
  .CTRL_LEFT: equ 1Dh

Modifier:
  .SHIFT_LEFT: equ 0000_0001b
  .SHIFT_RIGHT: equ 0000_0010b
  .SHIFT: equ 0000_0011b
  .CTRL_LEFT: equ 0000_0100b
  .CTRL_RIGHT: equ 0000_1000b
  .CTRL: equ 0000_1100b
  .ALT_LEFT: equ 0001_0000b
  .ALT_RIGHT: equ 0010_0000b
  .ALT: equ 0011_0000b
  .CMD_LEFT: equ 0100_0000b
  .CMD_RIGHT: equ 1000_0000b
  .CMD: equ 1100_0000b

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

kbd.readCode: ; : al : eax
  mov eax, [kbd.bufRead]
  inc eax
  and eax, ~kbd.buffer.#

  .waitWhile:
    cmp eax, [kbd.bufWrite]
    jne .waitBreak
    hlt
  jmp .waitWhile
  .waitBreak:

  mov [kbd.bufRead], eax
  mov al, [eax]
  mov ah, al
  and ah, 0111_1111b

  %macro _modifier 1
    cmp ah, ScanCode.%1
    jne %%modifierElse
    mov ah, Modifier.%1
    jmp .setModifier
    %%modifierElse:
  %endmacro

  _modifier SHIFT_LEFT
  _modifier CTRL_LEFT
  ret

  .setModifier:
  test al, al
  js .unsetModifier
  or [kbd.modifier], ah
  ret

  .unsetModifier:
  not ah
  and [kbd.modifier], ah
  ret
