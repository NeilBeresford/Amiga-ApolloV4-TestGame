;APS000033AA000033AA000033AA000033AA000033AA000033AA000033AA000033AA000033AA000033AA
;---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T---T
;-----------------------------------------------------------------------------
;	Project		Apollo V4 development - testGame
;	File		fontControl.s
;	Coder		Neil Beresford
;	Build envrn	ASM1.48,ASMPro1.20b
;-----------------------------------------------------------------------------

         SECTION    fontCode,CODE_F

;-----------------------------------------------------------------------------
; Defines
;-----------------------------------------------------------------------------

FCOL = $01
FPOS = $02
FINV = $0b
FRET = $0a


;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------

;----------------------------------------------------------
; DisplayString
; Displays the number on the screen
; Regs:
;	d0	- X position
;	d1	- Y position
;	a0	- zero terminated byte string 
;----------------------------------------------------------
DisplayString:

         movem.l    d0-a6,-(a7)
         move.l     d0,d3
         clr.l      d2
         move.b     #$99,fontCol 
.print:
         move.b     (a0)+,d2
         beq        .endPrint

	; check for carrage return

         cmp.b      #FRET,d2
         bne.s      .checkMisc
         move.l     d3,d0
         add        #8,d1
         bra        .print
	
.checkMisc:

	; check for colour change
	
         cmp.b      #FCOL,d2
         bne        .checkPos
         move.b     (a0)+,d2
         move.b     d2,fontCol
         jmp        .print
.checkPos:

	; check for new screen position

         cmp.b      #FPOS,d2
         bne.s      .checkRest
         clr.l      d2
         move.b     (a0)+,d2              ; X
         lsl.w      #3,d2
         move.l     d2,d0
         clr.l      d2                    ; Y
         move.b     (a0)+,d2
         lsl.w      #3,d2
         move.l     d2,d1
         bra        .print

	
.checkRest:

	; check what is being printed

         cmp.b      #'.',d2
         bne.s      .checkMisc2
         moveq      #0,d2
         bra.s      .printMisc
.checkMisc2:
         cmp.b      #',',d2
         bne.s      .checkMisc3
         moveq      #1,d2
         bra.s      .printMisc
.checkMisc3:
         cmp.b      #'!',d2
         bne.s      .checkMisc4
         moveq      #2,d2
         bra.s      .printMisc
.checkMisc4:
         cmp.b      #'?',d2
         bne.s      .checkMisc5
         moveq      #3,d2
         jmp        .printMisc
.checkMisc5:
         cmp.b      #FINV,d2
         bne        .checkrest
         moveq      #5,d2	
.printMisc:
         bsr        DisplayMisc
         jmp        .nextChar
.checkrest:

	; check space, letters and numbers
	
         cmp.b      #' ',d2               ; SPACE
         beq        .nextChar
         cmp.b      #'9',d2               ; Check for letter
         bgt        .printLetter
.printNumber:
         sub.b      #'0',d2               ; print number
         bsr        DisplayNumber
         jmp        .nextChar
.printLetter:
         sub.b      #'A',d2               ; print letter
         bsr        DisplayLetter
.nextChar:
         add.w      #8,d0
         jmp        .print 

.endPrint:

         movem.l    (a7)+,d0-a6
         rts


;----------------------------------------------------------
; DisplayNumber
; Displays the number on the screen
; Regs:
;	d0	- X position
;	d1	- Y position
;	d2	- Number 0 = '0' to 9 = '9' 
;----------------------------------------------------------
DisplayNumber:

         movem.l    d0-a6,-(a7)

         move.l     BildPtr,a0
         lea        fontNumbers,a1

PrintChar:

         mulu       #9,d2
         add.l      d2,a1
         mulu       #SCREENWIDTH,d1
         add.l      d0,d1	
         add.l      d1,a0		

         moveq      #9-1,d2
.charY:
         moveq      #8-1,d1
         move.b     (a1)+,d6
.charX:
         btst       d1,d6
         beq.b      .charCont
         move.b     fontCol,(a0)
.charCont:
         addq       #1,a0				
         dbf        d1,.charX
         add        #SCREENWIDTH-8,a0
         dbf        d2,.charY

         movem.l    (a7)+,d0-a6
         rts

;----------------------------------------------------------
; DisplayLetter
; Displays the letter on the screen
; Please note, this jumps to PrintChar, shared code
; Regs:
;	d0	- X position
;	d1	- Y position
;	d2	- Letter 0 = 'A' to 25 = 'Z' 
;----------------------------------------------------------
DisplayLetter:

         movem.l    d0-a6,-(a7)

         move.l     BildPtr,a0
         lea        fontLetters,a1
         bra.b      PrintChar

;----------------------------------------------------------
; DisplayMisc
; Displays the misc character on the screen
; Please note, this jumps to PrintChar, shared code
; Regs:
;	d0	- X position
;	d1	- Y position
;	d2	- Index for the misc char in fontMisc 
;----------------------------------------------------------
DisplayMisc:

         movem.l    d0-a6,-(a7)

         move.l     BildPtr,a0
         lea        fontMisc,a1
         bra.b      PrintChar


;----------------------------------------------------------
; DisplayHex
;  Convert long to 8 char HEX string, using fontStrbuffer
;	d0	- X position
;	d1	- Y position
;	d2	- hex value to display 
 
;----------------------------------------------------------
DisplayHex:

         movem.l    d0-d4/a0-a1,-(a7)


         move.b     #0,fontStrBuffer+8
         lea        fontStrBuffer,a0
         lea        fontHex,a1
         moveq      #8-1,d3
         clr.l      d4

