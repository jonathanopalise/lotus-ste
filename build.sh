command -v php >/dev/null 2>&1 || { echo >&2 "I require php but it's not installed.  Aborting."; exit 1; }
command -v vasmm68k_mot >/dev/null 2>&1 || { echo >&2 "I require vasmm68k_mot but it's not installed.  Aborting."; exit 1; }

php src/generate_road.php > src/road.s
vasmm68k_mot src/0x80000.s -Fbin -o bin/0x80000.bin
vasmm68k_mot src/0x76678.s -Fbin -o bin/0x76678.bin

echo "If the build process has succeeded, files named 0x80000.bin and 0x76678.bin will now be present in the bin directory"
