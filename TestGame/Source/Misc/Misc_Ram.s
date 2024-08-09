;APS00000089000000890000008900000089000000890000008900000089000000890000008900000089
;---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		Misc_Ram.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------

mult    = 34564
inc     = 7682
seed    = 12032
mod     = 65535

;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

    SECTION Code,CODE_F

;----------------------------------------------------------
; Misc_RandomRange
; Returns a random number between d0.w and d1.w both
;	trashed
; d0 = min
; d1 = max
; Returns
; d0 = random number
;----------------------------------------------------------
Misc_RandomRange:

    move.l  d2,-(sp)
    sub.w   d0,d1
    addq.w  #1,d1
    move.w  old_seed,d2

    mulu.w  #mult,d2
    add.l   #inc,d2
    divu.w  #mod,d2
    swap    d2
    move.w  d2,old_seed

    mulu.w  d1,d2
    divu.w  #mod,d2
    add.w   d2,d0
    move.l  (sp)+,d2
    rts

;----------------------------------------------------------
; Misc_RandomNumber
; Returns a random number
; Returns
; d0 = random number
;----------------------------------------------------------
Misc_RandomNumber:

    move.l  d2,-(sp)
    move.w  old_seed,d2
    mulu.w  #mult,d2
    add.l   #inc,d2
    divu.w  #mod,d2
    swap    d2
    move.w  d2,old_seed
    move.w  d2,d0
    move.l  (sp)+,d2

    rts

;----------------------------------------------------------
; Misc_RandomChangeSeed
; Changes the seed value
; d0 = new seed
;----------------------------------------------------------
Misc_RandomChangeSeed:

    move.w  d0,old_seed
    move.w	d0,new_seed
    rts

;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

    SECTION Data,DATA_F

new_seed:	dc.w seed
old_seed:   dc.w seed 

;-----------------------------------------------------------------------------
; End of file: Misc_Ram.s
;-----------------------------------------------------------------------------
