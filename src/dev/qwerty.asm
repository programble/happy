global qwerty.map, qwerty.map.shift, qwerty.map.ctrl

%define NUL 00h
%define SOH 01h
%define STX 02h
%define ETX 03h
%define EOT 04h
%define ENQ 05h
%define ACK 06h
%define BEL 07h
%define BS 08h
%define HT 09h
%define LF 0Ah
%define VT 0Bh
%define FF 0Ch
%define CR 0Dh
%define SO 0Eh
%define SI 0Fh
%define DLE 10h
%define DC1 11h
%define DC2 12h
%define DC3 13h
%define DC4 14h
%define NAK 15h
%define SYN 16h
%define ETB 17h
%define CAN 18h
%define EM 19h
%define SUB 1Ah
%define ESC 1Bh
%define FS 1Ch
%define GS 1Dh
%define RS 1Eh
%define US 1Fh
%define DEL 7Fh

%define XXX 0FFh

section .rodata
qwerty.map:
  ;  00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
  db XXX, ESC, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=',  BS,  HT ; 00
  db 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',  LF, XXX, 'a', 's' ; 10
  db 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', XXX, '\', 'z', 'x', 'c', 'v' ; 20
  db 'b', 'n', 'm', ',', '.', '/', XXX, XXX, XXX, ' ', XXX, XXX, XXX, XXX, XXX, XXX ; 30
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 40
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 50
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 60
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 70

.shift:
  ;  00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
  db XXX, ESC, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+',  BS,  HT ; 00
  db 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}',  LF, XXX, 'A', 'S' ; 10
  db 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~', XXX, '|', 'Z', 'X', 'C', 'V' ; 20
  db 'B', 'N', 'M', '<', '>', '?', XXX, XXX, XXX, ' ', XXX, XXX, XXX, XXX, XXX, XXX ; 30
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 40
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 50
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 60
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 70

.ctrl:
  ;  00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F
  db XXX, ESC, '1', NUL, '3', '4', '5',  RS, '7', '8', '9', '0',  US, '=',  BS,  HT ; 00
  db DC1, ETB, ENQ, DC2, DC4,  EM, NAK,  HT,  SI, DLE, ESC,  GS,  LF, XXX, SOH, DC3 ; 10
  db EOT, ACK, BEL,  BS,  LF,  VT,  FF, ';', "'", '`', XXX,  FS, SUB, CAN, ETX, SYN ; 20
  db STX,  SO,  CR, ',', '.', DEL, XXX, XXX, XXX, ' ', XXX, XXX, XXX, XXX, XXX, XXX ; 30
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 40
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 50
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 60
  db XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX ; 70
