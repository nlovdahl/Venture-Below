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

.ifndef ACTIONS_INCLUDED_
ACTIONS_INCLUDED_ = 1

; Resets the action system - this handles both periodic and continuous
; actions - so that the system is ready to have actions added to it. If there
; are already actions, these will be removed.
; This procedure takes no parameters and returns nothing
.global resetActionSystem

; Adds a periodic action to the next action set (starting a new action set if
; necessary) using the given procedure pointer and associated value. If the
; procedure pointer is zero, then this will mark a complete action set.
; This procedure takes two words as parameters: the pointer to the procedure
; associated with the action (in the X register), and the associated value
; for that action (pushed to the stack).
; This procedure returns nothing.
.global addPeriodicAction

; Marks the end of an action set. That is, this marks that any periodic actions
; previously submitted since the last action set (if any) compose a set which
; should all be processed together.
; This procedure takes no parameters.
; This procedure returns nothing.
.global markPeriodicActionSet

; Processes all of the periodic actions by calling the procedures with their
; associated values. If an action set has been marked, then only the actions in
; the current set are processed.
; This procedure takes no parameters and returns nothing.
.global processPeriodicActions

; Adds a continuous action to the list of continuous actions which are
; processed. The added action has a procedure pointer and an associated value
; like with periodic actions.
; This procedure takes two words as parameters: the pointer to the procedure
; associated with the action (in the X register), and the associated value
; for that action (pushed to the stack).
; This procedure returns the address where the action is stored (in the X
; register) which can be used to remove it later if the continuous action is
; successfully added. Otherwise, it returns zero.
.global addContinuousAction

; Removes a continuous action from the list of continuous actions which are
; processed.
; This procedure takes a single word as a parameter: the address for the
; continuous action to remove (in the X register). This should be the address
; that was returned by the addContinuousAction procedure for the respective
; action.
; This procedure returns nothing.
.global removeContinuousAction

; Processes all of the continuous actions by calling the procedures with their
; associated values.
; This procedure takes no parameters and returns nothing.
.global processContinuousActions

.endif ; ACTIONS_INCLUDED_