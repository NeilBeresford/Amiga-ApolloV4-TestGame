;APS000000A8000000A8000000A8000000A8000000A8000000A8000000A8000000A8000000A8000000A8

OPENLIBRARY        EQU -$228
CLOSELIBRARY       EQU -414
OPENSCREENTAGLIST  EQU -$264
BESTCMODEIDTAGLIST EQU -60

AUDIO_VOL          EQU $0040


*****************************************
INIT:
	
                 move.b     $DFF004,D0                                                ; OCS or ECS?
                 and.b      #$0F,D0                                                   ;
                 move.b     D0,ECS                                                    ;


                 move.b     $DFF3FC,D0                                                ; Vampire version
                 beq.w      FAIL                                                      ; no vampire?

                 move.w     #$FFFF,SCREENMASK                                         ; V4 oe V2
                 move.b     #4,V4
                 cmp.b      #1,D0
                 beq.s      V2
                 cmp.b      #2,D0
                 beq.s      V2
                 cmp.b      #6,D0
                 bne.s      ENDDETECTION
V2
                 move.w     #$00FF,SCREENMASK
                 clr.b      V4
ENDDETECTION



                 move.l     $4.w,A6                                                   ; execbase
                 lea        intuitionname,A1
                 moveq      #39,D0                                                    ; Min OS 3
                 jsr        OPENLIBRARY(A6)                                           ; open library
                 tst.l      D0
                 beq.w      FAIL
                 move.l     D0,intuitionbase

                 lea        cybergfxname,A1
                 moveq      #39,D0                                                    ; Min OS 3
                 jsr        OPENLIBRARY(A6)                                           ; open library
                 tst.l      D0
                 beq.w      FAIL
                 move.l     D0,cybergfxbase

                 move.l     cybergfxbase,A6
                 lea        modetags,A0
                 jsr        BESTCMODEIDTAGLIST(A6)
                 tst.l      D0
                 beq.w      FAIL
                 move.l     D0,screenmodeid

                 move.l     intuitionbase,A6
                 suba.l     A0,A0
                 lea        screentags,A1
                 jsr        OPENSCREENTAGLIST(A6)                                     ; Openscreentaglist
                 tst.l      D0
                 beq.w      FAIL
                 move.l     D0,screen


                 move.w     $DFF002,DMACON                                            ; SAVE DMACON
                 move.w     #$7FFF,$DFF096                                            ; ALL DMA OFF

                 move.w     $DFF01C,INTENA                                            ; SAVE INTENA
                 move.w     #$7FFF,$DFF09A                                            ; ALL INTENA OFF



                 move.l     #screens,D0                                               ; we use several Double Buffer
                 add.l      #31,D0                                                    ; this demo does not need this
                 and.l      #$FFFFFFE0,D0                                             ; with this trick we display over 100 FPS without flicker
                 move.l     D0,BildPtr
                 add.l      #SCREENSIZE,D0
                 move.l     D0,BildPtr2
                 add.l      #SCREENSIZE,D0
                 move.l     D0,BildPtr3



                 clr.w      $DFF1E6                                                   ; clear modulo
                 move.l     BildPtr,$DFF1EC                                           ; Set GFXPTR
                 move.w     #SCREENMODE,D0
                 and.w      SCREENMASK,D0	
                 move.w     D0,$DFF1F4                                                ; Set GFX to assigned mode


                 clr.l      $DFF1D0                                                   ; Clear MousePtr


                 moveC      VBR,A0
                 move.l     $70(A0),OldAudioHandler                                   ; Set Level 4 (audio) Vector.
						*	

******************************************
* Play Title Music
*
* On V4 we can use ARNE 32bit Audio DMA to play the Music YAY SUPERCOOLARNECHIP
* V4 will play stereo music on chan 0
*
* On V2 we only have Paula and need to copy chunks to chipmem to allow her to play it
* V2 will use channel 0 and 1 to play music
*
                 tst.b      V4
                 beq.s      .V2
.V4
                 move.l     #music+64,$DFF400                                         ; Set music Addr
                 move.l     #(music_e-music-64)/8,$DFF404                             ; set musik length
                 move.w     #$3F3F,$DFF408                                            ; max Volume
                 move.w     #80,$DFF40C                                               ; 22 Khz
                 move.w     #4,$DFF40A                                                ; 16bit stereo music
                 move.w     #$8201,$DFF096                                            ; turn Audio DMA on
                 bra.b      .endmusic
