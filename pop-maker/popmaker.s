
DEBUG       = 0 ; enables debug prints.
DEBUG_MENU  = 0 ; enables debug menu.

                use macs
                put equates

**
** Memory Map
**
** $2000-4AFF Our Code
** $4B00-4B40 Our ProDOS root path
** $4B41-4Bff Free
** $4C00-52FF Track 0 staging area (7 pages)
** $5300-64FF RW18 Input/Output Buffer (18 pages)
** $6500-68FF ProDOS working buffer (always 1 kB, 4 pages)
** $6900-7900 RW18 Driver
**

prodosBuffer    = $6500 ; $6500-68FF ProDOS working buffer (always 1 kB, 4 pages)
stagingBuffer   = $4C00 ; $4C00-52FF Track 0 staging area (BOOT needs 7 pages, RW18 needs 5)
rw18Buffer      = $5300 ; $5300-64FF RW18 Input/Output Buffer (18 pages)
rootPath        = $4B00 ; 64 bytes, 4B00-4B40
tmpPath         = $4B41

rw18BufferSize    = 18
stagingBufferSize = 7


**************************************
**
**  Entry Point
**
**************************************

                org $2000
                jmp PopMakerInit

**************************************
*
* Global variables
*
**************************************
destSlot        = rw18Slot
destDrive       db 0        ; 1 or 2
sourceSlot      db 0        ; Slot 1-7 shifted to high byte.
sourceDrive     db 0        ; Drive 1 or 2
hasTrackZero    db 0        ; Non-zero if we think we know the
                            ; position of the destination drive head.

**************************************
**
**  PopMakerInit
**
**************************************

PopMakerInit
    ldx #$FF            ; Init Stack
    txs
    sei                 ; Disable interrupts

    jsr $c300           ; Enable 80-col firmware for lowercase inverse text
    lda #kSet40Cols     ; Stay in 40-column mode
    jsr COUT

    jsr DisplayIntro    ; Welcome message

    jsr DOSInitSystem   ; Init ProDOS System
                        ; - Get Prefix
                        ; - Get Current slot/drive
    bcs Quit

    jsr DisplaySource   ; Display Source Prefix, Slot, and Drive

    jsr LoadRW18        ; Load RW18 to $6900
    bcs Quit

    jsr DOSSetSystemBitmap ; Set ProDOS system memory bitmap

    jsr GetDestDrive    ; Prompt for dest slot and drive
    bcs Quit

    jsr RWInit          ; Set dest slot/drive in RW18 API

    jsr MainMenu        ; Run main menu
                        ;   then fall-through to Quit

**************************************
**
**  Quit - Prompt to boot slot 6 or quit to ProDOS.
**
**************************************
Quit
    MPrintStr :quitMessage1
    jsr GetDestSlot
    jsr PrintBCD
    MPrintCRStr :quitMessage2
    jsr WaitForKey
    and #kUpperCase
    cmp #"B"
    beq :boot
    clc
    jmp DOSQuit

:boot                   ; e.g., JMP $C600
    jsr GetDestSlot
    and #$07
    ora #$C0
    sta :jump+2
    jsr ClearScreen
:jump jmp $C000

:quitMessage1 str kCR,"Hit 'B' to boot slot "
:quitMessage2 str kCR,"Hit any other key to return to ProDOS."

**************************************
**
**  DisplayIntro
**
**************************************
DisplayIntro
    jsr HOME
    MPrintStrMulti sIntroMulti
    rts

**************************************
**
**  DisplaySource
**
**************************************
DisplaySource
    MPrintStr :sSourcePrefix
    MLoadR1 rootPath
    jsr PrintAscii
    jsr PrintCR
    MPrintStr sSlotPrompt
    lda sourceSlot
    lsr
    lsr
    lsr
    lsr
    clc
    adc #"0"
    jsr COUT
    jsr PrintCR
    MPrintStr sDrivePrompt
    lda sourceDrive
    clc
    adc #"0"
    jsr COUT
    jsr PrintCR
    jsr PrintCR
    rts

:sSourcePrefix  str "Source Path: "

