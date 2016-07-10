global com.init, com.writeChar, com.write

; TODO: Actually read the UART manual.

Port.COM1:
  .DATA: equ 3F8h
  .FIFO: equ 3FAh
  .LINE: equ 3FBh
  .MODEM: equ 3FCh
  .STATUS: equ 3FDh

Line:
  .DL0: equ 0000_0000b
  .DL1: equ 0000_0001b
  .DL2: equ 0000_0010b
  .DL3: equ 0000_0011b
  .S: equ 0000_0100b
  .PRTY0: equ 0000_0000b
  .PRTY1: equ 0000_1000b
  .PRTY2: equ 0001_0000b
  .PRTY3: equ 0001_1000b
  .PRTY4: equ 0010_0000b
  .PRTY5: equ 0010_1000b
  .PRTY6: equ 0011_0000b
  .PRTY7: equ 0011_1000b
  .B: equ 0100_0000b
  .D: equ 1000_0000b

Fifo:
  .E: equ 0000_0001b
  .CLR: equ 0000_0010b
  .CLT: equ 0000_0100b
  .DMA: equ 0000_1000b
  .BS: equ 0010_0000b
  .LVL0: equ 0000_0000b
  .LVL1: equ 0100_0000b
  .LVL2: equ 1000_0000b
  .LVL3: equ 1100_0000b

Modem:
  .DTR: equ 0000_0001b
  .RTS: equ 0000_0010b
  .AO1: equ 0000_0100b
  .AO2: equ 0000_1000b
  .LB: equ 0001_0000b
  .AF: equ 0010_0000b

Status:
  .READY: equ 0010_0000b

section .text
com.init: ; : : al dx
  _out Port.COM1.LINE, Line.DL3
  _out Port.COM1.FIFO, Fifo.E | Fifo.CLT | Fifo.BS | Fifo.LVL3
  _out Port.COM1.MODEM, Modem.DTR | Modem.RTS
ret

com.writeChar: ; al(char) : : ah dx
  mov ah, al

  mov dx, Port.COM1.STATUS
  .while:
    in al, dx
  test al, Status.READY
  jz .while

  _out Port.COM1.DATA, ah
ret

; TODO: Avoid overflowing the buffer?
com.write: ; ecx(strLen) esi(str) : : al ecx(0) dx esi
  mov dx, Port.COM1.STATUS
  .while:
    in al, dx
  test al, Status.READY
  jz .while

  mov dx, Port.COM1.DATA
  rep outsb
ret
