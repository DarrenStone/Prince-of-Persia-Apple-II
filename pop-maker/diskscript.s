

*****************************
** DiskScript commands
**
** (Maximum 16 commands.  Command in lower nybble, modifier bits in upper nybble)
*****************************
dSeek          = $00   ; [track].  Force drive to seek to a given track.
dSetTrack      = $10   ; [track].  Set the next track for writing.  Seek will occur at next write.
dClearBuffer   = $01   ; No params.  Clear the rw18 buffer.
dLoadFile      = $02   ; {path addr}{offset addr}. Load ProDOS file from source drive.
dWriteTrack    = $03   ; No params. Write dest drive track, advance to next track, then clear buffer.
dOpenFile      = $04   ; {path addr}. Open ProDOS file from source drive.
dRead          = $05   ; [offset high-byte].  Read from the open ProDOS file.
dReadPartial   = $15   ; [offset high-byte][max length high byte] Parital read from the open ProDOS file.
dCloseFile     = $06   ; No params. Close the open ProDOS file.
dSetDiskID     = $07   ; [ID] Set the RW18 disk ID
dFixImageTable = $08   ; [buffer page][table high byte] Move image table header addresses.
dDefaultGameSaveData = $09 ; Set up save game data in rw18Buffer, for save game track.
dSetSourceDisk = $0A   ; [disk num] Prompt for this source disk when a file is not found.
dPrintString   = $0B   ; [String Length][Char 1][Char 2]... Print a string to the console.
dDebugBreak    = $0C   ; Debugger break
dDebugPause    = $1C   ; Pause for keyboard
dEOF           = $FF

_dsMaxCommand = dDebugBreak

*****************************
dsDispatchTable
    da dsSeek
    da dsClearBuffer
    da dsLoadFile
    da dsWrite
    da dsOpen
    da dsRead
    da dsClose
    da dsSetBundleId
    da dsFixImageTable
    da dsSaveGameData
    da dsSetSourceDisk
    da dsPrintString
    da dsBreak


dsSourceDisk db 0

*****************************
** Start the script in dsScriptPtr
**
** On return, carry set if script couldn't complete.
*****************************
DSStartScript
    bit $c010
    jsr RWInit                  ; Sets the dest slot and drive
    lda #0
    sta dsAuxPageCount          ; Reset AuxMem track buffer

    lda hasTrackZero
    bne :nextCommand
    jsr RWSeekToTrack0          ; Ensure we know where the drive head is before starting.

:nextCommand                    ; Loop over script commands
    jsr _DSCheckForEscape
    bcs :abort
    cmp #"x"-kCTRL              ; DEBUG.  Hit Ctrl-X to skip script without error
    beq :skip

    jsr _DSNextByte             ; Get the next script command
    cmp #dEOF                   ; Check for EOF
    bne :dispatchCommand        ;  If not, dispatch command in A

                                ; End of script clean up...
    jsr _DSFlushAuxBuffer       ; Flush any buffered tracks.
    bcs :error
:skip
    jsr DOSCloseIfNecessary
    jsr RWForceDriveOff         ; Turn off drive just to be sure.
    clc                         ;  and return success.
    rts

:dispatchCommand                ; Dispatch script command in A
    pha                         ; Save the original command
    and #$0F                    ; Clear the top nibble, which may contain modifier bits
    cmp #_dsMaxCommand+1        ; Make sure the command is in range.
    BRGreaterThanOrEqual :errorBadCommand ;  if not, crash.
    asl                         ; Multiply by 2 to get table index
    tax                         ; Put index in X, then load the pointer from the table
    lda dsDispatchTable,x       ;  into :dsDispatchPtr
    sta :dsDispatchPtr
    lda dsDispatchTable+1,x
    sta :dsDispatchPtr+1
    pla                         ; Restore the original command byte
    jsr :trampolene             ;  and dispatch.

    bcs :error                  ; If carry set, a disk error occurred.  Abort.
    bcc :nextCommand            ;  otherwise, run next command.

:trampolene
    jmp (:dsDispatchPtr)         ; Trampolene to the script function.

:error                          ; Disk error occurred.
    MPrintCRStr :sScriptFailed
    jsr PrintCR
    jsr DOSCloseIfNecessary      ; Ensure any open file is closed.
    jsr RWForceDriveOff
    sec
    rts

:errorBadCommand                ; Script dispatcher found a bad command.  This is always a bug.
    pha
    MPrintCRStr :sBadScript
    pla
    jsr PrintA
    brk                         ; crash

