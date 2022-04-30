# POP-Maker Manual
POP-Maker is a ProDOS application that will create or patch 18-sector Prince of Persia game disks on real hardware.  

The main advantage of 18-sector disks is speed.  The RW18 disk routines can read a full track in a single disk rotation (about 1/4 of a second), which is about twice as fast as a typical 16-sector disk.  The main disadvantage is that they're hard to copy.  

POP-Maker features a menu-driven user interface.  You can press a number to select a menu item, and you can hit escape at any time to cancel an operation or go back to a previous menu.

The application is distributed on three 5.25" disks, or a single 3.5" disk.  Both versions are self-booting ProDOS disks and contain all of the binary files necessary for creating complete game disks.

The 3.5" disk version can be copied to ProDOS hard drive folder.

### Requirements

* 128 kB Apple IIe, IIc, or IIGS
* One 5.25" drive to act as the destination drive.
* One other ProDOS drive or folder to act as the source drive.
* One blank 5.25" disk (formatted and double-sided).

*Your blank game disk must already be formatted as either DOS 3.3 or ProDOS using the disk utility of your choice.  In reality, only Side A/Track 0 needs to be formatted, but it's a good idea to do a complete format to ensure that the disk is good.*


#### 5.25" version notes

* The 5.25" version of POP-Maker requires two 5.25" disk drives; one as the source drive, and one as the destination drive.
* All three POP-Maker disks have the same ProDOS volume name, and all must be used from the same source drive.

## Usage

### Create a new original game disk

This process will create a new 18-sector game disk identical to the original release version.

1. Format a blank, double-sided, 5.25" disk using the disk utility of your choice (DOS 3.3 or ProDOS).
* Start `popmaker.system`.  You'll be prompted to enter the location of your destination drive (slot and drive number).
* Choose **Create New Game Disk** from the menu (press "1").
* Choose **Create New Game Disk (Side A)** from the menu.
* Insert your blank, formatted game disk into the destination drive, then hit any key to begin.

When that process completes, flip over your game disk and choose **Create New Game Disk (Side B)**.

### Patch an existing game disk 
This process will patch an existing 18-sector game disk with one of the four alternate versions.

1. Start `popmaker.system`, then enter the location of your destination drive.
* Choose **Patch Existing Game Disk** from the menu.
* Insert your existing game disk (Side A) into the destination drive, then hit any key.  The current version of your game disk will be displayed at the top of the screen.
* Select a patch version from the menu.

When the patch is complete, you will be returned to the patch menu.

## Game Versions

POP-Maker can create four versions of the game (Side B is the same for all versions).

### Original Release

This version is identical to the original release version circa February 5, 1990, except that the copy protection has been disabled.

### IIe Keyboard Fix

This version fixes a bug in the original code that could cause the keyboard controls to be unreliable on IIe and IIc hardware.  The bug is not present on IIGS hardware, or in most emulators.

### Development Version

This version enables the development cheat keys, and also includes the keyboard fix.  Keyboard commands are listed below.

### Debug Version

This version enables the development and debug cheat keys, and also includes the keyboard fix.  Keyboard commands are listed below.

## Prince of Persia Keyboard Commands

### Standard Keys

These commands are available in all versions.

| Key        | Command                               |
|------------|---------------------------------------|
| `CTRL+L`   | Load saved game (use at title screen) |
| `CTRL+G`   | Save Game (levels 3 to 12 only)       |
| `CTRL+S`   | Disable Sound                         |
| `CTRL+N`   | Disable Music                         |
| `CTRL+J`   | Enable Joystick Controls              |
| `CTRL+K`   | Enable Keyboard Controls              |
| `CTRL+A`   | Restart Level                         |
| `CTRL+R`   | Return to Title Screen                |
| `S K I P`  | Skip to next level, up to level 4.    |
| `Spacebar` | Show time remaining                   |
| `CTRL-V`   | Show game version                     |

### Development Keys

These commands are available in the Development and Debug versions, after entering `P O P`.

| Key        | Command                               |
|------------|---------------------------------------|
| `P O P`    | Enable the cheat keys.                |
| `S K I P`  | Skip to next level, up to level 12.   |
| `R`        | Increase player strength by one.      |
| `B O O S T`| Increase player strength to maximum.  |
| `Z`        | Decrease guard strength to minimum.   |
| `Z A P`    | Kill the guard.                       |
| `T I N A`  | Jump to the final Princess level.     |

### Debug Keys

These commands are available in the Debug version, after entering `P O P`.

| Key        | Command                               |
|------------|---------------------------------------|
| `P O P`    | Enable the cheat keys.                |
| `G O # #`  | Jump to a specific level (04 to 12)   |
| `S`        | Increase player strength              |
| `D`        | Decrease player strength              |
| `F`        | Maximum player strength               |
| `)`        | Jump ahead one level                  |
| `+`        | Jump ahead five levels                |
| `#` (0 to 9)| Set guard attack strategy            |
| `]`        | Speed up game (full speed is default) |
| `[`        | Slow down game                        |
| `@`        | Save screenshot to tracks 22 and 23.  |
| `A`        | Toggle auto/manual guard control.  When manual control is enabled, guard is controlled by whichever controls (keyboard or joystick) are not used by the player.|
| `<`        | Add one minute to time remaining.     |
| `>`        | Subtract minute from time remaining.  |
| `M`        | Set time to zero and end game.        |
| `*`        | Erase save-game data.                 |
| `CTRL+C`   | Reload code and images.               |
| `CTRL+E`   | Move player up one block level.       |  
| `CTRL+P`   | Return to level 1.                    |
| `CTRL+F`   | Full screen redraw.                   |
| `B`        | Toggle Blackout Mode (don't erase sprites). |
| `CTRL+Q`   | Antimatter Mode (disable collision detection for 17 frames). |

## Easter Eggs

### Boot-time Easter Eggs

At boot time (while the drive is seeking to track zero) press one of the keys below, then hold down Open-Apple and Closed-Apple until the easter egg begins.

| Key        | Command                               |
|------------|---------------------------------------|
| `Delete`   | Oscilloscope (IIGS Only).  Hit arrow keys to change timing.  Hit space bar to change from vertical and horizontal orientation.  Hold Command key to pause scope.  Runs best when GS is running in fast mode.|
| `!`        | A secret message for Robert from 8/25/89, then a double-low-res animation. |
| `Return`   | 'Confusion' Sierpinski Triangle.  Hit `C` to change color. |
| `@`        | Rotating 3D-cube animation. |
| `^`        | Make your disk drive sound like a motorcycle engine (not recommended).  Move joystick to rev engine/damage your drive. |

### Waving Jordan Mechner

1. Skip to level 3.  (Type `S K I P` to skip a level)
2. Hit `Ctrl+A` to restart the level.
3. Immediately hit `^` (Shift 6) as the level start to reload.

Note: Animation does not currently run on IIc hardware, due to incorrect VBLANK detection.