
    DO DEBUG_MENU

***************************************
**
** DebugMenu
**
***************************************
DebugMenu
    MSetWord menuTable;:menuTable
    jmp RunMenu

:menuTable
    da :sTitle
    db 8
    da :sWriteTrack0,LoadBootTrack
    da :sRunSideA,WriteSideA
    da :sRunSideB,WriteSideB
    da :sReadTrack1,ReadTrack1
    da :sSoftSeek,RWSeekToTrack0
    da :sVerifyA,RWVerifySideA
    da :sVerifyB,RWVerifySideB
    da :sQuit,$0000
    da $0000

:sTitle         str "DEBUG MENU",kCR
:sWriteTrack0   str "Write Boot Track 0"
:sRunSideA      str "Run Side A Disk Script"
:sRunSideB      str "Run Side B Disk Script"
:sReadTrack1    str "Read Track 1 and break"
:sSoftSeek      str "Soft seek to track 0"
:sVerifyA      str "Verify Side A"
:sVerifyB      str "Verify Side B"
:sQuit          str "Back to main"

**************************************
**
** ReadTrack1 (Debug)
**
**************************************
ReadTrack1
    jsr dsClearBuffer
    ;; Assume RW18 is already init'd and rw18CurrTrack is correct
    jsr RWDriveOn
    clc
    jsr RW18
    db rwSeek,0,1

    clc
    jsr RW18
    db rwReadSeq,>rw18Buffer
    php
    jsr RWDriveOff
    plp
    bcs :error

    MPrintStr :sReady
    brk

:error
    MPrintStr sReadError
    jsr PrintA
    jsr PrintCR
    clc
    rts

:sReady str "Track 1 loaded to $2000.$31FF  Breaking...",kCR

    FIN
