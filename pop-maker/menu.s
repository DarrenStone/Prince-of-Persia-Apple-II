
************************************
**
** Quick and dirty menu sytem
**
************************************

**
** Menu Table.  Format: [title string ptr][count][menu item string ptr][dispatch ptr]...
**
menuTable da $0000

**
** Menu Subtitles (optional hack)  Format: [string ptr][string ptr]...
**
menuSubtitles da $0000

**
** Dispatched functions can set this to automatically quit
** the menu on return.
**
menuQuitFlag db 0

** Menu table offsets
kMenuTitle = 0
kMenuCount = 2
kMenuItemTitle = 3
kMenuItemFunc = 5

************************************
**
** Menu System Entry Point
**
** Uses R2
**
************************************
RunMenu
]start
    MLoadR2Ptr menuTable

    lda #0
    sta _menuIndex
    sta menuQuitFlag
    jsr ClearScreen

    lda #2
    jsr VTab

**
** Print Title
**
    ldy #0                  ; Y is index into menu table
    jsr _PrintMenuString    ; Print string at Y, and increment

**
** Get Menu Item Count
**
    lda (R2),y
    sta _menuCount
    iny

    lda menuSubtitles+1     ; If menuSubtitles is nil, print a simple menu
    beq :printSimpleMenu

    jsr _PrintSubtitleMenu  ;  Otherwise, print a subtitled menu.
    jmp :keyboard
:printSimpleMenu
    jsr _PrintSimpleMenu

:keyboard
    MLoadR2Ptr menuTable
    jsr PrintCR
    jsr _PrintMenuString    ; Footer, if any

    bit $c010
]1  lda $c000
    bpl ]1
    bit $c010

    sta _menuKey
    cmp #"1"
    BRLessThan :noNum
    sec
    sbc #"1"
    cmp _menuCount
    BRLessThan :validKey

:noNum
    lda _menuKey
    cmp #kESC
    beq :rts
    and #kUpperCase
    cmp #"Q"
    beq :rts
    jmp ]1

:rts
    jsr _ResetMenuPointers
    rts

:validKey
    asl
    asl                     ; Multiply by 4 to get function pointer
    clc
    adc #kMenuItemFunc
    tay
    lda (R2),y
    sta _menuDispatchPtr
    iny
    lda (R2),y
    beq :rts                ; No function pointer.  Quit
    sta _menuDispatchPtr+1
    jsr :dispatch
    lda menuQuitFlag
    bne :rts
    jmp ]start


:dispatch
    lda menuTable
    pha
    lda menuTable+1
    pha
    lda menuSubtitles
    pha
    lda menuSubtitles+1
    pha

    jsr _ResetMenuPointers
    jsr :trampoline

    pla
    sta menuSubtitles+1
    pla
    sta menuSubtitles
    pla
    sta menuTable+1
    pla
    sta menuTable
    rts

:trampoline
    jmp (_menuDispatchPtr)

***************************************************
**
** Subtitle Menu
**
***************************************************
*  Y is index into start of menu items
*  _menuIndex is zero
*  _menuCount is count of menu items
_PrintSubtitleMenu
    lda #0
    sta :subtitleIndex
    sty :tableIndex
]next
    MLoadR2Ptr menuTable
    ldy :tableIndex

    inc _menuIndex
    lda _menuIndex
    cmp _menuCount
    beq :printQ                 ; Last item is quit

    jsr PrintBCD                ; Otherwise, print menu number
    jsr _PrintMenuItem
    iny
    iny
    sty :tableIndex

    MLoadR2Ptr menuSubtitles
    ldy :subtitleIndex
    lda #3
    sta CH
    jsr _PrintMenuString
    sty :subtitleIndex
    jsr PrintCR

    jmp ]next

:printQ
    lda #"Q"
    jsr COUT
    jsr _PrintMenuItem
    iny                 ; Move past quit function pointer
    iny
    dec _menuCount      ; Remove last item from number key dispatch
:rts rts

:tableIndex db 0
:subtitleIndex db 0

***************************************************
**
** Simple Menu
**
***************************************************
*  Y is index into start of menu items
*  _menuIndex is zero
*  _menuCount is count of menu items
_PrintSimpleMenu
    inc _menuIndex
    lda _menuIndex
    cmp _menuCount
    beq :printQ         ; Last item is quit

    jsr PrintBCD        ; Otherwise, print menu number
    jsr _PrintMenuItem
    iny
    iny
    jmp _PrintSimpleMenu

:printQ
    jsr PrintCR
    lda #"Q"
    jsr COUT
    jsr _PrintMenuItem
    iny                 ; Move past quit function pointer
    iny
    dec _menuCount      ; Remove last item from number key dispatch
:rts rts

_PrintMenuItem
    lda #"."
    jsr COUT
    lda #" "
    jsr COUT
    jsr _PrintMenuString
    rts

_menuIndex db 0
_menuKey db 0
_menuCount db 0
_menuDispatchPtr da $0000


*
* Y is index into table in R2
*
_PrintMenuString
    lda (R2),y
    sta R1
    iny
    lda (R2),y
    beq :noString
    iny
    sta R1+1
    jsr PrintString
    jmp PrintCR

:saveY db 0

:noString
    iny
    rts

_ResetMenuPointers
    lda #0
    sta menuTable
    sta menuTable+1
    sta menuSubtitles
    sta menuSubtitles+1
    sta menuQuitFlag
    rts
