	.include "include/kernal.asm"
	.include "include/boot.asm"
	
	; main program
	*=$1000

mainloop
	; if mod(count, 3) == 0
	ldx count
	ldy #$03
	stx dend
	sty dvsr
	jsr modulo
	lda output
	bne not3

	lda #$01
	sta fizzbuzz
	
	; print "FIZZ"
	lda #$46
	jsr CHROUT
	lda #$49
	jsr CHROUT
	lda #$5A
	jsr CHROUT
	jsr CHROUT

not3	; if mod(count, 5) == 0
	ldx count
	ldy #$05
	stx dend
	sty dvsr
	jsr modulo
	lda output
	bne not5
	
	lda #$01
	sta fizzbuzz
	
	; print "BUZZ"
	lda #$42
	jsr CHROUT
	lda #$55
	jsr CHROUT
	lda #$5A
	jsr CHROUT
	jsr CHROUT

not5	
	lda fizzbuzz
	bne next

	; output number
	ldx count
	jsr INTOUT
	
next	; comma and space, because 100 lines will not fit on the screen.
	lda #$2C
	jsr CHROUT
	lda #$20
	jsr CHROUT
	
	; reset fb flag, increment counter and loop
	lda #$00
	sta fizzbuzz
	inc count
	lda count
	cmp #$65 ; count to 101
	bcc mainloop
	
	rts
	
	; modulo function, using the dend and dvsr memory locations below
modulo
	lda dend
	ldy #$00
divloop	sec	; set carry bit
	sbc dvsr
	bcc divdone ; carry cleared == below zero
	iny
	bne divloop

divdone	sty output ; at this point, output == division result

	lda #$00
multloop	clc
	adc dvsr
	dec output
	bne multloop

	sta output ; at this point, output == int(x/y)*y
	
	lda dend
	sec
	sbc output
	
	sta output ; at this point, output == mod(x,y)
	
	rts

dend	.byte $00
dvsr	.byte $00
output	.byte $00
count	.byte $01
fizzbuzz	.byte $00
