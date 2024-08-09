;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
;--T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		GAMEBullets.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48/ASM-Pro1.20b
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------

GB_TOTALBULLETS   = 100                                 ; Total possible bullets active
TOP_SCREEN        = 18                                  ; Top of screen check for bullet removal

GBSTATE_FREE      = $00
GBSTATE_FIRED     = $01
GBSTATE_MOVING    = $02
GBSTATE_OFFSCREEN = $03
GBSTATE_HIT       = $04
GBSTATE_DISTROYED = $05
GBSTATE_DEAD      = $06

GBTYPE_NONE       = $00
GBTYPE_PLAYER     = $01
GBTYPE_INVADER    = $02
GBTYPE_MOTHER     = $03

GBSTRUCT_STATE    = $00
GBSTRUCT_TYPE     = $04
GBSTRUCT_TEMP     = $08
GBSTRUCT_X        = $0c                                 ; These four values make up the active rect
GBSTRUCT_Y        = $10
GBSTRUCT_W        = $14
GBSTRUCT_H        = $18
GBSTRUCT_SPRNUM   = $1C
GBSTRUCT_SIZE     = $20


GBSPEED_PLAYER    = 3
GBSPEED_INVADER   = 2
GBSPEED_MOTHER    = 3

;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

    SECTION GB_CODE,CODE_F

;----------------------------------------------------------
; GB_Init
; Starting point, initialise the bullet controller 
;----------------------------------------------------------
GB_Init:

    movem.l d0/a0,-(a7)
    move.l  #GB_TOTALBULLETS,d0
    lea     GBBullets,a0

.setup:

    move.l  #GBSTATE_FREE,GBSTRUCT_STATE(a0)
    move.l  #GBTYPE_NONE,GBSTRUCT_TYPE(a0)
    move.l  #0,GBSTRUCT_TEMP(a0)	
    move.l  #0,GBSTRUCT_X(a0)
    move.l  #0,GBSTRUCT_Y(a0)
    move.l  #0,GBSTRUCT_SPRNUM(a0)

    lea     GBSTRUCT_SIZE(a0),a0
    dbf     d0,.setup

	; update the rest
    moveq   #0,d0
    move.l  d0,GBActiveBullets

    movem.l (a7)+,d0/a0
    rts

;----------------------------------------------------------
; GB_Update
; Processes the logic for each active bullet 
;----------------------------------------------------------
GB_Update:

    movem.l d0-d4/a0,-(a7)
    lea     GBBullets,a0
    move.l  GBActiveBullets,d4
    beq     .end

.loop:
    cmp.l  #GBSTATE_FREE,GBSTRUCT_STATE(a0)	
    beq.s  .next
    sub.b  #1,d4                            ; sub as bullet is processed

	; check collision with invaders
    move.l  a0,a1
    lea     GBSTRUCT_X(a0),a0
    jsr     GI_CheckCollision	
    move.l  a1,a0
    btst    #0,d0
    bne.s   .killBullet	


    sub.l   #GBSPEED_PLAYER,GBSTRUCT_Y(a0)
    cmp.l   #TOP_SCREEN,GBSTRUCT_Y(a0)
    bgt.s   .next

.killBullet:
		
	; kill bullet, the quick and dirty way for now
    move.l  #GBSTATE_FREE,GBSTRUCT_STATE(a0)
    sub.l   #1,GBActiveBullets

.next:

    lea     GBSTRUCT_SIZE(a0),a0	
    cmpi.l  #0,d4
    bne.s   .loop

.end:

    movem.l (a7)+,d0-d4/a0
    rts

;----------------------------------------------------------
; GB_Draw
; Draws all active bullets
;----------------------------------------------------------
GB_Draw:

    movem.l d0-d3/a0,-(a7)

    lea     GBBullets,a0
    move.l  GBActiveBullets,d3
    beq     .end

.loop:

    cmp.l   #GBSTATE_FREE,GBSTRUCT_STATE(a0)	
    beq.s   .next

    sub.b   #1,d3

    move.l  GBSTRUCT_X(a0),d0
    move.l  GBSTRUCT_Y(a0),d1
    move.l  GBSTRUCT_SPRNUM(a0),d2
    jsr     DrawInvSprite
	
.next:
	
    lea     GBSTRUCT_SIZE(a0),a0	
    cmpi.b  #0,d3
    bne.s   .loop

.end:

    movem.l (a7)+,d0-d3/a0
    rts



	; Debug active bullets
;	lea	GBBullets,a0
;	move.l	#10,d0
;	move.l	#160,d1
;	move.w	GBSTRUCT_X+2(a0),d2
;	add.l	#3,d2
;	swap	d2
;	move.w	GBSTRUCT_Y+2(a0),d2
;	jsr	DisplayHex
;	add.l	#$00010001,d2
;	move.l	#170,d1
;	jsr	DisplayHex
;
;	lea	GIInvaders,a0
;	move.l	#10,d0
;	move.l	#230,d1
;	move.w	GISTRUCT_X+2(a0),d2
;	add.l	#3,d2
;	swap	d2
;	move.w	GISTRUCT_Y+2(a0),d2
;	jsr	DisplayHex
;	lea	GBBullets,a0
;	move.l	GBSTRUCT_STATE(a0),d2
;	move.l	#240,d1
;	jsr	DisplayHex


;----------------------------------------------------------
; GB_AddBullet
; Regs - in
;   D0 - X position start
;   D1 - Y position start
;   D2 - Type of bullet
; Regs - out
;   D0 - Trashed, returns index of bullet or -1
;----------------------------------------------------------
GB_AddBullet:

    movem.l d1-d3/a0,-(a7)

    moveq   #0,d3
    lea     GBBullets,a0

.find:	

    cmp.l   #GBSTATE_FREE,GBSTRUCT_STATE(a0)
    beq.s   .found
    addq    #1,d3
    lea     GBSTRUCT_SIZE(a0),a0
    cmp.l   #GB_TOTALBULLETS,d3
    bne.s   .find

    move.l  #-1,GBTemp
    bra.s   .failed	

.found:

    move.l  d3,GBTemp
    move.l  #GBSTATE_FIRED,GBSTRUCT_STATE(a0)
    add.l   #4,d0                            ; get to center of the sprite
    move.l  d0,GBSTRUCT_X(a0)                ; store starting X/Y adjusted position
    move.l  d1,GBSTRUCT_Y(a0)
    move.l  #1,GBSTRUCT_W(a0)                ; size of sprite 1x1
    move.l  #1,GBSTRUCT_H(a0)                ;
	
    move.l  d2,GBSTRUCT_TYPE(a0)

	; set the spr number, temp fixed to invader bullet

    move.l  #3,GBSTRUCT_SPRNUM(a0)
    add.l   #1,GBActiveBullets	

.failed:

    movem.l (a7)+,d1-d3/a0
    move.l GBTemp,d0
    rts

;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

    SECTION GB_DATA,DATA_F

GBActiveBullets dc.l   0
GBTemp          dc.l   0

GBBullets       dcb.l  GB_TOTALBULLETS*GBSTRUCT_SIZE

;-----------------------------------------------------------------------------
; End of file: GAMEBullets.s
;-----------------------------------------------------------------------------