**************************************
**
**  LoadRW18
**
**************************************
LoadRW18
    MSetPathName :rw18Path
    MSetWord dosReadInBuffer;$6900
    MSetWord dosReadReqLen;$1000
    jsr DOSLoadFile
    bcs :error
    rts

:error
    MPrintStr :noRW18
    sec
    rts

:rw18Path str "rw18.6900"
:noRW18 str kCR,"Couldn't load RW18.6900",kCR



***************************************
**
** MainMenu
**
***************************************
MainMenu
    MSetWord menuTable;:menuTable
    jmp RunMenu

    DO DEBUG_MENU

:menuTable
    da :sTitle
    db 5
    da :sCreateNewDisk,CreateMenu
    da :sPatchExisting,PatchMenu
    da :sSetDest,GetDestDrive
    da :sDebugMenu,DebugMenu
    da :sQuit,$0000
    da $0000

    ELSE

:menuTable
    da :sTitle
    db 4
    da :sCreateNewDisk,CreateMenu
    da :sPatchExisting,PatchMenu
    da :sSetDest,GetDestDrive
    da :sQuit,$0000
    da $0000

    FIN

:sTitle         str "MAIN MENU",kCR
:sCreateNewDisk str "Create New Game Disk..."
:sPatchExisting str "Patch Existing Game Disk..."
:sSetDest       str "Set Destination Drive"
:sDebugMenu     str "Debug Menu"
:sQuit          str "Quit"

***************************************
**
** CreateMenu
**
***************************************
CreateMenu
    MSetWord menuTable;:menuTable
    jmp RunMenu

:menuTable
    da :sTitle
    db 5
    da :sCreateSideA,CreateSideA
    da :sCreateSideB,CreateSideB
    da :sVerifyA,VerifySideA
    da :sVerifyB,VerifySideB
    da :sQuit,$0000
    da $0000

:sTitle         str "CREATE NEW DISK",kCR
:sCreateSideA   str "Create New Game Disk (Side A)"
:sCreateSideB   str "Create New Game Disk (Side B)"
:sVerifyA       str "Verify Side A"
:sVerifyB       str "Verify Side B"
:sQuit          str "Return to main menu"

***************************************
**
** CreateNewPopDisk Sides A and B
**
***************************************
CreateSideA
    jsr PromptForSideA
    bcs :rts
    jsr ClearScreen
    jsr LoadBootTrack
    bcs :aborted
    lda $c000
    cmp #kESC
    beq :aborted

    jsr WriteSideA
    jmp _ReturnToMenu

:rts rts

:aborted
    MPrintCRStr sAborted
    jmp _ReturnToMenu

***************************************
CreateSideB
    jsr PromptForSideB
    bcs :rts
    jsr ClearScreen
    jsr WriteSideB
    jmp _ReturnToMenu

:rts rts

_ReturnToMenu
    MPrintStr :sReturnToMenu
    jsr WaitForKey
    rts

:sReturnToMenu str kCR,"Hit any key to return to menu."


***************************************
**
** Prompts for Side A and B
**
***************************************

PromptForSideA
    jsr ClearScreen
    MPrintStr sInsertSideA
    jsr PrintDestDrive
    MPrintStrMulti sInsertSideA2
    jmp _FinishPrompt

***************************************
PromptForSideB
    jsr ClearScreen
    MPrintStr sInsertSideB
    jsr PrintDestDrive
    MPrintStrMulti sInsertSideB2

_FinishPrompt
    MPrintStrMulti sInsertSideClosing
    jmp HitAnyKeyToBegin

sInsertSideA str "Insert GAME DISK SIDE A into ",kCR
sInsertSideB str "Insert GAME DISK SIDE B into ",kCR
sInsertSideA2
    str ".",kCR,kCR,"NOTE",kCR
    str "- Side A/Track 0 must already be"
    str "  formatted. (ProDOS or DOS 3.3)",kCR
    str "- The rest of the tracks will be"
    str "  reformatted.",kCR
    db 0
sInsertSideB2
    str ".",kCR,kCR,"NOTE",kCR
    str "- Side B will be reformatted.",kCR
    db 0
