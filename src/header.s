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

.segment "HEADER_DATA"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; maker code
.byte $4E ; N
.byte $4C ; L
; game code
.byte $56 ; V
.byte $4E ; N
.byte $42 ; B
.byte $45 ; E
; fixed values
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00
; expansion RAM size
.byte $00 ; no extra RAM
; special version status
.byte $00 ; not a special version
; cartridge type
.byte $00 ; no need for this
; title of the game
.byte $56 ; V
.byte $65 ; e
.byte $6E ; n
.byte $74 ; t
.byte $75 ; u
.byte $72 ; r
.byte $65 ; e
.byte $20
.byte $42 ; B
.byte $65 ; e
.byte $6C ; l
.byte $6F ; o
.byte $77 ; w
.byte $20
.byte $20
.byte $20
.byte $20
.byte $20
.byte $20
.byte $20
.byte $20
; memory map mode
.byte $01 ; HiROM configuration
; ROM type
.byte $02 ; Cartridge includes extra RAM and a battery (SRAM)
; ROM size
.byte $0A ; 1 MiB
; SRAM size
.byte $03 ; 8 KiB
; destination
.byte $01 ; North America, expect NTSC
; fixed value
.byte $33
; version number
.byte $00
; checksum compliment
.word $0000
; checksum
.word $0000
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.segment "NATIVE_MODE_INTERRUPT_HANDLER_TABLE"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Native Mode Interrupts (16 bit mode)
.addr doNothingHandler ; COP (co-processor interrupt)
.addr doNothingHandler ; BRK (break interrupt)
.addr doNothingHandler ; ABT (abort interrupt)
.addr vBlankHandler    ; NMI (V-Blank)
.addr resetHandler     ; RST (reset / boot)
.addr doNothingHandler ; IRQ (interrupt request)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.segment "EMULATOR_MODE_INTERRUPT_HANDLER_TABLE"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Emulator Mode Interrupts (8 bit mode)
.addr doNothingHandler ; COP (should never happen)
.addr doNothingHandler ; BRK (should never happen)
.addr doNothingHandler ; ABT (should never happen)
.addr doNothingHandler ; NMI (V-Blank should only happen in Native Mode)
.addr resetHandler     ; RST (reset / boot)
.addr doNothingHandler ; IRQ (interrupt request)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.segment "COMPILATION_DATA"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.align 4
.word .version ; ca65 version
.dword .time ; time of compilation
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
