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

.ifndef INTERRUPT_HANDLERS_INCLUDED_
INTERRUPT_HANDLERS_INCLUDED_ = 1

; The interrupt handler called for a system reset (or startup). This performs
; all of the initialization needed.
.global resetHandler

; The interrupt handler for non-maskable interrupts - fired at the start of
; v-blank - during which changes can be made to graphics. This handler performs
; those changes.
.global vBlankHandler

; An interrupt handler that immediately returns, doing nothing.
.global doNothingHandler

.endif ; INTERRUPT_HANDLERS_INCLUDED_
