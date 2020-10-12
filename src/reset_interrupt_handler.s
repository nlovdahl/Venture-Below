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

.include "includes/interrupt_handlers.inc"
.include "includes/system_macros.inc"
.include "includes/system_aliases.inc"

.segment "RESET_INTERRUPT_HANDLER"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.proc ResetHandler
	sei ; disable interrupts
	clc ; enter native mode (switch from 8-bit mode to 16-bit mode)
	xce
	
	; initialize the CPU: set register sizes, set the stack pointer, etc.
	SET_BIN_MODE ; use binary mode and make registers A, X, and Y 16-bits
	SET_ACCUM_16_BIT
	SET_INDEX_16_BIT
	
	lda #$1FFF ; set the stack pointer at this address
	tcs
	
	lda #$0000 ; set the direct page to this address
	tcd
	
	SET_ACCUM_8_BIT ; make register A 8-bits now
	
	jml DataBankRegisterReset ; update the data bank register by jumping here
DataBankRegisterReset:

	; initialize the system's hardware registers
	lda #$80 ; disable drawing to screen and darken the screen
	sta INIDISP
	
	lda #$70 ; low byte of color first
	sta CGDATA
	lda #$03 ; then the high byte
	sta CGDATA
	
	; prepare to turn over controll of the system (restart some things)
	lda #$0F ; turn on the screen with full brightness
	sta INIDISP
	lda #$81 ; allow V-Blanks again and start automatically polling controllers
	sta NMITIMEN
	
	cli ; enable interrupts again
	
	wai ; stall the processor...
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
