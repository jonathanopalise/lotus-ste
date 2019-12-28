VASM = vasmm68k_mot 
NM = /home/jonathan/brown/bin/m68k-ataribrownest-elf-nm
PHP = php

BIN_FILES= bin/0x76690.bin bin/0x7a2c0.bin bin/0x7a2dc.bin bin/0x7a312.bin bin/0x80000.bin

default: check_dependencies all

check_dependencies:
	command -v php >/dev/null 2>&1 || { echo >&2 "I require php but it's not installed.  Aborting."; exit 1; }
	command -v vasmm68k_mot >/dev/null 2>&1 || { echo >&2 "I require vasmm68k_mot but it's not installed.  Aborting."; exit 1; }

.PHONY: clean

clean:
	rm bin/*.bin
	rm bin/*.o
	rm bin/road.s
	rm src/symbols.*

.PHONY: all

all: $(BIN_FILES)

bin/0x80000.bin: src/0x80000.s
	$(VASM) src/0x80000.s -Fbin -o bin/0x80000.bin

bin/0x7a2c0.bin: src/0x7a2c0.s
	$(VASM) src/0x7a2c0.s -Fbin -o bin/0x7a2c0.bin

bin/0x7a2dc.bin: src/0x7a2dc.s
	$(VASM) src/0x7a2dc.s -Fbin -o bin/0x7a2dc.bin

bin/0x7a312.bin: src/0x7a312.s
	$(VASM) src/0x7a312.s -Fbin -o bin/0x7a312.bin

bin/0x76690.bin: src/0x76690.s src/symbols.inc
	$(VASM) src/0x76690.s -Fbin -o bin/0x76690.bin

bin/0x80000.o: src/0x80000.s src/road.s
	$(VASM) src/0x80000.s -Felf -o bin/0x80000.o

src/road.s: src/generate_road.php
	php src/generate_road.php > src/road.s

src/symbols.inc: bin/0x80000.o src/process_symbols.php
	echo Process symbols...
	$(NM) bin/0x80000.o > src/symbols.txt
	$(PHP) src/process_symbols.php > src/symbols.inc
