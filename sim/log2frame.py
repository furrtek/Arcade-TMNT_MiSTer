# Converts simulation log_video.txt to a full PNG frame
# Shows frame limits (white lines), H and V sync, and timing graph for each line

from PIL import Image, ImageDraw, ImageFont

font = ImageFont.truetype("c:\windows\fonts\cour.ttf", 14)

f = open("log_video.txt", "r")
pixels = f.read().split()
f.close()

img = Image.new("RGB", (800, 280))
draw = ImageDraw.Draw(img)

draw.line((384, 264, 384, 274), fill=(255, 255, 255))
draw.line((384, 264, 394, 264), fill=(255, 255, 255))

for c in range(0, 4):
	x = 400 + c * 100
	draw.text((x, 264), "{:d}%".format(c * 25), (255, 255, 255), font=font)
	draw.line((x, 0, x, 264), fill=(255, 255, 255))

x = 0
y = 0
for pixel in pixels:
	if "T" in pixel:
		# Timing value
		n = int(pixel[1])
		value = int(pixel.split(':')[1], 16)
		#if (n == 1):
			# 2297
			# value = value * 400 / 2297.0
			# draw.line((400, y, 400 + value, y), fill=(255, 255, 255))
		#elif (n == 2):
		if (n == 2):
			value = value * 400 / 2297.0
			draw.line((400, y, 400 + value, y), fill=(0, 255, 0))
	else:
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
				r = ((color >> 10) & 31) << 3
				g = ((color >> 5) & 31) << 3
				b = (color & 31) << 3

			if x < 800 and y < 280:
				img.putpixel((x, y), (r, g, b))
			x += 1

img.save("frame.png")
