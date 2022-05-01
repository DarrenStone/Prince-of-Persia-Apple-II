

**************************************
** Print string in R1
**************************************

saveY db 0
saveX db 0
PrintString
    php
    pha
    sty saveY
    stx saveX
    ldy #0
    lda (R1),Y
    beq :done
    cmp #$FF        ; If first byte is $FF, then following data is a MultiString
    beq :doMulti
    tax
    iny
]next
    lda (R1),Y
    jsr COUT
    iny
    dex
    bne ]next
:done
    ldy saveY
    ldx saveX
    pla
    plp
    rts

:doMulti
    inc R1
    bne :1
    inc R1+1
:1  ldy saveY
    ldx saveX
    pla
    plp
    jmp PrintMultiString

PrintAscii
    php
    pha
    sty saveY
    stx saveX
    ldy #0
    lda (R1),Y
    beq :done
    tax
    iny
]next
    lda (R1),Y
    ora #$80
    jsr COUT
    iny
    dex
    bne ]next
:done
    ldy saveY
    ldx saveX
    pla
    plp
    rts

**************************************
** Print CR
**************************************
PrintCR
    pha
    lda #kCR
    jsr COUT
    pla
    rts

**************************************
** Print Space
**************************************
PrintSPC
    pha
    lda #kSpace
    jsr COUT
    pla
    rts

**************************************
** Print Hex in A
**************************************
PrintA
    pha
    jsr PRBYTE
    lda #" "
    jsr COUT
    pla
    rts

PrintACR
    pha
    jsr PrintA
    jsr PrintCR
    pla
    rts

DebugPrintA
    DO DEBUG
    jsr PrintA
    FIN
    rts

**************************************
** Print multiple strings, starting in R1
** String list terminated with $00
**************************************
PrintMultiString
    pha                 ; Save A and Y
    tya
    pha
    ldy #0

:nextString
    jsr PrintString     ; Print string in R1
    jsr PrintCR

                        ; Increment R1 point to the next string.

    lda (R1),y          ; Get the size of the string
    clc                 ; Add 1 (to skip over the size byte)
    adc #1
    sta :incSize        ; Store size in temp var
    lda R1              ; 16-bit increment R1 by :incSize
    clc
    adc :incSize
    sta R1
    bcc :1
    inc R1+1
:1
    lda (R1),y          ; Check for null
    bne :nextString

    pla                 ; Restore A and Y
    tay
    pla
    rts

:incSize db $00

**************************************
** Print 16-bit hex in R1
**************************************
Print16Hex
    pha
    sty saveY
    stx saveX
    lda #"$"
    jsr COUT
    ldy #0
    lda (R1),y
    pha
    iny
    lda (R1),y
    jsr PRBYTE   ; High Byte
    pla
    jsr PRBYTE   ; Low Byte
    ldy saveY
    ldx saveX
    pla
    rts

**************************************
** Print binary coded decimal in A
**************************************
PrintBCD
    pha
    pha
    lsr
    lsr
    lsr
    lsr
    beq :lowNybble
    clc
    adc #"0"
    jsr COUT
:lowNybble
    pla
    and #$0F
    clc
    adc #"0"
    jsr COUT
    pla
    rts

**************************************
** Copy String in R1 to R2
**************************************
StringCopy
    ldy #0
    lda (R1),y      ; Get string length and store in X
    tax
    beq :done
    sta (R2),y      ; Write the string length

:next
    iny             ; Copy chars until X is zero
    lda (R1),y
    sta (R2),y
    dex
    bne :next

:done
    rts


**************************************
** Clear screen and draw title bar
**************************************
ClearScreen
    jsr HOME
    MPrintStr sTitleBar

    ldx destSlot
    beq :done
    ldx destDrive
    beq :done
    lda #33
    sta CH
    lda #"S"
    jsr COUT
    jsr GetDestSlot
    jsr PrintBCD
    lda #" "
    jsr COUT
    lda #"D"
    jsr COUT
    lda destDrive
    jsr PrintBCD

:done
    lda #0
    jsr InvertTextRow
    lda #3
    jsr VTab
    rts

**************************************
** Invert a row of text
**************************************
; Row in A
InvertTextRow
    jsr BASCALC
    ldy #0
]1  lda (BASL),Y
    tax
    and #$E0
    cmp #$C0
    beq :upper
    txa
    and #$7F
    bne :out
:upper          ; Uppercase chars need top two bits cleared.  Others only clear top bit.
    txa
    and #$3F
:out
    sta (BASL),Y
    iny
    cpy #40
    bne ]1
    rts

