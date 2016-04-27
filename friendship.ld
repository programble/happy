ENTRY (boot)
SECTIONS {
  .mboot 0x00100000 : { *(.mboot) }
  .bss ALIGN(0x1000) : { *(.bss) }
  .data ALIGN(0x1000) : { *(.data) }
  .rodata ALIGN(0x1000) : { *(.rodata) }
  .text ALIGN(0x1000) : { *(.text) }
}
