;APS0000008A0000008A0000008A0000008A0000008A0000008A0000008A0000008A0000008A0000008A
;---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		StarfieldEffect.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48
;-----------------------------------------------------------------------------

; Notes
; The star position is 16 bit fixed point (32 bit full value)

;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------

SF_TOTALSTARS = 800

SFPOINT_X     = 0
SFPOINT_Y     = 4
SFPOINT_SP    = 8
SFPOINT_COL   = 12
SFPOINT_SIZE  = 16

;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

    SECTION Star_C,CODE_F


;----------------------------------------------------------
; StarField_Init
; Initializes the Starfield
;----------------------------------------------------------
Starfield_Init:

    movem.l d0-d2/d6/a0,-(sp)

    lea     StarData,a0
    move.l  #SF_TOTALSTARS-1,d6

.loop:

	clr.w	d0
	move.w	#SCREENWIDTH,d1
	jsr		Misc_RandomRange
	and.l	#$ffff,d0
	swap	d0
	move.l  d0,(a0)+

	clr.w	d0
	move.w	#SCREENHEIGHT,d1
	jsr		Misc_RandomRange
	and.l	#$ffff,d0
	swap	d0
	move.l  d0,(a0)+
	
    jsr     Misc_RandomNumber
	and.l	#$0000ffff,d0
    or.w  	#$07ff,d0                 ; min speed per frame
    move.l  d0,(a0)+

	lsl.l	#3,d0
    swap    d0
	move.w	#7,d1
	sub.w	d0,d1
	and.l	#$ff,d1
    addi.b  #$16,d1
    move.l  d1,(a0)+       

    dbf     d6,.loop

    movem.l (sp)+,d0-d2/d6/a0
    rts

;----------------------------------------------------------
; StarField_Update
; Updates the Starfield
;----------------------------------------------------------
Starfield_Update:

    movem.l d0-d3/a0,-(sp)

    lea     StarData,a0
    move.l  #SF_TOTALSTARS-1,d3

.loop:

    move.l  SFPOINT_Y(a0),d0  
    add.l   SFPOINT_SP(a0),d0
    swap    d0	
    cmp.w   #SCREENHEIGHT,d0
    blt.s   .storeY

    ; reset - random X position
	clr.w	d0
	move.w	#SCREENWIDTH,d1
	jsr		Misc_RandomRange
	and.l	#$ffff,d0
	swap	d0
	move.l  d0,SFPOINT_X(a0)
	
    jsr     Misc_RandomNumber
	and.l	#$0000ffff,d0
    or.w  	#$07ff,d0                 ; min speed per frame
    move.l  d0,SFPOINT_SP(a0)

	lsl.l	#3,d0
    swap    d0
	move.w	#7,d1
	sub.w	d0,d1
	and.l	#$ff,d1
	
    addi.b  #$16,d1
    move.l  d1,SFPOINT_COL(a0)       

    clr.l   d0

.storeY:
    swap	d0
    move.l  d0,SFPOINT_Y(a0)

    lea     SFPOINT_SIZE(a0),a0
    dbf     d3,.loop

    movem.l (sp)+,d0-d3/a0

    rts

;----------------------------------------------------------
; StarField_Draw
; Draws the Starfield
;----------------------------------------------------------
Starfield_Draw:

    movem.l d0-d3/a0,-(sp)

    lea     StarData,a0
    move.l  #SF_TOTALSTARS-1,d3
.loop:

    clr.l   d0
    clr.l   d1
    move.w  SFPOINT_X(a0),d0		; just high word
    move.w  SFPOINT_Y(a0),d1		; for X and Y
    move.l  SFPOINT_COL(a0),d2

    bsr.b   Starfield_DrawPixel

    lea     SFPOINT_SIZE(a0),a0
    dbf     d3,.loop

.end

    movem.l (sp)+,d0-d3/a0

    rts


;----------------------------------------------------------
; Starfield_DrawPixel
; Draws a star
; Regs d0 - x, d1 - y, d2 - color
;----------------------------------------------------------
Starfield_DrawPixel:

    movem.l d0-d2/a0,-(sp)

    move.l  BildPtr,a0
    mulu.w  #SCREENWIDTH,d1
    add.l   d1,d0
    add.l   d0,a0


    move.b  d2,(a0)

    movem.l (sp)+,d0-d2/a0
    rts



;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

    SECTION Star_D,DATA_F

StarData: 	ds.l	(SFPOINT_SIZE/4)*SF_TOTALSTARS
			ds.l	1000		

;-----------------------------------------------------------------------------
; End of file: StarfieldEffect.s
;-----------------------------------------------------------------------------
