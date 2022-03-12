
************************************************************
************************************************************

SideBScript
    DB dPrintString
    STR "SIDE B SCRIPT"
    DB dSetDiskID,kDiskIDSideB
    DB dClearBuffer

    DB dSetSourceDisk,2     ; popmaker disk 2

* Seeing strang behavior when copying between two real drives:
*
* If the head is already at track zero before the first flush,
* track 0 is not written correctly.  Perhaps the drive needs
* more time to settle when switching from another active drive.
* The problem doesn't occur when copying from a CFFA3000.
*
* To work around the problem, seek to track 1 at the start,
* and set track 0 as the next write.  This will force the
* head to move before writing begins, matching the behavior
* of the other tracks.
    DB dSeek,1
    DB dSetTrack,0
** - - - - - - - - - - - - - - - - - IMG.BGTAB1.PAL
    DB dOpenFile
    DA f_imgBgTab1Pal
    DB dRead,$00
    DB dWriteTrack             ; 0
    DB dRead,$00
    DB dWriteTrack             ; 1
    DB dCloseFile

** - - - - - - - - - - - - - - - - - IMG.BGTAB2.PAL
    DB dLoadFile
    DA f_imgBgTab2Pal,$0000
    DB dFixImageTable,$00,$84
    DB dWriteTrack             ; 2

** - - - - - - - - - - - - - - - - - IMG.CHTAB4.SKEL
    DB dOpenFile
    DA f_imgChTab4Skel
    DB dRead,$00
    DB dFixImageTable,$00,$96
    DB dWriteTrack             ; 3
    DB dRead,$00
    DB dCloseFile     ; Mixed Track

** - - - - - - - - - - - - - - - - - IMG.CHTAB4.GD
    DB dOpenFile
    DA f_imgChTab4Gd
    DB dRead,$06
    DB dFixImageTable,$06,$96
    DB dWriteTrack             ; 4
    DB dReadPartial,$00,$0C
    DB dCloseFile     ; Mixed Track

** - - - - - - - - - - - - - - - - - IMG.CHTAB4.FAT
    DB dOpenFile
    DA f_imgChTab4Fat
    DB dRead,$0c
    DB dFixImageTable,$0c,$96
    DB dWriteTrack             ; 5
    DB dRead,$00
    DB dWriteTrack             ; 6
    DB dCloseFile

    DB dSetSourceDisk,3        ; popmaker disk 3

** - - - - - - - - - - - - - - - - - IMG.BGTAB1.DUN
    DB dOpenFile
    DA f_imgBgTab1Dun
    DB dRead,$00
    DB dWriteTrack             ; 7
    DB dRead,$00
    DB dWriteTrack             ; 8
    DB dCloseFile

** - - - - - - - - - - - - - - - - - IMG.BGTAB2.DUN
    DB dLoadFile
    DA f_imgBgTab2Dun,$0000
    DB dFixImageTable,$00,$84
    DB dWriteTrack             ; 9

** - - - - - - - - - - - - - - - - - IMG.CHTAB4.SHAD
    DB dOpenFile
    DA f_imgChTab4Shad
    DB dRead,$00
    DB dFixImageTable,$00,$96
    DB dWriteTrack             ; 10
    DB dRead,$00     ; Mixed Track
    DB dCloseFile

** - - - - - - - - - - - - - - - - - IMG.CHTAB4.VIZ
    DB dOpenFile
    DA f_imgChTab4Viz
    DB dRead,$06
    DB dFixImageTable,$06,$96
    DB dWriteTrack             ; 11
    DB dRead,$00
    DB dCloseFile     ; Mixed Track

** - - - - - - - - - - - - - - - - - VID.STUFF.0C
    DB dOpenFile
    DA f_vidStuff
    DB dRead,$0c
    DB dWriteTrack             ; 12
    DB dRead,$00
    DB dWriteTrack             ; 13
    DB dRead,$00
    DB dWriteTrack             ; 14
    DB dRead,$00
    DB dWriteTrack             ; 15
    DB dRead,$00
    DB dWriteTrack             ; 16
    DB dRead,$00
    DB dWriteTrack             ; 17
    DB dCloseFile

** - - - - - - - - - - - - - - - - - STAGE1.SIDEB.DATA
    DB dOpenFile
    DA f_stage1SideB
    DB dRead,$00
    DB dWriteTrack             ; 18
    DB dRead,$00
    DB dWriteTrack             ; 19
    DB dRead,$00
    DB dWriteTrack             ; 20
    DB dRead,$00
    DB dWriteTrack             ; 21
    DB dRead,$00
    DB dWriteTrack             ; 22
    DB dCloseFile

    DB dDefaultGameSaveData
    DB dWriteTrack             ; 23 Default Game Save Data

** - - - - - - - - - - - - - - - - - IMG.CHTAB6.B
    DB dOpenFile
    DA f_imgChTab6B
    DB dRead,$00
    DB dWriteTrack             ; 24
    DB dRead,$00
    DB dWriteTrack             ; 25
    DB dCloseFile

** - - - - - - - - - - - - - - - - - PRINCESS.SIDEB.SCENE
    DB dOpenFile
    DA f_princessSideB
    DB dRead,$00
    DB dWriteTrack             ; 26
    DB dRead,$00
    DB dWriteTrack             ; 27
    DB dCloseFile

** - - - - - - - - - - - - - - - - - LEVEL13, LEVEL14
    DB dLoadFile
    DA f_level13,$0000
    DB dLoadFile
    DA f_level14,$0900
    DB dWriteTrack             ; 28

** - - - - - - - - - - - - - - - - - LEVEL11, LEVEL12
    DB dLoadFile
    DA f_level11,$0000
    DB dLoadFile
    DA f_level12,$0900
    DB dWriteTrack             ; 29

** - - - - - - - - - - - - - - - - - LEVEL9, LEVEL10
    DB dLoadFile
    DA f_level9,$0000
    DB dLoadFile
    DA f_level10,$0900
    DB dWriteTrack             ; 30

** - - - - - - - - - - - - - - - - - LEVEL7, LEVEL8
    DB dLoadFile
    DA f_level7,$0000
    DB dLoadFile
    DA f_level8,$0900
    DB dWriteTrack             ; 31

** - - - - - - - - - - - - - - - - - LEVEL5, LEVEL6
    DB dLoadFile
    DA f_level5,$0000
    DB dLoadFile
    DA f_level6,$0900
    DB dWriteTrack             ; 32

** - - - - - - - - - - - - - - - - - LEVEL3, LEVEL4
    DB dLoadFile
    DA f_level3,$0000
    DB dLoadFile
    DA f_level4,$0900
    DB dWriteTrack             ; 33

** - - - - - - - - - - - - - - - - - MUSIC.SET3
    DB dLoadFile
    DA f_musicSet3,$0000
    DB dWriteTrack             ; 34

    DB dEOF