.V2
	
	; Transfer initial audio data into buffers
                 move.l     #music+64,AudioStart                                      ; StartPointer
                 move.l     AudioStart,AudioWorkPtr                                   ; StartPointer
                 move.l     #music_e,AudioEnd                                         ; End
                 move.w     #$8203,$DFF096		* Audio an
                 bsr.w      InitV2Audio

.endmusic

                 rts
*****************************************



******************************
EXIT:            *
                 move.w     #$7FFF,$DFF096			* Goto back to DOS
                 move.w     DMACON,D0			*
                 or.w       #$8000,D0			*
                 move.w     D0,$DFF096			*
						*

                 move.w     #$7FFF,$DFF09A                                            ; ALL INTENA OFF
                 move.w     INTENA,D0			*
                 or.w       #$8000,D0			*
                 move.w     D0,$DFF09A			*

                 moveC      VBR,A0
                 move.l     OldAudioHandler,$70(A0)		* Set Level 4 (audio) Vector.


                 move.l     intuitionbase,A6
                 move.l     screen,A0
                 jsr        -$42(A6)                                                  ; Close Screen


                 move.l     $4.w,A6
                 move.l     cybergfxbase,A1
                 jsr        CLOSELIBRARY(A6)

                 move.l     intuitionbase,A1
                 jsr        CLOSELIBRARY(A6)

                 movem.l    (a7)+,D1-A6	

                 clr.l      D0                                                        ; return with no error
                 rts

*******************************
FAIL:	
                 movem.l    (a7)+,D1-A6	
                 moveq      #-1,D0
                 rts

*******************************
READKEY:
                 movem.l    d1-a6,-(a7)
                 move.b     $BFEC01,D0
                 bset       #6,$BFEE01
                 ror.b      #1,D0
                 not.b      D0
                 moveq      #50,D1
.wait
                 tst.b      $BFE001
                 dbra       D1,.wait
                 bclr       #6,$BFEE01
                 movem.l    (a7)+,D1-A6	
                 rts
*******************************
FLIPSCREEN:
                 move.l     a0,-(a7)
                 move.l     BildPtr,A0
                 move.l     A0,$DFF1EC
                 move.l     BildPtr2,BildPtr
                 move.l     BildPtr3,BildPtr2
                 move.l     A0,BildPtr3
                 move.l     (a7)+,a0
                 rts
*******************************
*************************************************
InitV2Audio:
                 move.l     AudioStart,A0
                 lea        leftBuffer1,a1
                 lea        rightBuffer1,a2



                 move.l     A0,AudioWorkPtr                                           ; save Ptr

	; Setup Audio Channel IRQ
                 moveC      VBR,A0
                 move.l     #AudioHandler,$70(A0)                                     ; Set Level 4 (audio) Vector.

	; Set Sampling Rate and Period
	; PAL Clock Constant = 3546895
	; Period = Clock Constant / Hz (22050hz -> 160.857)
                 tst.b      ECS
                 beq        .ocs
                 move.w     #80,$DFF0A6
                 move.w     #80,$DFF0B6

                 move.w     #221-1,d0                                                 ; Number of samples to copy.
.copy
                 move.w     (A0)+,D1                                                  ; Load 16bit sample (L)
                 move.w     (A0)+,D2                                                  ; Load 16bit sample (R)
                 move.b     (A0),D1
                 move.b     2(A0),D2
                 addq.l     #4,A0
                 move.w     D1,(A1)+
                 move.w     D2,(A2)+    
                 dbra       D0,.copy
                 bra        .bitrate
.ocs	
                 move.w     #160,$DFF0A6
                 move.w     #160,$DFF0B6

                 move.w     #221-1,d0                                                 ; Number of samples to copy.
.copy2
                 move.w     (A0)+,D1                                                  ; Load 16bit sample (L)
                 move.w     (A0)+,D2                                                  ; Load 16bit sample (R)
                 addq.l     #4,A0
                 move.b     (A0),D1
                 move.b     2(A0),D2
                 addq.l     #8,A0

                 move.w     D1,(A1)+
                 move.w     D2,(A2)+    
                 dbra       D0,.copy2
