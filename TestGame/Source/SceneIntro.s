;APS000027D4000027D4000027D4000027D4000027D4000027D4000027D4000027D4000027D4000027D4
;---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		SceneIntro.s
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
; The following are the related callbacks for the Intro Scene
;
;
;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------


SI_ID    = $ABCD0001

SIINIT   = $00
SISCROLL = $01
SIINVON  = $02
SIMESS   = $02
SIWAIT   = $03

;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

          SECTION    SICode,CODE_F


;----------------------------------------------------------
; SceneIntro_Add
; Scene Intro activation
;----------------------------------------------------------
SceneIntro_Add:

    movem.l    a0,-(a7)

    lea        SceneIntroStruct,a0

    move.l     #0,SDINIT(a0)
    move.l     #SIINIT,SDState(a0)
	jsr        CGC_AddScene

    movem.l    (a7)+,a0
    rts

;----------------------------------------------------------
; SceneIntro_Init
; Scene Init for the Intro
; Regs
;	A0 - points to control struct
;----------------------------------------------------------
SceneIntro_Init:

    move.l  #1,SDINIT(a0)
    move.l  #SISCROLL,SDState(a0)

    movem.l d0-d2/a0,-(a7)
    jsr     Starfield_Init
    movem.l (a7)+,d0-d2/a0

    rts

;----------------------------------------------------------
; SceneIntro_Update
; Scene Update for the Intro
; Regs
;	A0 - points to control struct
;----------------------------------------------------------
SceneIntro_Update:

    movem.l d0-d2,-(a7)

    jsr     Starfield_Update

	; check for fire button press
    btst    #1,$DFF221                                        ; fire 1
    beq.w   .end

	; change scene...
    jsr     SceneGame_Add
	
.end:

    movem.l (a7)+,d0-d2 

    rts

;----------------------------------------------------------
; SceneIntro_Draw
; Scene Draw for the Intro
; Regs
;	A0 - points to control struct
;----------------------------------------------------------
SceneIntro_Draw:

    movem.l d0-d7/a0,-(a7)

	; Background
    jsr    ClearScreen
    jsr    Starfield_Draw

	; Text on screen
    clr.l   d0
    clr.l   d1
    lea     SI_Title,a0
    jsr     DisplayString
			
    movem.l (a7)+,d0-d7/a0
    rts

;----------------------------------------------------------
; SceneIntro_Exit
; Scene Exit for the Intro
; Regs
;	A0 - points to control struct
;----------------------------------------------------------
SceneIntro_Exit:


    rts


;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

    SECTION    SIData,DATA_F

; Scene Control Struct

SceneIntroStruct:

    dc.l    0                                                 ; Initialized
    dc.l    SI_ID                                             ; ID
    dc.l    0                                                 ; State	
    dc.l    SceneIntro_Init                                   ; Init function
    dc.l    SceneIntro_Update                                 ; Update function
    dc.l    SceneIntro_Draw                                   ; Draw function
    dc.l    SceneIntro_Exit                                   ; Exit function

; Text for the intro ...

SI_Title:
    dc.b    FPOS,3,2, FCOL,55,FINV," SPACE INVADERS ",FINV
    dc.b    FPOS,3,4, FCOL,56,"BY NEIL BERESFORD"
    dc.b    FPOS,6,12,FCOL, 5,"START GAME  PRESS FIRE"
    dc.b    FPOS,6,14,FCOL, 5,"QUIT GAME   PRESS ESC"
    dc.b    FPOS,3,30,FCOL,55,"PLEASE NOTE, JOYSTICK ONLY"
    dc.b    0
			 


    EVEN

;-----------------------------------------------------------------------------
; End of file: SceneIntro.s
;-----------------------------------------------------------------------------
