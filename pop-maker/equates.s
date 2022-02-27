
**************************************
**
** Equates
**
**************************************

COUT            = $fded
HOME            = $fc58
CROUT           = $fde8
PRBYTE          = $fdda
TXTCLR          = $C050
TXTSET          = $C051
MIXCLR          = $C052
MIXSET          = $C053
TXTPAGE1        = $C054
TXTPAGE2        = $C055
LORES           = $C056
HIRES           = $C057

WAIT            = $FCA8
MON_VTAB        = $FC22
BASCALC         = $FBC1

kSet40Cols      = $11
kSet80Cols      = $12

CH              = $24   ; Cursor H-Pos
CV              = $25   ; Cursot V-Pos
BASL            = $28
BASH            = $29

prodosBuffer    = $6500 ; $6500-68FF ProDOS working buffer (always 1 kB, 4 pages)
stagingBuffer   = $4E00 ; $4E00-52FF Track 0 staging area (5 pages for RW18)
rw18Buffer      = $5300 ; $5300-64FF RW18 Input/Output Buffer (18 pages)
rootPath        = $4D00 ; 64 bytes, 4d00-4d40
tmpPath         = $4d41

rw18BufferSize    = 18
stagingBufferSize = 5

**************************************
**
** Zero Page 16-bit vars
**
**************************************

                DUM $0002

R1              ds 2   ; R1 used for memory moves and printing strings.
R2              ds 2   ; R2 used for memory moves and menu system.
dsScriptPtr     ds 2   ; Points to the current script

                DEND
