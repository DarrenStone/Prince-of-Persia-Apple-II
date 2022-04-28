# Prince of Persia, Merlin 32 Version

This folder contains a version of the Prince of Persia game code that will build using the Merlin 32 assembler on modern hardware.  The code originated from the `04 Support` disk, which appears to be the closest to the final release code.

Merlin 32 can be downloaded from the [Brutal Deluxe website](http://www.brutaldeluxe.fr/products/crossdevtools/merlin/).

### Changes

The code includes these changes:

* [Patched code for Merlin 32](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/b2750d3bf0c55f0e30085bb39027b4cd7e10e305).  This change works around bugs in the Merlin 32 assembler.
* [Disable copy protection in 5.25" build](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/5d7208839bbddc081e6bb51b6c891a217f46d3aa).  This change is required to allow the final Princess scene to run.
* [Improve keyboard controls on IIe and IIc hardware](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/965e19715de1a36014885bef0c77bfd7d7c00f71).  The original game has a bug that causes the keyboard controls to be unreliable on some IIe and IIc hardware (IIGS is not affected).  This change fixes that bug.

### Build

1. Install Merlin 32 to your system.  
2. Edit `makefile` and set the path to your Merlin32 binary.
3. Run `make`

Example:

    cd merlin32
    make clean
    make
    make install
    
`make install` will copy the binaries to the [`../pop-maker/obj/`](../pop-maker/obj/) directory.

Visit the [pop-maker](../pop-maker/) directory for instructions on building 5.25" game disks.