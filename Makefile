VASM = vasmm68k_mot 
NM = m68k-ataribrownest-elf-nm
PHP = php

BIN_FILES= bin/0x76690.bin bin/0x7666c.bin bin/0x7a2c0.bin bin/0x7a2dc.bin bin/0x7a312.bin bin/0x80000.bin

default: check_dependencies all

check_dependencies:
	command -v $(PHP) >/dev/null 2>&1 || { echo >&2 "I require $(PHP) but it's not installed.  Aborting."; exit 1; }
	command -v $(NM) >/dev/null 2>&1 || { echo >&2 "I require $(NM) but it's not installed.  Aborting."; exit 1; }
	command -v $(VASM) >/dev/null 2>&1 || { echo >&2 "I require $(VASM) but it's not installed.  Aborting."; exit 1; }

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

bin/0x7a312.bin: src/0x7a312.s src/symbols.inc
	$(VASM) src/0x7a312.s -Fbin -o bin/0x7a312.bin

bin/0x7666c.bin: src/0x7666c.s src/0x80000.s
	$(VASM) src/0x7666c.s -Fbin -o bin/0x7666c.bin

bin/0x76690.bin: src/0x76690.s src/0x80000.s
	$(VASM) src/0x76690.s -Fbin -o bin/0x76690.bin

bin/0x80000.o: src/0x80000.s src/road.s
	$(VASM) src/0x80000.s -Felf -o bin/0x80000.o

src/road.s: src/generate_road.php
	php src/generate_road.php > src/road.s

src/symbols.inc: bin/0x80000.o src/process_symbols.php
	echo Process symbols...
	$(NM) bin/0x80000.o > src/symbols.txt
	$(PHP) src/process_symbols.php > src/symbols.inc
