LD = ld
NASM = nasm

LD_FLAGS = -m elf_i386 -nostdlib
NASM_FLAGS = -f elf32 -p build/cpu.mac -i src/ -g

KERNEL = out/happy.elf
LD_SCRIPT = build/friendship.ld

SOURCES = $(wildcard src/*.asm)
OBJECTS = $(SOURCES:src/%.asm=out/obj/%.o)
DEPS = $(SOURCES:src/%.asm=out/dep/%.mk)

kernel: $(KERNEL)

$(KERNEL): $(LD_SCRIPT) $(OBJECTS)
	@mkdir -p out
	$(LD) $(LD_FLAGS) -o $@ -T $(LD_SCRIPT) $(OBJECTS)

-include $(DEPS)

out/obj/%.o: src/%.asm
	@mkdir -p out/obj out/dep
	$(NASM) $(NASM_FLAGS) -MD $(@:out/obj/%.o=out/dep/%.mk) -o $@ $<

.PHONY: kernel
