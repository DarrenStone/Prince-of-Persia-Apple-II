
**
** Public routines
**
**      DOSInitSystem
**      DOSSetSystemBitmap
**      DOSOpenFile
**      DOSReadFile
**      DOSCloseFile
**      DOSCloseIfNecessary
**      DOSWriteBlock
**      DOSSetPrefix
**      DOSLoadFile (Open, Read, Close)
**      DOSQuit
**
** Public variables
**
**      dosOpenPathName
**
**      dosReadInBuffer
**      dosReadReqLen
**      dosReadActLen
**
**      dosWriteBlockUnit
**      dosWriteBlockAddr
**      dosWriteBlockNum
**
**      dosSetPrefixPath


kDOSOpen            = $C8
kDOSRead            = $CA
kDOSClose           = $CC
kDOSGetPrefix       = $C7
kDOSSetPrefix       = $C6
kDOSWriteBlock      = $81
kDOSQuit            = $65
kDOSOnline          = $C5
PRODOS              = $bf00

dosCurrentPath      = $280
dosSystemBitmap     = $bf58
dosVersion          = $bffd
dosLastDevice       = $bf30

kDOSFileNotFound = $46
kDOSDirNotFound = $45

********************************************
**
** DOSInitSystem
**
** Init ProDOS System
**
** - Set Version
** - Ensure Prefix
** - Sets sourceSlot, sourceDrive
**
** Return: Carry set if prefix can't be found.
********************************************
DOSInitSystem
    lda #1
    sta dosVersion

    jsr _ResolvePrefix   ; Resolve prefix and get source slot and drive
    bcs :rts

    lda dosLastDevice    ; Get the source slot and drive based on the last device that ProDOS accessed.
    and #$70
    sta sourceSlot
    lda dosLastDevice
    ldx #1
    and #$80
    beq :drive1
    inx
:drive1
    stx sourceDrive

    jsr DOSDisconnectRam ; Lastly, disconnect the ram disk.
    clc
:rts
    rts                 ; Carry set if resolve failed

********************************************
**
** DOSSetSystemBitmap
**
** Set the System Memory Bitmap
**
** Surely overkill, but it will catch bugs
** if our buffers are not set up correctly.
**
********************************************

** ProDOS System Memory Bitmap, starting at offset 4
**                  2000-4AFF                  6900-7900
**                  20,28,30,38,40,48,50,58,60,68,70,78
systemBitmap    hex FF,FF,FF,FF,FF,E0,00,00,00,7F,FF,C0
systemBitmapLen    = *-systemBitmap
systemBitmapOffset = 4

DOSSetSystemBitmap
    ldx #0
:next
    cpx #systemBitmapLen
    beq :done
    lda systemBitmap,x
    sta dosSystemBitmap+systemBitmapOffset,x
    inx
    bne :next
:done
    rts

**************************************
**
** DOSOpenFile - Open file in dosOpenPathName
**
** In: dosOpenPathName: set to path name address
**
**************************************
DOSOpenFile
    do DEBUG
    MPrintStr sReading
    MPrintStrPtr dosOpenPathName
    fin
    clc
    jsr PRODOS
    db kDOSOpen
    da :params
    bcs :error
    rts

:error
    pha
    jsr PrintCR
    MPrintStr sOpenError
    pla
    jsr PrintA
    jsr PrintCR
    sec
    rts

:params         db $03
dosOpenPathName da $0000        ; Path Name
                da prodosBuffer
_openRefNum     db $00          ; Ref Number


**************************************
**
** DOSReadFile - Read Open File
**
** In:  dosReadInBuffer: Address of read buffer
**      dosReadReqLen: Buffer Length
**
** Out: dosReadActLen: Actual read length.
**
**************************************
DOSReadFile
    do DEBUG
    jsr PrintCR
    MPrintStr16Hex dosReadInBuffer
    MPrintStr16Hex dosReadReqLen
    jsr PrintCR
    fin

    lda _openRefNum
    sta _readRef
    clc
    jsr PRODOS
    db kDOSRead
    da :params
    bcs :error

    do DEBUG
    jsr PrintSPC
    MPrintStr16Hex dosReadActLen
    MPrintStr sBytes
    fin

    clc
    rts

