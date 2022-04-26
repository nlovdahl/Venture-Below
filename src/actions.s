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

; the address of the register that holds procedure pointers used for calls
PROC_ADDRESS_ADDR = .LOWORD(proc_address_)

.code
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ~~~~~~~~~~~~~~~~
; NAME: resetActionSystem
; SCOPE: Public
; DESCRIPTION:
;   Resets both the periodic and continuous action systems, removing any
;   actions. This needs to be called to initialize these systems too.
; ~~~~~~~~~~~~~~~~
.proc resetActionSystem
	stz num_periodic_actions_ ; no periodic actions to start with
	
	SET_ACCUM_16_BIT
	
	; start & end point to the start of the buffer
	lda #PERIODIC_BUFFER_ADDR
	sta periodic_actions_start_
	sta periodic_actions_end_
	
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

; ~~~~~~~~~~~~~~~~
; NAME: addPeriodicAction
; SCOPE: Public
; DESCRIPTION:
;   Adds a periodic action to the next action set (starting a new action set if
;   necessary) using the given procedure pointer and associated value. If the
;   procedure pointer is zero, then this will mark a complete action set.
; PARAMETERS:
;   X (word) - The pointer to the procedure associated with the action.
;   S + 3 (word) - The initial associated value for the action.
; ~~~~~~~~~~~~~~~~
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
	
	SET_ACCUM_16_BIT
	
	ldy periodic_actions_end_
	
	txa ; store the procedure pointer
	sta a:0, y
	
	lda 3, s ; store the associated value
	sta a:2, y
	
	tya ; advance the buffer's end pointer, rolling it over if need be
	clc
	adc #4
	cmp #PERIODIC_BUFFER_ADDR + PERIODIC_ACTIONS_SIZE
	bcc Store_Periodic_Action_End
	lda #PERIODIC_BUFFER_ADDR
Store_Periodic_Action_End:
	sta periodic_actions_end_
	
	SET_ACCUM_8_BIT ; return A to 8-bit before returning
	
	rts
	
Add_Periodic_Action_Marker:
	jmp markPeriodicActionSet
.endproc

; ~~~~~~~~~~~~~~~~
; NAME: markPeriodicActionSet
; SCOPE: Public
; DESCRIPTION:
;   Marks the end of an action set. That is, this marks that any periodic
;   actions previously submitted since the last action set (if any) compose a
;   set which should all be processed together.
; ~~~~~~~~~~~~~~~~
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
	
	SET_ACCUM_16_BIT
	
	lda periodic_actions_end_ ; fill in the values for a new marker
	tax
	stz a:0, x
	stz a:2, x
	
	ldy last_periodic_action_marker_ ; record this new action marker
	beq Set_Last_Marker ; skip to this if there is already a last action marker
	sta a:2, y ; else, record the new marker in the last marker too
Set_Last_Marker:
	sta last_periodic_action_marker_
	
	ldy first_periodic_action_marker_ ; check if this is the first marker
	bne Increment_Buffer_End ; skip to here if there's already a first marker
	sta first_periodic_action_marker_ ; store this as the first marker
	
Increment_Buffer_End:
	clc ; advance the buffer's end pointer, rolling it over if need be
	adc #4
	cmp #PERIODIC_BUFFER_ADDR + PERIODIC_ACTIONS_SIZE
	bcc Store_Period_Action_End ; if there's no rollover...
	lda #PERIODIC_BUFFER_ADDR
Store_Period_Action_End:
	sta periodic_actions_end_
	
	SET_ACCUM_8_BIT ; return A to 8-bit before returning
	
	rts
.endproc

; ~~~~~~~~~~~~~~~~
; NAME: processPeriodicActions
; SCOPE: Public
; DESCRIPTION:
;   Processes all of the periodic actions by calling the procedures with their
;   associated values. If an action set has been marked, then only the actions
;   in the current set are processed.
; ~~~~~~~~~~~~~~~~
.proc processPeriodicActions
	ldx first_periodic_action_marker_
	beq Finish_Processing_Periodic_Actions ; just return if that was zero
	
	SET_ACCUM_16_BIT ; we will be making use of A (mostly adding)
	clc ; make sure carry is clear before proceeding
	
	; cleanup before we start processing
	ldy periodic_actions_start_ ; keep the buffer's start pointer in Y for now
	bra Check_Next_For_Cleaning
	
Advance_Start_For_Cleaning:
	dec num_periodic_actions_ ; we are reducing the number of entries, so dec
	
	tya ; advance the buffer's end pointer, rolling it over if need be
	adc #4
	tay
	cpy #PERIODIC_BUFFER_ADDR + PERIODIC_ACTIONS_SIZE
	bcc Check_Next_For_Cleaning ; if there's no rollover...
	clc
	ldy #PERIODIC_BUFFER_ADDR
	
