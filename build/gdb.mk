GDB = gdb

GDB_FLAGS = \
  -ex 'set disassembly-flavor intel' \
  -ex 'display/i $$pc' \
  -ex 'target remote localhost:1234'

gdb: $(KERNEL)
	$(GDB) $(GDB_FLAGS) $<

.PHONY: gdb
