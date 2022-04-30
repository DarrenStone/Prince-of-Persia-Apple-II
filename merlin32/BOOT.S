EasterEggs = 1

*  boot
org = $800
 lst off
*-------------------------------
* $800 TS (0,0) boot sector

SLOT = $2b
sector = $50

text = $fb2f
home = $fc58
vtab = $FB5B
cout = $FDF0
normal = $fe84
pr0 = $fe93
in0 = $fe89

*-------------------------------
 org org

 hex 01

entry lda #$60
 sta entry

 ldx #$ff
 stx $4fb
 stx $3f3
 stx $3f4
 stx $c000 ;80store off
 stx $c002 ;RAMRD main
 stx $c004 ;RAMWRT main
 stx $c00c ;80col off
 stx $c00e ;Altcharset off
 stx $c081 ;write RAM, read ROM (2nd 4k bank)
 txs
 jsr text
 jsr home
 jsr normal
 jsr pr0
 jsr in0

 ldx SLOT
 txa
 lsr
 lsr
 lsr
 lsr
 ora #$c0
 sta :rdsect+2
 lda #$0f
 sta sector

:0 ldy sector
 lda skewtbl,y
 sta $3d
 lda sectaddr,y
 beq :1
 sta $27
:rdsect jsr $005c
:1 dec sector
 bne :0

 lda SLOT
 jmp $900

skewtbl hex 00,0d,0b,09,07,05,03,01
 hex 0e,0c,0a,08,06,04,02,0f


*
* 2022: If EasterEggs=0, BOOT code uses the first two physical sectors ($800 - $9E3)
*
*       If EasterEggs=1, BOOT code uses the first 6 physical sectors ($800 - $D4F).
*       Additionally, the GS easter egg code is loaded into address $1000-$11FF from 
*       sectors 13 and 14 (logical sectors $04 and $02).
*
*       On a retail copy-protected disk, BOOT code uses sectors 0-3 and 5-7 (easter eggs
*       plus copy protection code).  The sector 4 is the un-copyable bit-slip sector, 
*       and the last sector is the XOR decryption key for sectors 1-3 and 5-14.
*

    DO EasterEggs

*
* 2022 Easter Egg Boot
*
* Load the remaining fives pages of BOOT ($0900 to $0DFF), five pages of
* RW18 ($3000 to $34FF), and two pages of the GS Easter Egg ($1000 to $11FF)
*

sectaddr hex 00,09,0a,0b,0c,0d,00,00
 hex 30,31,32,33,34,10,11,00

    ELSE

*
* 1989 Dev Boot with no easter eggs.
*
* Load the second page of BOOT (to $0900), and the five pages of RW18 ($3000 to $34FF)
*

sectaddr hex 00,09,00,00,00,00,00,00
 hex 30,31,32,33,34,00,00,00

    FIN

*===============================
*  boot stage 2

rw18 = $d000

slot = $fd
track = $fe
lastrack = $ff

 dum $00

dest ds 2
source ds 2
endsourc ds 2

 dend
*-------------------------------
 ds $900-*

stage2 stx slot

 jsr check128k ;check for 128K memory

 jsr moverw18 ;& move RW18 to D000

 lda #0
 sta lastrack
 sta $3f3
 sta $3f4 ;zero reset vector

 jsr rw18
 hex 07,a9 ;Bbund ID byte

 jsr rw18
 hex 00,01,00 ;drive 1 on

 jsr rw18 ;seek track 1
 hex 02,00,01

* load & run stage 3 boot
* from drive 1

 jsr rw18
 hex c3,ee

 jmp $ee00

*-------------------------------------------------
* Check for AUX memory routine

CHECKER lda #$EE
 sta $C005
 sta $C003
 sta $0800
 lda $0C00
 cmp #$EE
 bne :0
 asl $0C00
 lda $0800
 cmp $0C00
 beq :1
:0 clc
:1 sta $C004
 sta $C002
 rts

CHECKEND = *-CHECKER

*-------------------------------------------------
*
* Check to make sure //c or //e
* with 128k
*
*-------------------------------
check128k
 sta $c081

 lda $FBB3 ;Apple // family ID byte
 cmp #6
 bne NOT128K ;Must be e/c/GS

 bit $C017
 bmi NOT128K

 ldx #CHECKEND
:0 lda CHECKER,X
 sta $180,X
 dex
 bpl :0

 jsr $180
 bcs NOT128K

 rts

*-------------------------------
* Turn off drive and display message

NOT128K ldx SLOT
 lda $C088,X

 jsr text
 jsr home
 lda #8
 jsr vtab

 ldy #0
:0 lda MEMTEXT,Y
 beq *
 jsr cout
 cmp #$8D
 bne :1
 lda #4
 sta $24
