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

.include "includes/ppu_control.inc"

.include "includes/actions.inc"

.a8
.i16

.code
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; See the appropriate include file for information about this procedure.
.proc addFadeInAction
	ldx #61
	phx
	ldx #.LOWORD(actionFadeIn)
	jsr addPeriodicAction
	
	rts
.endproc

; See the appropriate include file for information about this procedure.
.proc addFadeOutAction
	ldx #61
	phx
	ldx #.LOWORD(actionFadeOut)
	jsr addPeriodicAction
	
	rts
.endproc

; An action that controls the brightness of the screen - gradually increasing
; the brightness until it reaches its maximum value.
; This action takes in a word in X as a 'timer' and returns the next value
; in X.
.proc actionFadeIn
	dex ; decrease the timer
	txa ; take the value for the brightness from the timer value
	lsr
	lsr
	eor #$0F
	sta screen_brightness
	
	rts
.endproc

; An action that controls the brightness of the screen - gradually decreasing
; the brightness until it reaches its minimum value.
; This action takes in a word in X as a 'timer' and returns the next value
; in X.
.proc actionFadeOut
	dex ; decrease the timer
	txa ; take the value for the brightness from the timer value
	lsr
	lsr
	sta screen_brightness
	
	rts
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.bss
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
screen_brightness: .res 1 ; 0 (full darkness) - 15 (full brightness)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
