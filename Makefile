VASM = vasmm68k_mot 
VLINK = vlink
NM = m68k-ataribrownest-elf-nm
PHP = php
LZ4 = lz4
ZIP2ST = zip2st
ZIP = zip
UPX = upx

RELEASE_DISK_IMAGE = release/lotus_ste.st
GAMEFILES_DIR = gamefiles/
GAMEFILES_SOURCE_DIR = $(GAMEFILES_DIR)source/
GAMEFILES_DESTINATION_DIR = $(GAMEFILES_DIR)destination/
SOURCE_DIR = src/
GENERATED_SOURCE_DIR = $(SOURCE_DIR)generated/
BIN_DIR = bin/

GENERIC_CARS_REL_PATCHES = $(BIN_DIR)0x70660.bin $(BIN_DIR)0x7086e.bin $(BIN_DIR)0x70880.bin $(BIN_DIR)0x70896.bin $(BIN_DIR)0x709c0.bin $(BIN_DIR)0x71d62.bin $(BIN_DIR)0x7450c.bin $(BIN_DIR)0x744ba.bin $(BIN_DIR)0x74586.bin $(BIN_DIR)0x7c916.bin $(BIN_DIR)0x7a2c0.bin $(BIN_DIR)0x7a2dc.bin $(BIN_DIR)0x7a312.bin $(BIN_DIR)0x7a496.bin
0x7666C_CARS_REL_PATCH = $(BIN_DIR)0x7666c.bin
0x70400_CARS_REL_PATCH = $(BIN_DIR)0x70400.bin
CUSTOM_CARS_REL_PATCHES = $(0x7666C_CARS_REL_PATCH) $(0x70400_CARS_REL_PATCH)
CARS_REL_PATCHES = $(GENERIC_CARS_REL_PATCHES) $(CUSTOM_CARS_REL_PATCHES)
SAMPLES_DIR = $(SOURCE_DIR)samples
SAMPLES = $(SAMPLES_DIR)hitcar.snd $(SAMPLES_DIR)hitobject.snd $(SAMPLES_DIR)lowfuel.snd $(SAMPLES_DIR)racestarthigh.snd $(SAMPLES_DIR)racestartlow.snd $(SAMPLES_DIR)roadedge.snd $(SAMPLES_DIR)skid.snd

default: check_dependencies $(RELEASE_DISK_IMAGE)

check_dependencies:
	@command -v $(VASM) >/dev/null 2>&1 || { echo >&2 "I require $(VASM) but it's not installed.  Aborting."; exit 1; }
	@command -v $(VLINK) >/dev/null 2>&1 || { echo >&2 "I require $(LINK) but it's not installed.  Aborting."; exit 1; }
	@command -v $(NM) >/dev/null 2>&1 || { echo >&2 "I require $(NM) but it's not installed.  Aborting."; exit 1; }
	@command -v $(PHP) >/dev/null 2>&1 || { echo >&2 "I require $(PHP) but it's not installed.  Aborting."; exit 1; }
	@command -v $(LZ4) >/dev/null 2>&1 || { echo >&2 "I require $(LZ4) but it's not installed.  Aborting."; exit 1; }
	@command -v $(ZIP2ST) >/dev/null 2>&1 || { echo >&2 "I require $(ZIP2ST) but it's not installed.  Aborting."; exit 1; }
	@command -v $(ZIP) >/dev/null 2>&1 || { echo >&2 "I require $(ZIP) but it's not installed.  Aborting."; exit 1; }
	@command -v $(UPX) >/dev/null 2>&1 || { echo >&2 "I require $(UPX) but it's not installed.  Aborting."; exit 1; }

.PHONY: clean $(GAMEFILES_DESTINATION_DIR) $(GENERATED_SOURCE_DIR)

clean:
	rm $(GENERATED_SOURCE_DIR)* || true
	rmdir $(GENERATED_SOURCE_DIR)
	rm $(BIN_DIR)*.bin || true
	rm $(BIN_DIR)*.o || true
	rm $(RELEASE_DISK_IMAGE) || true

$(RELEASE_DISK_IMAGE): $(GAMEFILES_DESTINATION_DIR)CARS.REL $(GAMEFILES_DESTINATION_DIR)0x80000.LZ4 $(GAMEFILES_DESTINATION_DIR)AUTO/LOADER.PRG
	rm $(RELEASE_DISK_IMAGE) || true
	$(ZIP2ST) $(GAMEFILES_DESTINATION_DIR) $@
	@echo "*************************************************************"
	@echo "Build complete. See $(RELEASE_DISK_IMAGE) for the disk image."
	@echo "*************************************************************"

