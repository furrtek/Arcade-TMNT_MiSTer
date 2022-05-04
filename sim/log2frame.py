# Converts simulation log_video.txt from TMNT to a full PNG frame
# Shows frame limits (white lines), H and V sync for each line

from PIL import Image, ImageDraw

f = open("log_video.txt", "r")
pixels = f.read().split()
f.close()

img = Image.new("RGB", (400, 280))
draw = ImageDraw.Draw(img)

draw.line((384, 264, 384, 274), fill=(255, 255, 255))
draw.line((384, 264, 394, 264), fill=(255, 255, 255))

x = 0
y = 0
for pixel in pixels:
	# Pixel or sync
	if pixel == "L":
		x = 0				# New line
		y += 1
	elif pixel == "V":
		print("Frame done")
	else:
		if "x" in pixel or "z" in pixel:
			r = 255			# Undefined value
			g = 0
			b = 255
		elif pixel == "N":
			r = 63			# Blanking
			g = 63
			b = 63
		elif pixel == "HS":
			r = 63			# Horizontal sync
			g = 127
			b = 63
		elif pixel == "VS":
			r = 127			# Vertical sync
			g = 63
			b = 63
		elif pixel == "XS":
			r = 127			# Both H and V sync
			g = 127
			b = 63
		else:
			color = int(pixel, 16)
			r = ((color >> 12) & 63) << 2
			g = ((color >> 6) & 63) << 2
			b = (color & 63) << 2

		if x < 400 and y < 280:
			img.putpixel((x, y), (r, g, b))
		x += 1

img.save("frame.png")
