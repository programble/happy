LD = ld
NASM = nasm

LD_FLAGS = -m elf_i386 -nostdlib
NASM_FLAGS = -f elf32 -p build/prelude.mac -i src/ -g -F dwarf

KERNEL = out/happy.elf
LD_SCRIPT = build/friendship.ld

SOURCES = $(wildcard src/*.asm)
OBJECTS = $(SOURCES:src/%.asm=out/obj/%.o)
DEPS = $(SOURCES:src/%.asm=out/dep/%.mk)
EXPANDS = $(SOURCES:src/%.asm=out/expand/%.asm)

kernel: $(KERNEL)

expand: $(EXPANDS)

$(KERNEL): $(LD_SCRIPT) $(OBJECTS)
	@mkdir -p out
	$(LD) $(LD_FLAGS) -o $@ -T $(LD_SCRIPT) $(OBJECTS)

-include $(DEPS)

out/obj/%.o: src/%.asm
	@mkdir -p out/obj out/dep
	$(NASM) $(NASM_FLAGS) -MD $(@:out/obj/%.o=out/dep/%.mk) -o $@ $<

out/expand/%.asm: src/%.asm
	@mkdir -p out/expand
	$(NASM) $(NASM_FLAGS) -E -o $@ $<

.PHONY: kernel expand
