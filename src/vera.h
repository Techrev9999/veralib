extern void setDataPort(uint8_t c);
extern void setScreenScale(uint8_t hscale, uint8_t vscale);
extern uint8_t cdecl layerSetup(uint8_t layer, uint8_t mode, uint8_t enable, uint8_t map_size, int32_t map_base, int32_t font, int16_t hscroll, int16_t vscroll);

#define FONT_ASCII		0x1E800		// iso ascii font
#define FONT_UPETSCII	0x1F000		// PETSCII uppercase
#define FONT_LPETSCII	0x1F800		// PETSCII lowercase
#define L0_MAP_BASE		0x00000
#define L1_MAP_BASE		0x04000