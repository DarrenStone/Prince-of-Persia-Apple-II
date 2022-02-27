
ReleasePatchScript
    DB dPrintString
    STR "RELEASE PATCH SCRIPT"
    DB dSetDiskID,kDiskIDSideA
    DB dSetSourceDisk,1                 ; popmaker disk 1
    DB dClearBuffer
        
    DB dSetTrack,19
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

    DB dEOF


KeyboardPatchScript
    DB dPrintString
    STR "KEYBOARD PATCH SCRIPT"
    DB dSetDiskID,kDiskIDSideA
    DB dSetSourceDisk,1                 ; popmaker disk 1
    DB dClearBuffer

    DB dSetTrack,19
    ** - - - - - - - - - - - - - - - - - CTRLSUBS
    DB dLoadFile
    DA f_ctrlSubs,$0200
    ** - - - - - - - - - - - - - - - - - SPECIALK.KBD
    DB dLoadFile
    DA f_specialK_kbd,$0b00
    ** - - - - - - - - - - - - - - - - - VERSION.KBD
    DB dLoadFile
    DA f_version_kbd,$11d8
    DB dWriteTrack              ; 19

    DB dEOF


DevPatchScript
    DB dPrintString
    STR "DEVELOPMENT PATCH SCRIPT"
    DB dSetSourceDisk,1                 ; popmaker disk 1
    DB dSetDiskID,kDiskIDSideA
    DB dClearBuffer

    DB dSetTrack,19
    ** - - - - - - - - - - - - - - - - - CTRLSUBS
    DB dLoadFile
    DA f_ctrlSubs,$0200
    ** - - - - - - - - - - - - - - - - - SPECIALK.DEV
    DB dLoadFile
    DA f_specialK_dev,$0b00
    ** - - - - - - - - - - - - - - - - - VERSION.DEV
    DB dLoadFile
    DA f_version_dev,$11d8
    DB dWriteTrack              ; 19

    DB dEOF

DebugPatchScript
    DB dPrintString
    STR "DEBUG PATCH SCRIPT"
    DB dSetSourceDisk,1                 ; popmaker disk 1
    DB dSetDiskID,kDiskIDSideA
    DB dClearBuffer

    DB dSetTrack,19
    ** - - - - - - - - - - - - - - - - - CTRLSUBS
    DB dLoadFile
    DA f_ctrlSubs,$0200
    ** - - - - - - - - - - - - - - - - - SPECIALK.DBG
    DB dLoadFile
    DA f_specialK_dbg,$0b00
    ** - - - - - - - - - - - - - - - - - VERSION.DBG
    DB dLoadFile
    DA f_version_dbg,$11d8
    DB dWriteTrack              ; 19

    DB dEOF