.bitrate

	; Set Audio Data Buffer Lengths
                 move.w     #(442/2),$DFF0A4                                          ; Set Audio Length for Channel 0.
                 move.w     #(442/2),$DFF0B4                                          ; Set Audio Length for Channel 1.

	; Set Audio Buffer Locations
                 move.l     #leftBuffer1,$DFF0A0
                 move.l     #rightBuffer1,$DFF0B0

	; Enable Audio IRQ 
	; -> As both channels are in lock-step, we only need a single IRQ.
                 move.w     #$c080,$dff09a

	; Set Volume and Start DMA
                 move.w     #AUDIO_VOL,$DFF0A8                                        ; Set Volume for Channel 0.
                 move.w     #AUDIO_VOL,$DFF0B8                                        ; Set Volume for Channel 1.
                 move.w     #$8203,$DFF096                                            ; Enable Audio Channel DMA 0+1
                 clr.b      Audioticktock

                 rts
*****************************************
AudioHandler:
                 movem.l    d0-d2/a0-a2,-(a7)

                 move.w     #$0080,$DFF09C                                            ; Clear INTREQ for Audio 0.

                 tst.b      Audioticktock
                 beq.s      .pong
.ping
                 lea        leftBuffer1,a1
                 lea        rightBuffer1,a2
                 bra.s      .process
.pong
                 lea        leftBuffer2,a1
                 lea        rightBuffer2,a2

    ; We process both left and right channels from
    ; a single IRQ, as both are running at the same rate in lock-step
.process
                 not.b      Audioticktock
                 move.l     A1,$DFF0A0                                                ; Set New Buffer Address.
                 move.l     A2,$DFF0B0                                                ; Set New Buffer Address.

                 tst.b      ECS
                 beq        .ocs
.ecs
                 move.l     AudioWorkPtr,a0
                 move.w     #442/2-1,D0                                               ; Number of samples to copy.
.copyE
                 move.w     (A0)+,D1                                                  ; Load 16bit sample (L)
                 move.w     (A0)+,D2                                                  ; Load 16bit sample (R)
                 move.b     (A0),D1
                 move.w     D1,(A1)+
                 move.b     2(A0),D2
                 addq.l     #4,A0
                 move.w     D2,(A2)+
                 dbra       D0,.copyE
                 bra        .bitrate

.ocs
                 move.l     AudioWorkPtr,a0
                 move.w     #442/2-1,D0                                               ; Number of samples to copy.
.copyO
                 move.w     (A0)+,D1                                                  ; Load 16bit sample (L)
                 move.w     (A0)+,D2                                                  ; Load 16bit sample (R)
                 addq.l     #4,A0
                 move.b     (A0),D1
                 move.w     D1,(A1)+
                 move.b     2(A0),D2
                 addq.l     #8,A0
                 move.w     D2,(A2)+
                 dbra       D0,.copyO
.bitrate

                 move.l     AudioEnd,a1
                 cmp.l      a1,a0
                 blt.s      .noloop
                 move.l     AudioStart,A0
.noloop
                 move.l     A0,AudioWorkPtr
.done

                 movem.l    (a7)+,D0-D2/A0-A2
                 rte

*****************************

*****************************

                 SECTION    DATA,DATA_F
DMACON           dc.w       $0000
INTENA           dc.w       $0000

BildPtr          dc.l       0
BildPtr2         dc.l       0
BildPtr3         dc.l       0

ECS              dc.w       0
SCREENMASK       dc.w       0

OldAudioHandler  dc.l       0				
AudioStart       dc.l       0
AudioWorkPtr     dc.l       0
AudioEnd         dc.l       0
Audioticktock    dc.b       0

                 even


* Tags for ask OS for a screen
modetags         dc.l       $80050001,SCREENWIDTH
                 dc.l       $80050002,SCREENHEIGHT
                 dc.l       $80050000,SCREENCOLORDEPTH
                 dc.l       0,0

screentags       dc.l       $80000032
screenmodeid     dc.l       0                                                         ;ID=?
                 dc.l       0,0

intuitionbase    dc.l       0
intuitionname    dc.b       "intuition.library",0
                 even
cybergfxbase     dc.l       0
cybergfxname     dc.b       "cybergraphics.library",0
                 even

screen           dc.l       0

V4               dc.l       0



                 section    screens,BSS
screens          ds.b       SCREENSIZE*3+64


                 section    AppBSS,BSS_C
leftBuffer1      ds.w       221                                                       ; We use 2 buffers for each left/right 
leftBuffer2      ds.w       221                                                       ; so that we can ping-pong between them when reloading
rightBuffer1     ds.w       221                                                       ; during the IRQ.
rightBuffer2     ds.w       221



