include build/kernel.mk
include build/iso.mk
include build/qemu.mk
include build/gdb.mk
include build/gif.mk

clean:
	rm -rf out

.PHONY: clean

-include config.mk
