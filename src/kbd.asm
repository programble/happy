global kbd.init, kbd.poll, kbd.reset
global kbd.readCode, kbd.readChar, kbd.readLine
global kbd.printBuffers
extern idt.setGate, pic.unmask, pic.eoiMaster, core.halt, diag.printMem
extern qwerty.map, qwerty.map.shift, qwerty.map.ctrl
%include "macro.mac"
%include "core.mac"
%include "write.mac"

Port:
  .DATA: equ 60h
  .COMMAND: equ 64h

Status:
  .OUTPUT: equ 0000_0001b
  .INPUT: equ 0000_0010b
  .SYSTEM: equ 0000_0100b
  .COMMAND: equ 0000_1000b
  .TIMEOUT: equ 0100_0000b
  .PARITY: equ 1000_0000b

Command:
  .RESET: equ 0FEh

ScanCode:
  .SHIFT_LEFT: equ 2Ah
  .SHIFT_RIGHT: equ 36h
  .CTRL_LEFT: equ 1Dh
  .ALT_LEFT: equ 38h
  .F1: equ 3Bh

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

section .bss
kbd.buffer: resb 40h
.#: equ $ - kbd.buffer

kbd.line: resb 100h
.$:

section .data
kbd.bufRead: dd kbd.buffer
kbd.bufWrite: dd kbd.buffer + 1

kbd.modifier: db 0

section .text
kbd.init: ; : : eax edx
  mov eax, 21h
  mov edx, kbd.interrupt
  call idt.setGate
  mov eax, 0000_0000_0000_0010b
  call pic.unmask
ret

kbd.poll: ; : al : ax
  in al, Port.DATA
  mov ah, al
  .loop:
    in al, Port.DATA
  cmp al, ah
  je .loop
ret

kbd.reset: ; : : *
  in al, Port.COMMAND
  test al, Status.INPUT
  jnz kbd.reset
  mov al, Command.RESET
  out Port.COMMAND, al
jmp core.halt

kbd.interrupt: ; : :
  pushad

  in al, Port.DATA
  cmp al, ScanCode.F1
  _panicc e, 'manual panic'

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

kbd.readCode: ; : al(code) : eax
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
  _modifier SHIFT_RIGHT
  _modifier CTRL_LEFT
  _modifier ALT_LEFT
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

kbd.readChar: ; : al(char) : eax
  call kbd.readCode
  test al, al
  js kbd.readChar

  movzx eax, al

  test byte [kbd.modifier], Modifier.CTRL
  jz .ctrlElse
  mov al, [qwerty.map.ctrl + eax]
  jmp .ret
  .ctrlElse:

  test byte [kbd.modifier], Modifier.SHIFT
  jz .shiftElse
  mov al, [qwerty.map.shift + eax]
  jmp .ret
  .shiftElse:

  mov al, [qwerty.map + eax]

  .ret:
  test al, al
  js kbd.readChar
ret

kbd.readLine: ; : ecx(lineLen) esi(line) : eax edx edi
  xor ecx, ecx
  mov edi, kbd.line
  .while:
    call kbd.readChar
    cmp al, `\n`
    je .break

    cmp al, `\b`
    jne .stos
    cmp edi, kbd.line
    je .while
    dec edi
    dec ecx
    jmp .write

    .stos:
    stosb
    inc ecx

    .write:
    _push ecx, edi
    _writeChar
    _pop ecx, edi
  cmp edi, kbd.line.$
  jb .while

  .break:
  push ecx
  _writeChar `\n`
  pop ecx
  mov esi, kbd.line
ret

kbd.printBuffers: ; : : ax ecx(0) edx esi edi
  mov esi, kbd.buffer
  mov ecx, kbd.buffer.# / 4
  call diag.printMem
  _writeChar `\n`

  mov esi, kbd.line
  mov ecx, (kbd.line.$ - kbd.line) / 4
jmp diag.printMem
