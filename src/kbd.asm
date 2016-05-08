global kbd.init
extern idt.setGate, pic.unmask, pic.eoiMaster, fmt.hex
%include "core.mac"
%include "text.mac"

INTERRUPT: equ 21h
PIC_MASK: equ 0000_0000_0000_00010b
Port.DATA: equ 60h

section .text
kbd.init: ; : : eax edx
  mov eax, INTERRUPT
  mov edx, kbd.interrupt
  call idt.setGate
  mov eax, PIC_MASK
  call pic.unmask
  ret

kbd.interrupt: ; : :
  pushad

  xor eax, eax
  in al, Port.DATA
  call fmt.hex
  add esi, 6
  text.write
  text.writeChar ' '

  call pic.eoiMaster
  popad
  iret
