LD = ld
NASM = nasm
QEMU = qemu-system-i386

LD_FLAGS = -m elf_i386 -nostdlib
NASM_FLAGS = -f elf32 -i src/ -g
QEMU_FLAGS =

LD_SCRIPT = friendship.ld
OBJECTS = out/obj/boot.o
KERNEL = out/happy.elf

kernel: $(KERNEL)

$(KERNEL): $(LD_SCRIPT) $(OBJECTS)
	@mkdir -p out
	$(LD) $(LD_FLAGS) -o $@ -T $(LD_SCRIPT) $(OBJECTS)

out/obj/%.o: src/%.asm
	@mkdir -p out/obj
	$(NASM) $(NASM_FLAGS) -o $@ $<

clean:
	rm -rf out

qemu: $(KERNEL)
	$(QEMU) $(QEMU_FLAGS) -kernel $<

.PHONY: kernel clean qemu

-include config.mk
