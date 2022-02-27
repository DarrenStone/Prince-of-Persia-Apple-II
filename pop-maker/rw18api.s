**
** RW18 Wrapper
**
** Public routines:
**
** RWInit
** RWWriteTrack
** RWReadTrack
** RWSeek
** RWSeekWithVerify
** RWSeekToTrack0
** RWDriveOn
** RWDriveOff
** RWForceDriveOff
** RWSetSideA
** RWSetSideB
** RWVerifySideA
** RWVerifySideB
**
** Public vars:
**
** rw18Drive
** rw18Track
** rw18CurrentTrack
** rw18Slot
** rw18Buffer
**



**
** Entry Point
**
RW18            = $6900 ; $6900-7900

**
** Commands
**
rwDriveOn       = $00
rwDriveOff      = $01
rwSeek          = $02
rwReadSeq       = $03
rwReadSeqInc    = $43
rwReadGroup     = $04
rwReadGroupInc  = $44
rwWriteSeq      = $05
rwWriteSeqInc   = $45
rwWriteGroup    = $06
rwWriteGroupInc = $46
rwSetId         = $07

;; Disk IDs.
kDiskIDSideA     = $a9
kDiskIDSideB     = $ad

;; Zero Page
rw18Drive       = destDrive
rw18Slot        = $FD
rw18Track       = $FE
rw18CurrTrack   = $FF ; Current location of head, multiplied by 2

***************************************************
** Init RW18 - Set the drive number. Assumes rw18Track is already correct.
***************************************************
*  Called at the start of a new script.
RWInit
                lda rw18Drive
                sta _rwDrive
                jsr RW18
                db rwSetId,$A9
                rts

***************************************************
** Write rw18Buffer to the current RW18 track.
***************************************************
*  Track in A
RWWriteTrack
                MPrintCRStr sWritingTrack
                lda rw18Track
                jsr PrintA

                jsr RWDriveOn

                ;; Write 18 pages
                jsr RW18
                db rwWriteSeq,>rw18Buffer
                bcs :writeError

                ;; Verify
                jsr RW18
                db rwReadSeq,>rw18Buffer
                bcs :verifyError

                jsr RWDriveOff
                clc
                rts

:writeError     MPrintCRStr sWriteError
                jsr PrintCR
                jmp :finishError

:verifyError    MPrintCRStr sVerifyError
                jsr PrintCR

:finishError    jsr RWDriveOff
                sec
                rts



***************************************************
** Read track to rw18Buffer.
***************************************************
*  Track in A
RWReadTrack
    sta rw18Track   ; Read will automatically seek to this track.
    jsr RWDriveOn

    jsr RW18
    db rwReadSeq,>rw18Buffer
    bcs :error

    jsr RWDriveOff
    clc
    rts

:error
    jsr RWDriveOff
    sec
    rts


*****************************
** RW18 Seek to Track
*****************************
*  Track in A
RWSeekWithVerify
    ldx #1
    stx _rwSeekVerify
    jmp _RWSeek

RWSeek
    ldx #0
    stx _rwSeekVerify

_RWSeek
    cmp rw18Track
    bne :begin
    clc
    rts             ; We're already on the requested track.  Nothing to do.
                    ; RW18 seek will set carry in this condition, which will
                    ; cause the script to abort.  Instead, check it ourselves.

:begin
    sta _rwSeekTrack
    jsr RWDriveOn
    clc

    jsr RW18
    db rwSeek
_rwSeekVerify db 0
_rwSeekTrack db 0

    php
    jsr RWDriveOff
    plp
    rts


*****************************
** RWDriveOn - Turn drive on, or increment ref count.
*****************************
RWDriveOn
    lda _driveRefCount
    bne _RWDriveOnDone
    jsr RW18
    db rwDriveOn
_rwDrive
    db 0
    db 5
_RWDriveOnDone
    inc _driveRefCount
    rts


*****************************
** RWForceDriveOff - Set ref count to zero, then turn drive off.
*****************************
RWForceDriveOff
    lda #0
    sta _driveRefCount
                            ; fall-through

*****************************
** RWDriveOff - Decement ref count.  Turn drive off if count is zero.
*****************************
RWDriveOff
    lda _driveRefCount
    beq :off
    dec _driveRefCount
    bne :rts

:off
    jsr RW18
    db rwDriveOff

:rts rts

_driveRefCount db 0

***************************************
**
** RWSeekToTrack0: Tip-toe to track 0.
**
** Adapted from Disk II Controller boot rom
** https://6502disassembly.com/a2-rom/C600ROM.html
**
***************************************

IWM_PH0_OFF = $C080
IWM_PH0_ON  = $C081

RWSeekToTrack0
    jsr RWDriveOn

    ldy #80             ; Y = current phase, starting at 80 (40 tracks) down to zero.
    ldx rw18Slot        ; slot in high nybble

:seekLoop
    lda IWM_PH0_OFF,x   ; Turn off current phase
    tya                 ; Set X to next phase (0/2/4/6)
    and #$03            ;   A = phase mod 3.  A=(0/1/2/3)
    asl                 ;   double it.        A=(0/2/4/6)
    ora rw18Slot        ;   add in the slot index
    tax
    lda IWM_PH0_ON,x    ; turn on current phase
    lda #86
    jsr WAIT            ; wait a hollywood minute
    dey                 ; next phase
    bpl :seekLoop

    jsr RWDriveOff

    lda #0              ; Reset RW18 track
    sta rw18CurrTrack
    sta rw18Track
    lda #$FF
    sta hasTrackZero
    rts


***************************************
**  RWSetSide A or B
***************************************
RWSetSideA
    jsr RW18
    db rwSetId,kDiskIDSideA
    rts

RWSetSideB
    jsr RW18
    db rwSetId,kDiskIDSideB
    rts

***************************************
**
** Verify side A or B.
**
** Currently this just verifies that every RW18 track
** is readable.
**
** If we lost track of the drive head while creating
** a disk then this verification will fail.
**
***************************************
sVerifying str "Verifying "
sSideA str "Side A"
sSideB str "Side B"

RWVerifySideA
    jsr ClearScreen
    MPrintCRStr sVerifying
    MPrintStr sSideA
    jsr PrintCR

    jsr RWSetSideA
    jsr RWDriveOn
    jsr RWSeekToTrack0
    lda #1
    sta :track
    jmp _VerifyNextTrack

RWVerifySideB
    jsr ClearScreen
    MPrintCRStr sVerifying
    MPrintStr sSideB
    jsr PrintCR

    jsr RWSetSideB
    jsr RWDriveOn
    jsr RWSeekToTrack0
    lda #0
    sta :track
    jmp _VerifyNextTrack

_VerifyNextTrack
    lda $c000
    cmp #kESC
    beq :done

    lda #"."
    jsr COUT

    lda :track
    jsr RWReadTrack
    bcs :error

:incTrack
    inc :track
    lda :track
    cmp #34
    bne _VerifyNextTrack

:done
    jsr RWDriveOff
    MPrintCRStr sFinished
    MPrintCRStr sHitAnyKey
    jsr WaitForKey
    rts

:error
    MPrintCRStr :sBadTrack
    lda :track
    jsr PrintA
    clc
    jmp :incTrack

:track db 0
:sBadTrack str "Bad Track: "