$(GAMEFILES_DESTINATION_DIR)CARS.REL: $(CARS_REL_PATCHES) $(GAMEFILES_DESTINATION_DIR)
	php $(SOURCE_DIR)generate_cars_rel.php $@ $(CARS_REL_PATCHES)

$(GAMEFILES_DESTINATION_DIR)0x80000.LZ4: $(BIN_DIR)0x80000.bin $(GAMEFILES_DESTINATION_DIR)
	lz4 -1 $< $@

$(GAMEFILES_DESTINATION_DIR)AUTO/LOADER.PRG: $(SOURCE_DIR)loader.s $(GENERATED_SOURCE_DIR)system_check_graphics.s $(GENERATED_SOURCE_DIR)system_check_palette.s $(GAMEFILES_DESTINATION_DIR)
	$(VASM) $(SOURCE_DIR)loader.s -Felf -o $(BIN_DIR)loader.o
	mkdir -p $(GAMEFILES_DESTINATION_DIR)AUTO
	vlink -s -S -x -b ataritos $(BIN_DIR)loader.o -o $@
	upx $@

$(GAMEFILES_DESTINATION_DIR):
	mkdir -p $(GAMEFILES_DESTINATION_DIR)
	rm -r $(GAMEFILES_DESTINATION_DIR)* || true
	cp $(GAMEFILES_SOURCE_DIR)* $(GAMEFILES_DESTINATION_DIR) || true
	rm $(GAMEFILES_DESTINATION_DIR)README || true

$(GENERIC_CARS_REL_PATCHES): $(BIN_DIR)%.bin: $(SOURCE_DIR)%.s $(GENERATED_SOURCE_DIR)symbols_0x80000.inc
	$(VASM) $< -Fbin -o $@

$(0x70400_CARS_REL_PATCH): $(SOURCE_DIR)0x70400.s $(GENERATED_SOURCE_DIR)symbols_0x7666c.inc
	$(VASM) $< -Fbin -o $@

$(0x7666C_CARS_REL_PATCH): $(SOURCE_DIR)0x7666c.s $(GENERATED_SOURCE_DIR)symbols_0x80000.inc
	$(VASM) $< -Fbin -o $@

$(GENERATED_SOURCE_DIR)symbols_0x7666c.inc: $(BIN_DIR)0x7666c.o $(SOURCE_DIR)process_symbols.php
	@echo "Process symbols for 0x7666c..."
	$(NM) $< > $(GENERATED_SOURCE_DIR)symbols_0x7666c.txt
	$(PHP) $(SOURCE_DIR)process_symbols.php $(GENERATED_SOURCE_DIR)symbols_0x7666c.txt > $@

$(BIN_DIR)0x7666c.o: $(SOURCE_DIR)0x7666c.s
	$(VASM) $< -Felf -o $@

$(BIN_DIR)0x80000.bin: $(SOURCE_DIR)0x80000.s $(GENERATED_SOURCE_DIR)road.s $(PCM_SAMPLES)
	$(VASM) $< -Fbin -o $@

$(BIN_DIR)0x80000.o: $(SOURCE_DIR)0x80000.s $(GENERATED_SOURCE_DIR)road.s
	$(VASM) $< -Felf -o $@

$(GENERATED_SOURCE_DIR)symbols_0x80000.inc: $(BIN_DIR)0x80000.o $(SOURCE_DIR)process_symbols.php
	@echo "Process symbols..."
	$(NM) $< > $(GENERATED_SOURCE_DIR)symbols_0x80000.txt
	$(PHP) $(SOURCE_DIR)process_symbols.php $(GENERATED_SOURCE_DIR)symbols_0x80000.txt > $(GENERATED_SOURCE_DIR)symbols_0x80000.inc

$(GENERATED_SOURCE_DIR)road.s: $(SOURCE_DIR)generate_road.php $(GENERATED_SOURCE_DIR)
	php $< > $@

$(GENERATED_SOURCE_DIR)system_check_palette.s: $(SOURCE_DIR)generate_palette.php $(SOURCE_DIR)system_check.raw.pal $(GENERATED_SOURCE_DIR)
	php $< $(SOURCE_DIR)system_check.raw.pal > $@

$(GENERATED_SOURCE_DIR)system_check_graphics.s: $(SOURCE_DIR)generate_planar.php $(SOURCE_DIR)system_check.raw $(GENERATED_SOURCE_DIR)
	php $< $(SOURCE_DIR)system_check.raw > $@

$(GENERATED_SOURCE_DIR):
	mkdir -p $@
