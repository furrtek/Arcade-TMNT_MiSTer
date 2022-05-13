#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <unistd.h>

// This tool outputs verilog memory initialization files from a MAME savestate
// Part of the TMNT FPGA project
// Last mod: furrtek 05/2022

#define HEADER_LENGTH 	32
#define VRAM_SPR_START	0x7C		// k051960 Sprite Generator m_ram (0x400) - Do we need to extract m_spriterombank and others ?
#define VRAM_BG_BANKS	0x48F		// k052109 registers 1D80 and 1F00 as 4 nibbles, used for mapping COL[3:2] to {CAB, COL[3:2]}
#define VRAM_BG_START	0x4A5		// k052109 Tilemap Generator m_ram (0x4000) - Do we need to extract m_charrombank, m_scrollctrl and others ?
#define PALETTES_START	0x8C48E		// Palette (0x1000)

int main(int argc, char *argv[]) {
	unsigned int line = 0;
	unsigned short int pixel;
	unsigned long int ng_color;
	char rd[8];
	FILE * file_ptr;
	char * in_buffer;
	unsigned long int in_size;
	
	if (argc != 2) {
		puts("usage: sta2verilog input.sta\n");
		return 1;
	}
	
	file_ptr = fopen(argv[1], "rb");
	if (file_ptr == NULL)
		return 1;
	fseek(file_ptr, 0, SEEK_END);
	in_size = ftell(file_ptr);
	rewind(file_ptr);
	
	in_buffer = (char*)malloc(in_size);
	
	fread(in_buffer, 1, in_size, file_ptr);
	fclose(file_ptr);
	
	//printf("In: %lu\nOut: %lu\n", in_size, in_size - HEADER_LENGTH);
	
	// Remove MAME header
	file_ptr = fopen("sta_raw.bin", "wb");
	fwrite(in_buffer + HEADER_LENGTH, 1, in_size - HEADER_LENGTH, file_ptr);
	fclose(file_ptr);
	
	// Unzip data
	remove("sta_raw_unpack.bin");
	system("offzip sta_raw.bin");
	remove("sta_raw.bin");
	
	file_ptr = fopen("sta_raw_unpack.bin", "rb");
	fseek(file_ptr, 0, SEEK_END);
	in_size = ftell(file_ptr);
	rewind(file_ptr);
	
	free(in_buffer);
	in_buffer = (char*)malloc(in_size);

	fread(in_buffer, in_size, 1, file_ptr);
	fclose(file_ptr);
	
	file_ptr = fopen("vram_spr.bin", "wb");
	fwrite(in_buffer + VRAM_SPR_START, 0x400, 1, file_ptr);
	fclose(file_ptr);
	
	file_ptr = fopen("vram_bg_banks.bin", "wb");
	fwrite(in_buffer + VRAM_BG_BANKS, 0x4, 1, file_ptr);
	fclose(file_ptr);
	
	file_ptr = fopen("vram_bg_L.bin", "wb");
	fwrite(in_buffer + VRAM_BG_START, 0x2000, 1, file_ptr);
	fclose(file_ptr);
	file_ptr = fopen("vram_bg_U.bin", "wb");
	fwrite(in_buffer + VRAM_BG_START + 0x2000, 0x2000, 1, file_ptr);
	fclose(file_ptr);
	
	file_ptr = fopen("palettes.bin", "wb");
	fwrite(in_buffer + PALETTES_START, 0x1000, 1, file_ptr);
	fclose(file_ptr);

	free(in_buffer);
	
	printf("Done.");
	
	return 0;
}

