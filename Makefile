VASM = vasmm68k_mot 
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

CARS_REL_PATCHES = bin/0x70660.bin bin/0x7086e.bin bin/0x70880.bin bin/0x70896.bin bin/0x7450c.bin bin/0x744ba.bin bin/0x74586.bin bin/0x7666c.bin bin/0x7c916.bin bin/0x7a2c0.bin bin/0x7a2dc.bin bin/0x7a312.bin bin/0x7a496.bin

default: check_dependencies $(RELEASE_DISK_IMAGE)

check_dependencies:
	@command -v $(PHP) >/dev/null 2>&1 || { echo >&2 "I require $(PHP) but it's not installed.  Aborting."; exit 1; }
	@command -v $(NM) >/dev/null 2>&1 || { echo >&2 "I require $(NM) but it's not installed.  Aborting."; exit 1; }
	@command -v $(VASM) >/dev/null 2>&1 || { echo >&2 "I require $(VASM) but it's not installed.  Aborting."; exit 1; }
	@command -v $(LZ4) >/dev/null 2>&1 || { echo >&2 "I require $(LZ4) but it's not installed.  Aborting."; exit 1; }
	@command -v $(ZIP2ST) >/dev/null 2>&1 || { echo >&2 "I require $(ZIP2ST) but it's not installed.  Aborting."; exit 1; }
	@command -v $(ZIP) >/dev/null 2>&1 || { echo >&2 "I require $(ZIP) but it's not installed.  Aborting."; exit 1; }

.PHONY: clean $(GAMEFILES_DESTINATION_DIR)

clean:
	rm src/symbols.* || true
	rm src/road.s || true
	rm $(BIN_DIR)*.bin || true
	rm $(BIN_DIR)*.o || true
	mv $(GAMEFILES_DESTINATION_DIR)README $(GAMEFILES_DIR)
	rm -r $(GAMEFILES_DESTINATION_DIR)* || true
	mv $(GAMEFILES_DIR)README $(GAMEFILES_DESTINATION_DIR)
	rm $(RELEASE_DISK_IMAGE) || true

$(RELEASE_DISK_IMAGE): $(GAMEFILES_DESTINATION_DIR)CARS.REL $(GAMEFILES_DESTINATION_DIR)0x80000.LZ4
	rm $(RELEASE_DISK_IMAGE) || true
	$(ZIP2ST) $(GAMEFILES_DESTINATION_DIR) $@
	@echo "*************************************************************"
	@echo "Build complete. See $(RELEASE_DISK_IMAGE) for the disk image."
	@echo "*************************************************************"

$(GAMEFILES_DESTINATION_DIR)CARS.REL: $(CARS_REL_PATCHES) $(GAMEFILES_DESTINATION_DIR)
	php src/generate_cars_rel.php $@ $(CARS_REL_PATCHES)

$(GAMEFILES_DESTINATION_DIR)0x80000.LZ4: $(BIN_DIR)0x80000.bin $(GAMEFILES_DESTINATION_DIR)
	lz4 -1 $< $@

$(GAMEFILES_DESTINATION_DIR):
	@echo "Copying game files..."
	cp -R $(GAMEFILES_SOURCE_DIR) $(GAMEFILES_DESTINATION_DIR)

$(CARS_REL_PATCHES): bin/%.bin: src/%.s src/symbols.inc
	$(VASM) $< -Fbin -o $@

bin/0x80000.bin: src/0x80000.s src/road.s
	$(VASM) src/0x80000.s -Fbin -o bin/0x80000.bin

bin/0x80000.o: src/0x80000.s src/road.s
	$(VASM) src/0x80000.s -Felf -o bin/0x80000.o

src/road.s: src/generate_road.php
	php src/generate_road.php > src/road.s

src/symbols.inc: bin/0x80000.o src/process_symbols.php
	@echo "Process symbols..."
	$(NM) $(BIN_DIR)0x80000.o > src/symbols.txt
	$(PHP) src/process_symbols.php > src/symbols.inc