Check_Next_For_Cleaning:
	ldx a:0, y
	beq Handle_Action_Set_Marker_Cleaning ; if zero, it's an action set marker
	ldx a:2, y
	bne Finish_Cleanup ; if non-zero, we are done cleaning
	bra Advance_Start_For_Cleaning
	
Handle_Action_Set_Marker_Cleaning:
	; the next action marker will now be first, it should be the assoc. value
	ldx a:2, y
	stx first_periodic_action_marker_
	; if the associated value was zero, this was the last marker (end will be 0)
	bne Advance_Start_For_Cleaning ; but if was non-zero, just advance
	stx last_periodic_action_marker_
	bra Finish_Processing_Periodic_Actions
	
Finish_Cleanup:
	sty periodic_actions_start_ ; update the pointer to its now value
	
	; cleanup is done, check if we still have an action marker
	ldx first_periodic_action_marker_
	beq Finish_Processing_Periodic_Actions ; just return if that was zero
	; else, start processing until we hit the first action set marker
	
Check_Next_For_Processing:
	cpy first_periodic_action_marker_
	beq Finish_Processing_Periodic_Actions ; finish if we hit the marker
	clc
	
	ldx a:0, y ; get and store the procedure pointer (we may or may not use it)
	stx proc_address_
	
	ldx a:2, y ; get and check the associated value now
	beq Advance_Start_For_Processing ; skip processing if value is zero
	; else, we will call the procedure with the appropriate value
	
	phy ; save our index into the buffer from being clobbered
	pea Return_From_Called_Procedure - 1 ; -1 since PC will be incremented
	SET_ACCUM_8_BIT ; set A to 8-bits for the procedure being called
	jmp (PROC_ADDRESS_ADDR) ; jump to the procedure being pointed to
	
Return_From_Called_Procedure:
	ply ; restore Y for indexing
	
	SET_ACCUM_16_BIT ; return A to 16-bits and clear carry too
	clc
	
	txa ; store the new associated value
	sta a:2, y
	
Advance_Start_For_Processing:
	tya ; advance the buffer's end pointer, rolling it over if need be
	adc #4
	tay
	cpy #PERIODIC_BUFFER_ADDR + PERIODIC_ACTIONS_SIZE
	bcc Check_Next_For_Processing ; if there's no rollover...
	clc
	ldy #PERIODIC_BUFFER_ADDR
	bra Check_Next_For_Processing
	
Finish_Processing_Periodic_Actions:
	SET_ACCUM_8_BIT ; return A to 8-bits before returning

	rts
.endproc

; ~~~~~~~~~~~~~~~~
; NAME: addContinuousAction
; SCOPE: Public
; DESCRIPTION:
;   Adds a continuous action to the list of continuous actions which are
;   processed. The added action has a procedure pointer and an associated value
;   like with periodic actions.
; PARAMETERS:
;   X (word) - A pointer to the procedure associated with the action.
;   S + 3 (word) - The initial associated value for the action.
; RETURNS:
;   X (word) - A pointer to the added action. This will be needed to remove the
;              action. If the action could not be added, zero is returned
;              instead.
; ~~~~~~~~~~~~~~~~
.proc addContinuousAction
	rts
.endproc

; ~~~~~~~~~~~~~~~~
; NAME: removeContinuousAction
; SCOPE: Public
; DESCRIPTION:
;   Removes a continuous action from the list of continuous actions which are
;   processed.
; PARAMETERS:
;   X (word) - A pointer to the continuous action to remove. This should be the
;              address returned by addContinuousAction.
; ~~~~~~~~~~~~~~~~
.proc removeContinuousAction
	rts
.endproc

; ~~~~~~~~~~~~~~~~
; NAME: processContinuousActions
; SCOPE: Public
; DESCRIPTION:
;   Processes all of the continuous actions by calling the procedures with their
;   associated values.
; ~~~~~~~~~~~~~~~~
.proc processContinuousActions
	rts
.endproc
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.bss
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; registers used for periodic actions
num_periodic_actions_:         .res 1 ; number of actions & markers in buffer
periodic_actions_start_:       .res 2 ; point to start of the circular buffer
periodic_actions_end_:         .res 2 ; point to end of the circular buffer
first_periodic_action_marker_: .res 2 ; point to the first marker in the buffer
last_periodic_action_marker_:  .res 2 ; point to the last marker in the buffer

; registers used for continuous actions
filled_continuous_actions_ptr_: .res 2 ; point to doubly-linked list of actions
empty_continuous_actions_ptr_:  .res 2 ; point to doubly-linked list of empties
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.segment "JUMP_PROC_ADDRESS"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc_address_: .res 2 ; holds the address of the procedure to call
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.segment "ACTION_SYSTEM_DATA"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.align 256
periodic_actions_buffer_:   .res PERIODIC_ACTIONS_SIZE
continuous_actions_buffer_: .res CONTINUOUS_ACTIONS_SIZE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~