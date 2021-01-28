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

.ifndef SYSTEM_MACROS_INCLUDED_
SYSTEM_MACROS_INCLUDED_ = 1

.include "system_aliases.inc"

.define PRESERVE_REGS_TRUE 1  ; registers should be preserved
.define PRESERVE_REGS_FALSE 0 ; registers need not be preserved

; CPU Control Macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Set the CPU to binary mode (as opposed to decimal mode).
; This macro takes no parameters.
.macro SET_BIN_MODE
	rep #$08
.endmacro

; Set the CPU to decimal mode (as opposed to binary mode).
; This macro takes no parameters.
.macro SET_DEC_MODE
	sep #$08
.endmacro

; Set the accumulator register (A) to be 16-bits.
; This macro takes no parameters.
.macro SET_ACCUM_16_BIT
	rep #$20
.endmacro

; Set the accumulator register (A) to be 8-bits.
; This macro takes no parameters.
.macro SET_ACCUM_8_BIT
	sep #$20
.endmacro

; Set the index registers (X & Y) to be 16-bits.
; This macro takes no parameters.
.macro SET_INDEX_16_BIT
	rep #$10
.endmacro

; Set the index registers (X & Y) to be 8-bits.
; This macro takes no parameters.
.macro SET_INDEX_8_BIT
	sep #$10
.endmacro

; Sets the data bank register.
; This macro takes two parameters.
; 'preserve' determines whether or not CPU registers should be preserved when
; this macro is called. If 'preserve' is zero (PRESERVE_REGS_FALSE), then CPU
; registers may be clobbered by this macro.
; 'data_bank' is the value to be used to set the data bank register.
.macro SET_DATA_BANK preserve, data_bank
	.if .paramcount <> 2
	.error "Incorrect number of parameters for SET_DATA_BANK macro"
	.endif
	
	; save the A register if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	pha
	.endif
	
	lda data_bank ; load and set the data bank register through the stack
	pha
	plb
	
	; restore the A register if we should preserve registers
	.if preserve <> PRESERVE_REGS_FALSE
	pla
	.endif
.endmacro

; Sets the direct page register to an immediate address.
; This macro takes a single parameter.
; 'direct_page' is the value to which the direct page should be set. It should
; be in the form of $XXXX - not #$XXXX or ($XXXX).
.macro SET_DIRECT_PAGE_IMMEDIATE direct_page
	.if paramcount <> 1
	.error "Incorrect number of parameters for SET_DIRECT_PAGE_IMMEDIATE macro"
	.endif
	
	pea direct_page ; set the direct page using the stack
	pld
.endmacro
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; DMA Macros
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Transfers data to low WRAM using DMA.
; This macro takes five parameters.
; 'preserve' determines whether or not CPU registers should be preserved when
; this macro is called. If 'preserve' is zero (PRESERVE_REGS_FALSE), then CPU
; registers may be clobbered by this macro.
; 'src_bank' is the source's data bank (upper 8 bits).
; 'src_addr' is the source's address (lower 16 bits).
; 'dest_addr' is the destination address in low WRAM.
; 'num_bytes' is the number of bytes to transfer. Note that using 0 will
; actually transfer 65536 bytes.
.macro LWRAM_TRANSFER preserve, src_bank, src_addr, dest_addr, num_bytes
	.if .paramcount <> 4
	.error "Incorrect number of parameters for LWRAM_TRANSFER macro"
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

; Transfers data to high WRAM using DMA.
; This macro takes five parameters.
; 'preserve' determines whether or not CPU registers should be preserved when
; this macro is called. If 'preserve' is zero (PRESERVE_REGS_FALSE), then CPU
; registers may be clobbered by this macro.
; 'src_bank' is the source's data bank (upper 8 bits).
; 'src_addr' is the source's address (lower 16 bits).
; 'dest_addr' is the destination address in low WRAM.
; 'num_bytes' is the number of bytes to transfer. Note that using 0 will
; actually transfer 65536 bytes.
.macro HWRAM_TRANSFER preserve, src_bank, src_addr, dest_addr, num_bytes
	.if .paramcount <> 4
	.error "Incorrect number of parameters for HWRAM_TRANSFER macro"
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

; Transfers data to VRAM using DMA.
; This macro takes five parameters.
; 'preserve' determines whether or not CPU registers should be preserved when
; this macro is called. If 'preserve' is zero (PRESERVE_REGS_FALSE), then CPU
; registers may be clobbered by this macro.
; 'src_bank' is the source's data bank (upper 8 bits).
; 'src_addr' is the source's address (lower 16 bits).
; 'dest_addr' is the destination address in low WRAM.
; 'num_bytes' is the number of bytes to transfer. Note that using 0 will
; actually transfer 65536 bytes.
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

; Transfers data to CGRAM using DMA.
; This macro takes five parameters.
; 'preserve' determines whether or not CPU registers should be preserved when
; this macro is called. If 'preserve' is zero (PRESERVE_REGS_FALSE), then CPU
; registers may be clobbered by this macro.
; 'src_bank' is the source's data bank (upper 8 bits).
; 'src_addr' is the source's address (lower 16 bits).
; 'dest_addr' is the destination address in low WRAM.
; 'num_bytes' is the number of bytes to transfer. Note that using 0 will
; actually transfer 65536 bytes.
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
