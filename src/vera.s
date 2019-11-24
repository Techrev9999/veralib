		.import         vset, popa, popax
        .include        "cx16.inc"
        .include		"zeropage.inc"
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
	DC_BASE			= $1F0000
	DC_VIDEO		= DC_BASE + 0


;	Layer 0 
	L0_BASE 		= $1F2000
	L0_CTRL0		= L0_BASE + 0
	L0_CTRL1		= L0_BASE + 1

;	Layer 1
	L1_BASE 		= $1F3000
	L1_CTRL0		= L1_BASE + 0
	L1_CTRL1		= L1_BASE + 1


	SCREEN_MEM		= $00000		; start of screen memory

	FONT_ASCII		= $11E800		; Font definition #1 : iso ascii font
	FONT_UPETSCII	= $11F000		; Font definition #2 : PETSCII uppercase
	FONT_LPETSCII	= $11F800		; Font definition #3 : PETSCII lowercase
	PALETTE			= $1F1000


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
;.byte $FF
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
;.byte $FF
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
;.byte $FF
	sta vscroll
	stx vscroll + 1
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
;.byte $FF
	sta vscroll
	stx vscroll + 1
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
.segment "ZEROPAGE"
	sourceaddr:
		.word $0000

.segment    "CODE"
;.byte $FF
    ;hard coded for now, but eventually this will be turned into parameters.  Need to get things funcioning before I create extra complexity.
    VADDR PALETTE
;.byte $FF
    lda #<palette
    sta sourceaddr  
    lda #>palette
    sta sourceaddr +1
    lda #$02   ;number of bytes to copy over high order
    sta count
    ldx #$00   ;number of bytest low order
    beq loophi
looploinit:
	ldy #$00
looplo:
	lda (sourceaddr), y		; load A with source + y
	sta VERA_DATA0		; store in data0
	iny
	dex
	bne looplo						; continue if more bytes to xfer
	inc sourceaddr +1	; increment src(hi) by 1
loophi:
	lda count
	beq fin
	dec count
	bra looploinit
fin:
;.byte $FF
	VADDR FONT_LPETSCII
 ;.byte $FF
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
	lda (sourceaddr), y		; load A with source + y
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
;.byte $FF
    rts
.endproc

;void cdecl fillWindow(uint32_t layerMap, uint8_t numCols, uint8_t startCol, uint8_t startRow, uint8_t width, uint8_t height, uint8_t char, uint8_t color);
.export _fillWindow

.segment    "CODE"
.proc    _fillWindow: near

.segment    "DATA"
	numCols:
		.byte $00
	startCol:
		.byte $00
	startRow:
		.byte $00
	height:
		.byte $00
	width:
		.byte $00
	chr:
		.byte $00
	clr:
		.byte $00

.segment	"CODE"
;.byte $FF
	sta 	VERA_ADDR_LO
	stx 	VERA_ADDR_MID
	lda sreg
	sta 	VERA_ADDR_HI
	jsr popax
	sta clr
	stx chr
	jsr popax
	sta height
	stx width
	jsr popax
	sta startRow
	stx startCol
	jsr popa
	sta numCols

	cmp 32
	beq jumpa
	cmp 64
	beq jumpb
	;cmp 128
	;beq jumpc
	;cmp 256
	;beq jumpd
jumpa:
	lda startRow
	ldx startCol
	AddCwRowColToVAddr32:
	jmp jumpc
jumpb:
	lda startRow
	ldx startCol
	AddCwRowColToVAddr64:
	jmp jumpc
jumpc:
		ldy height						; height counter
jumpd:
		ldx width						; width counter
jumpe:
		lda chr
		sta VERA_DATA0					; store char
		lda clr
		sta VERA_DATA0					; store color
		dex					; dec col count
		bne jumpe
		dey					; dec row count
		beq fin
		lda numCols
		sbc height
		asl a
		jsr Add_A_ToVAddr
		bra jumpd
fin:
		rts
.endproc

.export Add_A_ToVAddr

.segment    "CODE"
.proc    Add_A_ToVAddr: near
		clc
		adc VERA_ADDR_LO
		sta VERA_ADDR_LO
		bcc fin
		lda VERA_ADDR_MID
		adc #0			; carry is already set
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		rts
.endproc

.export AddCwColToVAddr

.segment    "CODE"
.proc    AddCwColToVAddr: near
		;lda cw_col load cw_col in a before calling
		asl a
		clc
		adc VERA_ADDR_LO
		sta VERA_ADDR_LO
		bcc fin
		lda VERA_ADDR_MID
		adc #0			; carry is already set
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		rts
.endproc

.export AddCwRowColToVAddr32

.segment    "CODE"
.proc    AddCwRowColToVAddr32: near
.segment 	"DATA"
	startRow:
		.byte $00	
	startCol:
		.byte $00
.segment    "CODE"
		;lda cw_row call with startRow in a, startCol in x.
		sta startRow
		stx startCol
		asl a
		asl a
		asl a
		asl a
		asl a
		asl a
		clc
		adc VERA_ADDR_LO
		sta VERA_ADDR_LO
		bcc jump
		lda VERA_ADDR_MID
		adc #0
		sta VERA_ADDR_MID
		bcc jump
		lda VERA_ADDR_HI
		adc #0
		sta VERA_ADDR_HI
jump:
		lda startRow
		lsr a
		lsr a
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
		lda startCol
		jsr AddCwColToVAddr
		rts
fin:
.endproc

.export AddCwRowColToVAddr64

.segment    "CODE"
.proc    AddCwRowColToVAddr64: near
.segment 	"DATA"
	startRow:
		.byte $00	
	startCol:
		.byte $00
.segment    "CODE"
		;lda cw_row call with startRow in a, startCol in x.
		sta startRow
		stx startCol
		lsr a
		bcc jump
		lda #$80
		clc
		adc VERA_ADDR_LO
		sta VERA_ADDR_LO
		bcc jump
		lda VERA_ADDR_MID
		adc #0
		sta VERA_ADDR_MID
		bcc jump
		lda VERA_ADDR_HI
		adc #0
		sta VERA_ADDR_HI
jump:
		lda startRow
		lsr a
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
		lda startCol
		jsr AddCwColToVAddr
		rts
fin:
.endproc

;This belongs in the C-Code, and passed here.
.segment "DATA"
	fonthud:
		.incbin "../res/font-hud.bin"
	palette:	
		.incbin "../res/palette.bin"