from shutil import copy

f_in = open("../roms/963-x23.j17", "rb")	# 68k high 1
ba_high = bytes(f_in.read())
f_in.close()

f_in = open("../roms/963-x21.j15", "rb")	# 68k high 2
ba_high += bytes(f_in.read())
f_in.close()

f_in = open("../roms/963-x24.k17", "rb")	# 68k low 1
ba_low = bytes(f_in.read())
f_in.close()

f_in = open("../roms/963-x22.k15", "rb")	# 68k low 2
ba_low += bytes(f_in.read())
f_in.close()

f_out = open("../roms/rom_68k.bin", "wb")	# Interleave
for c in range(0, len(ba_low)):
	f_out.write(bytes([ba_high[c], ba_low[c]]))
f_out.close()

copy("../roms/963e20.g13", "../roms/rom_z80.bin")

f_in = open("../roms/963a29.k27", "rb")		# Tiles high
ba_high = bytes(f_in.read())
f_in.close()

f_in = open("../roms/963a28.h27", "rb")		# Tiles low
ba_low = bytes(f_in.read())
f_in.close()

f_out = open("../roms/rom_tiles.bin", "wb")	# Interleave
for c in range(0, len(ba_high), 2):
	f_out.write(bytes([ba_high[c+1], ba_high[c], ba_low[c+1], ba_low[c]]))
f_out.close()

# Sprites: ROMs possibly in wrong order

f_in = open("../roms/963a15.k4", "rb")		# Sprites high 1
ba_high = bytes(f_in.read())
f_in.close()

f_in = open("../roms/963a16.k6", "rb")		# Sprites high 2
ba_high += bytes(f_in.read())
f_in.close()

f_in = open("../roms/963a17.h4", "rb")		# Sprites low 1
ba_low = bytes(f_in.read())
f_in.close()

f_in = open("../roms/963a18.h6", "rb")		# Sprites low 2
ba_low += bytes(f_in.read())
f_in.close()

f_out = open("../roms/rom_sprites.bin", "wb")	# Interleave
for c in range(0, len(ba_high), 2):
	f_out.write(bytes([ba_high[c+1], ba_high[c], ba_low[c+1], ba_low[c]]))
f_out.close()

copy("../roms/963a30.g7", "../roms/prom_sprdec.bin")
copy("../roms/963a31.g19", "../roms/prom_prio.bin")
copy("../roms/963a26.c13", "../roms/rom_007232.bin")
copy("../roms/963a27.d18", "../roms/rom_7759C.bin")
copy("../roms/963a25.d5", "../roms/rom_theme.bin")
