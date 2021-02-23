VASM = vasmm68k_mot 
VLINK = vlink
NM = m68k-ataribrownest-elf-nm
PHP = php
LZ4 = lz4
ZIP2ST = zip2st
ZIP = zip

RELEASE_DISK_IMAGE = release/lotus_ste.st
GAMEFILES_DIR = gamefiles/
GAMEFILES_SOURCE_DIR = $(GAMEFILES_DIR)source/
GAMEFILES_DESTINATION_DIR = $(GAMEFILES_DIR)destination/
BIN_DIR = bin/

GENERIC_CARS_REL_PATCHES = bin/0x70660.bin bin/0x7086e.bin bin/0x70880.bin bin/0x70896.bin bin/0x7450c.bin bin/0x744ba.bin bin/0x74586.bin bin/0x7c916.bin bin/0x7a2c0.bin bin/0x7a2dc.bin bin/0x7a312.bin bin/0x7a496.bin
0x7666C_CARS_REL_PATCH = bin/0x7666c.bin
0x70400_CARS_REL_PATCH = bin/0x70400.bin
CUSTOM_CARS_REL_PATCHES = $(0x7666C_CARS_REL_PATCH) $(0x70400_CARS_REL_PATCH)
CARS_REL_PATCHES = $(GENERIC_CARS_REL_PATCHES) $(CUSTOM_CARS_REL_PATCHES)

default: check_dependencies $(RELEASE_DISK_IMAGE)

check_dependencies:
	@command -v $(VASM) >/dev/null 2>&1 || { echo >&2 "I require $(VASM) but it's not installed.  Aborting."; exit 1; }
	@command -v $(VLINK) >/dev/null 2>&1 || { echo >&2 "I require $(LINK) but it's not installed.  Aborting."; exit 1; }
	@command -v $(NM) >/dev/null 2>&1 || { echo >&2 "I require $(NM) but it's not installed.  Aborting."; exit 1; }
	@command -v $(PHP) >/dev/null 2>&1 || { echo >&2 "I require $(PHP) but it's not installed.  Aborting."; exit 1; }
	@command -v $(LZ4) >/dev/null 2>&1 || { echo >&2 "I require $(LZ4) but it's not installed.  Aborting."; exit 1; }
	@command -v $(ZIP2ST) >/dev/null 2>&1 || { echo >&2 "I require $(ZIP2ST) but it's not installed.  Aborting."; exit 1; }
	@command -v $(ZIP) >/dev/null 2>&1 || { echo >&2 "I require $(ZIP) but it's not installed.  Aborting."; exit 1; }

.PHONY: clean $(GAMEFILES_DESTINATION_DIR)

clean:
	rm src/symbols*.* || true
	rm src/road.s || true
	rm $(BIN_DIR)*.bin || true
	rm $(BIN_DIR)*.o || true
	mv $(GAMEFILES_DESTINATION_DIR)README $(GAMEFILES_DIR)
	rm -r $(GAMEFILES_DESTINATION_DIR)* || true
	mv $(GAMEFILES_DIR)README $(GAMEFILES_DESTINATION_DIR)
	rm $(RELEASE_DISK_IMAGE) || true

$(RELEASE_DISK_IMAGE): $(GAMEFILES_DESTINATION_DIR)CARS.REL $(GAMEFILES_DESTINATION_DIR)0x80000.LZ4 $(GAMEFILES_DESTINATION_DIR)SYSCHECK.LZ4 $(GAMEFILES_DESTINATION_DIR)AUTO/LOADER.PRG
	rm $(RELEASE_DISK_IMAGE) || true
	$(ZIP2ST) $(GAMEFILES_DESTINATION_DIR) $@
	@echo "*************************************************************"
	@echo "Build complete. See $(RELEASE_DISK_IMAGE) for the disk image."
	@echo "*************************************************************"

$(GAMEFILES_DESTINATION_DIR)CARS.REL: $(CARS_REL_PATCHES) $(GAMEFILES_DESTINATION_DIR)
	php src/generate_cars_rel.php $@ $(CARS_REL_PATCHES)

$(GAMEFILES_DESTINATION_DIR)0x80000.LZ4: $(BIN_DIR)0x80000.bin $(GAMEFILES_DESTINATION_DIR)
	lz4 -1 $< $@

$(GAMEFILES_DESTINATION_DIR)SYSCHECK.LZ4: $(BIN_DIR)system_check.bin $(GAMEFILES_DESTINATION_DIR)
	lz4 -1 $< $@

$(GAMEFILES_DESTINATION_DIR)AUTO/LOADER.PRG: src/loader.s $(GAMEFILES_DESTINATION_DIR)
	$(VASM) src/loader.s -Felf -o bin/loader.o
	mkdir -p $(GAMEFILES_DESTINATION_DIR)AUTO
	vlink -b ataritos bin/loader.o -o $@

$(GAMEFILES_DESTINATION_DIR):
	@echo "Copying game files..."
	cp $(GAMEFILES_SOURCE_DIR)* $(GAMEFILES_DESTINATION_DIR) || true

$(GENERIC_CARS_REL_PATCHES): bin/%.bin: src/%.s src/symbols_0x80000.inc
	$(VASM) $< -Fbin -o $@

$(0x70400_CARS_REL_PATCH): src/0x70400.s src/symbols_0x7666c.inc
	$(VASM) $< -Fbin -o $@

$(0x7666C_CARS_REL_PATCH): src/0x7666c.s src/symbols_0x80000.inc
	$(VASM) $< -Fbin -o $@

src/symbols_0x7666c.inc: bin/0x7666c.o src/process_symbols.php
	@echo "Process symbols for 0x7666c..."
	$(NM) $(BIN_DIR)0x7666c.o > src/symbols_0x7666c.txt
	$(PHP) src/process_symbols.php src/symbols_0x7666c.txt > src/symbols_0x7666c.inc

bin/0x7666c.o: src/0x7666c.s
	$(VASM) src/0x7666c.s -Felf -o bin/0x7666c.o

bin/0x80000.bin: src/0x80000.s src/road.s
	$(VASM) src/0x80000.s -Fbin -o bin/0x80000.bin

bin/0x80000.o: src/0x80000.s src/road.s
	$(VASM) src/0x80000.s -Felf -o bin/0x80000.o

src/symbols_0x80000.inc: bin/0x80000.o src/process_symbols.php
	@echo "Process symbols..."
	$(NM) $(BIN_DIR)0x80000.o > src/symbols_0x80000.txt
	$(PHP) src/process_symbols.php src/symbols_0x80000.txt > src/symbols_0x80000.inc

src/road.s: src/generate_road.php
	php src/generate_road.php > src/road.s

bin/system_check.bin: src/system_check.s bin/system_check_palette.s bin/system_check_graphics.s
	$(VASM) src/system_check.s -Fbin -o bin/system_check.bin

bin/system_check_palette.s: src/system_check.raw.pal src/generate_palette.php
	php src/generate_palette.php src/system_check.raw.pal > src/system_check_palette.s

bin/system_check_graphics.s: src/system_check.raw src/generate_planar.php
	php src/generate_planar.php src/system_check.raw > src/system_check_graphics.s