:1 iny
 bne :0

MEMTEXT hex 8D
 asc "REQUIRES A //C OR //E WITH 128K"
 hex 00

*-------------------------------
* Move RW18
* d0 < 30.40
*-------------------------------
moverw18
 bit $c08b
 bit $c08b ;rd/wrt RAM, 1st 4k bank

 lda #$d0
 ldx #$30
 ldy #$40

* a < x.y
* 20 < 40.60 means 2000 < 4000.5fffm
* WARNING: If x >= y, routine will wipe out 64k

movemem sta dest+1
 stx source+1
 sty endsourc+1

 ldy #0
 sty dest
 sty source
 sty endsourc

:loop lda (source),y
 sta (dest),y

 iny
 bne :loop

 inc source+1
 inc dest+1

 lda source+1
 cmp endsourc+1
 bne :loop

    DO EasterEggs
 beq yippee
    FIN
]rts rts

*-------------------------------

    DO EasterEggs

*
* The following code is copied from POPBOOT0.S, on disk "03 Disk Protection"
*

oscsh sec           ; IIGS Oscilloscope
 jsr $FE1F
 bcs *

 jsr $1000

 jmp ($FFFC)


yippee ldx SLOT     ; Easter Egg dispatcher
 lda $C061
 bpl ]rts
 lda $C062
 bpl ]rts
 lda $C000
 bpl ]rts
 bit $C010
 sta :cmp+1

 ldy #-3
:loop iny
 iny
 iny
 lda :dispatch,y
 beq ]rts
:cmp cmp #$11
 bne :loop

 lda :dispatch+1,y
 sta 0
 lda :dispatch+2,y
 sta 1

 bit $C081
 lda $C088,x

 jmp (0)

:dispatch hex FF
 da oscsh

 asc "!"
 da rcmess

 hex 8D
 da confusion

 asc "@"
 da rotcube

 asc "^"
 da drive

 db 0

*-------------------------------------------------
*
* motorcycle disk drive
*

drive lda $C089,x ;drive back on!

:loop lda $C087,x
 lda $C080,x
 jsr :delay
 lda $C085,x
 lda $C086,x
 jsr :delay
 lda $C083,x
 lda $C084,x
 jsr :delay
 lda $C081,x
 lda $C082,x
 jsr :delay
 jmp :loop

:delay lda #6
 sta 0

:del2 bit $C070
 nop
 nop
 bit $C064
 bmi *-3

 dec 0
 bne :del2
 rts

*------------------------------------------------- rotcube

mainYoffset = 46 ;(192-60)/2
botYoffset = 72
mainXoffset = 68 ;(280-144)/2

color = $E4
page = $E6

 dum 0
index ds 1
ysave ds 1
yadd ds 1
yoffset ds 1
 dend

*-------------------------------------------------

rotcube jsr $f3e2 ;hgr
 jsr $f3d8 ;hgr2

 lda #1
 sta yadd

 sta yoffset

* Draw on page not showing:

mainloop lda page
 eor #$60
 sta page
 ldx #$7F
 jsr draw

* If not a //c, then wait for vbl

 lda $FBC0
 beq :is2c
 lda $C019
 bpl *-3
 lda $C019
 bmi *-3
:is2c

* Now display that page

 bit $C054
 lda page
 cmp #$20
 beq *+5
 bit $C055

* Now erase old image from last page

 eor #$60
 sta :smc0+2
 sta :smc1+2
 ldx #$20
 lda #0
:loop tay
:smc0 sta $2000,y
:smc1 sta $2080,y
 iny
 bpl :smc0
 inc :smc0+2
 inc :smc1+2
 dex
 bne :loop

 inc index
 jmp mainloop

*-------------------------------------------------

draw stx color

 ldy #12-1
:drawloop lda drawlist,y
 sty ysave

 pha
 and #15
 jsr getpoint

 tax
 tya
 ldy #0
 jsr $f457 ;plot

 pla
 lsr
 lsr
 lsr
 lsr
 jsr getpoint
 ldx #0
 jsr $f53a ;lineto

 ldy ysave
 dey
 bpl :drawloop

 lda yoffset
 clc
 adc yadd
 bne :not0

 inc yadd ;make +1
 inc yadd

:not0 cmp #191-48-botYoffset
 bcc :0

 dec yadd ;make -1
 dec yadd

:0 sta yoffset
 rts

*-------------------------------------------------
*
* given a = point number, return a = xcoor, y = ycoor
*

getpoint tay

* Get index into tables

 asl ;*16
 asl
 asl
 asl
 adc index
 and #$3F
 tax
 tya

 and #4 ;bottom?
 cmp #4

* Compute ycoor

 lda ydata,x
 bcc :not_bot
 adc #botYoffset-1

