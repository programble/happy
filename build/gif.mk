CONVERT = convert

CONVERT_FLAGS = -delay 10 -loop 0

GIF = out/screenshot.gif
SCREENSHOTS = $(wildcard screenshot/*.png)

gif: $(GIF)

$(GIF): $(SCREENSHOTS)
	@mkdir -p out
	$(CONVERT) $(CONVERT_FLAGS) $^ $@

.PHONY: gif