:error
    pha
    jsr PrintCR
    MPrintStr sReadError
    pla
    jsr PrintA
    jsr PrintCR
    sec
    rts


:params             db $04
_readRef            db $00
dosReadInBuffer     da rw18Buffer
dosReadReqLen       da $1200        ; Buffer Size is 18 pages
dosReadActLen       da $0000


**************************************
**
** DOSCloseFile - Close open file
**
**************************************
DOSCloseFile
    DO DEBUG
    MPrintStr sClosing
    MPrintStrPtr dosOpenPathName
    jsr PrintCR
    FIN

    lda _openRefNum
    sta _closeRefNum
    clc
    jsr PRODOS
    db kDOSClose
    da :params
    bcs :error
    lda #0
    sta _openRefNum
    clc
    rts

:error
    pha
    jsr PrintCR
    MPrintStr sCloseError
    pla
    jsr PrintA
    jsr PrintCR
    sec
    rts

:params         db $01
_closeRefNum    db $00

**************************************
**
** DOSCloseIfNecessary - Close open file, if open.
**
**************************************
DOSCloseIfNecessary
    lda _openRefNum
    bne DOSCloseFile
    rts


**************************************
** Write a single 512 byte block
**
** In:  dosWriteBlockNum: The block number to write to.
**      dosWriteBlockAddr: The address of the buffer
**************************************
DOSWriteBlock
    lda #"="
    jsr COUT
    jsr PRODOS
    db kDOSWriteBlock
    da :params
    bcs :error
    rts

:error
    pha
    jsr PrintCR
    MPrintStr sWriteError
    pla
    jsr PrintA
    jsr PrintCR
    sec
    rts


:params             db $03
dosWriteBlockUnit   db $00
dosWriteBlockAddr   da $2000
dosWriteBlockNum    da $0000

**************************************
** Set Prefix
**
** In:  dosSetPrefixPath: Pointer to prefix string
**************************************
DOSSetPrefix
    DO DEBUG
    MPrintCRStr :sSetPrefix
    MPrintStrPtr dosSetPrefixPath
    jsr PrintCR
    FIN

    jsr PRODOS
    db kDOSSetPrefix
    da :params
    bcs :error
    rts

:error
    pha
    jsr PrintCR
    MPrintStr sError
    pla
    jsr PrintA
    jsr PrintCR
    sec
    rts

:params             db $01
dosSetPrefixPath    da $0000

    DO DEBUG
:sSetPrefix str "Setting Prefix: "
    FIN

**************************************
** Load a ProDOS file into memory
**
** dosOpenPathName: Points to the file to open
** dosReadInBuffer: Addess to load in to
** dosReadReqLen  : Size of buffer
**************************************
DOSLoadFile
    jsr DOSOpenFile
    bcs :rts
    jsr DOSReadFile
    php
    jsr DOSCloseFile
    plp
:rts
    rts

:readError
    pha
    lda #"X"
    jsr COUT
    MPrintStr sReadError
    pla
    jsr PrintA
    jsr DOSCloseFile
    sec
    rts

:closeError
    pha
    lda #"Y"
    jsr COUT
    MPrintStr sCloseError
    pla
    jsr PrintA
    sec
    rts

**************************************
** Quit to ProDOS
**************************************
DOSQuit
    bit $c010
    inc $3F4    ; Invalidate powerup byte
    jsr PRODOS
    db kDOSQuit
    da :params
:params
    db $04
    db $00
    da $0000
    db $00
    da $0000


**************************************
** Resolve the root prefix
**
** Get current prefix from ProDOS.
** If it's empty or not an absolute path,
** then get prefix from dosCurrentPath by
** truncating the last path component.
**************************************
_ResolvePrefix
    jsr _GetPrefix
    bcs :error          ; ProDOS returned error
    jsr _TestRootPath
    bcs :findPrefix
    rts                 ; rootPath is good