:abort
    jsr DOSCloseIfNecessary      ; Ensure any open file is closed.
    MPrintCRStr :sScriptAborted
    sec
    rts

:dsDispatchPtr da $0000

:sScriptFailed  str "Script failed.  Aborting... "
:sBadScript     str "Bad Script Command: "
:sScriptAborted str "Script aborted."


*****************************
** Read the next DiskScript byte into A.
**
** Processor flags represent the state of the last read to A. (zero and minus)
*****************************
_DSNextByte
    ldy #0
    lda (dsScriptPtr),Y         ; Get the next command into A
    MDebugPrintA
    php                         ; Save the flags for the command

    inc dsScriptPtr             ; 16-bit increment dsScriptPtr
    bne :done
    inc dsScriptPtr+1
:done
    plp                         ; Restore the flags to represent the current state of A
    rts                         ;   and return.

*****************************
** MACRO - Read the next DiskScript word (L/H) into given address
**
** e.g.: _MDSNextWord openFilePath
*****************************
_MDSNextWord MAC
    jsr _DSNextByte
    sta ]1
    jsr _DSNextByte
    sta ]1+1
    <<<


*****************************
** Set bundle ID [id]
*****************************
dsSetBundleId
        clc
        jsr _DSNextByte ; ID
        sta :idByte

        jsr RW18
        db rwSetId
:idByte db $00
        rts


*****************************
** Move image table [buffer page][new offset page]
*****************************
dsFixImageTable
    jsr _DSNextByte     ; Buffer page (Address of table in memory)
    clc
    adc #>rw18Buffer
    sta tableAddr

    jsr _DSNextByte     ; Table base address
    sta newOffset
    jmp _DSFixImageTable

*****************************
** Write default save-game data to rw18Buffer
*****************************
dsSaveGameData
    ldx #0
    ldy #saveDataLen
]1
    lda saveData,x
    sta rw18Buffer,x
    inx
    dey
    bne ]1
    rts

** Default save game data: Level 3, Strength: 4, Time: 60 mins
saveData hex 03,04,00,39,00,00,02,00
saveDataLen = *-saveData

*****************************
** Set the source disk number.
**
** We will prmopt for this disk when a file is not found.
*****************************
dsSetSourceDisk
    jsr _DSNextByte
    sta dsSourceDisk
    clc
    rts

*****************************
** Print a string [length byte][char 1][char 2]...
*****************************
dsPrintString
    jsr PrintCR
    jsr _DSNextByte ; String len
    beq :rts
    tax
:next
    jsr _DSNextByte
    jsr COUT
    dex
    bne :next

:rts clc
    rts


*****************************
** Debug Break
*****************************
dsBreak
    cmp #dDebugPause        ; Check modifier bits
    beq :Pause
    MPrintCRStr :breaking
    brk

:Pause
    MPrintCRStr :paused
    MPrintStr sHitAnyKey
    jsr PrintCR

    bit $c010
]1  lda $c000
    bpl ]1
    bit $c010
    clc
    rts

:paused     str "Paused."
:breaking   str "Breaking in script...",kCR


*****************************
** Seek [track]
*****************************
dsSeek
    sta :saveA
*
* If we're asked to seek then we have to flush the buffer
* before moving the track head.
*
    jsr _DSFlushAuxBuffer
    bcs :fail

*
* If modifier bit 0 is clear then move the head.
* Otherwise, set up rw18Track for the next write.
*
    lda :saveA
    and #$10
    bne :setTrack

    jsr _DSNextByte  ; track num
    cmp #0
    beq :seekTo0
    jmp RWSeek
:seekTo0
    jmp RWSeekToTrack0IfNecessary

:setTrack
    jsr _DSNextByte  ; track num
    sta rw18Track
    clc
    rts

:fail
    sec
    rts

:saveA db 0

*****************************
** Clear the rw18Buffer (no params)
*****************************
dsClearBuffer
    clc
    MDebugPrintStr :title
    lda #>rw18Buffer
    ldy #18
    jmp ClearBuffer

:title str "Clearing Buffer",kCR

*****************************
** Load ProDOS File {path addr},{offset addr}
**
** Open, Read, and Close a file
*****************************
dsLoadFile
    lda #0                      ; Set up 18 page buffer length
    sta dosReadReqLen

    _MDSNextWord dosOpenPathName
    _MDSNextWord dosReadInBuffer
    lda #18                     ; Set max buffer size
    sec
    sbc dosReadInBuffer+1          ;    by decrementing offset from 18
    sta dosReadReqLen+1            ;    and storing in dosReadReqLen high byte

    lda dosReadInBuffer+1          ; Increment high byte to match our rw18 buffer
    clc
    adc #>rw18Buffer
    sta dosReadInBuffer+1
