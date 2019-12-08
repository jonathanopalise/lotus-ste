# Lotus STE

_Enhancements to the Atari ST version of Lotus Esprit Turbo Challenge to support STE hardware features_

![Screenshot of current progress](https://github.com/jonathanopalise/lotus-ste/blob/master/screenshot.png)

This project is at a very early stage and currently doesn't do anything of great interest to end users.

Directory layout is as follows:

* `bin` - contains binary patches generated by means of compiling the code in `src`.
* `doc` - contains documentation pertaining to the reverse engineering efforts of the ST side
* `src` - contains the core source code to generate the code for use on the ST side
* `util` - contains utilities for use in reverse engineering efforts

Run `build.sh` to generate the binary patches for use on the ST side. In order to successfully run the build process, you'll need a reasonably recent install of `php` (https://php.net) in your path, along with the `vasmm68k_mot` executable from the vasm project (http://sun.hasenbraten.de/vasm/). The build script is designed for use only with Linux but I imagine the build process could be repurposed for Windows by means of a batch script or something similar.

In order to test the current functionality of this project, you'll need a recent build of the Hatari emulator, configured as an STE with 1 meg of memory.

You'll also need a specific disk image of Lotus to apply the code to at runtime. The filename of this image is `Lotus Esprit Turbo Challenge (1990)(Gremlin)[cr Empire][a].st` and the md5sum is `942911068dd0a82debfba6d45d3370c4`.

Insert the above floppy image, boot the virtual STE, start a race, and then enter the debugger. Enter the following commands to apply the patches:

* `loadbin /path/to/0x76690.bin 0x76690`
* `loadbin /path/to/0x80000.bin 0x80000`

Exit the debugger to see the STE enhancements in action - currently limited to an improved Blitter-based rendering of the road that runs a little slower than the standard method.

Possible forthcoming objectives for this project are as follows:

* Render the road with visuals reminiscent on the Amiga version, with performance matching the non-blitter renderer;
* Add sampled sound effects to replace the current synthesised ones - e.g. car collisions, empty fuel etc;
* Render trackside objects with single pixel horizontal precision (objects on the ST version are currently shifted to the nearest 16 pixel offset);
* Add further zoom levels for trackside objects;
* (Unlikely but nice to have) Render a sky gradient similar to that present on the Amiga version. 
