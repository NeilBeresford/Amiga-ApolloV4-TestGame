;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
;---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		COREGameCtrl.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;  Description
;-----------------------------------------------------------------------------

; CoreGameCtrl manages the current scene, for want of a better word.
; This has four function pointers which are;
;
;      0 - Init		Initializes the scene
;      1 - Update	Any logic update is here
;      2 - Draw		All display functionality
;      3 - Exit		Called at scene-change
;
;

;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------


; Scene States

SS_READY        = $00
SS_STARTING     = $01
SS_RUNNING      = $02
SS_EXITING      = $03

; Scene Data structure

SDINIT          = $00
SDID            = $04
SDState         = $08
SDInit          = $0c
SDUpdate        = $10
SDDraw          = $14
SDExit          = $18

; CGCCtrl structure

CGC_Initialized = $00
CGC_ActScID     = $04
CGC_ActScState  = $08
CGC_ActInit     = $0C
CGC_ActUpdate   = $10
CGC_ActDraw     = $14
CGC_ActExit     = $18
CGC_Size        = $1C

;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

	SECTION CGC_Code,CODE_F
;----------------------------------------------------------
; CGC_Init
; Initializes the Core Game Ctrl
;----------------------------------------------------------
CGC_Init:

	movem.l a0,-(a7)

	lea		CGCStruct,a0
	move.l	#1,CGC_Initialized(a0)
	move.l	#0,CGC_ActScID(a0)
	move.l	#CGC_DummyInit,CGC_ActInit(a0)	
	move.l	#CGC_DummyExit,CGC_ActExit(a0)	
	move.l	#CGC_DummyUpdate,CGC_ActUpdate(a0)	
	move.l	#CGC_DummyDraw,CGC_ActDraw(a0)	
	movem.l (a7)+,a0
	rts

;----------------------------------------------------------
; CGC_Exit
; Tidy up for the Core Game Ctrl
;----------------------------------------------------------
CGC_Exit:

	rts

;----------------------------------------------------------
; CGC_ReturnID
; Returns the active scene ID in d0
; Regs
; Return d0 active scene ID (d0 trashed) 
;----------------------------------------------------------
CGC_ReturnID:

	move.l 	a0,-(a7)

	lea    	CGCStruct,a0
	move.l	SDID(a0),d0

	move.l	(a7)+,a0
	rts

;----------------------------------------------------------
; CGC_AddScene
; Calls Exit for current scene and then adds the new scene.
; REGS:	a0	- CGCSTRUCT for scene
;----------------------------------------------------------
CGC_AddScene:

	movem.l	d0/a0-a2,-(a7)

	; call the exit for the current scene
	lea    	CGCStruct,a1
	move.l 	CGC_ActExit(a1),a2
	jsr    	(a2)
	move.l 	a0,a2
	move.l 	#(CGC_Size/4)-1,d0

.loop:
		
	move.l 	(a0)+,(a1)+
	dbf    	d0,.loop

	; call Init for the new scene
	move.l 	CGC_ActInit(a2),a1
	move.l 	a2,a0
	jsr    	(a1)

	movem.l (a7)+,d0/a0-a2
	rts

;----------------------------------------------------------
; CGC_Process
; Process the current active scene
;----------------------------------------------------------
CGC_Process:

	movem.l a0-a1,-(a7)

	lea    	CGCStruct,a0

	; Draw the current scene
 	move.l 	CGC_ActDraw(a0),a1
 	jsr    	(a1)

	; update the current scene
 	move.l 	CGC_ActUpdate(a0),a1
 	jsr    	(a1)

	movem.l (a7)+,a0-a1
	rts

;----------------------------------------------------------
; CGC_DummyInit
; Dummy scene Init
;----------------------------------------------------------
CGC_DummyInit:

 	move.l 	#SS_READY,SDState(a0)
 	move.l 	#1,SDINIT(a0)
 	rts


;----------------------------------------------------------
; CGC_DummyUpdate
; Dummy scene Update
;----------------------------------------------------------
CGC_DummyUpdate:

	rts

;----------------------------------------------------------
; CGC_DummyDraw
; Dummy scene Draw
;----------------------------------------------------------
CGC_DummyDraw:

	rts

;----------------------------------------------------------
; CGC_DummyExit
; Dummy scene exit
;----------------------------------------------------------
CGC_DummyExit:

	rts

;----------------------------------------------------------
; CGC_RandonWord
; Random word generated, using horizontal raster and event
; counter.
;Regs return d0 word random number
;            d7 trashed
;----------------------------------------------------------
CGC_RandonWord

	bsr.s  	.rndB
	rol.w  	#8,d0

.rndB:

	move.b 	$dff007,d0                        ;Hpos
	move.b 	$bfd800,d7                        ;event counter
	eor.b  	d7,d0

	rts

;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

	SECTION CGC_Data,DATA_F

; Core Game Ctrl - Data Structure

CGCStruct:

	dc.b   0                                 ; Initialized
	dc.b   0                                 ; _PAD
	dc.b   0                                 ; _PAD
	dc.b   0                                 ; _PAD

ActiveScene:

	dc.l   0                                 ; ID
	dc.l   0                                 ; State
	dc.l   0                                 ; Init function ptr
	dc.l   0                                 ; Update function ptr
	dc.l   0                                 ; Draw function ptr
	dc.l   0                                 ; Exit function ptr

CGCStructE:

	

;-----------------------------------------------------------------------------
; End of file: COREGameCtrl.s
;-----------------------------------------------------------------------------
