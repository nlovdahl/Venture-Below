; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This file is a part of Venture Below, a game for the SNES.
; Copyright (C) 2021 Nicholas Lovdahl

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
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.include "includes/interrupt_handlers.inc"

.include "includes/system_macros.inc"
.include "includes/system_aliases.inc"

.include "includes/actions.inc"
.include "includes/main_loop.inc"

.segment "INTERRUPT_HANDLER_CODE"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; See the appropriate include file for this procedure.
.proc resetHandler
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
	
	jml Program_Bank_Register_Reset ; update the program bank register via jump
Program_Bank_Register_Reset:

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
	stz BG1HOFS ; write twice to set
	stz BG1HOFS
	stz BG1VOFS ; write twice to set
	stz BG1VOFS
	stz BG2HOFS ; write twice to set
	stz BG2HOFS
	stz BG2VOFS ; write twice to set
	stz BG2VOFS
	stz BG3HOFS ; write twice to set
	stz BG3HOFS
	stz BG3VOFS ; write twice to set
	stz BG3VOFS
	stz BG4HOFS ; write twice to set
	stz BG4HOFS
	stz BG4VOFS ; write twice to set
	stz BG4VOFS
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
	; initialize IO port
	lda #$FF
	sta WRIO
	; initialize values for H/V count timers
	stz HTIMEL
	stz HTIMEH
	stz VTIMEL
	stz VTIMEH
	
	lda #0 ; set the first color in CGRAM
	sta CGADD
	lda #$0F ; low byte
	sta CGDATA
	lda #$F0 ; high byte
	sta CGDATA
	
	; set the data bank register to the low WRAM bank
	SET_DATA_BANK PRESERVE_REGS_FALSE, #LWRAM_BANK
	
	; jump to a process in the code bank nexta
	jml systemInit ; initialize software systems / subsystems
.endproc

; once initialization is done, it should jump back here to perform cleanup
.proc resetHandlerCleanup
	; set the data bank register to the the hardware bank
	SET_DATA_BANK PRESERVE_REGS_FALSE, #HARDWARE_BANK
	
	; prepare to turn over control of the system (restart some things)
	lda #$0F ; turn on the screen with full brightness
	sta INIDISP
	lda #$81 ; allow V-Blanks again and start automatically polling controllers
	sta NMITIMEN
	
	; set the data bank register to the low WRAM bank
	SET_DATA_BANK PRESERVE_REGS_FALSE, #LWRAM_BANK
	
	cli ; enable interrupts again
	
	; go to the main loop for the program now that everything is ready
	jml mainLoop
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.code
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; A procedure that performs initialization for the software systems and 
; subsystems used by this program.
; This procedure takes no parameters and returns nothing.
.proc systemInit
	jsr resetActionSystem ; this effectively initializes the action system
	
	jml resetHandlerCleanup
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~