**
** Prefix isn't set.  Try to get it from dosCurrentPath
**
** Example dosCurrentPath: /work35/popmaker.system
** Exmaple rootPath: /work35/
**
:findPrefix
    MLoadR1 dosCurrentPath
    MLoadR2 rootPath
    jsr StringCopy      ; Copy current path into rootPath
                        ; Then modify the length of the rootPath
                        ; to truncate the last path component

    clc
    jsr _TestRootPath
    bcs :notFound       ; dosCurrentPath is bad

    ldx rootPath        ; Original String length
:nextChar
*
* Walk backwards to the last /
*
    lda rootPath,x
    ora #$80
    cmp #"/"
    beq :found
    dex
    beq :notFound       ; If x == 0, we didn't find a /
    bne :nextChar
:found
    stx rootPath        ; X is the new string length
    clc
    lda #<rootPath
    sta dosSetPrefixPath
    lda #>rootPath
    sta dosSetPrefixPath+1
    jmp DOSSetPrefix     ; Set the prefix

:error
    MPrintStr :prefixError
    jsr PrintACR
    jmp _WaitForKeyAndFail

:notFound
    MPrintStr :cantFindPrefix
    jmp _WaitForKeyAndFail

:prefixError str kCR,"Prefix error:"
:cantFindPrefix str kCR,"Error: Can't resolve prefix."

_TestRootPath
    lda rootPath
    beq :bad     ; If len == 0 then bad
    lda rootPath+1
    ora #$80
    cmp #"/"     ; If rootPath[1] != '/' then bad
    bne :bad
    clc
    rts
:bad
    sec
    rts

**************************************
** Wait for key, then set carry to fail
**************************************
_WaitForKeyAndFail
    bit $c010
]1  lda $c000       ; Wait for key...
    bpl ]1
    bit $c010
    sec             ; ... and fail
    rts

**************************************
** Load the current prefix into rootPath
**************************************
_GetPrefix
    clc
    jsr PRODOS
    db kDOSGetPrefix
    da getPrefixParams
    rts

getPrefixParams db $01
getPrefixPath   da rootPath

**********************************************
**
** DOSDisconnectRam (Adapeted from ProDOS Technical Manual)
**
**********************************************

DEVCNT EQU $BF31       ; GLOBAL PAGE DEVICE COUNT
DEVLST EQU $BF32       ; GLOBAL PAGE DEVICE LIST
MACHID EQU $BF98       ; GLOBAL PAGE MACHINE ID BYTE
RAMSLOT EQU $BF26      ; SLOT 3, DRIVE 2 IS /RAM'S DRIVER VECTOR
*
* NODEV IS THE GLOBAL PAGE SLOT ZERO, DRIVE 1 DISK DRIVE VECTOR.
* IT IS RESERVED FOR USE AS THE "NO DEVICE CONNECTED" VECTOR.
*
NODEV EQU $BF10

DOSDisconnectRam
    PHP
*
* FIRST THING TO DO IS TO SEE IF THERE IS A /RAM TO DISCONNECT!
*
    LDA MACHID            ; LOAD THE MACHINE ID BYTE
    AND #$30              ; TO CHECK FOR A 128k SYSTEM
    CMP #$30              ; IS IT 128k?
    BNE :DONE              ; IF NOT THEN BRANCH SINCE NO /RAM!

    LDA RAMSLOT           ; IT IS 128K; IS A DEVICE THERE?
    CMP NODEV             ; COMPARE WITH LOW BYTE OF NODEV
    BNE :CONT              ; BRANCH IF NOT EQUAL, DEVICE IS CONNECTED
    LDA RAMSLOT+1         ; CHECK HI BYTE FOR MATCH
    CMP NODEV+1           ; ARE WE CONNECTED?
    BEQ :DONE              ; BRANCH, NO WORK TO DO; DEVICE NOT THERE
