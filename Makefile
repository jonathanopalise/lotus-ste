VASM_CMD = vasmm68k_mot
VASM_OPTS = -no-opt
VASM = $(VASM_CMD) $(VASM_OPTS)
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

GENERIC_CARS_REL_PATCHES =\
	$(BIN_DIR)0x70572.bin\
	$(BIN_DIR)0x70660.bin\
	$(BIN_DIR)0x7086e.bin\
	$(BIN_DIR)0x70880.bin\
	$(BIN_DIR)0x70896.bin\
	$(BIN_DIR)0x709b2.bin\
	$(BIN_DIR)0x70be2.bin\
	$(BIN_DIR)0x70d6c.bin\
	$(BIN_DIR)0x71938.bin\
	$(BIN_DIR)0x71ce6.bin\
	$(BIN_DIR)0x72abc.bin\
	$(BIN_DIR)0x72afa.bin\
	$(BIN_DIR)0x72b04.bin\
	$(BIN_DIR)0x73968.bin\
	$(BIN_DIR)0x744ba.bin\
	$(BIN_DIR)0x7450c.bin\
	$(BIN_DIR)0x74586.bin\
	$(BIN_DIR)0x76646.bin\
	$(BIN_DIR)0x7a2c0.bin\
	$(BIN_DIR)0x7a2dc.bin\
	$(BIN_DIR)0x7a312.bin\
	$(BIN_DIR)0x7a496.bin\
	$(BIN_DIR)0x7c916.bin\
	$(BIN_DIR)0x7de36.bin\
	$(BIN_DIR)0x7de50.bin\
	$(BIN_DIR)0x7de6a.bin

0x7666C_CARS_REL_PATCH = $(BIN_DIR)0x7666c.bin
0x70400_CARS_REL_PATCH = $(BIN_DIR)0x70400.bin
CUSTOM_CARS_REL_PATCHES = $(0x7666C_CARS_REL_PATCH) $(0x70400_CARS_REL_PATCH)
CARS_REL_PATCHES = $(GENERIC_CARS_REL_PATCHES) $(CUSTOM_CARS_REL_PATCHES)
SAMPLES_DIR = $(SOURCE_DIR)samples/

0X80000_DEPENDENCIES =\
	$(GENERATED_SOURCE_DIR)road.s\
	$(SOURCE_DIR)lz4_decode.s\
	$(SOURCE_DIR)init_draw_road.s\
	$(SOURCE_DIR)blitter_sprites.s\
	$(SOURCE_DIR)sky_gradient.s\
	$(SOURCE_DIR)preprocess_palette.s\
	$(SOURCE_DIR)ym_volume_adjust.s\
	$(SOURCE_DIR)ym_engine_volume_adjust.s\
	$(SOURCE_DIR)vbl_start_intercept.s\
	$(SOURCE_DIR)mixer_init.s\
	$(SOURCE_DIR)mixer_data.s\
	$(SOURCE_DIR)mixer_variables.s\
	$(SOURCE_DIR)mixer_vbl.s\
	$(SOURCE_DIR)write_microwire.s\
	$(SOURCE_DIR)do_sound_events.s\
	$(SAMPLES_DIR)lotus-intro.snd

default: check_dependencies $(RELEASE_DISK_IMAGE)

check_dependencies:
	@command -v $(VASM_CMD) >/dev/null 2>&1 || { echo >&2 "I require $(VASM_CMD) but it's not installed.  Aborting."; exit 1; }
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

$(RELEASE_DISK_IMAGE): $(GAMEFILES_DESTINATION_DIR)CARS.LZ4 $(GAMEFILES_DESTINATION_DIR)0x80000.LZ4 $(GAMEFILES_DESTINATION_DIR)SAMPLES.LZ4 $(GAMEFILES_DESTINATION_DIR)AUTO/LOADER.PRG
	rm $(RELEASE_DISK_IMAGE) || true
	$(ZIP2ST) $(GAMEFILES_DESTINATION_DIR) $@
	@echo "*************************************************************"
	@echo "Build complete. See $(RELEASE_DISK_IMAGE) for the disk image."
	@echo "*************************************************************"

$(GAMEFILES_DESTINATION_DIR)CARS.LZ4: $(CARS_REL_PATCHES) $(GAMEFILES_DESTINATION_DIR)
	php $(SOURCE_DIR)generate_cars_rel.php $(GAMEFILES_DESTINATION_DIR)CARS.REL $(CARS_REL_PATCHES)
	$(LZ4) -9 $(GAMEFILES_DESTINATION_DIR)CARS.REL $@
	rm $(GAMEFILES_DESTINATION_DIR)CARS.REL

$(GAMEFILES_DESTINATION_DIR)0x80000.LZ4: $(BIN_DIR)0x80000.bin $(GAMEFILES_DESTINATION_DIR)
	$(LZ4) -9 $< $@

$(GAMEFILES_DESTINATION_DIR)SAMPLES.LZ4: $(SAMPLES_DIR)lotus-sounds.snd $(GAMEFILES_DESTINATION_DIR)
	$(LZ4) -9 $< $@

$(GAMEFILES_DESTINATION_DIR)AUTO/LOADER.PRG: $(SOURCE_DIR)loader.s $(GENERATED_SOURCE_DIR)system_check_graphics.s $(GENERATED_SOURCE_DIR)system_check_palette.s $(GAMEFILES_DESTINATION_DIR)
	$(VASM) $(SOURCE_DIR)loader.s -Felf -o $(BIN_DIR)loader.o
	mkdir -p $(GAMEFILES_DESTINATION_DIR)AUTO
	vlink -s -S -x -b ataritos $(BIN_DIR)loader.o -o $@
	$(UPX) -9 $@

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

$(BIN_DIR)0x80000.bin: $(SOURCE_DIR)0x80000.s $(0X80000_DEPENDENCIES)
	$(VASM) $< -Fbin -o $@

$(BIN_DIR)0x80000.o: $(SOURCE_DIR)0x80000.s $(0X80000_DEPENDENCIES) 
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