.loop:	
         move.b     d2,d4
         and.b      #$0f,d4
         move.b     (a1,d4),(a0,d3)	
         lsr.l      #4,d2
         dbf        d3,.loop

         bsr        DisplayString
	

         movem.l    (a7)+,d0-d4/a0-a1
         rts


;-----------------------------------------------------------------------------
; Data
;-----------------------------------------------------------------------------

         SECTION    fontData,DATA_F

fontCol  dc.b       $99                   ; Store for the font colour
         dc.b       0,0,0	
fontHex  dc.b       "0123456789ABCDEF"


fontStrBuffer:

         dcb.b      256                   ; large buffer	

fontNumbers:

         dc.b       %00000000             ; 0
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %01001100
         dc.b       %01010100
         dc.b       %01100100
         dc.b       %01000100
         dc.b       %00111000
         dc.b       %00000000
         dc.b       %00000000             ; 1
         dc.b       %00010000
         dc.b       %00110000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %01111100
         dc.b       %00000000
         dc.b       %00000000             ; 2
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %00000100
         dc.b       %00111000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01111100
         dc.b       %00000000
         dc.b       %00000000             ; 3
         dc.b       %01111000
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %00111000
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %01111000
         dc.b       %00000000
         dc.b       %00000000             ; 4
         dc.b       %00001100
         dc.b       %00010100
         dc.b       %00100100
         dc.b       %01111110
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %00000000
         dc.b       %00000000             ; 5
         dc.b       %01111100
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01111000
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %01111000
         dc.b       %00000000
         dc.b       %00000000             ; 6
         dc.b       %00111000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00111000
         dc.b       %00000000
         dc.b       %00000000             ; 7
         dc.b       %01111100
         dc.b       %00000100
         dc.b       %00001000
         dc.b       %00010000
         dc.b       %00100000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %00000000
         dc.b       %00000000             ; 8
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00111000
         dc.b       %00000000
         dc.b       %00000000             ; 9
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00111100
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %00001000
         dc.b       %00000000
fontLetters:
         dc.b       %00000000             ; A
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01111100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00000000
         dc.b       %00000000             ; B
         dc.b       %01111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01111000
         dc.b       %00000000
         dc.b       %00000000             ; C
         dc.b       %00111100
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %00111100
         dc.b       %00000000
         dc.b       %00000000             ; D
         dc.b       %01111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01111000
         dc.b       %00000000
         dc.b       %00000000             ; E
         dc.b       %00111100
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01111000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %00111100
         dc.b       %00000000
         dc.b       %00000000             ; F
         dc.b       %00111100
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01111000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %00000000
         dc.b       %00000000             ; G
         dc.b       %00111100
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01001100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00111100
         dc.b       %00000000
         dc.b       %00000000             ; H
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01111100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00000000
         dc.b       %00000000             ; I
         dc.b       %01111100
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %01111100
         dc.b       %00000000
         dc.b       %00000000             ; J
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %01111000
         dc.b       %00000000
         dc.b       %00000000             ; K
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01001000
         dc.b       %01110000
         dc.b       %01001000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00000000
         dc.b       %00000000             ; L
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %00111100
         dc.b       %00000000
         dc.b       %00000000             ; M
         dc.b       %01000100
         dc.b       %01101100
         dc.b       %01010100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00000000
         dc.b       %00000000             ; N
         dc.b       %01000100
         dc.b       %01100100
         dc.b       %01010100
         dc.b       %01001100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00000000
         dc.b       %00000000             ; O
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00111000
         dc.b       %00000000
         dc.b       %00000000             ; P
         dc.b       %01111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01111000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %00000000
         dc.b       %00000000             ; Q
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01010100
         dc.b       %01001100
         dc.b       %00111100
         dc.b       %00000010
         dc.b       %00000000             ; R
         dc.b       %01111000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01111000
         dc.b       %01010000
         dc.b       %01001000
         dc.b       %01000100
         dc.b       %00000000
         dc.b       %00000000             ; S
         dc.b       %00111100
         dc.b       %01000000
         dc.b       %01000000
         dc.b       %00111000
         dc.b       %00000100
         dc.b       %00000100
         dc.b       %01111000
         dc.b       %00000000
         dc.b       %00000000             ; T
         dc.b       %01111100
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00000000             ; U
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00111000
         dc.b       %00000000
         dc.b       %00000000             ; V
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00101000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00000000             ; W
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %01010100
         dc.b       %01101100
         dc.b       %01000100
         dc.b       %00000000
         dc.b       %00000000             ; X
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00101000
         dc.b       %00010000
         dc.b       %00101000
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00000000
         dc.b       %00000000             ; Y
         dc.b       %01000100
         dc.b       %01000100
         dc.b       %00101000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00000000             ; Z
         dc.b       %01111100
         dc.b       %00000100
         dc.b       %00001000
         dc.b       %00010000
         dc.b       %00100000
         dc.b       %01000000
         dc.b       %01111100
         dc.b       %00000000
fontMisc:
         dc.b       %00000000             ; full stop
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00000000             ; comma
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00010000
         dc.b       %00100000
         dc.b       %00000000             ; !
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00000000             ; ?
         dc.b       %00111000
         dc.b       %01000100
         dc.b       %00001000
         dc.b       %00010000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00000000             ; colong
         dc.b       %00000000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00010000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000
         dc.b       %00000000             ; 0x0b invader
         dc.b       %00010000
         dc.b       %01111100
         dc.b       %11111110
         dc.b       %10010010
         dc.b       %11111110
         dc.b       %00101000
         dc.b       %01010100
         dc.b       %10000010




         dc.b       %00000000




;-----------------------------------------------------------------------------
; End of file: fontControl.s
;-----------------------------------------------------------------------------
