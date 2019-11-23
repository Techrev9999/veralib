		.import         vset, popa, popax
        .include        "cx16.inc"
;***************************************************
; Constants

	ADDR_INC_0  	= $000000
	ADDR_INC_1  	= $100000
	ADDR_INC_2  	= $200000
	ADDR_INC_4  	= $300000
	ADDR_INC_8  	= $400000
	ADDR_INC_16  	= $500000
	ADDR_INC_32 	= $600000
	ADDR_INC_64  	= $700000
	ADDR_INC_128  	= $800000
	ADDR_INC_256  	= $900000
	ADDR_INC_512  	= $A00000
	ADDR_INC_1024  	= $B00000
	ADDR_INC_2048  	= $C00000
	ADDR_INC_4096  	= $D00000
	ADDR_INC_8192  	= $E00000
	ADDR_INC_16384 	= $F00000

;***************************************************
;	VERA external address space

	VERA_BASE 		= $9F20
	VERA_ADDR_LO  	= VERA_BASE + 0
	VERA_ADDR_MID 	= VERA_BASE + 1
	VERA_ADDR_HI  	= VERA_BASE + 2
	VERA_DATA0		= VERA_BASE + 3
	VERA_DATA1		= VERA_BASE + 4
	VERA_CTRL 	 	= VERA_BASE + 5
	VERA_IEN 	 	= VERA_BASE + 6
	VERA_ISR 	 	= VERA_BASE + 7

;***************************************************
;	VERA internal registers

;	Video RAM
	VRAM_BASE		= $00000

;	Display composer
	DC_BASE			= $F0000
	DC_VIDEO		= DC_BASE + 0
	DC_HSCALE		= DC_BASE + 1
	DC_VSCALE		= DC_BASE + 2
	DC_BORDER_COLOR	= DC_BASE + 3
	DC_HSTART_L		= DC_BASE + 4
	DC_HSTOP_L		= DC_BASE + 5
	DC_VSTART_L		= DC_BASE + 6
	DC_VSTOP_L		= DC_BASE + 7
	DC_STARTSTOP_H	= DC_BASE + 8
	DC_IRQ_LINE_L	= DC_BASE + 9
	DC_IRQ_LINE_H	= DC_BASE + 10

;	Palette
	PALETTE_BASE	= $F1000

;	Layer 0 
	L0_BASE 		= $F2000
	L0_CTRL0		= L0_BASE + 0
	L0_CTRL1		= L0_BASE + 1
	L0_MAP_BASE_L	= L0_BASE + 2
	L0_MAP_BASE_H	= L0_BASE + 3
	L0_TILE_BASE_L	= L0_BASE + 4
	L0_TILE_BASE_H	= L0_BASE + 5
	L0_HSCROLL_L	= L0_BASE + 6
	L0_HSCROLL_H	= L0_BASE + 7
	L0_VSCROLL_L	= L0_BASE + 8
	L0_VSCROLL_H	= L0_BASE + 9

;	Layer 1
	L1_BASE 		= $F3000
	L1_CTRL0		= L1_BASE + 0
	L1_CTRL1		= L1_BASE + 1
	L1_MAP_BASE_L	= L1_BASE + 2
	L1_MAP_BASE_H	= L1_BASE + 3
	L1_TILE_BASE_L	= L1_BASE + 4
	L1_TILE_BASE_H	= L1_BASE + 5
	L1_HSCROLL_L	= L1_BASE + 6
	L1_HSCROLL_H	= L1_BASE + 7
	L1_VSCROLL_L	= L1_BASE + 8
	L1_VSCROLL_H	= L1_BASE + 9

	SCREEN_MEM		= $00000		; start of screen memory

	FONT_ASCII	= $1E800		; Font definition #1 : iso ascii font
	FONT_UPETSCII	= $1F000		; Font definition #2 : PETSCII uppercase
	FONT_LPETSCII	= $1F800		; Font definition #3 : PETSCII lowercase
	PALETTE			= $F1000


.macro VADDR ADDR 
	LDA 	#<(ADDR >> 16)
	STA 	VERA_ADDR_HI
	LDA 	#<(ADDR >> 8)
	STA 	VERA_ADDR_MID
	LDA 	#<(ADDR)
	STA 	VERA_ADDR_LO
.endmacro

.macro VREG ADDR, DATA 
	VADDR	ADDR
	LDA 	#(DATA)
	STA 	VERA_DATA0
.endmacro


.export _setDataPort

.segment    "CODE"
.proc    _setDataPort: near
.segment    "CODE"
.byte $FF
    sta     VERA_CTRL
    rts
.endproc

.export _setScreenScale

