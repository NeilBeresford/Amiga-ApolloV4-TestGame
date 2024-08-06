;APS00001D2F00001D2F00001D2F00001D2F00001D2F00001D2F00001D2F00001D2F00001D2F00001D2F
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		GAMEInvaders.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------

GI_TOTALINVADERS = 50
GI_NUMACROSS	= 10
GI_NUMDOWN	= 5
GI_STARTXPOS	= 10
GI_STARTYPOS	= 30
GI_INVSPACING	= 12
GI_FRAMEDELAY	= 6

GISTATE_FREE	= $00
GISTATE_ACTIVE	= $01
GISTATE_EXPLODE	= $02

GISTRUCT_STATE	= $00
GISTRUCT_X	= $04
GISTRUCT_Y	= $08
GISTRUCT_W	= $0C
GISTRUCT_H	= $10
GISTRUCT_SPRNUM = $14
GISTRUCT_TEMP	= $18
GISTRUCT_SIZE	= $1C


;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------


	SECTION	GI_CODE,CODE_F
	

;----------------------------------------------------------
; GInv_Init
; Initialise the Game Invaders
;----------------------------------------------------------
GI_Init:

	movem.l	d0-d5/a0,-(SP)

	; Initial positions and invader frames

	clr.l	d5
	move.l	#GI_NUMDOWN-1,d0
	lea	GIInvaders,a0

	move.l	#GI_STARTYPOS,d2
	move.l	#0,d3

.startRow:

	move.l	#GI_NUMACROSS-1,d4
	move.l	#GI_STARTXPOS,d1

.setup:
	move.l	#GISTATE_ACTIVE,GISTRUCT_STATE(a0)
	move.l	d1,GISTRUCT_X(a0)
	move.l	d2,GISTRUCT_Y(a0)
	move.l	#8,GISTRUCT_W(a0)
	move.l	#8,GISTRUCT_H(a0)
	move.l	d3,GISTRUCT_SPRNUM(a0)
	lea	GISTRUCT_SIZE(a0),a0
	add	#GI_INVSPACING,d1
	addq	#1,d5
	dbf	d4,.setup

	move.l	#GI_STARTXPOS,d1
	eor.b	#1,d3
	add	#GI_INVSPACING,d2

	dbf	d0,.startRow

	; setup the controller

	move.l	#1,GINVDirection
	move.l	d5,GINVTotalActive
	move.l	#GI_FRAMEDELAY,GINVFrameDelay

	movem.l	(SP)+,d0-d5/a0
	rts

;----------------------------------------------------------
; GInv_Update
; Logic update the Game Invaders
;----------------------------------------------------------
GI_Update:

	movem.l	d0-d2/a0,-(SP)

	; Moving the invaders
	

	subq.l	#1,GINVFrameDelay
	bpl.s	.skipFrameChange

	move.l	#GI_FRAMEDELAY,GINVFrameDelay
	lea	GIInvaders,a0
	move.l	#GI_TOTALINVADERS-1,d0

.frameChange:
	
	cmpi.l	#GISTATE_ACTIVE,GISTRUCT_STATE(a0)
	bne.s	.frameNext
	eor.l	#1,GISTRUCT_SPRNUM(a0)
.frameNext:
	lea	GISTRUCT_SIZE(a0),a0
	dbf	d0,.frameChange	

.skipFrameChange:

	lea	GIInvaders,a0
	move.l	GINVTotalActive,d0
	move.l	GINVDirection,d1
	clr.l	d2
	cmp.l	#0,d1
	bge	.update
	move.l	#SCREENWIDTH,d2

.update:

	cmp.l	#GISTATE_FREE,GISTRUCT_STATE(a0)
	beq.s	.next	

	sub.l	#1,d0

	cmp.l	#GISTATE_ACTIVE,GISTRUCT_STATE(a0)
	beq.s	.activeState

.explodeState:

	sub.l	#1,GISTRUCT_TEMP(a0)
	bne.s	.activeState
			
	move.l	#GISTATE_FREE,GISTRUCT_STATE(a0)
	sub.l	#1,GINVTotalActive
	bra.s	.next

