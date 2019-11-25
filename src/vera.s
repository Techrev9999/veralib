		.import         vset, popa, popax		; Import the functions we need to pull data from the stack.
        .include        "cx16.inc"				; This is a necessary include file, for some basic functionality we need.
        .include		"zeropage.inc"			; This gives us some nice functionality when it comes to zeropage addressing.

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


;	Display composer
	DC_VIDEO			= $F0000

;	Layer 0 Addresses
	L0_BASE 		= $F2000
	L0_CTRL0		= L0_BASE + 0
	L0_CTRL1		= L0_BASE + 1

;	Layer 1 Addresses
	L1_BASE 		= $F3000
	L1_CTRL0		= L1_BASE + 0
	L1_CTRL1		= L1_BASE + 1


	FONT_ASCII		= $1E800		; Font definition #1 : iso ascii font      --  These 4 definitions are here temporarily, until I
	FONT_UPETSCII	= $1F000		; Font definition #2 : PETSCII uppercase   --  fix the copy data function.
	FONT_LPETSCII	= $1F800		; Font definition #3 : PETSCII lowercase
	PALETTE			= $F1000


.macro VADDR ADDR 					; This macro will take an address passed to it, add the stride value, and send it to Vera.
	LDA 	#<(ADDR >> 16)			; The stride value is added to the first 4 bits of the 24 bit address.
	ORA		stride					; So, if you have a stride of 1, and the address is $F0000, what will be sent to Vera
	STA 	VERA_ADDR_HI			; will be $1F0000.
	LDA 	#<(ADDR >> 8)			; The stride must be added to all Vera addressing.
	STA 	VERA_ADDR_MID
	LDA 	#<(ADDR)
	STA 	VERA_ADDR_LO
.endmacro

.segment "ZEROPAGE"					; I use a global zero page address for the stride variable, since it must be available
	stride:							; to almost all Vera functions.
		.byte $00

.export _setDataPort				; This function I use to set up the Vera Dataport, and set the global stride variable.
									; I, currently, don't know of a reason why the stride would change after initialization.
.segment    "CODE"					; If I find one, I will change this system.
.proc    _setDataPort: near
.segment    "CODE"
;.byte $FF
    sta     VERA_CTRL				; Since we are using fastcall parameter passing from C, by default, the first parameter
    jsr popa  						; comes in A by default.  We, then, pop the next value off the stack, which is the stride.
    asl  							; I shift the stride value left 4 bits, which allows me to easily or it with the high byte
    asl 							; of the 24 bit Vera addresses we will be using in later functions.
    asl
    asl
    sta stride
    rts
.endproc

.export _setScreenScale				; This function sets the Vera screen scale.

.segment    "CODE"
.proc    _setScreenScale: near
.segment "DATA"
	vscale:
		.byte	$00					; I set up local variables to hold data I pop from the stack, so I can use it more effectively.

.segment    "CODE"
;.byte $FF
	sta vscale
	VADDR DC_VIDEO					; An example of passing a 24 bit address to Vera using VADDR.  This one is for video configurations.
	lda #%00000001  				; select vga mode, this may need to be parameterized (probably).
	sta VERA_DATA0
	lda vscale
	sta VERA_DATA0	
	jsr popa 						; Popping another parameter off the stack.
	sta VERA_DATA0
    rts
.endproc

.export _layer0Setup				; Layer0Setup for setting up the Layer 0 configuration options.

.segment    "CODE"
.proc    _layer0Setup: near

.segment    "DATA"
	hscroll: 						; More variables for Layer0Setup
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
	jsr popax				; popax lets me pop 2 bytes off the stack at once.  One goes in A, the other in X.  It helps speed things up.
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

.export _layer1Setup			;Layer1Setup.  Layer 1 configuration options.

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

.export _copyData				;This is copydata, it is currently a hack, and needs to be rewritten.

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
.export _fillWindow   ; fillWindow for placing different sized rectangles on the screen.

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
	sta 	VERA_ADDR_LO				; By default, with fastcall, if the first variable is more than 16 bits, the high order bits
	stx 	VERA_ADDR_MID 				; in a 24 bit addresswill be in sreg.  This is a zeropage register, and is why we include 
	lda sreg 							; zeropage.inc.
	ORA stride 
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
	inc
	sta numCols

	cmp #$21
	beq jumpa
	cmp #$41
	beq jumpb
	;cmp 128
	;beq jumpc
	;cmp 256
	;beq jumpd
jumpa:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr32
	jmp jumpc
jumpb:
	lda startRow
	ldx startCol
	jsr AddCwRowColToVAddr64
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
;.byte $FF
		clc
		lda numCols
		sbc width
		asl a
		jsr Add_A_ToVAddr
		bra jumpd
fin:
		rts
.endproc

.export Add_A_ToVAddr					; The rest of this is pretty much about finding the location in video memory
										; to place the characters in, and placing them.
.segment    "CODE"						; I will, probably, create other functions that use different methods to
.proc    Add_A_ToVAddr: near 			; display tiles and graphics information.  It's a bit messy, but it works.
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
;.byte $FF
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
fin:
		lda startCol
		jsr AddCwColToVAddr
		rts
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
;.byte $FF
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
fin:
		lda startCol
		jsr AddCwColToVAddr
		rts
.endproc

.export AddCwRowColToVAddr128

.segment    "CODE"
.proc    AddCwRowColToVAddr128: near
.segment 	"DATA"
	startRow:
		.byte $00	
	startCol:
		.byte $00
.segment    "CODE"
;.byte $FF
		sta startRow
		stx startCol
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		lda startCol
		jsr AddCwColToVAddr
		rts
.endproc

.export AddCwRowColToVAddr256

.segment    "CODE"
.proc    AddCwRowColToVAddr256: near
.segment 	"DATA"
	startRow:
		.byte $00	
	startCol:
		.byte $00
.segment    "CODE"
;.byte $FF
		sta startRow
		stx startCol
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc loopa
		inc VERA_ADDR_HI
loopa:
		lda startRow
		clc
		adc VERA_ADDR_MID
		sta VERA_ADDR_MID
		bcc fin
		inc VERA_ADDR_HI
fin:
		lda startCol
		jsr AddCwColToVAddr
		rts
.endproc

; Still to add for the short term are the fillChar functions, and 128 bit and 256 bit functionality.


; This belongs in the C-Code, and passed here.  Moving this out of the library is one of my next tasks.
; Anything that is specific to a game or program should not be in the library at all.  Unless I add a
; default font and palette here that can be overwritten or something.

.segment "DATA"
	fonthud:
		.incbin "../res/font-hud.bin"
	palette:	
		.incbin "../res/palette.bin"