:tryAgain
    MPrintCRStr :sLoading
    MPrintStrPtr dosOpenPathName
    DO DEBUG
    MPrintStr :sTo
    MPrintStr16Hex dosReadInBuffer
    MPrintCR
    FIN
    jsr DOSLoadFile
    bcs :loadError
    rts

:loadError
    cmp #kDOSFileNotFound
    beq :diskPrompt
    sec
    rts

:diskPrompt
    jsr _DSPromptForDisk
    bcc :tryAgain
    rts

:sLoading str "Loading "
:sTo      str " to "

*****************************
** Write the current track and advange to next track (no params).
**
** Writes are buffered to 10 tracks in Aux memory.
*****************************
_dsSaveA  db 00
dsWrite
    clc
    sta _dsSaveA            ; Save the original command

    lda dsAuxPageCount      ; Buffered Write to Aux Memory
    ldx #0
    jsr _DSToAux            ; Move rw18Buffer to Aux

    jsr dsClearBuffer       ; Clear buffer, then check if we need to flush
    ldx dsAuxPageCount
    inx
    stx dsAuxPageCount      ; If AuxPageCount == 10 then flush buffer
    cpx #10
    bne :rts
    jmp _DSFlushAuxBuffer
:rts rts

*****************************
** Open a file for reading {path addr}
*****************************
dsOpen
    _MDSNextWord dosOpenPathName
:tryAgain
    MPrintCRStr :sOpening
    MPrintStrPtr dosOpenPathName
    jsr DOSOpenFile
    bcs :openError
    rts

:openError
    cmp #kDOSFileNotFound
    beq :diskPrompt
    sec
    rts

:diskPrompt
    jsr _DSPromptForDisk
    bcc :tryAgain
    rts

:sOpening str "Opening "

*****************************
** Read the open file. (buffer offset page)
*****************************
dsRead
    pha                             ; Save command for modifiers
    lda #0
    sta dosReadInBuffer
    jsr _DSNextByte                 ; Get the offset
    sta _saveA2
    lda #>rw18Buffer                ;   and adjust the dosReadInBuffer
    clc
    adc _saveA2
    sta dosReadInBuffer+1

    lda #0                          ; Set the buffer size
    sta dosReadReqLen                  ;   low byte is always zero

    pla                             ; Check for partial read
    cmp #dReadPartial
    beq :readPartial

    lda #$12                        ; Subtract the offset from the buffer size.  $12 is max (18 pages)
    sec
    sbc _saveA2
    sta dosReadReqLen+1
    jmp :finish

:readPartial
    jsr _DSNextByte                 ; Partial read.  Get length
    sta dosReadReqLen+1

:finish
    MDebugPrintStr :sReadingTo
    lda dosReadInBuffer+1
    MDebugPrintA
    MDebugPrintStr :sMaxLen
    lda dosReadReqLen+1
    MDebugPrintA
    MDebugPrintCR

    lda #":"
    jsr COUT
    jmp DOSReadFile

_saveA2 db $00
:sReadingTo str "Reading to page "
:sMaxLen    str ", max len "

*****************************
** Close the open file.
** Clear the buffer after closing.
*****************************
dsClose
    lda #"|"
    jsr COUT
    MDebugPrintStr :sClosing
    jsr DOSCloseFile
    rts

:sClosing str "Closing",kCR



*****************************
**
** _DSFixImageTable
**
** Move POP image table
**
** newOffset: the new base address (high byte)
** tableAddr: the address of the table in memory (high byte)
*****************************
newOffset db $00
tableAddr db $00
_DSFixImageTable
    lda tableAddr
    sta :addr1
    sta :addr2
    sta :addr3

    MDebugPrintStr :sFixTable
    ldx #0
    lda $FF00,x
:addr1 = *-1
    MDebugPrintA
    cmp #0
    beq :error
    tay             ; entry count

    MPrintStr :sOffset
    lda newOffset
    jsr PrintA

]next
    inx
    inx
    lda $FF00,x
:addr2 = *-1
    sec
    sbc #$60
    clc
    adc newOffset
    sta $FF00,x
:addr3 = *-1

    dey
    bne ]next

    clc
    rts

:error brk

:sFixTable str "Fixing table. Entries:"
:sOffset   str " $60->$"

*****************************
** _DSCheckForEscape
**
** Check keyboard for ESC char, set carry if true.
*****************************
_DSCheckForEscape
    clc
    lda $c000                   ; Check for escape
    cmp #kESC
    beq :escape
    clc
    rts