.segment    "CODE"
.proc    _setScreenScale: near
.segment "DATA"
	vscale:
		.byte	$00

.segment    "CODE"
.byte $FF
	sta vscale
	VADDR DC_VIDEO
	lda #%00000001  ;select vga mode
	sta VERA_DATA0
	lda vscale
	sta VERA_DATA0	
	jsr popa
	sta VERA_DATA0
    rts
.endproc

.export _layer0Setup

.segment    "CODE"
.proc    _layer0Setup: near

.segment    "DATA"
	hscroll:
		.byte $00, $00
	vscroll:
		.byte $00, $00
	font:
		.byte $00, $00
	map_base:
		.byte $00, $00
	map:
		.byte $00
	enable:
		.byte $00
	mode:
		.byte $00

	.segment	"CODE"
.byte $FF
	sta vscroll
	stx vscroll + 1
	jsr popax
	jsr popax
	sta hscroll
	stx hscroll + 1
	jsr popax
	sta font
	stx font +1
	jsr popax
	sta map_base
	stx map_base + 1
	jsr popax
	sta map
	stx mode

	VADDR L0_CTRL0
	lda mode
	sta VERA_DATA0
	lda map
	sta VERA_DATA0
	lda map_base
	sta VERA_DATA0
	lda map_base + 1
	sta VERA_DATA0
	lda font
	sta VERA_DATA0
	lda font + 1
	sta VERA_DATA0
	lda hscroll
	sta VERA_DATA0
	lda hscroll + 1
	sta VERA_DATA0
	lda vscroll
	sta VERA_DATA0
	lda vscroll + 1
	sta VERA_DATA0
	rts
.endproc

.export _layer1Setup

.segment    "CODE"
.proc    _layer1Setup: near

.segment    "DATA"
	hscroll:
		.byte $00, $00
	vscroll:
		.byte $00, $00
	font:
		.byte $00, $00
	map_base:
		.byte $00, $00
	map:
		.byte $00
	enable:
		.byte $00
	mode:
		.byte $00

	.segment	"CODE"
.byte $FF
	sta vscroll
	stx vscroll + 1
	jsr popax
	jsr popax
	sta hscroll
	stx hscroll + 1
	jsr popax
	sta font
	stx font +1
	jsr popax
	sta map_base
	stx map_base + 1
	jsr popax
	sta map
	stx mode

	VADDR L1_CTRL0
	lda mode
	sta VERA_DATA0
	lda map
	sta VERA_DATA0
	lda map_base
	sta VERA_DATA0
	lda map_base + 1
	sta VERA_DATA0
	lda font
	sta VERA_DATA0
	lda font + 1
	sta VERA_DATA0
	lda hscroll
	sta VERA_DATA0
	lda hscroll + 1
	sta VERA_DATA0
	lda vscroll
	sta VERA_DATA0
	lda vscroll + 1
	sta VERA_DATA0
	rts
.endproc

.export _copyData

.segment    "CODE"
.proc    _copyData: near
.segment    "DATA"
	count:
		.byte  $00
	sourceaddr:
		.word  $0000
.segment    "CODE"
.byte $FF
    ;hard coded for now, but eventually this will be turned into parameters.  Need to get things funcioning before I create extra complexity.
    VADDR PALETTE
    lda #<palette
    sta sourceaddr
    lda #>palette
    sta sourceaddr + 1
    lda #$02   ;number of bytes to copy over high order
    sta count
    ldx #$00   ;number of bytest low order
    beq loophi
looploinit:
	ldy #$00
looplo:
	lda sourceaddr, y		; load A with source + y
	sta VERA_DATA0		; store in data0
	iny
	dex
	bne looplo						; continue if more bytes to xfer

	inc sourceaddr + 1		; increment src(hi) by 1
loophi:
	lda count
	beq fin
	dec count
	bra looploinit
fin:
	VADDR FONT_LPETSCII
    lda #<fonthud
    sta sourceaddr
    lda #>fonthud
    sta sourceaddr + 1
    lda #$08
    sta count
    ldx #$00
    beq loophi2
looploinit2:
	ldy #$00
looplo2:
	lda sourceaddr, y		; load A with source + y
	sta VERA_DATA0		; store in data0
	iny
	dex
	bne looplo2						; continue if more bytes to xfer

	inc sourceaddr + 1		; increment src(hi) by 1
loophi2:
	lda count
	beq fin2
	dec count
	bra looploinit2
fin2:
    rts

.endproc
;#Vera.copyDataToVera palette, Vera.PALETTE, 512
.segment "DATA"
	fonthud:
		.incbin "../res/font-hud.bin"
	palette:	
		.incbin "../res/palette.bin"