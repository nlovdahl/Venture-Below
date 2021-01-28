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

.a8
.i16

.segment "INTERRUPT_HANDLER_CODE"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; See the appropriate include file for this procedure.
.proc vBlankHandler
	sei ; disable interrupts
	
	phb ; save registers A, X, Y, dp, and db registers
	phd
	phy
	phx
	pha
	
	SET_DATA_BANK PRESERVE_REGS_FALSE, #HARDWARE_BANK
	
	lda #$01 ; disable further v-blank (NMI) interrupts
	sta NMITIMEN
	
	lda RDNMI ; acknowledge NMI by reading the flag
	
	SET_DATA_BANK PRESERVE_REGS_FALSE, #LWRAM_BANK
	
	; skip all vblank work if the vblank interrupt flag is already set
	lda vblank_interrupt_active_flag_
	bne vBlankHandlerCleanup
	
	lda #$FF ; set the flag now that the vblank interrupt is running
	sta vblank_interrupt_active_flag_
	
	jml vBlankProcess ; jump to a process proc in the code bank
.endproc

; once the process proc is done, it should jump back to here to perform cleanup
.proc vBlankHandlerCleanup
	SET_DATA_BANK PRESERVE_REGS_FALSE, #HARDWARE_BANK
	
	lda #$81 ; reenable v-blank interrupts
	sta NMITIMEN
	
	SET_DATA_BANK PRESERVE_REGS_FALSE, #LWRAM_BANK
	
	pla ; restore the A, X, Y, and dp registers before returning
	plx
	ply
	pld
	
	stz vblank_interrupt_active_flag_ ; clear the flag now that we're done
	
	plb ; restore the db register
	
	cli ; reenable interrupts
	
	rti
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.code
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.proc vBlankProcess
	; check for changes to be made thru the PPU
	; TODO...
	
	; assume v-blank is up - do not make changes to the screen past this point!
	; handle continuous actions, and then periodic actions
	jsr processContinuousActions
	jsr processPeriodicActions
	
Process_End:
	jml vBlankHandlerCleanup ; jump back to perform cleanup and return
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.bss
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vblank_interrupt_active_flag_: .res 1 ; non-zero if vblank interrupt is active
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
