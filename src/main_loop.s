; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; This file is a part of Venture Below, a game for the SNES.
; Copyright (C) 2021 - 2022 Nicholas Lovdahl

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

.include "includes/main_loop.inc"

.include "includes/ppu_control.inc"
.include "includes/actions.inc"

.a8
.i16

.code
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ~~~~~~~~~~~~~~~~
; NAME: mainLoop
; SCOPE: Public
; DESCRIPTION:
;   The main loop for the program.
; ~~~~~~~~~~~~~~~~
.proc mainLoop
Main_Loop:
	; fade in...
	jsr addFadeInAction
	jsr markPeriodicActionSet
	; then fade out...
	jsr addFadeOutAction
	jsr markPeriodicActionSet
	
	bra Main_Loop
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
