# 2022 Fork
The goal of this fork is to provide an easy way to build 18-sector 5.25" game disks on real Apple II hardware.  This fork also fixes a couple of bugs in the original game.

This fork includes the following additions:

* **[POP-Maker](pop-maker/)**: A menu-driven ProDOS application for creating 18-sector game disks on real hardware.
* **[Merlin 32](merlin32/)**: A version of the game source that will build on modern machines using the Merlin 32 assembler.
* **IIe Keyboard Fix**: Improve the keyboard controls on IIe and IIc hardware.

### Game Code Changes

The merlin32 directory contains a copy of the game code that will build on modern machines using the [Merlin 32 assembler from Brutal Deluxe](http://www.brutaldeluxe.fr/products/crossdevtools/merlin/). 

The code in the merlin32 directory fixes two bugs in the original game:

* [Improve keyboard controls on IIe and IIc hardware](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/965e19715de1a36014885bef0c77bfd7d7c00f71).  The original game has a bug that causes the keyboard controls to be unreliable on some IIe and IIc hardware (IIgs is not affected).  This change fixes that bug.
* [Fixed the "Waving Jordan" video easter egg on IIc hardware](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/49446e004231bd0725156b3f9fd8a7594f511bde).  The original easter egg did not run on IIc hardware due to differences in VBlank detection between the IIc and IIe/IIgs hardware.


The code also includes these changes:

* [Patched code for Merlin 32](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/b2750d3bf0c55f0e30085bb39027b4cd7e10e305).  The original code exposes some bugs in the Merlin 32 assembler.  This change works around those bugs.
* [Disable copy protection in 5.25" build](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/5d7208839bbddc081e6bb51b6c891a217f46d3aa).  This change is needed to allow the final Princess scene to run.
* [Added the boot-time easter eggs to the non-copy protected boot code](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/99f3cf118d4927276ee147c9524b0d8ea0cb179c).
* [Simplified VBlank detection on IIc](https://github.com/DarrenStone/Prince-of-Persia-Apple-II/commit/cb513f093ecafa6c17183e82681d65ea3293daee).  The original code worked, but was wrong.



---

[Jordan Mechner's GitHub Repository](https://github.com/jmechner/Prince-of-Persia-Apple-II)

# Prince of Persia Apple II

Some background: This archive contains the source code for the original Prince of Persia game that I wrote on the Apple II, in 6502 assembly language, between 1985-89. The game was first released by Broderbund Software in 1989, and is part of the ongoing Ubisoft game franchise.

For a capsule summary of Prince of Persia's 25-year history, and my involvement with its various incarnations, see [jordanmechner.com](https://jordanmechner.com/).

For those interested in a fuller understanding of the context -- creative, business, personal, and technical -- in which this source code was created, I've published my dev journals from that period. See [jordanmechner.com/books/journals](https://jordanmechner.com/books/journals).

For those who'd like to dig into the source code itself, I've posted an explanatory technical document at [jordanmechner.com/library](https://jordanmechner.com/library) which should help. This is a package I put together in October 1989 for the benefit of the teams that were undertaking the ports of POP to various platforms such as PC, Amiga, Sega, Genesis, etc.

Beyond that, please don't ask me to explain anything about the source code, because I don't remember! I hung up my 6502 programming guns in October 1989, and after two decades working primarily as a writer, game designer, and creative director, to say my coding skills are rusty would be an understatement.

Thanks to [Jason Scott](http://www.textfiles.com) and [Tony Diaz](http://www.apple2.org) for successfully extracting the source code from a 22-year-old 3.5" floppy disk archive, a task that took most of a long day and night, and would have taken much longer if not for Tony's incredible expertise, perseverence, and well-maintained collection of vintage Apple hardware.

We extracted and posted the 6502 code because it was a piece of computer history that could be of interest to others, and because if we hadn't, it might have been lost for all time. We did this for fun, not profit. As the author and copyright holder of this source code, I personally have no problem with anyone studying it, modifying it, attempting to run it, etc. Please understand that this does NOT constitute a grant of rights of any kind in Prince of Persia, which is an ongoing Ubisoft game franchise. Ubisoft alone has the right to make and distribute Prince of Persia games.

That's about all I know. If additional information becomes available, I'll post and/or tweet about it ([@jmechner](https://twitter.com/jmechner)). In the meantime, if you have questions -- technical, legal, or otherwise -- I recommend that you direct them to the community at large, whose collective knowledge and expertise far exceeds mine, and will only increase as more people get their eyes on this code.

As for me, it's time to get back to my day job of making new games and making up stories.

Have fun!

-- Jordan Mechner