:not_bot adc yoffset
 tay

* Compute xcoor

 lda xdata,x
 adc #mainXoffset
 rts

*-------------------------------------------------

drawlist hex 01122330 ;draw top
 hex 45566774 ;draw bottom
 hex 04152637 ;draw connecting lines

xdata hex 908F8E8C8A87837F7A757069635C564F
 hex 484039332C261F1A15100C0805030100
 hex 0000010305080C10151A1F262C333940
 hex 474F565C636970757A7F83878A8C8E8F

ydata hex 181A1C1E21232527282A2B2D2E2E2F2F
 hex 2F2F2F2E2E2D2B2A28272523211E1C1A
 hex 181513110E0C0A080705040201010000
 hex 000000010102040507080A0C0E111315

*------------------------------------------------- confusion

 dum 0
xr ds 1
yr ds 1
randseed ds 1
temp ds 1
 dend

hgr2 = $F3D8
plot = $F457
hcolor = $F6F0

* Confusion triangle

confusion lda #$7F
 sta $E4 ;hcolor=3

 jsr hgr2

* xr=xarray(0), yr=yarray(0)

 ldx xarray
 ldy yarray
 stx xr
 sty yr

* Plot that dot

:loop lda $C000
 bpl :nokey
 bit $C010
 cmp #$E0
 bcc *+4
 and #$DF
 cmp #"C"
 bne :nokey

:randcol jsr getrandcol
 sta temp
 jsr $F3F4 ;clear to that color

:randloop jsr getrandcol
 tax
 eor temp
 bmi :randloop ;different hi bits
 cpx temp ;same color
 beq :randloop

:nokey ldy #0
 lda xr
 asl
 tax
 bcc :skip
 iny
:skip lda yr
 jsr plot

 lda yr
 ldx $E0
 ldy $E1
 inx
 bne *+3
 iny
 jsr plot

* Get a random number between 0-2

 jsr random
 sec
:sub30 sbc #30
 bcs :sub30
 adc #30
 sec
:sub3 sbc #3
 bcs :sub3
 adc #3
 tax

*-----------
* xr stuff:
* determine which midpoint routine to use

 lda xarray,x
 cmp xr
 bge :xarr_xr

* If xarray(rand) < xr then:
* xr = xarray + ( xr - xarray) / 2

 lda xr
 sec
 sbc xarray,x
 lsr
 clc
 adc xarray,x
 jmp :sta_xr

* If xarray(rand) >= xr then:
* xr = xr + ( xarray - xr ) / 2

:xarr_xr lda xarray,x
 sec
 sbc xr
 lsr
 clc
 adc xr
:sta_xr sta xr

*-----------
* yr stuff:
* determine which midpoint routine to use

 lda yarray,x
 cmp yr
 bge :yarr_yr

* If yarray(rand) < yr then:
* yr = yarray + ( yr - yarray) / 2

 lda yr
 sec
 sbc yarray,x
 lsr
 clc
 adc yarray,x
 jmp :sta_yr

* If yarray(rand) >= yr then:
* yr = yr + ( yarray - yr ) / 2

:yarr_yr lda yarray,x
 sec
 sbc yr
 lsr
 clc
 adc yr
:sta_yr sta yr

 jmp :loop

xarray db 70,139,0
yarray db 0,191,191

random lda randseed
 adc #$23
 sta randseed
 eor $C020 ;a little randomness
 rts

getrandcol jsr random
 and #7
 tax
 jmp hcolor

*------------------------------------------------- rcmess

rcmess ldy #0
:0 lda :text,y
 beq :lores
 jsr $FDF0
 iny
 bne :0

:lores bit $c000
 bpl :lores

 sta $c00d ;80 col
 sta $c001 ;80 store
 bit $c056
 bit $c052
 bit $c050
 bit $c05e ;merez

:loop lda #$FF
 jsr :random
 sta $30 ;color

 lda #80 ;max x
 jsr :random
 lsr
 tay
 bit $c054
 bcs *+5
 bit $c055

 lda #48 ;max y
 jsr :random

 jsr $F800 ;plot

 jmp :loop

:random sta 1

 lda 0
 adc #$23
 sta 0
 eor $C020

 cmp 1
 bcc :ok
:loop2 sbc 1
 bcs :loop2
 adc 1

:ok rts

:text hex 8d8d
 asc "8/25/89",8d8d8d
 asc "Robert!",8d8d8d
 asc "Jordan and Roland wish you the very",8d8d
 asc "Brightest College Years.",8d8d8d8d8d
 asc "  meres !",8d,8d
 asc "    meres !",8d,8d
 asc "      meres !"
 brk

*------------------------------------------------- EOF

    FIN ; EasterEggs

 sav boot
