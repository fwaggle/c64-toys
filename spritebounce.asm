	.include "include/kernal.asm"
	.include "include/boot.asm"

	; main program
	*=$1000
	
	; clear screen
	lda #$93	; CHR$(147)
	jsr CHROUT
	
	; black out
	lda #$00
	sta $d020
	sta $d021
	
	; lower case mode
	lda #23
	sta $d018
	
	lda #$00 ; all sprites high-res
	sta $d01c
	
	lda #$FF ; sprites all stretched
	sta $d01d
	sta $d017
	
	lda #$80 ; ptr to sprite 1
	sta $07f8
	lda #$81 ; ptr to sprite 2
	sta $07f9
	lda #$82 ; ptr to sprite 3
	sta $07fa
	
	lda #$01 ; colors
	sta $d027
	sta $d028
	sta $d029
	
	lda #$07 ; enable sprite 1 + 2 + 3
	sta $d015
	
	lda #$80 ; sprite 1 position
	sta $d000

	lda #$50 ; all sprite y position
	sta $d001
	sta $d003
	sta $d005
	
	lda #$b0 ; sprite 2 x
	sta $d002
	
	lda #$e0
	sta $d004

	; start with scroll register filled
	ldx #$7
	stx $d016
	
	; make all text light grey
	ldx #$00
	lda #$0F
colloop	sta $D9E0, x
	inx
	cpx #39
	bne colloop
	
	; now fade it at the edges
	lda #$0C
	sta $D9E1
	sta $DA05

	lda #$0B
	sta $D9E0
	sta $DA06
	
outer	ldy #$00

	jsr SOFTSCROLL

inner
	ldx #00
shift	; shift everything left
	lda $05E1, x
	sta $05E0, x
	inx
	cpx #$38
	bne shift
	
	ldx #39
	; load newest character
	lda textdata, y
	beq outer ; if we get to null, start outer loop again
	
	; do we need to shift it?
	; this is an abomination by the way, hacked out with trial
	; and error "voodoo" programming.
	cmp #$80
	bcc lowercase
	sbc #$80
	jmp uppercase
lowercase
	and #$3f
uppercase

	; store the new character on the screen
	sta $05E0, x
	iny ; increment pointer in string
	
	jsr SOFTSCROLL
	jmp inner

; soft scroll routine
; start with VIC scroll register at 7, decrement approximately
; every 15 frames, then reset it before returning.

; this one has sprite bounce in the delay too!
SOFTSCROLL
	ldx #$7
scrlloop	
	stx $d016
pause	lda $d012 ; wait for screen frame
	bne pause
	
	; check direction
	lda direction
	bne up
	
	; down
	lda $d001
	cmp #$60
	bcc moredown
	lda #$01
	sta direction
	
	jmp bncdone
	
moredown	inc $d001
	inc $d003
	inc $d005
	
	jmp bncdone
	
up	lda $d001
	cmp #$50
	bcs moreup
	lda #$00
	sta direction
	
	jmp bncdone
	
moreup	dec $d001
	dec $d003
	dec $d005

bncdone	lda #$09
	sta delay

bncdelay	lda $d012 ; wait for screen frame
	bne bncdelay
	dec delay
	bne bncdelay
	
	dex
	bne scrlloop
	
	ldx #$7
	stx $d016
	
	rts
	
textdata	
	.text "Welp, here we are with the scroller plus the sprite "
	.text "bounce. No music yet, but that's the fun part amirite? "
	.text "Sprites were drawn in using SpritePad (7up Sprite kept "
	.text "crashing). The bounce took about an hour to get right, "
	.text "mostly through voodoo programming. "
	.repeat 38," " ; 38 blank spaces to clear screen at end
	.byte $00 ; null byte to terminate string
	
delay	.byte $09
direction	.byte $00
	
	*=$2000
	.byte $00,$00,$00,$1c,$00,$00,$3c,$00,$00,$36,$00,$00,$22,$00,$00,$20
	.byte $00,$00,$30,$00,$30,$30,$06,$7c,$78,$26,$06,$73,$36,$37,$3b,$f6
	.byte $7f,$19,$fc,$e6,$19,$dc,$e6,$1c,$cc,$7e,$0c,$84,$7f,$0c,$00,$01
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

	.byte $00,$00,$00,$00,$01,$c0,$00,$01,$c0,$00,$00,$c0,$00,$00,$c0,$00
	.byte $00,$c0,$70,$e0,$c0,$f9,$f0,$ce,$dd,$b8,$df,$cf,$98,$fb,$cf,$98
	.byte $f3,$cd,$98,$7e,$ff,$fc,$78,$7e,$fc,$79,$86,$0c,$6f,$1f,$bf,$64
	.byte $19,$b3,$00,$18,$b1,$00,$19,$b3,$00,$0f,$1e,$00,$00,$00,$00,$00

	.byte $00,$00,$00,$02,$00,$00,$03,$80,$00,$07,$80,$00,$07,$00,$00,$07
	.byte $00,$00,$07,$00,$00,$0e,$00,$00,$0e,$00,$00,$0c,$00,$00,$8c,$00
	.byte $00,$0c,$00,$00,$18,$00,$00,$98,$00,$00,$90,$00,$00,$00,$00,$00
	.byte $30,$00,$00,$30,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