sInsertSideClosing
    str "- Hit Escape at any time to cancel.",kCR
    db 0
sHitAnyKeyToBegin
    str "-= Hit any key to begin =-"

***************************************
PrintDestDrive
    MPrintStr sSlot
    jsr GetDestSlot
    jsr PrintBCD
    MPrintStr sComma
    MPrintStr sDrive
    lda destDrive
    jsr PrintBCD
    rts

PrintSourceDrive
    MPrintStr sSlot
    lda sourceSlot
    lsr
    lsr
    lsr
    lsr
    jsr PrintBCD
    MPrintStr sComma
    MPrintStr sDrive
    lda sourceDrive
    jsr PrintBCD
    rts

***************************************
HitAnyKeyToBegin
    lda #22
    jsr VTab
    lda #6
    sta CH
    MPrintStr sHitAnyKeyToBegin
    clc
    jmp WaitForKeyOrEscape


sSlot           str "Slot "
sDrive          str "Drive "
sComma          str ", "


***************************************
VerifySideA
    jsr ClearScreen
    MPrintStr sInsertSideA
    jsr PrintDestDrive
    jsr HitAnyKeyToBegin
    bcs :rts
    jmp RWVerifySideA
:rts rts

***************************************
VerifySideB
    jsr ClearScreen
    MPrintStr sInsertSideB
    jsr PrintDestDrive
    jsr HitAnyKeyToBegin
    bcs :rts
    jmp RWVerifySideB
:rts rts


**************************************
**
** LoadBootTrack
**
** Load BOOT to stagingBuffer, then map it into rw18Buffer via MMovePages
** Load RW18 to stagingBuffer, then map it into rw18Buffer via MMovePages
** Write 16 pages in rw18Buffer to track 0
**
**************************************
LoadBootTrack
    lda #>rw18Buffer     ; Clear the staging and output buffers
    ldy #rw18BufferSize
    jsr ClearBuffer

*
* Set ProDOS Read Buffer
*
    lda #stagingBufferSize
    sta dosReadReqLen+1
    lda #0
    sta dosReadReqLen
    MSetWord dosReadInBuffer;stagingBuffer

*
* Load the BOOT into staging buffer
*
:loadBoot
    jsr :clearStagingBuffer
    MSetPathName f_boot
    jsr DOSLoadFile
    bcs :checkDisk
    MMovePages bootSource;bootDest;bootPageCount

*
* Load RW18 to staging buffer
*
    jsr :clearStagingBuffer
    MSetPathName f_rw18
    jsr DOSLoadFile
    bcs :rts
    MMovePages rw18Source;rw18Dest;rw18Count

*
* Load EGG.GS.SCOPE to staging buffer
*
    jsr :clearStagingBuffer
    MSetPathName f_gsEgg
    jsr DOSLoadFile
    bcs :rts
    MMovePages gsEggSource;gsEggDest;gsEggCount

*
* Write the output buffer to track 0
*
    jsr WriteTrackZero
:rts
    rts
    
* Check Disk.  If file not found then prompt for Disk 1; otherwise, fail.
:checkDisk
    cmp #kDOSFileNotFound
    bne :fail
    jsr PromptForDisk1
    bcc :tryAgain
:fail
    sec
    rts
    
:tryAgain
    jmp :loadBoot

:clearStagingBuffer
    lda #>stagingBuffer
    ldy #stagingBufferSize
    jmp ClearBuffer

bootSource      db 0, 1, 2, 3, 4, 5, 6
bootDest        db 0,14,13,12,11,10, 9
bootPageCount   = *-bootDest
rw18Source      db 0,1,2,3,4
rw18Dest        db 7,6,5,4,3
rw18Count       = *-rw18Dest
gsEggSource     db 0,1
gsEggDest       db 2,1
gsEggCount      = *-gsEggDest


PromptForDisk1
    MPrintCRStr :sInsertDisk1
    jsr PrintSourceDrive
    jsr PrintCR
    jmp WaitForKeyOrEscape

:sInsertDisk1 str kCR,"Insert POPMAKER DISK 1 to ",kCR