:escape
    sec           ; Found escape.  Set carry
]rts rts


*****************************
** _DSFlushAuxBuffer
**
** Flush any tracks in Aux Memory to disk
*****************************
_DSFlushAuxBuffer
    ldx dsAuxPageCount  ; Check the buffer size.  If zero there's nothing to do
    beq ]rts

    jsr RWDriveOn

    lda #0              ; Start at first slot
    sta :currentSlot
]next
    jsr _DSCheckForEscape
    bcs :fail
    cmp #"x"-kCTRL      ; DEBUG.  Hit Ctrl-X to skip script without error
    beq :skip

    lda :currentSlot    ; Move :currentSlot to Main Memory
    ldx #1
    jsr _DSToAux

    jsr RWWriteTrack    ; Write it
    bcs :fail
    jsr _DSAdvanceTrack ; Increment track

    inc :currentSlot    ; Increment slot
    dec dsAuxPageCount  ; Decrement buffer size
    bne ]next
    jsr RWDriveOff
    rts

:fail
    jsr RWDriveOff
    sec
    rts

:skip
    jsr RWDriveOff
    lda #0
    sta dsAuxPageCount
    clc
    rts

:currentSlot db 0
dsAuxPageCount db 0

*****************************
** _DSAdvanceTrack
**
** Increment rw18 track.
*****************************
_DSAdvanceTrack
    ldx rw18Track
    cpx #34
    BRGreaterThanOrEqual :rts
    inx
    stx rw18Track  ; RW18 will automatically seek to this track on the next read/write
:rts rts


*****************************
**
** _DSToAux
**
** Move rw18 buffer to aux memory slot [slot number]
**
** 10 slots available, 0-9
**
** Modifier bits:
** 0x: Move to Aux
** 1x: Move from Aux
*****************************

* 80-col firmware API
AUXMOVE = $C311     ; Carry: 1 = To Aux.  0 = To Main
A1      = $3C       ; Source Address Start
A2      = $3E       ; Source Address End
A4      = $42       ; Dest Address

* Aux memory slots (page numbers)
* 0: 08-19
* 1: 1a-2b
* 2: 2c-3d
* 3: 3e-4f
* 4: 50-61
* 5: 62-73
* 6: 74-85
* 7: 86-97
* 8: 98-a9
* 9: aa-bb
* Slot in A, Direction in X (0=ToAux, 1=ToMain)
_DSToAux
    stx :saveX
    cmp #10
    BRGreaterThanOrEqual :badSlot
    jsr _SetA4AuxSlot   ; Set A4 to start of aux slot memory
    ldx :saveX
    cpx #0              ; Check modifier bit. 1 == Aux to Main
    bne :fromAux

    ;; Main To Aux
    ;; A1 = rw18Buffer
    ;; A2 = rw18Buffer + $11FF
    ;; A4 = Aux Slot
    MSetWord A1;rw18Buffer
    jsr _SetA2EndAddr
    sec                     ; Move to AUX
    jsr AUXMOVE
    clc
    rts

*
* Move aux slot address in A4 to A1
*
:fromAux
    lda A4
    sta A1
    lda A4+1
    sta A1+1
    jsr _SetA2EndAddr           ; Set end address in A2
    MSetWord A4;rw18Buffer      ; Dest address is rw18Buffer
    clc                         ; Move from AUX
    jsr AUXMOVE
    clc
    rts

:badSlot
    MPrintStr :sBadSlot
    jsr PrintA
    brk

:sBadSlot str "Move To Aux. Bad Slot Number:"
:saveX db 0


_SetA4AuxSlot
    tax
    inx         ; Slot number in X

    lda #$08    ; Start at $0800
]1  dex         ; Repeatedly add $1200 until X is zero
    beq :done
    clc
    adc #$12
    bne ]1      ; Branch always
:done
    sta A4+1
    stx A4      ; Zero
    rts

_SetA2EndAddr
    lda A1+1
    clc
    adc #$11
    sta A2+1
    lda #$FF
    sta A2
    rts


_DSPromptForDisk
    jsr PrintCR
    MPrintCRStr :sInsertDisk
    lda dsSourceDisk
    jsr PrintBCD
    MPrintStr :sInto
    jsr PrintCR
    jsr PrintSourceDrive
    jsr PrintCR
    jsr PrintCR
    jmp WaitForKeyOrEscape

:sInsertDisk str "Insert POPMAKER DISK "
:sInto str " into "
