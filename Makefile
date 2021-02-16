VASM = vasmm68k_mot 
NM = m68k-ataribrownest-elf-nm
PHP = php

BIN_FILES = bin/0x70660.bin bin/0x7086e.bin bin/0x70880.bin bin/0x70896.bin bin/0x744ba.bin bin/0x74586.bin bin/0x7666c.bin bin/0x7a2c0.bin bin/0x7a2dc.bin bin/0x7a312.bin bin/0x7a496.bin bin/0x80000.bin

default: check_dependencies all

check_dependencies:
	command -v $(PHP) >/dev/null 2>&1 || { echo >&2 "I require $(PHP) but it's not installed.  Aborting."; exit 1; }
	command -v $(NM) >/dev/null 2>&1 || { echo >&2 "I require $(NM) but it's not installed.  Aborting."; exit 1; }
	command -v $(VASM) >/dev/null 2>&1 || { echo >&2 "I require $(VASM) but it's not installed.  Aborting."; exit 1; }

.PHONY: clean

clean:
	rm src/symbols.*
	rm src/road.s
	rm bin/*.bin
	rm bin/*.o

.PHONY: all

all: $(BIN_FILES)

bin/0x80000.bin: src/0x80000.s src/road.s
	$(VASM) src/0x80000.s -Fbin -o bin/0x80000.bin

bin/0x80000.o: src/0x80000.s src/road.s
	$(VASM) src/0x80000.s -Felf -o bin/0x80000.o

bin/0x70660.bin: src/0x70660.s src/symbols.inc
	$(VASM) src/0x70660.s -Fbin -o bin/0x70660.bin

bin/0x7086e.bin: src/0x7086e.s src/symbols.inc
	$(VASM) src/0x7086e.s -Fbin -o bin/0x7086e.bin

bin/0x70880.bin: src/0x70880.s src/symbols.inc
	$(VASM) src/0x70880.s -Fbin -o bin/0x70880.bin

bin/0x70896.bin: src/0x70896.s src/symbols.inc
	$(VASM) src/0x70896.s -Fbin -o bin/0x70896.bin

bin/0x744ba.bin: src/0x744ba.s src/symbols.inc
	$(VASM) src/0x744ba.s -Fbin -o bin/0x744ba.bin

bin/0x74586.bin: src/0x74586.s src/symbols.inc
	$(VASM) src/0x74586.s -Fbin -o bin/0x74586.bin

bin/0x7a2c0.bin: src/0x7a2c0.s
	$(VASM) src/0x7a2c0.s -Fbin -o bin/0x7a2c0.bin

bin/0x7a2dc.bin: src/0x7a2dc.s
	$(VASM) src/0x7a2dc.s -Fbin -o bin/0x7a2dc.bin

bin/0x7a496.bin: src/0x7a496.s src/symbols.inc
	$(VASM) src/0x7a496.s -Fbin -o bin/0x7a496.bin

bin/0x7a312.bin: src/0x7a312.s src/symbols.inc
	$(VASM) src/0x7a312.s -Fbin -o bin/0x7a312.bin

bin/0x7666c.bin: src/0x7666c.s src/symbols.inc
	$(VASM) src/0x7666c.s -Fbin -o bin/0x7666c.bin

src/road.s: src/generate_road.php
	php src/generate_road.php > src/road.s

src/symbols.inc: bin/0x80000.o src/process_symbols.php
	echo Process symbols...
	$(NM) bin/0x80000.o > src/symbols.txt
	$(PHP) src/process_symbols.php > src/symbols.inc