**************************************
**
** WriteTrackZero
**
** Write rw18Buffer to 16-sector track zero
**
**************************************
WriteTrackZero
    MPrintStr sWritingTrack
    lda #"0"
    jsr COUT
    jsr PrintCR

    jsr RWSeekToTrack0

*
* Set ProDOS block unit
*
    lda #0
    ldx destDrive
    cpx #2
    bne :slot
    lda #$80
:slot
    ora destSlot    ; destSlot is already shifted to upper nybble
    sta dosWriteBlockUnit

*
* Write 8 blocks from $rw18buffer
*
    lda #>rw18Buffer
    clc
    adc #$10
    sta :endPage            ; End of buffer, >rw18Buffer + $10

    lda #>rw18Buffer
    sta dosWriteBlockAddr+1
*
* Start at block 0
*
    lda #0
    sta dosWriteBlockNum
    sta dosWriteBlockNum+1

:next
    jsr DOSWriteBlock
    bcs :rts

    inc dosWriteBlockNum       ; Inc block number.  Max is 8
    lda dosWriteBlockAddr+1    ; Inc source page by 2.  Max is :endPage
    clc
    adc #2
    sta dosWriteBlockAddr+1
    cmp :endPage
    BRLessThan :next

*
* We know we're at track zero, so update the rw18 track state.
*
    lda #0
    sta rw18Track
    sta rw18CurrTrack
    clc
:rts
    rts

:endPage db $00

**************************************
**
** Move page from stagingBuffer to rw18Buffer
**
** A = Source page in stagingBuffer
** X = Dest page in rw18Buffer
**
**************************************
MovePage
    pha
    stx saveX
    sty saveY
    clc
    adc #>stagingBuffer
    sta :inputPage
    txa
    clc
    adc #>rw18Buffer
    sta :outputPage

    ldx #0
]1  lda stagingBuffer,X
:inputPage = *-1
    sta rw18Buffer,X
:outputPage = *-1
    inx
    bne ]1

    ldx saveX
    ldy saveY
    pla
    rts

**************************************
**
** Move multiple pages from stagingBuffer to rw18Buffer
**
** R1 = Address of source array
** R2 = Address of dest array
** a = Number of pages to move.  Both arrays must be this size
**
**************************************
MovePages
    cmp #0
    beq :done
    sta movePageCount
    ldy #0

]nextPage
    lda (R2),y
    tax
    lda (R1),y
    jsr MovePage
    iny
    dec movePageCount
    bne ]nextPage

:done
    rts

movePageCount   db $00

**************************************
**
** Clear Y pages from A
**
**************************************
ClearBuffer
    ldx #0
    sta :page
    lda #0
]1  sta $FF00,X
:page = *-1
    inx
    bne ]1
    inc :page
    dey
    bne ]1
    clc
    rts

***************************************
**
** PatchMenu
**
***************************************
PatchMenu
    jsr ClearScreen
    MPrintStrMulti :sIntroMulti
    jsr PrintDestDrive
    jsr PrintCR
    MPrintCRStr sHitAnyKey
    jsr PrintCR
    jsr WaitForKeyOrEscape
    bcs :rts
    jsr ClearScreen
    jsr LoadVersion
    bcs :rts

    MSetWord menuTable;:menuTable
    MSetWord menuSubtitles;:subtitles
    jmp RunMenu

:rts rts

:menuTable
    da :sMenuTitle
    db 5
    da :sReleasePatch,ReleasePatch
    da :sKeyboardPatch,KeyboardPatch
    da :sDevPatch,DevPatch
    da :sDebugPatch,DebugPatch
    da :sQuit,$0000
    da $0000

:subtitles
    da :sReleaseSubtitle
    da :sKeyboardSubtitle
    da :sDevSubtitle
    da :sDebugSubtitle
    da $0000