.activeState:

	add.l	d1,GISTRUCT_X(a0)
	cmp.l	#0,d1
	bge	.goingRight
	
	cmp.l	GISTRUCT_X(a0),d2
	bgt	.setLimit
	bra.s	.next


.goingRight:

	cmp.l	GISTRUCT_X(a0),d2
	bgt	.next

.setLimit:

	move.l	GISTRUCT_X(a0),d2

.next:
	lea	GISTRUCT_SIZE(a0),a0
	cmpi.l	#0,d0	
	bne.s	.update

	; check direction change

	cmp.l	#SCREENWIDTH-22,d2
	bgt	.changeDir
	cmp.l	#10,d2
	bgt	.skipDirChange

.changeDir:	

	neg.l	d1
	move.l	d1,GINVDirection

.skipDirChange:
		
	movem.l	(SP)+,d0-d2/a0
	rts


;----------------------------------------------------------
; GI_Draw
; Draws all active Game Invaders
;----------------------------------------------------------
GI_Draw:

	movem.l	d0-d2/d7/a0,-(SP)

	move.l	GINVTotalActive,d7
	lea	GIInvaders,a0

.draw
	cmp.l	#GISTATE_FREE,GISTRUCT_STATE(a0)
	beq.s	.skipDraw

	subq	#1,d7

	move.l	GISTRUCT_X(a0),d0
	move.l	GISTRUCT_Y(a0),d1
	move.l  GISTRUCT_SPRNUM(a0),d2
	jsr	DrawInvSprite

.skipDraw

	lea	GISTRUCT_SIZE(a0),a0
	cmpi.l	#0,d7
	bne.s	.draw

	movem.l	(SP)+,d0-d2/d7/a0
	rts


;----------------------------------------------------------
; GI_CheckCollision
; Checks the collision between the source passed in, and
; all active invaders
;   Regs a0 - points to source RECT
;   returns
;	 d0 - 0 no collides, 1 collided 	
;----------------------------------------------------------
GI_CheckCollision:


	movem.l	d7/a1-a2,-(SP)
	
	move.l	GINVTotalActive,d7
	lea	GIInvaders,a2

.loop:
	cmp.l	#GISTATE_FREE,GISTRUCT_STATE(a2)
	beq.s	.next

	subq	#1,d7

	cmp.l	#GISTATE_ACTIVE,GISTRUCT_STATE(a2)
	bne.s	.next

	lea	GISTRUCT_X(a2),a1

	jsr 	CheckCollision
	btst	#0,d0
	beq.s	.next


	; Explosion sound
	move.l	#SNDInvExplode,$DFF440	; Set music Addr
	move.l	#(SNDInvExplodeE-SNDInvExplode)/4,$DFF444	; set musik length
	move.w	#$7F7F,$DFF448		; set Volume
	move.w	#80,$DFF44C		; 
	move.w	#3,$DFF44A		; 16bit mono music, one shoot
	move.w	#$8004,$DFF096		; turn Audio DMA on
	


	move.l	#10,GISTRUCT_TEMP(a2)
	move.l	#GISTATE_EXPLODE,GISTRUCT_STATE(a2)
	move.l	#5,GISTRUCT_SPRNUM(a2)
	moveq	#1,d0	
	bra.s	.end

.next:

	lea	GISTRUCT_SIZE(a2),a2
	cmpi.l	#0,d7
	bne.w	.loop
	clr.l	d0
			
.end:

	movem.l	(SP)+,d7/a1-a2
	rts



;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

	SECTION GI_DATA,DATA_F

GINVDirection	dc.l	4
GINVFrameDelay	dc.l	GI_FRAMEDELAY
GINVTotalActive	dc.l	0

GIInvaders	dcb.b	GISTRUCT_SIZE*GI_TOTALINVADERS	

SNDInvExplode	incbin	"Sound/alien-kill2.raw"	
SNDInvExplodeE


;-----------------------------------------------------------------------------
; End of file: GAMEInvaders.s
;-----------------------------------------------------------------------------

