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
SOFTSCROLL
	ldx #$7
scrlloop	
	stx $d016
	lda #$10 ; delay for ~0x10 frames
	sta delay
pause	lda $d012 ; wait for screen frame
	bne pause
	dec delay
	bne pause
	
	dex
	bne scrlloop
	
	ldx #$7
	stx $d016
	
	rts
	
textdata	
	.text "@fwaggle was here, WAY back in 2015. Hope you "
	.text "enjoy the show! This is a simple yet somewhat "
	.text "pretty smooth soft-scroller, written in ASM "
	.text "for TMPx/TMP. Your mileage may vary, batteries "
	.text "not included."
	.repeat 38," " ; 38 blank spaces to clear screen at end
	.byte $00 ; null byte to terminate string
	
delay	.byte $10
