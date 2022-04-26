; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This file is a part of Venture Below, a game for the SNES.
; Copyright (C) 2021-2022 Nicholas Lovdahl

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
; ~~~~~~~~~~~~~~~~
; NAME: addFadeInAction
; SCOPE: Public
; DESCRIPTION:
;   Adds a periodic action that fades in - gradually increasing the brightness
;   of the screen.
; ~~~~~~~~~~~~~~~~
.proc addFadeInAction
	ldx #61 ; prepare the procedure pointer and the associated value
	phx
	ldx #.LOWORD(actionFadeIn)
	
	jsr addPeriodicAction
	
	plx ; pop the extra parameter from the stack before returning
	
	rts
.endproc

; ~~~~~~~~~~~~~~~~
; NAME: addFadeOutAction
; SCOPE: Public
; DESCRIPTION:
;   Adds a periodic action that fades out - gradually decreasing the brightness
;   of the screen
; ~~~~~~~~~~~~~~~~
.proc addFadeOutAction
	ldx #61 ; prepare the procedure pointer and the associated value
	phx
	ldx #.LOWORD(actionFadeOut)
	
	jsr addPeriodicAction
	
	plx ; pop the extra parameter from the stack before returning
	
	rts
.endproc

; This action takes in a word in X as a 'timer' and returns the next value
; in X.
; ~~~~~~~~~~~~~~~~
; NAME: actionFadeIn
; SCOPE: Private
; DESCRIPTION:
;   An action that controls the brightness of the screen - gradually increasing
;   the brightness until it reaches its maximum value.
; PARAMETERS:
;   X (word) - The 'timer' value used by this action.
; RETURNS:
;   X (word) - The next value for the 'timer'.
; ~~~~~~~~~~~~~~~~
.proc actionFadeIn
	dex ; decrease the timer
	txa ; take the value for the brightness from the timer value
	lsr
	lsr
	eor #$0F
	sta screen_brightness
	
	rts
.endproc

; This action takes in a word in X as a 'timer' and returns the next value
; in X.
; ~~~~~~~~~~~~~~~~
; NAME: actionFadeOut
; SCOPE: Private
; DESCRIPTION:
;   An action that controls the brightness of the screen - gradually decreasing
;   the brightness until it reaches its minimum value.
; PARAMETERS:
;   X (word) - The 'timer' value used by this action.
; RETURNS:
;   X (word) - The next value for the 'timer'.
; ~~~~~~~~~~~~~~~~
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
