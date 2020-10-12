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

; System Aliases
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; PPU Control Registers
INIDISP  = $2100 ; Controls initial settings for the screen
OBJSEL   = $2101 ; Controls object size and object data area designation
OAMADDL  = $2102 ; Controls the address for object attribute memory
OAMADDH  = $2103 ; Controls the address for object attribute memory
OAMDATA  = $2104 ; Data for an OAM write
BGMODE   = $2105 ; Background Mode and character size settings
MOSAIC   = $2106 ; Settings for a Mosaic Display
BG1SC    = $2107 ; Address for storing SC data for respective background and SC
BG2SC    = $2108 ; Address for storing SC data for respective background and SC
BG3SC    = $2109 ; Address for storing SC data for respective background and SC
BG4SC    = $210A ; Address for storing SC data for respective background and SC
BG12NBA  = $210B ; Background character data area designation (BG1 & BG2)
BG34NBA  = $210C ; Background character data area designation (BG3 & BG4)
BG1H0FS  = $210D ; Horizontal Scroll value designation for BG1
BG1V0FS  = $210E ; Vertical Scroll value designation for BG1
BG2H0FS  = $210F ; Horizontal Scroll value designation for BG2
BG2V0FS  = $2110 ; Vertical Scroll value designation for BG2
BG3H0FS  = $2111 ; Horizontal Scroll value designation for BG3
BG3V0FS  = $2112 ; Vertical Scroll value designation for BG3
BG4H0FS  = $2113 ; Horizontal Scroll value designation for BG4
BG4V0FS  = $2114 ; Vertical Scroll value designation for BG4
VMAINC   = $2115 ; VRAM Address Increment Value designation
VMADDL   = $2116 ; Address for VRAM read and write
VMADDH   = $2117 ; Address for VRAM read and write
VMDATAL  = $2118 ; Data for VRAM write
VMDATAH  = $2119 ; Data for VRAM write
M7SEL    = $211A ; Initial setting in Screen Mode 7
M7A      = $211B ; Argument for linear transformations in Mode 7
M7B      = $211C ; Argument for linear transformations in Mode 7
M7C      = $211D ; Argument for linear transformations in Mode 7
M7D      = $211E ; Argument for linear transformations in Mode 7
M7X      = $211F ; Argument for linear transformations in Mode 7
M7Y      = $2120 ; Argument for linear transformations in Mode 7
CGADD    = $2121 ; Address for CG-RAM read and write
CGDATA   = $2122 ; Data for CG-RAM read and write
W12SEL   = $2123 ; Window Mask settings (BG1 & BG2)
W34SEL   = $2124 ; Window Mask settings (BG4 & BG3)
WOBJSEL  = $2125 ; Window Mask settings (Color Window / Object Window)
WH0      = $2126 ; Left positon of Window 1
WH1      = $2127 ; Right position of Window 1
WH2      = $2128 ; Left position of Window 2
WH3      = $2129 ; Right position of Window 2
WBGLOG   = $212A ; Window logic settings for backgrounds
WOBJLOG  = $212B ; Window logic settings for color and obj
TM       = $212C ; Main Screen designation
TS       = $212D ; Sub Screen designation
TMW      = $212E ; Window Mask designation for the Main Screen
TSW      = $212F ; Window Mask designation for the Sub Screen
CGSWSEL  = $2130 ; Initial settings for fixed color or screen addition
CGADSUB  = $2131 ; Addition / substration designation for BG1, BG2, BG3, BG4
COLDATA  = $2132 ; Fixed color data for color addition / subtraction
SETINI   = $2133 ; Initial Screen Settings
MPYL     = $2134 ; Result from multiplication
MPYM     = $2135 ; Result from multiplication
MPYH     = $2136 ; Result from multiplication
SLHV     = $2137 ; Software latch for the H/V Counter
ROAMDATA = $2138 ; Read data from OAM
RVMDATAL = $2139 ; Read data from VRAM
RVMDATAH = $213A ; Read data from VRAM
RCGDATA  = $213B ; Read data from CGRAM
OPHCT    = $213C ; Output data from H Counter
OPVCT    = $213D ; Output data from V Counter
STAT77   = $213E ; PPU Status Flag and Version Number
STAT78   = $213F ; PPU Status Flag and Version Number
APUIO0   = $2140 ; IO Port for the APU
APUIO1   = $2141 ; IO Port for the APU
APUIO2   = $2142 ; IO Port for the APU
APUIO3   = $2143 ; IO Port for the APU
WMDATA   = $2180 ; Data for consecutive reads and writes to WRAM
WMADDL   = $2181 ; Address for consecutive reads and writes to WRAM
WMADDM   = $2182 ; Address for consecutive reads and writes to WRAM
WMADDH   = $2183 ; Address for consecutive reads and writes to WRAM

