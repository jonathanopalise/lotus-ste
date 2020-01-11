# Lotus STE

_Enhancements to the Atari ST version of Lotus Esprit Turbo Challenge to support STE hardware features_

![Screenshot of current progress](https://github.com/jonathanopalise/lotus-ste/blob/master/screenshot.png)

This project is at a very early stage and currently doesn't do anything of great interest to end users.

Directory layout is as follows:

* `bin` - contains binary patches generated by means of compiling the code in `src`.
* `doc` - contains documentation pertaining to the reverse engineering efforts of the ST side
* `src` - contains the core source code to generate the code for use on the ST side
* `util` - contains utilities for use in reverse engineering efforts

Run `make` to generate the binary patches for use on the ST side. In order to successfully run the Makefile, you'll need a reasonably recent install of `php` (https://php.net) in your path, along with the `vasmm68k_mot` executable from the vasm project (http://sun.hasenbraten.de/vasm/). You'll also need a `m68k-ataribrownest-elf-nm` executable or something similar from one of the available GCC cross-assembler packages (e.g. https://bitbucket.org/ggnkua/bigbrownbuild/src/default/). The Makefile is designed for use only with Linux but I imagine it could be repurposed for Windows or Mac with some changes.

In order to test the current functionality of this project, you'll need a recent build of the Hatari emulator, configured as an STE with 1 meg of memory.

You'll also need a specific disk image of Lotus to apply the code to at runtime. The filename of this image is `Lotus Esprit Turbo Challenge (1990)(Gremlin)[cr Empire][a].st` and the md5sum is `942911068dd0a82debfba6d45d3370c4`.

Insert the above floppy image, boot the virtual STE, start a race, and then enter the debugger. Enter the following commands to apply the patches:

* `loadbin /path/to/0x7a2c0.bin 0x7a2c0`
* `loadbin /path/to/0x7a2dc.bin 0x7a2dc`
* `loadbin /path/to/0x7a312.bin 0x7a312`
* `loadbin /path/to/0x7a312.bin 0x7a496`
* `loadbin /path/to/0x76690.bin 0x7666c`
* `loadbin /path/to/0x76690.bin 0x76690`
* `loadbin /path/to/0x80000.bin 0x80000`

`/path/to` in the above commands represents the directory to which `bin` files have been assembled - normally the `bin` directory within the repository.

Exit the debugger to see the STE enhancements in action. You should see the following changes:

* The road is rendered using the Blitter and features graphical details resembling those of the Amiga version;
* All roadside scenery and cars are rendered at single-pixel horizontal accuracy (currently with a few unresolved issues around clipping)

Possible forthcoming objectives for this project are as follows:

* Render the road with visuals reminiscent on the Amiga version, with performance matching the non-blitter renderer;
* Add sampled sound effects to replace the current synthesised ones - e.g. car collisions, empty fuel etc;
* Add further zoom levels for trackside objects;
* Use enhanced palette of STE for improved colours;
* (Unlikely but nice to have) Render a sky gradient similar to that present on the Amiga version. 
