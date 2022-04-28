
# -------------------------------------------------------------------------
#
# Update these paths to match your build environment
#
# Merlin32 and Cadius are available at https://www.brutaldeluxe.fr/products/crossdevtools/
#
# -------------------------------------------------------------------------

MERLIN=~/opt/bin/Merlin32
CADIUS=~/opt/bin/cadius
RM=rm
CP=cp
THUMBDRIVE=/Volumes/IIGS
THUMBDRIVE_DEST=$(THUMBDRIVE)/Darren/


# -------------------------------------------------------------------------
#
# Usage:
#
# make                  Build popmaker and rw18 binaries
# make disk             Build popmaker and rw18 binaries and update disk images

# make all              Make all binaries and disks
# make alldisks         Build all disk images.

# make clean            Delete popmaker and rw18 binaries and related files
# make cleandisks       Delete disk images.
# make cleanall         Delete binaries and disk images.

# make disk35           Build a complete 3.5 disk image
# make disk525          Build three complete 5.25 disk images.

# make install          Copy disk images to USB drive (For transferring to Apple II hardware)
# make eject            Eject USB drive (macOS) 
#
# -------------------------------------------------------------------------


ASM=$(MERLIN) -v ./

OBJS=popmaker.system rw18.6900
SOURCES=popmaker.s diskscript.s prodos.s menu.s strings.s macs.s rw18api.s script.sidea.s script.sideb.s script.patches.s debugutil.s equates.s

DISK35=popmaker35.po
VOL35=popmaker.35
DISK51=popmaker525.1.po
DISK52=popmaker525.2.po
DISK53=popmaker525.3.po
# All 5.25 disks should have the same volume name to simplify disk switching code.
VOL51=popmaker.525
VOL52=popmaker.525
VOL53=popmaker.525


popmaker: $(OBJS)
# Merlin32 doesn't set the _FileInformation.txt properly for popmaker.system, so overwrite 
# it with the correct info
	$(CP) FileInformation.txt _FileInformation.txt

all: popmaker alldisks
	@echo Make All

disk: popmaker $(DISK35) $(DISK51)
	$(CADIUS) replacefile $(DISK35) /$(VOL35) ./popmaker.system
	$(CADIUS) replacefile $(DISK51) /$(VOL51) ./popmaker.system

alldisks: disk disk35 disk525
	@echo Make all disks

clean:
	-$(RM) $(OBJS) popmaker.system_Output.txt rw18.6900_Output.txt _FileInformation.txt

cleandisks: clean35 clean525
	@echo Clean Disks

cleanall: clean cleandisks
	@echo Clean All

disk35: $(OBJS) $(DISK35)
	@echo Make 3.5 Disk

disk525: $(OBJS) $(DISK51) $(DISK52) $(DISK53)
	@echo Make 5.25 Disks

install: alldisks
	$(CP) $(DISK35) $(THUMBDRIVE_DEST)
	$(CP) $(DISK51) $(THUMBDRIVE_DEST)
	$(CP) $(DISK52) $(THUMBDRIVE_DEST)
	$(CP) $(DISK53) $(THUMBDRIVE_DEST)

eject:
	diskutil eject $(THUMBDRIVE)

popmaker.system: $(SOURCES)
	$(ASM) popmaker.s

rw18.6900: rw18.6900.s
	$(ASM) rw18.6900.s

clean35:
	-$(RM) $(DISK35)

clean525:
	-$(RM) $(DISK51) $(DISK52) $(DISK53)

$(DISK35):
	$(CADIUS) createvolume $(DISK35) $(VOL35) 800kB
	$(CADIUS) addfile $(DISK35) /$(VOL35)/ system/PRODOS
	$(CADIUS) addfile $(DISK35) /$(VOL35)/ ./popmaker.system
	$(CADIUS) addfile $(DISK35) /$(VOL35)/ system/BITSY.BOOT
	$(CADIUS) addfile $(DISK35) /$(VOL35)/ system/QUIT.SYSTEM
	$(CADIUS) addfile $(DISK35) /$(VOL35)/ ./rw18.6900
	$(CADIUS) addfolder $(DISK35) /$(VOL35)/obj ./obj
	$(CADIUS) addfolder $(DISK35) /$(VOL35)/img ./img
	$(CADIUS) addfolder $(DISK35) /$(VOL35)/lev ./lev