**************************************
** Set V-Tab from A
**************************************
VTab
    sta CV
    lda #0
    sta CH
    jmp MON_VTAB


**
** Side A Paths
**
f_boot          str "obj/boot"
f_rw18          str "obj/rw18"
f_hires         str "obj/hires"
f_master        str "obj/master.525"
f_hrtables      str "obj/hrtables"
f_unpack        str "obj/unpack.525"
f_tables        str "obj/tables"
f_frameAdv      str "obj/frameadv"
f_grafix        str "obj/grafix.525"
f_topctrl       str "obj/topctrl"
f_imgBgTab1Dun  str "img/img.bgtab1.dun"
f_imgChTab1     str "img/img.chtab1"
f_imgChTab2     str "img/img.chtab2"
f_imgChTab3     str "img/img.chtab3"
f_imgChTab5     str "img/img.chtab5"
f_imgChTab4gd   str "img/img.chtab4.gd"
f_frameDef      str "obj/framedef"
f_seqTable      str "obj/seqtable"
f_ctrl          str "obj/ctrl"
f_coll          str "obj/coll"
f_gameBG        str "obj/gamebg"
f_auto          str "obj/auto"
f_imgBgTab2Dun  str "img/img.bgtab2.dun"
f_ctrlSubs      str "obj/ctrlsubs"
f_specialK      str "obj/specialk"
f_version       str "obj/version"
f_musicSet2     str "img/music.set2"
f_subs          str "obj/subs"
f_sound         str "obj/sound"
f_mover         str "obj/mover"
f_misc          str "obj/misc"
f_stage1SideA   str "img/stage1.sidea"
f_imgChTab7     str "img/img.chtab7"
f_imgChTab6a    str "img/img.chtab6.a"
f_princessSideA str "img/princess.sidea"
f_level2        str "lev/level2"
f_level0        str "lev/level0"
f_level1        str "lev/level1"
f_musicSet1     str "img/music.set1"

f_specialK_kbd  str "obj/specialk.kbd"
f_specialK_dev  str "obj/specialk.dev"
f_specialK_dbg  str "obj/specialk.dbg"
f_version_kbd   str "obj/version.kbd"
f_version_dev   str "obj/version.dev"
f_version_dbg   str "obj/version.dbg"

**
** Side B Paths
**
f_imgBgTab1Pal  str "img/img.bgtab1.pal"
f_imgBgTab2Pal  str "img/img.bgtab2.pal"
f_imgChTab4Skel str "img/img.chtab4.skel"
f_imgChTab4Gd   str "img/img.chtab4.gd"
f_imgChTab4Fat  str "img/img.chtab4.fat"
f_imgChTab4Shad str "img/img.chtab4.shad"
f_imgChTab4Viz  str "img/img.chtab4.viz"
f_loshow        str "obj/loshow"
f_loshowData    str "img/egg.loshow.dat"
f_gsEgg         str "img/egg.gs.scope"
f_stage1SideB   str "img/stage1.sideb"
f_imgChTab6B    str "img/img.chtab6.b"
f_princessSideB str "img/princess.sideb"
f_level14       str "lev/level14"
f_level13       str "lev/level13"
f_level12       str "lev/level12"
f_level11       str "lev/level11"
f_level10       str "lev/level10"
f_level9        str "lev/level9"
f_level8        str "lev/level8"
f_level7        str "lev/level7"
f_level6        str "lev/level6"
f_level5        str "lev/level5"
f_level4        str "lev/level4"
f_level3        str "lev/level3"
f_musicSet3     str "img/music.set3"



kCR = $8d
kSpace = " "
kESC = $9B
kCTRL = $60
kUpperCase = %1101_1111

sReading        str  "Reading "
sBytes          str " Bytes.",kCR
sOpenError      str "Can't open file:"
sReadError      str "Can't read file:"
sClosing        str "Closing "
sCloseError     str "Close Error:"
sWritingTrack   str "Writing Track "
sWriteError     str "Write Error:"
sVerifyError    str "Verify Error:"
sError          str "Error:"
sDone           str "Done.",kCR
sAborted        str "Aborted."
sFinished       str "Finished."

sHitAnyKey      str "Hit any key to continue."

sTitleBar       str "  POP MAKER v1.0  "
sIntroMulti     str " --------------------------------------"
                str "  Prince of Persia Disk Maker     v1.0"
                str "  Darren Stone               2022-3-11"
                str " --------------------------------------",kCR
                str "  This utility allows you to  create a"
                str "  real 18-sector Prince of Persia game"
                str "  disk on real hardware.",kCR
                str "  To begin, enter the location of your"
                str "  destination 5.25 disk drive.",kCR,kCR
                db 0
