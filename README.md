# Lotus STE

_Enhancements to the Atari ST version of Lotus Esprit Turbo Challenge to support STE hardware features_

![Screenshot of current progress](https://github.com/jonathanopalise/lotus-ste/blob/master/screenshot.png)

## Credits

* **Graphics enhancements**: Chicane/AF (Jonathan Thomas)
* **Sound enhancements**: Junosix/AF (Jamie Hamshere)
* **Loader and other technical assistance**: Grazey/PHF

**Thanks to**:

* **masteries/AF** - for providing the original sound mixer code, without which we might not have digital sound in this project
* **Defence Force/Dbug** - for code review and suggestions around performance optimisation
* **metalages/AF** - for ideas and discussion around the idea of a YM-based engine sound

_(AF = Atari-Forum - https://www.atari-forum.com/)_

## What STE enhancements have been made?

* The road is rendered by the Blitter and features graphical details resembling those of the Amiga version;
* All roadside scenery and cars are rendered by the Blitter at single-pixel horizontal accuracy (as opposed to at 16 pixel intervals on the standard ST version);
* The background mountains are rendered by the Blitter and scroll at single-pixel horizontal accuracy (as opposed to at 4 pixel intervals on the standard ST version);
* The sky features a gradient of raster bars resembling those of the Amiga version;
* The road and roadside colours are refined to leverage the enhanced STE colour palette;
* Sampled sound effects and engine noise are present.

Possible forthcoming objectives for this project are as follows:

* Fullscreen mode for player 1;
* New tracks, or modification to existing tracks;
* Modified trackside objects, or additional zoom levels for trackside objects.

## Does the enhanced game work on non-STE models?

The game will work on STF, STM, STFM and Mega ST models, but only if the machine has a Blitter chip fitted. In this case, only a subset of the full set of STE enhancements will be available:

* The sky gradient will feature less colours than on the STE;
* The road and roadside colours will be less refined than those on the STE;
* No sampled sound effects and engine noise will be available.

## Directory layout

Directory layout is as follows:

* `bin` - contains binary patches generated by means of compiling the code in `src`;
* `doc` - contains informal documentation pertaining to the reverse engineering efforts of the ST side;
* `gamefiles` - contains a `source` directory that must be manually populated with the contents of the Empire crack of Lotus (see below) before running the Makefile. Also contains a `destination` directory used as an intermediate step in the build process;
* `release` - contains a bootable disk image named `lotus_ste.st` upon successful completion of the build process.
* `src` - contains the core source code to generate the code for use on the ST side. There is a `generated` subdirectory within that contains machine generated source files;
* `util` - contains utilities for use in reverse engineering efforts.

## How to build

The build process is controlled by a `Makefile`. The `Makefile` is confirmed to work with Linux and OSX (thanks to [Rajesh Singh](https://github.com/shockdesign) for help with getting the build working on OSX). It could possibly be repurposed for Windows with some changes - please get in touch if you can help. Before attempting to run the `Makefile`, you'll need to obtain the "Empire" crack of Lotus, which needs to obtained separately from the usual channels. The filename of this disk image is `Lotus Esprit Turbo Challenge (1990)(Gremlin)[cr Empire][a].st` and the md5sum is `942911068dd0a82debfba6d45d3370c4`.

Once the disk image has been obtained, the `gamefiles/source` directory needs to be populated with the contents of the root directory of the above disk image. This can be done by using the Hatari emulator (https://hatari.tuxfamily.org/) to map a Gemdos hard drive to a directory on the host machine, entering the GEM environment on the Atari ST, and copying the files from drive A: to drive C:, at which point they should appear on the filesystem of the host machine, within the directory assigned to the Gemdos hard drive. The files will then need to be copied from this location to the `gamefiles/source` directory.

Following the above step, run `make` to start the build process. The following executable dependencies will need to be present in the path:

- `vasm` (http://sun.hasenbraten.de/vasm/)
- `vlink` (http://sun.hasenbraten.de/vlink/)
- `m68k-ataribrownest-elf-nm` (https://bitbucket.org/ggnkua/bigbrownbuild-git/src/master/)
- `php` (https://www.php.net/)
- `lz4` (https://github.com/lz4/lz4)
- `zip2st` (packaged with the Hatari emulator - https://hatari.tuxfamily.org/)
- `zip` (commonly packaged with Linux distributions)
- `upx` (https://upx.github.io/)

Should the build process succeed, there will be a `lotus_ste.st` file present within the `release` directory that can be run within an emulator such as Hatari (https://hatari.tuxfamily.org/) or transferred elsewhere to run on real STE hardware. Whether running on an emulator or real hardware, the machine will need to be configured as an STE with one meg or more of memory. In the event that the build process fails, please raise an issue against the project and I'll help in any way I can.