:sReleasePatch      str "ORIGINAL RELEASE"
:sReleaseSubtitle   str "Version 1.0 (2/5/90)"
:sKeyboardPatch     str "KEYBOARD PATCH (2/15/22)"
:sKeyboardSubtitle  str "Improves keyboard support on",kCR,"   older //e and //c machines."
:sDevPatch          str "DEVELOPMENT BUILD"
:sDevSubtitle       str "Enables development cheat keys."
:sDebugPatch        str "DEBUG BUILD"
:sDebugSubtitle     str "Enables dev and debug keys."
:sQuit              str "Return to main menu."

:sIntroMulti
    str "Patch Existing Game Disk",kCR
    str "--------------------------",kCR
    str "Insert Game Disk (SIDE A) into "
    db 0

:sMenuTitle db $FF          ; FF means MultiString terminated with $00
    str "Current Version"
    str "---------------"
_versionBuffer
    db 40
    ds 40," "
    str "Select a patch:"
    db 0

***************************************
**
** Load version string from track 19, side a, and print it.
**
** Carry set on fail.
**
***************************************
LoadVersion
    MPrintCRStr :sLoading

*
* Clear versio string buffer
*
    ;; Set up buffer
    ldx #40
    lda #" "
]1  sta _versionBuffer,x
    dex
    bne ]1

*
* Seek to track 19
*
    lda hasTrackZero    ; Check if we need to locate the drive head.
    bne :simpleSeek
    jsr RWSeekToTrack0

:simpleSeek
    jsr RWSetSideA

*
* Load track 19  to rw18Buffer.
* Version String is at offset $11D8 ($1200 - 40)
    lda #19
    jsr RWReadTrack
    bcs :error

*
* Set the read pointer high byte by adding $11 to rw18Buffer high byte
*
    lda #>rw18Buffer
    clc
    adc #$11
    sta :addr
    ldx #0
:next
    lda $FFd8,x
:addr = *-1
    cmp #"@"        ; Read until @ character
    beq :done
    sta _versionBuffer+1,x
    inx
    iny
    cpx #40
    bne :next
:done
    clc
    rts

:error
    MPrintCRStr :sVersionError
    jmp _WaitForKeyAndFail


:sLoading str "Loading Version...",kCR
:sVersionError str "Couldn't read version.  Check disk.",kCR




**************************************
**
**  Return destSlot in low-nybble of A
**
**************************************
GetDestSlot
    lda destSlot
    lsr
    lsr
    lsr
    lsr
    rts

***************************************
** Wait for any key.
**
** Carry set if Escape key pressed
***************************************
WaitForKeyOrEscape
    clc
    jsr WaitForKey
    cmp #kESC
    beq :fail
    clc
    rts
:fail
    sec
    rts

WaitForKey
    bit $c010
]1  lda $c000
    bpl ]1
    bit $c010
    rts

**************************************
**
** Prompt for slot and drive
**
**************************************
GetDestDrive
]slot
    MPrintStr :sDest
    MPrintStr sSlotPrompt
    lda #6
    sta currentNum
    lda #"8"
    sta maxNum
    jsr GetNum
    bcs :fail
    cmp #8
    BRGreaterThanOrEqual ]slot
    cmp #1
    BRLessThan ]slot
    asl
    asl
    asl
    asl
    sta destSlot
]drive
    MPrintStr sDrivePrompt
    ldx #1              ; default drive 1 or 2
    lda sourceSlot      ; If source is slot 6 drive 1 then default to drive 2.
    cmp #$60
    bne :getDrive
    lda destSlot
    cmp #$60
    bne :getDrive
    lda sourceDrive
    cmp #1
    bne :getDrive
    inx                 ; Default drive 2
:getDrive
    stx currentNum
    lda #"3"
    sta maxNum
    jsr GetNum
    bcs :fail
    cmp #2
    beq :setDrive
    cmp #1
    bne ]drive
:setDrive
    sta destDrive

    lda sourceSlot  ; Compare with source slot and drive
    cmp destSlot
    bne :checkSlot
    lda sourceDrive
    cmp destDrive
    bne :checkSlot

    MPrintStr :sDestError
    jmp ]slot

:fail
    sec
    rts

