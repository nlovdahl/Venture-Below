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

.include "includes/actions.inc"

.include "includes/system_macros.inc"

.a8
.i16

; the max number of periodic actions that can be handled
MAX_PERIODIC_ACTIONS = 128
; the number of bytes needed for periodic action data
PERIODIC_ACTIONS_SIZE = MAX_PERIODIC_ACTIONS * 4 ; 4 bytes / action
; the address of the buffer for periodic action data
PERIODIC_BUFFER_ADDR = .LOWORD(periodic_actions_buffer_)

; the max number of continuous actions that can be handled
MAX_CONTINUOUS_ACTIONS = 64
; the number of bytes needed for continuous action data
CONTINUOUS_ACTIONS_SIZE = MAX_CONTINUOUS_ACTIONS * 8 ; 8 bytes / action
; the address of the buffer for continuous action data
CONTINUOUS_BUFFER_ADDR = .LOWORD(continuous_actions_buffer_)

.code
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; See the appropriate include file for information about this procedure.
.proc resetActionSystem
	stz num_periodic_actions_ ; no periodic actions to start with
	
	SET_ACCUM_16_BIT
	
	; start & end point to the start of the buffer
	lda #PERIODIC_BUFFER_ADDR
	sta periodic_action_start_
	sta periodic_action_end_
	
	stz first_periodic_action_marker_ ; null since there are no markers yet
	stz last_periodic_action_marker_  ; null since there are no markers yet
	
	stz filled_continuous_actions_ptr_ ; set filled pointer to 0 (null)
	
	lda #CONTINUOUS_BUFFER_ADDR ; set empty pointer to fist node
	sta empty_continuous_actions_ptr_
	
	; create the linked list of empty nodes for continuous actions
	lda #CONTINUOUS_BUFFER_ADDR + 8
	ldx #CONTINUOUS_BUFFER_ADDR
	ldy #CONTINUOUS_BUFFER_ADDR - 8
	clc
	
	; at this point:
	; A points to the next node, X to the current node, and Y to the last node
Setup_Next_Node:
	sta a:4, x ; store next pointer in the current node (use abs addressing)
	tya
	sta a:6, x ; store last pointer in the current node (use abs addressing)
	txy
	adc #16
	tax
	adc #8
	
	; keep looping until all of the nodes are set up
	cpx #CONTINUOUS_BUFFER_ADDR + CONTINUOUS_ACTIONS_SIZE
	bcc Setup_Next_Node ; branch if X is less than
	
	; fix the pointer to the last node in the first node (it should be null)
	stz CONTINUOUS_BUFFER_ADDR + 6
	; fix the pointer to the last node in the last node (it should be null)
	stz CONTINUOUS_BUFFER_ADDR + CONTINUOUS_ACTIONS_SIZE - 4
	
	SET_ACCUM_8_BIT ; return A to 8-bit before returning
	
	rts
.endproc

; See the appropriate include file for information about this procedure.
.proc addPeriodicAction
	cpx #0 ; branch if the procedure pointer is zero
	beq Add_Periodic_Action_Marker
	
	; check if we have room to add another periodic action
Check_Num:
	lda num_periodic_actions_
	cmp #MAX_PERIODIC_ACTIONS
	bcc Add_Periodic_Action ; skip to here if we have room
	wai ; else, wait for v-blank and then check if there is room again
	bra Check_Num
	
Add_Periodic_Action:
	; increment the number of periodic actions since we are adding one
	inc num_periodic_actions_ ; use inc since it is 'atomic'
	
	ldy periodic_action_end_
	stx 0, y ; store the procedure pointer
	plx
	stx 2, y ; store the associated value
	
	iny ; advance the buffer's end pointer, rolling it over if need be
	iny
	iny
	iny
	cpy #PERIODIC_BUFFER_ADDR + PERIODIC_ACTIONS_SIZE
	bcc Store_Period_Action_End
	ldy #PERIODIC_BUFFER_ADDR
Store_Period_Action_End:
	sty periodic_action_end_
	
	rts
	
Add_Periodic_Action_Marker:
	jmp markPeriodicActionSet
.endproc

; See the appropriate include file for information about this procedure.
.proc markPeriodicActionSet
	; check if we have room to add another periodic action
Check_Num:
	lda num_periodic_actions_
	cmp #MAX_PERIODIC_ACTIONS
	bcc Add_Marker ; skip to here if we have room
	wai ; else, wait for v-blank and then check if there is room again
	bra Check_Num
	
Add_Marker:
	; increment the number of periodic actions since we are adding a marker
	inc num_periodic_actions_ ; use inc since it is 'atomic'
	
	ldx periodic_action_end_ ; fill in the values for a new marker
	stz 0, x
	stz 2, x
	
	ldy last_periodic_action_marker_ ; record this new action marker
	beq Set_Last_Marker ; skip to this if there is already a last action marker
	stx 2, y ; else, record the new marker in the last marker too
Set_Last_Marker:
	stx last_periodic_action_marker_
	
	ldy first_periodic_action_marker_ ; check if this is the first marker
	bne Increment_Buffer_End ; skip to here if there's already a first marker
	stx first_periodic_action_marker_ ; store this as the first marker
	
Increment_Buffer_End:
	inx ; advance the buffer's end pointer, rolling it over if need be
	inx
	inx
	inx
	cpx #PERIODIC_BUFFER_ADDR + PERIODIC_ACTIONS_SIZE
	bcc Store_Period_Action_End ; if there's no rollover...
	ldx #PERIODIC_BUFFER_ADDR
Store_Period_Action_End:
	stx periodic_action_end_
	
	rts
.endproc

; See the appropriate include file for information about this procedure.
.proc processPeriodicActions
	rts
.endproc

; See the appropriate include file for information about this procedure.
.proc addContinuousAction
	rts
.endproc

; See the appropriate include file for information about this procedure.
.proc removeContinuousAction
	rts
.endproc

; See the appropriate include file for information about this procedure.
.proc processContinuousActions
	rts
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.bss
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; registers used for periodic actions
num_periodic_actions_:         .res 1 ; number of actions & markers in buffer
periodic_action_start_:        .res 2 ; point to start of the circular buffer
periodic_action_end_:          .res 2 ; point to end of the circular buffer
first_periodic_action_marker_: .res 2 ; point to the first marker in the buffer
last_periodic_action_marker_:  .res 2 ; point to the last marker in the buffer

; registers used for continuous actions
filled_continuous_actions_ptr_: .res 2 ; point to doubly-linked list of actions
empty_continuous_actions_ptr_:  .res 2 ; point to doubly-linked list of empties

; other registers
proc_address_: .res 2 ; holds the address to call
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.segment "ACTION_SYSTEM_DATA"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.align 256
periodic_actions_buffer_:   .res PERIODIC_ACTIONS_SIZE
continuous_actions_buffer_: .res CONTINUOUS_ACTIONS_SIZE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~