extern void setDataPort(uint8_t c);
extern void setScreenScale(uint8_t hscale, uint8_t vscale);
extern void cdecl layer0Setup(uint8_t modeenable, uint8_t map_size, int16_t map_base, int16_t font, int16_t hscroll, int16_t vscroll);
extern void cdecl layer1Setup(uint8_t modeenable, uint8_t map_size, int16_t map_base, int16_t font, int16_t hscroll, int16_t vscroll);
extern void cdecl copyData();  //This is temporary, need to create a real function here.  For now it will just trigger a local copy.

#define FONT_ASCII		0x1E800		// iso ascii font
#define FONT_UPETSCII	0x1F000		// PETSCII uppercase
#define FONT_LPETSCII	0x1F800		// PETSCII lowercase
#define L0_MAP_BASE		0x00000
#define L1_MAP_BASE		0x04000

	// Not sure why these are shifted left 2 bits?
	//FONT_ASCII	= $1E800		; Font definition #1 : iso ascii font
	//FONT_UPETSCII	= $1F000		; Font definition #2 : PETSCII uppercase
	//FONT_LPETSCII	= $1F800		; Font definition #3 : PETSCII lowercase