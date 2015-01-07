	.include "include/kernal.asm"
	.include "include/boot.asm"
	
	; main program
	*=$1000
	
	; clear screen
	lda #$93	; CHR$(147)
	jsr CHROUT
	
	ldx #$00
printloop	lda textdata, x
		; cmp #$00 implied by lda
	beq done	; hit null byte at end of string = done
	jsr CHROUT
	inx
	jmp printloop
done	rts

textdata	.text "fwaggle was here."
	.byte $0D, $0D ; CR
	.text "hello world!"
	.byte $00
