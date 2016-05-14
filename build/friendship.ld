ENTRY (core.boot)
SECTIONS {
  . = 0x00100000;
  core.boundLower = .;
  .mboot : {
    core.sectionMboot = .;
    *(.mboot)
  }
  .bss ALIGN(0x1000) : {
    core.sectionBss = .;
    *(.bss)
  }
  .data ALIGN(0x1000) : {
    core.sectionData = .;
    *(.data)
  }
  .rodata ALIGN(0x1000) : {
    core.sectionRodata = .;
    *(.rodata)
  }
  .text ALIGN(0x1000) : {
    core.sectionText = .;
    *(.text)
  }
  core.boundUpper = .;
}
