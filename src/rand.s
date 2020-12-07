; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This file is a part of Venture Below, a game for the SNES.
; Copyright (C) 2020 Nicholas Lovdahl

; Venture Below is free software: you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the Free
; Software Foundation, either version 3 of the License, or (at your option) any
; later version.

; Venture Below is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
; details.

; You should have received a copy of the GNU General Public License along with
; Venture Below. If not, see <https://www.gnu.org/licenses/>.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.include "includes/rand.inc"
.include "includes/system_macros.inc"

.a8
.i16

.bss
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
seed:       .res 2 ; the seed for rng / the last number generated
rand_value: .res 2 ; the holding place for the generated number to be read
odd_byte:   .res 1 ; whether or not there is an odd random byte leftover
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.code
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; sets the seed used for rng - if the seed is zero it will be altered
.proc setSeed
	cpx #0 ; check if the seed in x is zero
	bne SetGoodSeed ; if the seed isn't 0, we can just set it
	
	ldx #$4DE1 ; chose this number as a default if we do have 0
	
SetGoodSeed:
	stx seed
	stz odd_byte ; no leftover bytes since we just set the seed
	
	rts
.endproc

; generates a random byte and places it at the first byte of rand_value
.proc nextRandomByte
	lda odd_byte ; check if there is a leftover byte to use
	bmi LeftoverByte ; if the high bit is set (negative number) we have a byte
	; otherwise, we need to generate another random number
	
	jsr nextRandomWord
	
	lda #$FF ; store a negative number in odd_byte to flag a leftover byte
	sta odd_byte
	
	rts
	
LeftoverByte:
	lda seed + 1 ; move the leftover byte into position
	sta rand_value
	
	stz odd_byte ; we used the leftover byte, no more left
	
	rts
.endproc

; generates a random word and places it in rand_value
.proc nextRandomWord
	stz odd_byte ; we need a whole word, no leftover bytes
	
	SET_ACCUM_16_BIT
	
	lda seed
	
	asl ; seed ^= seed << 7
	asl
	asl
	asl
	asl
	asl
	asl
	eor seed
	sta seed
	
	lsr ; seed ^= seed >> 9
	lsr
	lsr
	lsr
	lsr
	lsr
	lsr
	lsr
	lsr
	eor seed
	sta seed
	
	asl ; seed ^= seed << 8
	asl
	asl
	asl
	asl
	asl
	asl
	asl
	eor seed
	sta seed
	
	sta rand_value ; set rand_value
	
	SET_ACCUM_8_BIT
	
	rts
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~