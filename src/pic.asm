global pic.init, pic.mask, pic.unmask

Icw1:
  .ICW1: equ 0001_0000b
  .IC4: equ 0000_0001b
  .SNGL: equ 0000_0010b
  .ADI: equ 0000_0100b
  .LTIM: equ 0000_1000b

Icw4:
  .MUPM: equ 0000_0001b
  .AEOI: equ 0000_0010b
  .MS: equ 0000_0100b
  .BUF: equ 0000_1000b
  .SFNM: equ 0001_0000b

Port.MASTER:
  .COMMAND: equ 20h
  .DATA: equ 21h

Port.SLAVE:
  .COMMAND: equ 0A0h
  .DATA: equ 0A1h

section .text
pic.init: ; : : al
  mov al, Icw1.ICW1 | Icw1.IC4
  out Port.MASTER.COMMAND, al
  out Port.SLAVE.COMMAND, al

  mov al, 20h
  out Port.MASTER.DATA, al
  mov al, 28h
  out Port.SLAVE.DATA, al

  mov al, 0000_0100b
  out Port.MASTER.DATA, al
  mov al, 0000_0010b
  out Port.SLAVE.DATA, al

  mov al, Icw4.MUPM | Icw4.AEOI
  out Port.MASTER.DATA, al
  out Port.SLAVE.DATA, al

  mov al, 1111_1111b
  out Port.MASTER.DATA, al
  out Port.SLAVE.DATA, al

  ret

pic.mask: ; ax : : dx
  mov dx, ax
  in al, Port.SLAVE.DATA
  mov ah, al
  in al, Port.MASTER.DATA
  or ax, dx
  out Port.MASTER.DATA, al
  mov al, ah
  out Port.SLAVE.DATA, al
  ret

pic.unmask: ; ax : : dx
  mov dx, ax
  not dx
  in al, Port.SLAVE.DATA
  mov ah, al
  in al, Port.MASTER.DATA
  and ax, dx
  out Port.MASTER.DATA, al
  mov al, ah
  out Port.SLAVE.DATA, al
  ret
