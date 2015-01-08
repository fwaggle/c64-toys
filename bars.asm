	.include "include/kernal.asm"
	.include "include/boot.asm"
	
	; main program
	*=$1000
	
loop	inc $d020
	ldx #$5A
wait	dex
	bne wait
	jmp loop
