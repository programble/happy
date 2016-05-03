ENTRY (boot)
SECTIONS {
  . = 0x00100000;
  core.boundLower = .;
  .mboot : { *(.mboot) }
  .bss ALIGN(0x1000) : { *(.bss) }
  .data ALIGN(0x1000) : { *(.data) }
  .rodata ALIGN(0x1000) : { *(.rodata) }
  .text ALIGN(0x1000) : { *(.text) }
  core.boundUpper = .;
}