*
*
* AT THIS POINT /RAM (OR SOME OTHER DEVICE) IS CONNECTED IN
* THE SLOT 3, DRIVE 2 VECTOR.  NOW WE MUST GO THRU THE DEVICE
* LIST AND FIND THE SLOT 3, DRIVE 2 UNIT NUMBER OF /RAM ($BF).
* THE ACTUAL UNIT NUMBERS, (THAT IS TO SAY 'DEVICES') THAT WILL
* BE REMOVED WILL BE $BF, $BB, $B7, $B3.  /RAM'S DEVICE NUMBER
* IS $BF.  THUS THIS CONVENTION WILL ALLOW OTHER DEVICES THAT
* DO NOT NECESSARILY RESEMBLE (OR IN FACT, ARE COMPLETELY DIFFERENT
* FROM) /RAM TO REMAIN INTACT IN THE SYSTEM.
*
*
:CONT
    LDY DEVCNT        ; GET THE NUMBER OF DEVICES ONLINE
]LOOP
    LDA DEVLST,Y      ; START LOOKING FOR /RAM OR FACSIMILE
    AND #$F3              ; LOOKING FOR $BF, $BB, $B7, $B3
    CMP #$B3              ; IS DEVICE NUMBER IN {$BF,$BB,$B7,$B3}?
    BEQ :FOUND             ; BRANCH IF FOUND..
    DEY                   ; OTHERWISE CHECK OUT THE NEXT UNIT #.
    BPL ]LOOP              ; BRANCH UNLESS YOU'VE RUN OUT OF UNITS.
    BMI :DONE              ; SINCE YOU HAVE RUN OUT OF UNITS TO
:FOUND
    LDA DEVLST,Y     ; GET THE ORIGINAL UNIT NUMBER BACK
    STA RAMUNITID         ; AND SAVE IT OFF FOR LATER RESTORATION.
*
* NOW WE MUST REMOVE THE UNIT FROM THE DEVICE LIST BY BUBBLING
* UP THE TRAILING UNITS.
*
]GETLOOP
    LDA DEVLST+1,Y ; GET THE NEXT UNIT NUMBER
    STA DEVLST,Y         ; AND MOVE IT UP.
    BEQ :EXIT             ; BRANCH WHEN DONE(ZEROS TRAIL THE DEVLST)
    INY                  ; CONTINUE TO THE NEXT UNIT NUMBER...
    BNE ]GETLOOP          ; BRANCH ALWAYS.

:EXIT
    LDA RAMSLOT      ; SAVE SLOT 3, DRIVE 2 DEVICE ADDRESS.
    STA ADDRESS          ; SAVE OFF LOW BYTE OF /RAM DRIVER ADDRESS
    LDA RAMSLOT+1        ; SAVE OFF HI BYTE
    STA ADDRESS+1        ;

    LDA NODEV            ; FINALLY COPY THE 'NO DEVICE CONNECTED'
    STA RAMSLOT          ; INTO THE SLOT 3, DRIVE 2 VECTOR AND
    LDA NODEV+1          ;
    STA RAMSLOT+1        ;
    DEC DEVCNT           ; DECREMENT THE DEVICE COUNT.

:DONE
    PLP              ; RESTORE STATUS

    RTS                  ; AND RETURN

ADDRESS DW $0000      ; STORE THE DEVICE DRIVER ADDRESS HERE
RAMUNITID DFB $00     ; STORE THE DEVICE'S UNIT NUMBER HERE


* Reload prefix from source drive
DOSReloadPrefix
    lda sourceSlot
    ldx sourceDrive
    cpx #2
    bne :next
    ora #$80
:next
    sta :unitNum

    jsr PRODOS
    db kDOSOnline
    da :params
    bcs :error

    lda tmpPath+1
    and #$0F
    cmp #0
    beq :error

    clc
    adc #1
    sta tmpPath
    lda #'/'
    sta tmpPath+1

    lda #<tmpPath
    sta dosSetPrefixPath
    lda #>tmpPath
    sta dosSetPrefixPath+1
    jmp DOSSetPrefix

:params db 2
:unitNum db 0
    da tmpPath+1

:error
    pha
    lda #"E"
    jsr COUT
    pla
    jsr PrintA
    jsr WaitForKey
    sec
    rts
