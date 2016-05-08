GENISOIMAGE = genisoimage

GENISOIMAGE_FLAGS = \
  -R -b boot/grub/stage2_eltorito \
  -no-emul-boot -boot-load-size 4 -boot-info-table

ISO = out/happy.iso
STAGE2 = build/stage2_eltorito
MENU_LST = build/menu.lst

iso: $(ISO)

$(ISO): out/iso/boot/grub/stage2_eltorito out/iso/boot/grub/menu.lst out/iso/boot/happy.elf
	$(GENISOIMAGE) $(GENISOIMAGE_FLAGS) -o $@ out/iso

out/iso/boot/grub/stage2_eltorito: $(STAGE2)
	@mkdir -p out/iso/boot/grub
	cp $< $@

out/iso/boot/grub/menu.lst: $(MENU_LST)
	@mkdir -p out/iso/boot
	cp $< $@

out/iso/boot/happy.elf: $(KERNEL)
	@mkdir -p out/iso/boot
	cp $< $@

.PHONY: iso
