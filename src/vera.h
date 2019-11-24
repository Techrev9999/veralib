extern void setDataPort(uint8_t c);
extern void setScreenScale(uint8_t hscale, uint8_t vscale);
extern void layer0Setup(uint8_t modeenable, uint8_t mapSize, int16_t mapBase, int16_t font, int16_t hscroll, int16_t vscroll);
extern void layer1Setup(uint8_t modeenable, uint8_t mapSize, int16_t mapBase, int16_t font, int16_t hscroll, int16_t vscroll);
extern void copyData();  //This is temporary, need to create a real function here.  For now it will just trigger a local copy.
extern void fillWindow(uint8_t numCols, uint8_t startCol, uint8_t startRow, uint8_t wdth, uint8_t hght, uint8_t chr, uint8_t clr, uint32_t layerMap);  //, uint8_t numCols, uint8_t startCol, uint8_t startRow, uint8_t width, uint8_t height, uint8_t char, uint8_t color

#define FONT_ASCII		0x1E800		// iso ascii font
#define FONT_UPETSCII	0x1F000		// PETSCII uppercase
#define FONT_LPETSCII	0x1F800		// PETSCII lowercase
#define L0_MAP_BASE1		0x00000
#define L1_MAP_BASE1		0x04000		//0x04000
#define L0_MAP_BASE		0x100000
#define L1_MAP_BASE		0x104000	// Need to add stride to code and remove from addresses.

	// Not sure why these are shifted left 2 bits?
	//FONT_ASCII	= $1E800		; Font definition #1 : iso ascii font
	//FONT_UPETSCII	= $1F000		; Font definition #2 : PETSCII uppercase
	//FONT_LPETSCII	= $1F800		; Font definition #3 : PETSCII lowercase