; CPU Control Registers
NMITIMEN = $4200 ; Flag for V-blank, timer enable, and standard controller
WRIO     = $4201 ; Programmable IO port (out)
WRMPYA   = $4202 ; Multiplicand for multiplication
WRMPYB   = $4203 ; Multiplier for multiplication
WRDIVL   = $4204 ; Dividend for division
WRDIVH   = $4205 ; Dividend for division
WRDIVB   = $4206 ; Divisor for division
HTIMEL   = $4207 ; H Count Timer settings
HTIMEH   = $4208 ; H Count Timer Settings
VTIMEL   = $4209 ; V Count Timer Settings
VTIMEH   = $420A ; V Count Timer Settings
MDMAEN   = $420B ; General DMA enable flags
HDMAEN   = $420C ; H DMA enable flags
MEMSEL   = $420D ; Memory Access Cycle designation
RDNMI    = $4210 ; NMI flag by V-blank and CPU version number
TIMEUP   = $4211 ; IRQ flag by H/V Count Timer
HVBJOY   = $4212 ; H/V Blank flag and Standard Controller enable flag
RDIO     = $4213 ; Programmable IO port (in)
RDDIVL   = $4214 ; Result of division
RDDIVH   = $4215 ; Result of division
RDMPYL   = $4216 ; Result of multiplication
RDMPYH   = $4217 ; Result of multiplication
CNTRL1L  = $4218 ; Input from Standard Controller 1
CNTRL1H  = $4219 ; Input from Standard Controller 1
CNTRL2L  = $421A ; Input from Standard Controller 2
CNTRL2H  = $421B ; Input from Standard Controller 2
CNTRL3L  = $421C ; Input from Standard Controller 3
CNTRL3H  = $421D ; Input from Standard Controller 3
CNTRL4L  = $421E ; Input from Standard Controller 4
CNTRL4H  = $421F ; Input from Standard Controller 4
DMA0P    = $4300 ; Parameters for DMA 0 transfer (highest priority)
DMA0B    = $4301 ; B-Bus address for DMA 0
DMA0A1L  = $4302 ; A1 Table address
DMA0A1H  = $4303 ; A1 Table address
DMA0ATB  = $4304 ; A Table Bank
DMA0DL   = $4305 ; Data address stored by H-DMA and number of bytes to transfer
DMA0DH   = $4306 ; Data address stored by H-DMA and number of bytes to transfer
DMA0DB   = $4307 ; Data address stored by H-DMA and number of bytes to transfer
DMA0A2L  = $4308 ; A2 Table address
DMA0A2H  = $4309 ; A2 Table address
DMA0NL   = $430A ; Number of lines transfered by H-DMA
DMA1P    = $4310 ; Parameters for DMA 1 transfer
DMA1B    = $4311 ; B-Bus address for DMA 1
DMA1A1L  = $4312 ; A1 Table address
DMA1A1H  = $4313 ; A1 Table address
DMA1ATB  = $4314 ; A Table Bank
DMA1DL   = $4315 ; Data address stored by H-DMA and number of bytes to transfer
DMA1DH   = $4316 ; Data address stored by H-DMA and number of bytes to transfer
DMA1DB   = $4317 ; Data address stored by H-DMA and number of bytes to transfer
DMA1A2L  = $4318 ; A2 Table address
DMA1A2H  = $4319 ; A2 Table address
DMA1NL   = $431A ; Number of lines transfered by H-DMA
DMA2P    = $4320 ; Parameters for DMA 2 transfer
DMA2B    = $4321 ; B-Bus address for DMA 2
DMA2A1L  = $4322 ; A1 Table address
DMA2A1H  = $4323 ; A1 Table address
DMA2ATB  = $4324 ; A Table Bank
DMA2DL   = $4325 ; Data address stored by H-DMA and number of bytes to transfer
DMA2DH   = $4326 ; Data address stored by H-DMA and number of bytes to transfer
DMA2DB   = $4327 ; Data address stored by H-DMA and number of bytes to transfer
DMA2A2L  = $4328 ; A2 Table address
DMA2A2H  = $4329 ; A2 Table address
DMA2NL   = $432A ; Number of lines transfered by H-DMA
DMA3P    = $4330 ; Parameters for DMA 3 transfer
DMA3B    = $4331 ; B-Bus address for DMA 3
DMA3A1L  = $4332 ; A1 Table address
DMA3A1H  = $4333 ; A1 Table address
DMA3ATB  = $4334 ; A Table Bank
DMA3DL   = $4335 ; Data address stored by H-DMA and number of bytes to transfer
DMA3DH   = $4336 ; Data address stored by H-DMA and number of bytes to transfer
DMA3DB   = $4337 ; Data address stored by H-DMA and number of bytes to transfer
DMA3A2L  = $4338 ; A2 Table address
DMA3A2H  = $4339 ; A2 Table address
DMA3NL   = $433A ; Number of lines transfered by H-DMA
DMA4P    = $4340 ; Parameters for DMA 4 transfer
DMA4B    = $4341 ; B-Bus address for DMA 4
DMA4A1L  = $4342 ; A1 Table address
DMA4A1H  = $4343 ; A1 Table address
DMA4ATB  = $4344 ; A Table Bank
DMA4DL   = $4345 ; Data address stored by H-DMA and number of bytes to transfer
DMA4DH   = $4346 ; Data address stored by H-DMA and number of bytes to transfer
DMA4DB   = $4347 ; Data address stored by H-DMA and number of bytes to transfer
DMA4A2L  = $4348 ; A2 Table address
DMA4A2H  = $4349 ; A2 Table address
DMA4NL   = $434A ; Number of lines transfered by H-DMA
DMA5P    = $4350 ; Parameters for DMA 5 transfer
DMA5B    = $4351 ; B-Bus address for DMA 5
DMA5A1L  = $4352 ; A1 Table address
DMA5A1H  = $4353 ; A1 Table address
DMA5ATB  = $4354 ; A Table Bank
DMA5DL   = $4355 ; Data address stored by H-DMA and number of bytes to transfer
DMA5DH   = $4356 ; Data address stored by H-DMA and number of bytes to transfer
DMA5DB   = $4357 ; Data address stored by H-DMA and number of bytes to transfer
DMA5A2L  = $4358 ; A2 Table address
DMA5A2H  = $4359 ; A2 Table address
DMA5NL   = $435A ; Number of lines transfered by H-DMA
DMA6P    = $4360 ; Parameters for DMA 6 transfer
DMA6B    = $4361 ; B-Bus address for DMA 6
DMA6A1L  = $4362 ; A1 Table address
DMA6A1H  = $4363 ; A1 Table address
DMA6ATB  = $4364 ; A Table Bank
DMA6DL   = $4365 ; Data address stored by H-DMA and number of bytes to transfer
DMA6DH   = $4366 ; Data address stored by H-DMA and number of bytes to transfer
DMA6DB   = $4367 ; Data address stored by H-DMA and number of bytes to transfer
DMA6A2L  = $4368 ; A2 Table address
DMA6A2H  = $4369 ; A2 Table address
DMA6NL   = $436A ; Number of lines transfered by H-DMA
DMA7P    = $4370 ; Parameters for DMA 7 transfer (lowest priority)
DMA7B    = $4371 ; B-Bus address for DMA 7
DMA7A1L  = $4372 ; A1 Table address
DMA7A1H  = $4373 ; A1 Table address
DMA7ATB  = $4374 ; A Table Bank
DMA7DL   = $4375 ; Data address stored by H-DMA and number of bytes to transfer
DMA7DH   = $4376 ; Data address stored by H-DMA and number of bytes to transfer
DMA7DB   = $4377 ; Data address stored by H-DMA and number of bytes to transfer
DMA7A2L  = $4378 ; A2 Table address
DMA7A2H  = $4379 ; A2 Table address
DMA7NL   = $437A ; Number of lines transfered by H-DMA
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
