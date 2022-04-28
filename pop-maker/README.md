# POP-Maker

POP-Maker is a ProDOS application that will create or patch 18-sector Prince of Persia game disks on real hardware.  

The application is distributed on three 5.25" disks, or a single 3.5" disk.  Both versions are self-booting ProDOS disks and contain all of the binary files necessary for creating complete game disks.



### Documentation

* [Instructions and Usage](MANUAL.md)
* [Build](BUILD.md)
* [Game Disk Layout](DISK-LAYOUT.md)

## Adam Green's Build

POP-Maker builds upon the excellent work that Adam Green did to reverse engineer the Prince of Persia game disks.  To read more about that work, visit the [Notes](../Notes/) folder.

#### POP-Maker Differences

* The Merlin 32 assembler supports 65816 instructions, so the game will now run correctly on Apple IIGS machines.
* The `VID.STUFF` binary was missing the last track of data (track 17), which caused the Waving Jordan animation easter egg to be truncated.  The binary has been replaced with the complete version.
