;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
;---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		testGame.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------

SCREENWIDTH      = 320                                                                                   ; Screen width
SCREENHEIGHT     = 256                                                                                   ; Screen height

SCREENSIZE       = SCREENWIDTH*SCREENHEIGHT

SCREENCOLORDEPTH = 8                                                                                     ; 256 colours
SCREENMODE       = $0301                                                                                 ; Set to 320x256 mode
KEYDELAY1SEC     = 50


TEST			 = 0

;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

Main:
    jmp    Start

;-----------------------------------------------------------------------------
; Includes
;-----------------------------------------------------------------------------

	include "source/misc/misc_ram.s"		; Random number generation
	include "source/fontControl.s"                                                                   ; Font display
    include "source/spriteControl.s"                                                                 ; sprite display
    include "source/COREGameCtrl.s"                                                                  ; CORE - Game controller
    include "source/GAMEPlayer.s"                                                                    ; GAME - Player control
    include "source/GAMEInvaders.s"                                                                  ; GAME - Invader control
    include "source/GAMEBullets.s"                                                                   ; GAME - Bullet control
    include "source/SceneIntro.s"                                                                    ; GAME - Intro
    include "source/SceneGame.s"                                                                     ; GAME - Game
    include "source/StarfieldEffect.s"                                                               ; Effect - Starfield        
        
    EVEN

;----------------------------------------------------------
; Start
; Starting point, initialise and process the main loop
;----------------------------------------------------------
Start:
    
    movem.l d1-a6,-(a7)


;---TEST----Start----	

	IF		TEST=1
	
	jsr 	Starfield_Init
	move.l	#5,d0
.l:
	jsr		Starfield_Update
	jsr		Starfield_Draw
	dbf		d0,.l


	ENDIF

;---TEST----End------	


    ; System Init

    bsr.w   INIT                                                                                     ; This sets the screen mode and starts audio
    bsr.w   SetPalette                                                                               ; Fixed palette, taken from old image
    bsr.w   FLIPSCREEN                                                                               ; Flip screen 

    jsr     CGC_Init                                                                                 ; Init the Scene Controller
    jsr     SceneIntro_Add                                                                           ; Start the Intro scene

    move.l  #KEYDELAY1SEC,KeyDelay

    ; Main loop

.reloop:

    bsr.b   WaitVBL                                                                                  ; wait for vertical blank

    jsr     CGC_Process                                                                              ; Scene update and draw


    ; Check for ESC, terminates program

    jsr     CGC_ReturnID
    cmpi.l  #SI_ID,d0
    bne.b   .Continue
    
    cmp.l   #0,KeyDelay
    beq.s   .readkey
    sub.l   #1,KeyDelay
    bra.s   .Continue

.readkey:

    bsr.w   READKEY
    cmp.b   #$45,D0
    beq.w   EXIT

.Continue:


    ; Flip screen and reloop

    bsr.w  FLIPSCREEN
    bra.b  .reloop


;----------------------------------------------------------
; WaitVBL
; Waits until the vertical blank to be triggered
;----------------------------------------------------------
WaitVBL:

    btst    #5,$DFF01F                                                                               ; Wait VBL
    beq.b   WaitVBL
    move.w  #$0020,$DFF09C                                                                           ; clr VBL
    rts



;----------------------------------------------------------
; SetPalette
; Sets 64 32bit colours $dff388 ChunkColReg
;----------------------------------------------------------
SetPalette:

    movem.l d0/a0,-(a7)
    
    lea     paletteData,A0
    move.l  (a0)+,d0
    sub.l   #1,d0

.palset:
    
    move.l  (A0)+,$DFF388
    dbra    D0,.palset

    movem.l (a7)+,d0/a0

    rts

;----------------------------------------------------------
; KeyCheckRelease
; Checks for keypress, then awaits its release
; Regs d1 key to check	
;----------------------------------------------------------
KeyCheckRelease:

    bsr     READKEY
    cmp.b   d1,d0
    bne.s   .end

.loop:

    bsr     READKEY
    cmp.b   d1,d0
    beq.s   .loop

    move.b 	d1,d0

.end:
    
    rts

;----------------------------------------------------------
; DrawImage
; copys image data to screen
; Regs:
;	a1 - Points to the image to copy
;----------------------------------------------------------
DrawImage:

    movem.l d0/a0-a1,-(a7)

    move.l  BildPtr,A0
    move.l  #(SCREENSIZE/4)-1,d0
.background:
    move.l  (a1)+,(a0)+
    dbf     d0,.background
            
    movem.l (a7)+,d0/a0-a1
    rts

;----------------------------------------------------------
; ClearScreen
; Clears the screen
;----------------------------------------------------------
 ClearScreen:   
    
    movem.l d0-d1/a0,-(a7)

    move.l  #SCREENSIZE/4,d0
    move.l  #$01010101,d1
    move.l  BildPtr,a0
.loop:
    move.l  d1,(a0)+
    dbf     d0,.loop

    movem.l (a7)+,d0-d1/a0
    rts    

;-----------------------------------------------------------------------------
; Support Code
;-----------------------------------------------------------------------------

    include "source/basicfunctions.s"

;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

    section data,DATA_F

KeyDelay dc.l   0	

StrTest:
        dc.b   "SCORE 00000     ",FCOL,$11,"SPACE",FCOL,$99,"      SCORE 00000",FRET
        dc.b   "LIVES 3",FINV,FINV,FINV,FCOL,$11,"     INVADER",FCOL,$99,"     LIVES 3",FINV,FINV,FINV,0       	

TempBuff:
        dcb.b  255,0
    
    section musi,DATA_F

music:
    incbin "sound/popcorn.aiff"
music_e:

    EVEN
    
paletteData:

    ; details - NUMBER OF ENTRIES
    ;         - INDEX,RED,GREEN,BLUE

    incbin "Graphics/Sprite-Player.png.raw.pal"
    
PaletteDataE:

    EVEN

BackgroundImage:

    incbin "Graphics/Invaders.png.raw"

BackgroundImageE:

;-----------------------------------------------------------------------------
; End of file: testGame.s
;-----------------------------------------------------------------------------
