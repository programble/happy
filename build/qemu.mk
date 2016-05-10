QEMU = qemu-system-i386

QEMU_FLAGS = -cpu 486,-vme -serial stdio

qemu: qemu-iso

qemu-iso: $(ISO)
	$(QEMU) $(QEMU_FLAGS) -cdrom $<

qemu-kernel: $(KERNEL)
	$(QEMU) $(QEMU_FLAGS) -kernel $<

.PHONY: qemu qemu-iso qemu-kernel
