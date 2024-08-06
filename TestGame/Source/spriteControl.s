;APS000018B5000018B5000018B5000018B5000018B5000018B5000018B5000018B5000018B5000018B5
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		spriteControl.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48,ASMPro1.20b
;-----------------------------------------------------------------------------

	SECTION sprCode,CODE_F

;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------


RECT_X		= $00
RECT_Y		= $04
RECT_W		= $08
RECT_H		= $0C
RECT_SIZE	= $10


;-----------------------------------------------------------------------------
; Macros
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

;----------------------------------------------------------
; DrawTestSprite
; Draws the test sprite
; Regs:
;	d0	- SCR X position
;	d1	- SCR Y position
;	d2	- Index, see InvSpriteData (x,y,w,h)
;----------------------------------------------------------
DrawInvSprite:

	movem.l	d0-a2,-(SP)

	; get the sprite data
	lsl.l	#2,d2
	lea	InvSpriteData,a2
	add.l	d2,a2
	

	; calc the screen position
	mulu	#SCREENWIDTH,d1
	add	d0,d1
	lea	InvSprites,a1
	move.l	BildPtr,a0
	;lea	BackgroundImage,a0
	add.l	d1,a0

	; get dimentions of sprite
	; and calculate screen modulo
	
	clr.l	d0	; x position of source
	clr.l	d1	; y position of source
	clr.l	d5	; w of sprite to draw
	clr.l	d6	; h of sprite to draw
	move.b	(a2)+,d0
	move.b	(a2)+,d1
	move.b	(a2)+,d5
	move.b	(a2)+,d6

	; calc the position of the sprite

	mulu	#208,d1
	add.l	d0,d1
	add.l	d1,a1
		
	move.l	#SCREENWIDTH,d4
	sub.w	d5,d4
	move.l	#208,d2
	sub	d5,d2

	move.b	(a1),d3	; transparent colour

	; Draw sprite
	sub	#1,d5
	sub	#1,d6

.loopY:

	move.l	d5,d0

.loopX:

	cmp.b	(a1),d3
	beq.s	.skip
	move.b	(a1),(a0)

.skip:

	add.l	#1,a1
	add.l	#1,a0
	dbf	d0,.loopX
	add.l	d2,a1
	add.l	d4,a0
	dbf	d6,.loopY	
	
	movem.l	(SP)+,d0-a2
	rts


;----------------------------------------------------------
; CheckCollision
; Checks the source rect against dest rect
;  RECT is assumed to be:  X,Y,W,H
; Regs:
;	a0	- points to source RECT
;	a1	- points to target RECT
; Ret:	d0	- ZERO no collision / 1 collision
;----------------------------------------------------------
CheckCollision:

	movem.l d1-d3,-(SP)

	; checks:
	; X positions

	move.l	RECT_X(a0),d0		; Source LEFT
	move.l	RECT_X(a1),d1		; Target LEFT
	move.l	d0,d2
	move.l	d1,d3
	add.l	RECT_W(a0),d2		; Source RIGHT
	add.l	RECT_W(a1),d3		; Target RIGHT

	; if ( sLeft < tRight && sRight > tLeft )

	cmp.l	d3,d0
	bgt.s	.notC
	cmp.l	d2,d1
	bgt.s	.notC
	
	; checks:
	; Y positions

	move.l	RECT_Y(a0),d0		; Source TOP
	move.l	RECT_Y(a1),d1		; Target TOP
	move.l	d0,d2
	move.l	d1,d3
	add.l	RECT_H(a0),d2		; Source BOTTON
	add.l	RECT_H(a1),d3		; Target BOTTOM

	; if ( sTop < tBottom && sBottom > tTop )

	cmp.l	d0,d3
	blt.s	.notC
	cmp.l	d1,d2
	bgt.s	.notC
	
.Collison:

	; TEMP - generate a hit sound 
	;move.l	#GPFireSND+64,$DFF420	; Set music Addr
	;move.l	#(GPFireSNDE-GPFireSND-64)/4,$DFF424	; set musik length
	;move.w	#$7F7F,$DFF428		; max Volume
	;move.w	#160,$DFF42C		; 22 Khz
	;move.w	#3,$DFF42A		; 16bit mono music, one shoot
	;move.w	#$8004,$DFF096		; turn Audio DMA on

	moveq	#1,d0
	bra.s	.endC

.notC:

	clr.l	d0

.endC:

	movem.l (SP)+,d1-d3	
	rts


;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------


	SECTION sprData,DATA_F

InvSpriteData:

	dc.b	$00,$00,$08,$08	; 0 Invader 1-1
	dc.b	$09,$00,$08,$08	; 1 Invader 1-2
	dc.b	115,63,11,8	; 2 Player
	dc.b	119,54,3,5	; 3 Player Bullet
	dc.b	112,126,24,24	; 4 BASE
	dc.b	102,0,8,8	; 5 Invader explode frame

	EVEN
	
InvSprites:

	incbin "Graphics/InvSprites.png.raw"

InvSpritesE:



;-----------------------------------------------------------------------------
; End of file: spriteControl.s
;-----------------------------------------------------------------------------
