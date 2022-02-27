
MLoadR1 MAC
    lda #<]1
    sta R1
    lda #>]1
    sta R1+1
    <<<

MLoadR2 MAC
    lda #<]1
    sta R2
    lda #>]1
    sta R2+1
    <<<

MLoadR1Ptr MAC
    lda ]1
    sta R1
    lda ]1+1
    sta R1+1
    <<<

MLoadR2Ptr MAC
    lda ]1
    sta R2
    lda ]1+1
    sta R2+1
    <<<

MPrintStr MAC
    MLoadR1 ]1
    jsr PrintString
    <<<

MPrintCRStr MAC
    jsr PrintCR
    MPrintStr ]1
    <<<

MPrintStrMulti MAC
    MLoadR1 ]1
    jsr PrintMultiString
    <<<

MPrintStrPtr MAC
    MLoadR1Ptr ]1
    jsr PrintString
    <<<

MPrintStr16Hex MAC
    MLoadR1 ]1
    jsr Print16Hex
    <<<

MPrintStr16HexPtr MAC
    MLoadR1Ptr ]1
    jsr Print16Hex
    <<<

MPrintCR MAC
    lda #kCR
    jsr COUT
    <<<

;; MMovePages sourcePages destPages pageCount
MMovePages MAC
    MLoadR1 ]1  ; sourcePageTable
    MLoadR2 ]2  ; destPageTable
    lda #]3     ; tableLength
    jsr MovePages
    <<<

MSetPathName MAC
    lda #<]1
    sta dosOpenPathName
    lda #>]1
    sta dosOpenPathName+1
    <<<

;; MLoadFile pathName;addr
MLoadFile MAC
    MSetPathName ]1
    lda #<]2
    sta dosReadInBuffer
    lda #>]2
    sta dosReadInBuffer+1
    jsr DOSLoadFile
    <<<

;; MSetWord location;value
MSetWord MAC
    lda #<]2
    sta ]1
    lda #>]2
    sta ]1+1
    <<<

MDebugPrintStr MAC
    DO DEBUG
    MPrintStr ]1
    FIN
    <<<

MDebugPrintA MAC
    DO DEBUG
    jsr PrintA
    FIN
    <<<

MDebugPrintCR MAC
    DO DEBUG
    jsr PrintCR
    FIN
    <<<

BRLessThan MAC
    bcc ]1
    <<<

BRGreaterThanOrEqual MAC
    bcs ]1
    <<<
