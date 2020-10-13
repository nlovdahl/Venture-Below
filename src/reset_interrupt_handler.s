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
	
	jml ProgramBankRegisterReset ; update the program bank register by jumping
ProgramBankRegisterReset:

	; initialize the system's hardware registers
	lda #$80 ; disable drawing to screen
	sta INIDISP
	
	; initialize basic PPU registers
	stz OBJSEL
	stz BGMODE
	stz MOSAIC
	stz BG1SC
	stz BG2SC
	stz BG3SC
	stz BG4SC
	stz BG12NBA
	stz BG34NBA
	; initialize background scroll registers
	stz BG1H0FS ; write twice to set
	stz BG1H0FS
	stz BG1V0FS ; write twice to set
	stz BG1V0FS
	stz BG2H0FS ; write twice to set
	stz BG2H0FS
	stz BG2V0FS ; write twice to set
	stz BG2V0FS
	stz BG3H0FS ; write twice to set
	stz BG3H0FS
	stz BG3V0FS ; write twice to set
	stz BG3V0FS
	stz BG4H0FS ; write twice to set
	stz BG4H0FS
	stz BG4V0FS ; write twice to set
	stz BG4V0FS
	; initialize registers related to mode 7 transformations
	stz M7SEL
	lda #$01
	sta M7A ; write twice to set
	stz M7A
	stz M7B ; write twice to set
	stz M7B
	stz M7C ; write twice to set
	stz M7C
	sta M7D ; write twice to set
	stz M7D
	stz M7X ; write twice to set
	stz M7X
	stz M7Y ; write twice to set
	stz M7Y
	; initialize window mask registers
	stz W12SEL
	stz W34SEL
	stz WOBJSEL
	stz WH0
	stz WH1
	stz WH2
	stz WH3
	stz WBGLOG
	stz WOBJLOG
	; initialize screen and window mask designation registers
	stz TM
	stz TS
	stz TMW
	stz TSW
	; initialize color math registers
	lda #$30
	sta CGSWSEL
	stz CGADSUB
	lda #$E0
	sta COLDATA
	; initialize register for screen settings
	stz SETINI
	; initialize screen control / timing registers
	stz NMITIMEN
	; initialize IO port (controllers?)
	lda #$FF
	sta WRIO
	; initialize values for H/V count timers
	stz HTIMEL
	stz HTIMEH
	stz VTIMEL
	stz VTIMEH
	
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
	
InfiniteLoop:
	wai ; stall the processor...
	jmp InfiniteLoop
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
