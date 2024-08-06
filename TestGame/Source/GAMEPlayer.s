;APS00001FF200001FF200001FF200001FF200001FF200001FF200001FF200001FF200001FF200001FF2
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		GAMEPlayer.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;  Defines
;-----------------------------------------------------------------------------

GAME_NUMPLAYERS	= 1

GPSTRUCT_STATE	= $00
GPSTRUCT_BULDLY	= $02
GPSTRUCT_X	= $06		; these are used for RECT calcs like collision
GPSTRUCT_Y	= $0a
GPSTRUCT_W	= $0e
GPSTRUCT_H	= $12
GPSTRUCT_SIZE	= $16


GP_BULLETDELAY	= $0a


;-----------------------------------------------------------------------------
;  Code
;-----------------------------------------------------------------------------


	SECTION	GP_Code,CODE_F


;----------------------------------------------------------
; GPlayer_Init
; Initializes the Game players
;----------------------------------------------------------
GPlayer_Init:

	movem.l	d0/a0,-(SP)


	; initialize the active players
	
	move.l	#0,ActivePlyrs

	lea	GPlayers,a0

	move.l	ActivePlyrs,d0
	subq	#1,d0
.loop:
	move.w	#0,GPSTRUCT_STATE(a0)
	move.l	#155,GPSTRUCT_X(a0)
	move.l	#230,GPSTRUCT_Y(a0)

	add.l	#GPSTRUCT_SIZE,(a0)
	dbf	d0,.loop
			
	movem.l	(SP)+,d0/a0
	rts



;----------------------------------------------------------
; GPlayer_Update
; Updates the active player, called per frame
;----------------------------------------------------------
GPlayer_Update:


	movem.l	d0-d2/a0,-(SP)
	; Joystrick control

	lea	GPlayers,a0

	; check for bullet firing delay
	cmp.l	#0,GPSTRUCT_BULDLY(a0)
	beq.s	.checkFire
	sub.l	#1,GPSTRUCT_BULDLY(a0)
	bra.s	.noFire

.checkFire:

	btst	#1,$DFF221		; fire 1
	beq.s	.noFire

	; gun fire sound
	
	move.l	#GPFireSND+64,$DFF420	; Set music Addr
	move.l	#(GPFireSNDE-GPFireSND-64)/4,$DFF424	; set musik length
	move.w	#$7F7F,$DFF428		; max Volume
	move.w	#160,$DFF42C		; 22 Khz
	move.w	#3,$DFF42A		; 16bit mono music, one shoot
	move.w	#$8004,$DFF096		; turn Audio DMA on


	; start bullet
	move.l	GPSTRUCT_X(a0),d0
	move.l	GPSTRUCT_Y(a0),d1
	move.l	#GBTYPE_PLAYER,d2
	jsr	GB_AddBullet

	move.l	#GP_BULLETDELAY,GPSTRUCT_BULDLY(a0)
	
.noFire:

	move.w	$dff220,d0

	btst	#15,d0			; Right DPAD
	beq.s	.checkLeft
	
	add.l	#1,GPSTRUCT_X(a0)

.checkLeft:
	btst	#14,d0			; Left DPAD
	beq.s	.noMoreChecks

	sub.l	#1,GPSTRUCT_X(a0)
	
.noMoreChecks:

	movem.l	(SP)+,d0-d2/a0
	rts
	


;----------------------------------------------------------
; GPlayer_Draw
; Draws  the active player, called per frame
;----------------------------------------------------------
GPlayer_Draw:

	movem.l	d0-d2/a0,-(SP)

	lea	GPlayers,a0
	move.l	GPSTRUCT_X(a0),d0
	move.l	GPSTRUCT_Y(a0),d1
	moveq	#2,d2
	jsr	DrawInvSprite		

	movem.l (SP)+,d0-d2/a0
	rts


;-----------------------------------------------------------------------------
;  Data
;-----------------------------------------------------------------------------

	SECTION	GP_Data,DATA_F

ActivePlyrs:	dc.l	0

GPlayers:

		dcb.b	GPSTRUCT_SIZE*GAME_NUMPLAYERS,0 

GPlayersE:

	SECTION GP_Data2,DATA_C


GPFireSND:

	incbin "Sound/fireplayer1.aiff"

GPFireSNDE:



;-----------------------------------------------------------------------------
;  End of file: GAMEPlayer.s
;-----------------------------------------------------------------------------
