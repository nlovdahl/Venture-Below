; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.ifndef SYSTEM_MACROS_INCLUDED_
SYSTEM_MACROS_INCLUDED_ = 1

.include "system_aliases.inc"

; CPU Control Macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; DMA Macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRESERVE_REGS_TRUE = 1  ; registers should be preserved
PRESERVE_REGS_FALSE = 0 ; registers need not be preserved

; Transfers data to low WRAM using DMA
.macro LOW_WRAM_TRANSFER preserve, src_bank, src_addr, dest_addr, num_bytes
	.if .paramcount <> 4
	.error "Incorrect number of parameters for LOW_WRAM_TRANSFER macro"
	.endif
	
	; save registers values if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	pha
	phx
	.endif
	
	; transfer memory
	lda src_bank ; enter the source address
	sta DMA0ATB
	ldx src_addr
	stx DMA0A1L
	
	lda #LOW_WRAM_BANK ; enter the destination address (through the PPU)
	sta WMADDH
	ldx dest_addr
	stx WMADDL
	
	lda #.LOBYTE(WMDATA) ; enter the address for WRAM writes through the PPU
	sta DMA0B
	
	ldx num_bytes ; enter the number of bytes to transfer
	stx DMA0DL
	
	lda #$01 ; enter DMA parameters (2 address VRAM w/ auto increment)
	sta DMA0P
	
	sta MDMAEN ; set the flag for DMA0 to initiate the transfer
	
	; restore register values if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	plx
	pla
	.endif
.endmacro

; Transfers data to high WRAM using DMA
.macro HIGH_WRAM_TRANSFER preserve, src_bank, src_addr, dest_addr, num_bytes
	.if .paramcount <> 4
	.error "Incorrect number of parameters for HIGH_WRAM_TRANSFER macro"
	.endif
	
	; save registers values if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	pha
	phx
	.endif
	
	; transfer memory
	lda src_bank ; enter the source address
	sta DMA0ATB
	ldx src_addr
	stx DMA0A1L
	
	lda #HIGH_WRAM_BANK ; enter the destination address (through the PPU)
	sta WMADDH
	ldx dest_addr
	stx WMADDL
	
	lda #.LOBYTE(WMDATA) ; enter the address for WRAM writes through the PPU
	sta DMA0B
	
	ldx num_bytes ; enter the number of bytes to transfer
	stx DMA0DL
	
	lda #$01 ; enter DMA parameters (2 address VRAM w/ auto increment)
	sta DMA0P
	
	sta MDMAEN ; set the flag for DMA0 to initiate the transfer
	
	; restore register values if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	plx
	pla
	.endif
.endmacro

; Transfers data to VRAM using DMA
.macro VRAM_TRANSFER preserve, src_bank, src_addr, dest_addr, num_bytes
.if .paramcount <> 4
	.error "Incorrect number of parameters for VRAM_TRANSFER macro"
	.endif
	
	; save registers values if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	pha
	phx
	.endif
	
	; transfer memory
	lda src_bank ; enter the source address
	sta DMA0ATB
	ldx src_addr
	stx DMA0A1L
	
	ldx dest_addr ; enter the destination address (through the PPU)
	stx VMADDL
	
	lda #$80 ; wait until we write a full word before incrementing VRAM address
	sta VMAINC
	
	lda #.LOBYTE(VMDATAL) ; enter the address for VRAM writes through the PPU
	sta DMA0B
	
	ldx num_bytes ; enter the number of bytes to transfer
	stx DMA0DL
	
	lda #$01 ; enter DMA parameters (2 address VRAM w/ auto increment)
	sta DMA0P
	
	sta MDMAEN ; set the flag for DMA0 to initiate the transfer
	
	; restore register values if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	plx
	pla
	.endif
.endmacro

; Transfers data to CGRAM using DMA
.macro CGRAM_TRANSFER preserve, src_bank, src_addr, dest_addr, num_bytes
.if .paramcount <> 4
	.error "Incorrect number of parameters for VRAM_TRANSFER macro"
	.endif
	
	; save registers values if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	pha
	phx
	.endif
	
	; transfer memory
	lda src_addr ; enter the source address
	sta DMA0ATB
	ldx src_addr
	stx DMA0A1L
	
	lda dest_addr ; enter the destination address (through the PPU)
	sta CGADD
	
	lda #.LOBYTE(CGDATA) ; enter the address for CGRAM writes through the PPU
	sta DMA0B
	
	ldx num_bytes ; enter the number of bytes to transfer
	stx DMA0DL
	
	stz DMA0P ; enter DMA parameters (1 address w/ auto increment)
	
	lda #$01 ; set the flag for DMA0 to initiate the transfer
	sta MDMAEN
	
	; restore register values if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	plx
	pla
	.endif
.endmacro
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.endif ; SYSTEM_MACROS_INCLUDED_