*
* Check slot signature bytes for 5.25 controller
*
:checkSlot
    jsr GetDestSlot    ; Set slot address
    and #$07
    ora #$C0
    sta R1+1
    lda #0
    sta R1

    ldy #1          ; Cx01 = $20
    lda (R1),y
    cmp #$20
    bne :badSlot
    ldy #3          ; Cx03 = $00
    lda (R1),y
    cmp #$00
    bne :badSlot
    ldy #5          ; Cx05 = $03
    lda (R1),y
    cmp #$03
    bne :badSlot
    ldy #7          ; Cx07 = $3C
    lda (R1),y
    cmp #$3C
    bne :badSlot
;    ldy #6          ; Check for CFFA3000
;    lda (R1),y
;    cmp #$A9
;    bne :good
    beq :good
:badSlot
    MPrintStr :sWarnSlot
    MPrintCRStr sHitAnyKey
    jsr WaitForKey

:good
    jsr RWInit  ; Update drive number for RW18 API
    clc
    rts

:sDestError
    db $FF
    str kCR,"Dest drive cannot be the same as the"
    str "source drive. Choose another drive.",kCR
    db 0
:sWarnSlot
    db $FF
    str "WARNING! Destination slot does not"
    str "appear to contain a 5.25 drive"
    str "controller.  Trouble ahead.",kCR
    db 0

:sDest          str "Destination",kCR
sSlotPrompt     str "       Slot: "
sDrivePrompt    str "      Drive: "

**************************************
**
** Get a number from the keyboard
**
** Return in A.  Carry set if cancelled.
**
**************************************
currentNum      db 0
maxNum          db #"8"
minNum          db #"1"
GetNum
    lda currentNum          ; Print the current number inversed
    jsr :PrintCurrentNum

    bit $c010               ; Wait for key
]1  lda $c000
    bpl ]1
    bit $c010
    cmp #kESC               ; If escape then fail
    beq :fail
    cmp #kCR                ; If return then accept current value
    beq :accept
                            ; Otherwise, check if valid number and update curretn value
:2  cmp maxNum
    BRGreaterThanOrEqual ]1
    cmp minNum
    BRLessThan ]1
                            ; Valid number.  Update currentNum and print it
    sec
    sbc #"0"
    sta currentNum
    jsr :PrintCurrentNum
    jmp ]1                  ; Wait for return key to accept

:accept
    lda currentNum
    clc
    adc #"0"
    jsr COUT                ; Print non-inverse value
    jsr PrintCR
    lda currentNum
    clc
    rts

:fail
    sec
    rts

:PrintCurrentNum   ; Print inversed number in A
    pha
    clc
    adc #'0'
    jsr COUT
    dec CH
    pla
    rts

**************************************
**
** Disk Scripts
**
**************************************
RunDiskScript
    jsr DSStartScript
    bcs :rts
    php
    MPrintCRStr sDone
    plp
:rts rts

RunPatchScript
    jsr RunDiskScript
    bcs :error
    MPrintCRStr sHitAnyKey
    jsr WaitForKey
    jsr LoadVersion
    rts

:error
    MPrintCRStr sHitAnyKey
    jsr WaitForKey
    inc menuQuitFlag          ; Quit to main menu
    rts

**************************************
WriteSideA
    MSetWord dsScriptPtr;SideAScript
    jmp RunDiskScript

**************************************
WriteSideB
    MSetWord dsScriptPtr;SideBScript
    jmp RunDiskScript

**************************************
KeyboardPatch
    MSetWord dsScriptPtr;KeyboardPatchScript
    jmp RunPatchScript

**************************************
DevPatch
    MSetWord dsScriptPtr;DevPatchScript
    jmp RunPatchScript

**************************************
DebugPatch
    MSetWord dsScriptPtr;DebugPatchScript
    jmp RunPatchScript

**************************************
ReleasePatch
    MSetWord dsScriptPtr;ReleasePatchScript
    jmp RunPatchScript


***************************************************
***************************************************
***************************************************
***************************************************

    put prodos
    put rw18api
    put diskscript
    put strings
    put menu
    put debugutil
    put script.sidea
    put script.sideb
    put script.patches

    sav popmaker.system
    
