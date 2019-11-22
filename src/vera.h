extern void setDataPort(uint8_t c);
extern void setScreenScale(uint8_t hscale, uint8_t vscale);
extern void cdecl layer0Setup(uint8_t modeenable, uint8_t map_size, int16_t map_base, int16_t font, int16_t hscroll, int16_t vscroll);
extern void cdecl layer1Setup(uint8_t modeenable, uint8_t map_size, int16_t map_base, int16_t font, int16_t hscroll, int16_t vscroll);

#define FONT_ASCII		0x7a00		// iso ascii font
#define FONT_UPETSCII	0x7c00		// PETSCII uppercase
#define FONT_LPETSCII	0x7e00		// PETSCII lowercase
#define L0_MAP_BASE		0x0000
#define L1_MAP_BASE		0x1000