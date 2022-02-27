************************************************************
************************************************************

SideAScript
    DB dPrintString
    STR "SIDE A SCRIPT"
    DB dSetDiskID,kDiskIDSideA

    DB dSetSourceDisk,1     ; popmaker disk 1

    DB dSetTrack,1  ; We can assume we're still at track 0 after writing
                    ; boot sectors, so just set the next write to track 1.
                    
    DB dClearBuffer

** - - - - - - - - - - - - - - - - - HIRES
    DB dLoadFile
    DA f_hires,$0000
** - - - - - - - - - - - - - - - - - MASTER.525
    DB dLoadFile
    DA f_master,$0a80
    DB dWriteTrack              ; 1

** - - - - - - - - - - - - - - - - - HRTABLES
    DB dLoadFile
    DA f_hrtables,$0000
** - - - - - - - - - - - - - - - - - UNPACK.525
    DB dLoadFile
    DA f_unpack,$0a00
    DB dWriteTrack              ; 2

** - - - - - - - - - - - - - - - - - TABLES
    DB dLoadFile
    DA f_tables,$0000
** - - - - - - - - - - - - - - - - - FRAMEADV
    DB dLoadFile
    DA f_frameAdv,$0490
    DB dWriteTrack              ; 3

** - - - - - - - - - - - - - - - - - GRAFIX.525
    DB dLoadFile
    DA f_grafix,$0000
** - - - - - - - - - - - - - - - - - TOPCTRL
    DB dLoadFile
    DA f_topctrl,$0a00
    DB dWriteTrack              ; 4

** - - - - - - - - - - - - - - - - - IMG.BGTAB1.DUN
    DB dOpenFile
    DA f_imgBgTab1Dun
    DB dRead,$00
    DB dWriteTrack              ; 5
    DB dRead,$00
    DB dCloseFile
    DB dWriteTrack              ; 6

** - - - - - - - - - - - - - - - - - IMG.CHTAB1
    DB dOpenFile
    DA f_imgChTab1
    DB dRead,$00
    DB dWriteTrack              ; 7
    DB dRead,$00
    DB dCloseFile
    DB dWriteTrack              ; 8

** - - - - - - - - - - - - - - - - - IMG.CHTAB2
    DB dOpenFile
    DA f_imgChTab2
    DB dRead,$00
    DB dFixImageTable,$00,$84
    DB dWriteTrack              ; 9
    DB dRead,$00
    DB dCloseFile
    DB dWriteTrack              ; 10

** - - - - - - - - - - - - - - - - - IMG.CHTAB3
    DB dOpenFile
    DA f_imgChTab3
    DB dRead,$00
    DB dFixImageTable,$00,$08
    DB dWriteTrack              ; 11
    DB dRead,$00
    DB dCloseFile         ; Mixed Track

** - - - - - - - - - - - - - - - - - IMG.CHTAB5
    DB dOpenFile
    DA f_imgChTab5
    DB dRead,$06
    DB dFixImageTable,$06,$A8
    DB dWriteTrack              ; 12
    DB dRead,$00
    DB dCloseFile         ; Mixed Track

** - - - - - - - - - - - - - - - - - IMG.CHTAB4.GD
    DB dOpenFile
    DA f_imgChTab4gd
    DB dRead,$0c
    DB dFixImageTable,$0c,$96
    DB dWriteTrack              ; 13
    DB dReadPartial,$00,$0f
    DB dCloseFile
    DB dWriteTrack              ; 14

** - - - - - - - - - - - - - - - - - FRAMEDEF
    DB dLoadFile
    DA f_frameDef,$0000
** - - - - - - - - - - - - - - - - - SEQTABLE
    DB dLoadFile
    DA f_seqTable,$0800
    DB dWriteTrack              ; 15

** - - - - - - - - - - - - - - - - - CTRL
    DB dLoadFile
    DA f_ctrl,$0000
** - - - - - - - - - - - - - - - - - COLL
    DB dLoadFile
    DA f_coll,$0b00
    DB dWriteTrack              ; 16

** - - - - - - - - - - - - - - - - - GAMEBG
    DB dLoadFile
    DA f_gameBG,$0000
** - - - - - - - - - - - - - - - - - AUTO
    DB dLoadFile
    DA f_auto,$0800
    DB dWriteTrack              ; 17

    DB dSetSourceDisk,2     ; popmaker disk 2

** - - - - - - - - - - - - - - - - - IMG.BGTAB2.DUN
    DB dLoadFile
    DA f_imgBgTab2Dun,$0000
    DB dFixImageTable,$00,$84
    DB dWriteTrack              ; 18

** - - - - - - - - - - - - - - - - - CTRLSUBS
    DB dLoadFile
    DA f_ctrlSubs,$0200
** - - - - - - - - - - - - - - - - - SPECIALK
    DB dLoadFile
    DA f_specialK,$0b00
** - - - - - - - - - - - - - - - - - VERSION
    DB dLoadFile
    DA f_version,$11d8
    DB dWriteTrack              ; 19

** - - - - - - - - - - - - - - - - - MUSIC.SET2
    DB dLoadFile
    DA f_musicSet2,$0000
** - - - - - - - - - - - - - - - - - SUBS
    DB dLoadFile
    DA f_subs,$0400
** - - - - - - - - - - - - - - - - - SOUND
    DB dLoadFile
    DA f_sound,$0e00
    DB dWriteTrack              ; 20

** - - - - - - - - - - - - - - - - - MOVER
    DB dLoadFile
    DA f_mover,$0000
** - - - - - - - - - - - - - - - - - MISC
    DB dLoadFile
    DA f_misc,$0b00
    DB dWriteTrack              ; 21

** - - - - - - - - - - - - - - - - - STAGE1.SIDEA
    DB dOpenFile
    DA f_stage1SideA
    DB dRead,$00
    DB dWriteTrack              ; 22
    DB dRead,$00
    DB dWriteTrack              ; 23
    DB dRead,$00
    DB dWriteTrack              ; 24
    DB dRead,$00
    DB dWriteTrack              ; 25
    DB dRead,$00
    DB dWriteTrack              ; 26
    DB dRead,$00
    DB dWriteTrack              ; 27
    DB dRead,$00           ; Mixed Track
    DB dCloseFile

** - - - - - - - - - - - - - - - - - IMG.CHTAB7
    DB dLoadFile
    DA f_imgChTab7,$0d00
    DB dFixImageTable,$0d,$9F
    DB dWriteTrack              ; 28

** - - - - - - - - - - - - - - - - - IMG.CHTAB6.A
    DB dOpenFile
    DA f_imgChTab6a
    DB dRead,$00
    DB dWriteTrack              ; 29
    DB dRead,$00
    DB dCloseFile
    DB dWriteTrack              ; 30

** - - - - - - - - - - - - - - - - - PRINCESS.SIDEA.SCENE
    DB dOpenFile
    DA f_princessSideA
    DB dRead,$00
    DB dWriteTrack              ; 31
    DB dRead,$00           ; Mixed Track
    DB dCloseFile

** - - - - - - - - - - - - - - - - - LEVEL2
    DB dLoadFile
    DA f_level2,$0900
    DB dWriteTrack              ; 32

** - - - - - - - - - - - - - - - - - LEVEL0, LEVEL1
    DB dLoadFile
    DA f_level0,$0000
    DB dLoadFile
    DA f_level1,$0900
    DB dWriteTrack              ; 33

** - - - - - - - - - - - - - - - - - MUSIC.SET1
    DB dLoadFile
    DA f_musicSet1,$0000
    DB dWriteTrack              ; 34

    DB dEOF


