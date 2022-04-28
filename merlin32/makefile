# -------------------------------------------------------------------------
#
# Update these paths to match your build environment
#
# Merlin32 is available at https://www.brutaldeluxe.fr/products/crossdevtools/
#
# -------------------------------------------------------------------------

MERLIN=~/opt/bin/Merlin32
RM=rm -f
CP=cp

# -------------------------------------------------------------------------
#
# Usage:
#
# make                  Build Prince of Perisa object files.
# make clean	        Delete object files.
# make install          Copy object files to ../pop-maker/obj/ directory.
#
# -------------------------------------------------------------------------

OBJS_UNIVERSAL=AUTO BOOT COLL CTRL CTRLSUBS FRAMEADV FRAMEDEF GAMEBG  HIRES HRTABLES MISC MOVER RW18 SEQTABLE SOUND SPECIALK SUBS TABLES TOPCTRL VERSION

OBJS_525=GRAFIX.525 MASTER.525 UNPACK.525

OBJS_PATCHED=SPECIALK.DEV SPECIALK.DBG SPECIALK.KBD VERSION.KBD VERSION.DBG VERSION.DEV

OBJS=$(OBJS_UNIVERSAL) $(OBJS_525) $(OBJS_PATCHED)


ASM=$(MERLIN) -v ./


all: $(OBJS)

clean:
	$(RM) $(OBJS)
	$(RM) _FileInformation.txt
	$(RM) *_Output.txt

install: $(OBJS)
	$(CP) $(OBJS) ../pop-maker/obj/

./% : %.S
	$(ASM) $<

./RW18 : RW18525.S
	$(ASM) $<