$(DISK51):
	$(CADIUS) createvolume $(DISK51) $(VOL51) 140kB
	$(CADIUS) addfile $(DISK51) /$(VOL51)/ system/PRODOS
	$(CADIUS) addfile $(DISK51) /$(VOL51)/ ./popmaker.system
	$(CADIUS) addfile $(DISK51) /$(VOL51)/ system/BITSY.BOOT
	$(CADIUS) addfile $(DISK51) /$(VOL51)/ system/QUIT.SYSTEM
	$(CADIUS) addfile $(DISK51) /$(VOL51)/ ./rw18.6900
	$(CADIUS) createfolder $(DISK51) /$(VOL51)/obj
	$(CADIUS) createfolder $(DISK51) /$(VOL51)/img
	$(CADIUS) createfolder $(DISK51) /$(VOL51)/lev
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/BOOT
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/RW18
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/HIRES
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/MASTER.525
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/HRTABLES
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/UNPACK.525
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/TABLES
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/FRAMEADV
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/GRAFIX.525
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/TOPCTRL
	$(CADIUS) addfile $(DISK51) /$(VOL51)/img/ img/IMG.BGTAB1.DUN
	$(CADIUS) addfile $(DISK51) /$(VOL51)/img/ img/IMG.CHTAB1
	$(CADIUS) addfile $(DISK51) /$(VOL51)/img/ img/IMG.CHTAB2
	$(CADIUS) addfile $(DISK51) /$(VOL51)/img/ img/IMG.CHTAB3
	$(CADIUS) addfile $(DISK51) /$(VOL51)/img/ img/IMG.CHTAB5
	$(CADIUS) addfile $(DISK51) /$(VOL51)/img/ img/IMG.CHTAB4.GD
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/FRAMEDEF
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/SEQTABLE
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/CTRL
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/COLL
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/CTRLSUBS
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/SPECIALK
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/SPECIALK.DBG
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/SPECIALK.DEV
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/SPECIALK.KBD
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/VERSION
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/VERSION.DBG
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/VERSION.DEV
	$(CADIUS) addfile $(DISK51) /$(VOL51)/obj/ obj/VERSION.KBD

$(DISK52):
	$(CADIUS) createvolume $(DISK52) $(VOL52) 140kB
	$(CADIUS) createfolder $(DISK52) /$(VOL52)/obj
	$(CADIUS) createfolder $(DISK52) /$(VOL52)/img
	$(CADIUS) createfolder $(DISK52) /$(VOL52)/lev
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/GAMEBG
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/AUTO
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/IMG.BGTAB2.DUN
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/CTRLSUBS
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/SPECIALK
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/VERSION
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/MUSIC.SET2
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/SUBS
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/SOUND
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/MOVER
	$(CADIUS) addfile $(DISK52) /$(VOL52)/obj/ obj/MISC
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/STAGE1.SIDEA
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/IMG.CHTAB7
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/IMG.CHTAB6.A
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/PRINCESS.SIDEA
	$(CADIUS) addfile $(DISK52) /$(VOL52)/lev/ lev/LEVEL2
	$(CADIUS) addfile $(DISK52) /$(VOL52)/lev/ lev/LEVEL0
	$(CADIUS) addfile $(DISK52) /$(VOL52)/lev/ lev/LEVEL1
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/MUSIC.SET1
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/IMG.BGTAB1.PAL
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/IMG.BGTAB2.PAL
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/IMG.CHTAB4.SKEL
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/IMG.CHTAB4.GD
	$(CADIUS) addfile $(DISK52) /$(VOL52)/img/ img/IMG.CHTAB4.FAT

$(DISK53): 
	$(CADIUS) createvolume $(DISK53) $(VOL53) 140kB
	$(CADIUS) createfolder $(DISK53) /$(VOL53)/obj
	$(CADIUS) createfolder $(DISK53) /$(VOL53)/img
	$(CADIUS) createfolder $(DISK53) /$(VOL53)/lev
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/IMG.BGTAB1.DUN
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/IMG.BGTAB2.DUN
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/IMG.CHTAB4.SHAD
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/IMG.CHTAB4.VIZ
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/VID.STUFF.0C
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/STAGE1.SIDEB
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/IMG.CHTAB6.B
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/PRINCESS.SIDEB
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL14
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL13
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL12
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL11
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL10
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL9
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL8
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL7
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL6
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL5
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL4
	$(CADIUS) addfile $(DISK53) /$(VOL53)/lev/ lev/LEVEL3
	$(CADIUS) addfile $(DISK53) /$(VOL53)/img/ img/MUSIC.SET3
