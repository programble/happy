LD = ld
NASM = nasm
QEMU = qemu-system-i386
GDB = gdb

LD_FLAGS = -m elf_i386 -nostdlib
NASM_FLAGS = -f elf32 -i src/ -g
QEMU_FLAGS = -s -S
GDB_FLAGS = \
  -ex 'set disassembly-flavor intel' \
  -ex 'display/i $$pc' \
  -ex 'target remote localhost:1234'

LD_SCRIPT = friendship.ld
SOURCES = $(wildcard src/*.asm)
OBJECTS = $(SOURCES:src/%.asm=out/obj/%.o)
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

gdb: $(KERNEL)
	$(GDB) $(GDB_FLAGS) $<

.PHONY: kernel clean qemu gdb

-include config.mk
