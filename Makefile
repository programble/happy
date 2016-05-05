LD = ld
NASM = nasm
GENISOIMAGE = genisoimage
QEMU = qemu-system-i386
GDB = gdb
GREP = grep
CONVERT = convert

LD_FLAGS = -m elf_i386 -nostdlib
NASM_FLAGS = -f elf32 -i src/ -g
GENISOIMAGE_FLAGS = \
  -R -b boot/grub/stage2_eltorito \
  -no-emul-boot -boot-load-size 4 -boot-info-table
QEMU_FLAGS = -cpu pentium,-vme -serial stdio
GDB_FLAGS = \
  -ex 'set disassembly-flavor intel' \
  -ex 'display/i $$pc' \
  -ex 'target remote localhost:1234'
CONVERT_FLAGS = -delay 10 -loop 0

KERNEL = out/happy.elf
LD_SCRIPT = friendship.ld
SOURCES = $(wildcard src/*.asm)
OBJECTS = $(SOURCES:src/%.asm=out/obj/%.o)
DEPS = $(SOURCES:src/%.asm=out/dep/%.mk)
ISO = out/happy.iso
STAGE2 = stage2_eltorito
MENU_LST = menu.lst
GIF = out/screenshot.gif

kernel: $(KERNEL)

$(KERNEL): $(LD_SCRIPT) $(OBJECTS)
	@mkdir -p out
	$(LD) $(LD_FLAGS) -o $@ -T $(LD_SCRIPT) $(OBJECTS)

-include $(DEPS)

out/obj/%.o: src/%.asm
	@mkdir -p out/obj out/dep
	$(NASM) $(NASM_FLAGS) -MD $(@:out/obj/%.o=out/dep/%.mk) -o $@ $<

iso: $(ISO)

$(ISO): out/iso/boot/grub/stage2_eltorito out/iso/boot/grub/menu.lst out/iso/boot/happy.elf
	$(GENISOIMAGE) $(GENISOIMAGE_FLAGS) -o $@ out/iso

out/iso/boot/grub/stage2_eltorito: $(STAGE2)
	@mkdir -p out/iso/boot/grub
	cp $< $@

out/iso/boot/grub/menu.lst: $(MENU_LST)
	@mkdir -p out/iso/boot/grub
	cp $< $@

out/iso/boot/happy.elf: $(KERNEL)
	@mkdir -p out/iso/boot
	cp $< $@

clean:
	rm -rf out

qemu: $(KERNEL)
	$(QEMU) $(QEMU_FLAGS) -kernel $<

qemu-iso: $(ISO)
	$(QEMU) $(QEMU_FLAGS) -cdrom $<

gdb: $(KERNEL)
	$(GDB) $(GDB_FLAGS) $<

annotations:
	$(GREP) -h ': ;' $(SOURCES)

gif: $(GIF)

$(GIF): $(wildcard screenshot/*.png)
	$(CONVERT) $(CONVERT_FLAGS) $^ $@

.PHONY: kernel iso clean qemu gdb annotations gif

-include config.mk
