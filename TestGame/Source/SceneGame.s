;APS00001B7100001B7100001B7100001B7100001B7100001B7100001B7100001B7100001B7100001B71
;--T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		SceneGame.s
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
; The following are the related callbacks for the Game Scene
;
;
;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------


SG_ID    = $ABCD0002

SGINIT   = $00
SGSCROLL = $01
SGINVON  = $02
SGIMESS  = $02
SGIWAIT  = $03

;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

  SECTION    SICode,CODE_F


;----------------------------------------------------------
; SceneGame_Add
; Scene Game activation
;----------------------------------------------------------
SceneGame_Add:

  movem.l    a0,-(a7)

  lea        SceneGameStruct,a0

  move.l     #0,SDINIT(a0)
  move.l     #SGINIT,SDState(a0)
	
  jsr        CGC_AddScene

  movem.l    (a7)+,a0
  rts

;----------------------------------------------------------
; SceneGame_Init
; Scene Init for the Game
; Regs
;	A0 - points to control struct
;----------------------------------------------------------
SceneGame_Init:

  movem.l  d0-a6,-(a7)

  	move.l  #1,SDINIT(a0)
  	move.l  #SGSCROLL,SDState(a0)

	; Game Init

	jsr		Starfield_Init 
  	jsr     GPlayer_Init              ; Init the player
  	jsr     GI_Init                   ; Invaders setup
  	jsr     GB_Init                   ; Bullet control setup

  	movem.l (a7)+,d0-a6

  rts

;----------------------------------------------------------
; SceneGame_Update
; Scene Update for the Game
; Regs
;	A0 - points to control struct
;----------------------------------------------------------
SceneGame_Update:

  movem.l    d0-a6,-(a7)

	;cmp.l	#1,SDINIT(a0)
	;bne.s	.end
	;cmp.l	#SG_ID,SDID(a0)
	;bne.s	.end

  jsr        READKEY                   ; ESC returns to intro
  cmp.b      #$45,D0
  bne.b      .continue


  jsr        SceneIntro_Add
  move.l     #KEYDELAY1SEC,KeyDelay
  jmp        .end
	
.continue:

	; logic update

	jsr		Starfield_Update	
  jsr      GPlayer_Update            ; Control for player
  jsr      GI_Update                 ; Invader control
  jsr      GB_Update                 ; Bullet control


.end:
  movem.l  (a7)+,d0-a6 

  rts

;----------------------------------------------------------
; SceneGame_Draw
; Scene Draw for the Game
; Regs
;	A0 - points to control struct
;----------------------------------------------------------
SceneGame_Draw:

  movem.l    d0-a6,-(a7)
	
	;cmp.l	#1,SDINIT(a0)
	;bne.s	.end
	;cmp.l	#SG_ID,SDID(a0)
	;bne.s	.end

	; background

  ;lea        BackgroundImage,a1        ; Old invaders image
  ;jsr        DrawImage
	jsr		ClearScreen
	jsr		Starfield_Draw		

	; Top score and lives
	
  move.l     #8,d0                     ; X pos
  move.l     #2,d1                     ; Y pos
  lea        StrTest,a0                ; String to display
  jsr        DisplayString


  jsr        GB_Draw                   ; the bullets
  jsr        GI_Draw                   ; the invaders	
	

	; the four bases

  move.l     #54,d0
  move.l     #194,d1
  move.l     #4,d2
  move.l     #3,d7
.bases:
  jsr        DrawInvSprite
  add        #60,d0
  dbf        d7,.bases

	; the player

  jsr        GPlayer_Draw

.end:
			
  movem.l    (a7)+,d0-a6
  rts

;----------------------------------------------------------
; SceneGame_Exit
; Scene Exit for the Game
; Regs
;	A0 - points to control struct
;----------------------------------------------------------
SceneGame_Exit:


  rts


;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

  SECTION    SIData,DATA_F

; Scene Control Struct

  EVEN

SceneGameStruct:

  dc.l       0                         ; Initialized
  dc.l       SG_ID                     ; ID
  dc.l       0                         ; State	
  dc.l       SceneGame_Init            ; Init function
  dc.l       SceneGame_Update          ; Update function
  dc.l       SceneGame_Draw            ; Draw function
  dc.l       SceneGame_Exit            ; Exit function

; 


;-----------------------------------------------------------------------------
; End of file: SceneGame.s
;-----------------------------------------------------------------------------

