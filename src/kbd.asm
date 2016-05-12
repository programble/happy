global kbd.init, kbd.readCode, kbd.readChar, kbd.readLine, kbd.printBuffers
extern idt.setGate, pic.unmask, pic.eoiMaster, diag.printMem
extern qwerty.map, qwerty.map.shift, qwerty.map.ctrl
%include "macro.mac"
%include "text.mac"

ScanCode:
  .SHIFT_LEFT: equ 2Ah
  .SHIFT_RIGHT: equ 36h
  .CTRL_LEFT: equ 1Dh
  .ALT_LEFT: equ 38h

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

kbd.readChar: ; : al : eax
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

kbd.readLine: ; : esi : eax ecx edx edi
  mov edi, kbd.line
  .while:
    call kbd.readChar
    mpush eax, edi
    text.writeChar
    mpop eax, edi
    cmp al, `\n`
    je .break
    stosb
  cmp edi, kbd.line.$ - 1
  jb .while

  .break:
  mov byte [edi], 0
  mov esi, kbd.line
  ret

kbd.printBuffers: ; : : eax ecx(0) edx esi edi
  mov esi, kbd.buffer
  mov ecx, kbd.buffer.# / 4
  call diag.printMem

  mov esi, kbd.line
  mov ecx, (kbd.line.$ - kbd.line) / 4
  jmp diag.printMem
