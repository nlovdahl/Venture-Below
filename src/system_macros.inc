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

; CPU Control Macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Set the CPU to binary mode (as opposed to decimal mode)
.macro SET_BIN_MODE
	rep #$08
.endmacro

; Set the CPU to decimal mode (as opposed to binary mode)
.macro SET_DEC_MODE
	sep #$08
.endmacro

; Set the accumulator register (A) to be 16-bits
.macro SET_ACCUM_16_BIT
	rep #$20
.endmacro

; Set the accumulator register (A) to be 8-bits
.macro SET_ACCUM_8_BIT
	sep #$20
.endmacro

; Set the index registers (X & Y) to be 16-bits
.macro SET_INDEX_16_BIT
	rep #$10
.endmacro

; Set the index registers (X & Y) to be 8-bits
.macro SET_INDEX_8_BIT
	sep #$10
.endmacro
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~