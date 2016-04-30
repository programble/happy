global gdt.init

struc gdt.Gdt
  .limit: resw 1
  .base: resd 1
endstruc

struc gdt.Entry
  .limit_lo: resw 1
  .base_lo: resw 1
  .base_mi: resb 1
  .access: resb 1
  .limit_hi_flags: resb 1
  .base_hi: resb 1
endstruc

gdt.Access equ 0x10
gdt.Access.AC equ 1
gdt.Access.RW equ 2
gdt.Access.DC equ 4
gdt.Access.EX equ 8
gdt.Access.PR equ 0x80
gdt.Access.Privl equ 5

gdt.Flags.SZ_32 equ 0x40
gdt.Flags.GR_PAGE equ 0x80

section .data
gdt.gdt:
  istruc gdt.Gdt
    at gdt.Gdt.limit, dw gdt.#entries
    at gdt.Gdt.base, dd gdt.~entries
  iend

gdt.~entries:
  .null:
    istruc gdt.Entry
      at gdt.Entry.limit_lo, dw 0
      at gdt.Entry.base_lo, dw 0
      at gdt.Entry.base_mi, db 0
      at gdt.Entry.access, db 0
      at gdt.Entry.limit_hi_flags, db 0
      at gdt.Entry.base_hi, db 0
    iend
  .code:
    istruc gdt.Entry
      at gdt.Entry.limit_lo, dw 0xFFFF
      at gdt.Entry.base_lo, dw 0
      at gdt.Entry.base_mi, db 0
      at gdt.Entry.access, db gdt.Access | gdt.Access.RW | gdt.Access.EX | gdt.Access.PR
      at gdt.Entry.limit_hi_flags, db 0xF | gdt.Flags.SZ_32 | gdt.Flags.GR_PAGE
      at gdt.Entry.base_hi, db 0
    iend
  .data:
    istruc gdt.Entry
      at gdt.Entry.limit_lo, dw 0xFFFF
      at gdt.Entry.base_lo, dw 0
      at gdt.Entry.base_mi, db 0
      at gdt.Entry.access, db gdt.Access | gdt.Access.RW | gdt.Access.PR
      at gdt.Entry.limit_hi_flags, db 0xF | gdt.Flags.SZ_32 | gdt.Flags.GR_PAGE
      at gdt.Entry.base_hi, db 0
    iend
gdt.#entries equ $ - gdt.~entries

section .text
gdt.init: ; : : ax
  lgdt [gdt.gdt]
  mov ax, gdt.~entries.data - gdt.~entries
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  jmp (gdt.~entries.code - gdt.~entries):.ret
  .ret:
  ret
