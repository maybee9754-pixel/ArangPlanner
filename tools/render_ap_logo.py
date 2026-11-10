#!/usr/bin/env python3
"""Original AP monogram, built from geometric paths for PNG/TGA shared use."""
from PIL import Image,ImageDraw
from pathlib import Path
root=Path(__file__).resolve().parents[1]
size=256
im=Image.new("RGBA",(size,size),(0,0,0,0))
d=ImageDraw.Draw(im)
gold=(212,175,55,255)
dark=(16,16,20,255)
# Rounded, asymmetric AP ligature approximating approved #8 concept.
d.arc((21,18,234,231),35,315,fill=gold,width=13)
d.line([(49,206),(116,50),(175,175)],fill=gold,width=25,joint="curve")
d.polygon([(116,52),(96,95),(136,95)],fill=gold)
d.line([(107,156),(183,156)],fill=gold,width=24)
d.arc((123,83,215,166),270,90,fill=gold,width=25)
d.line([(137,91),(176,91)],fill=gold,width=25)
d.line([(163,164),(163,207)],fill=gold,width=24)
d.ellipse((172,96,201,127),fill=dark)
# Keep transparent outside glyph for button/logo use.
out=root/"ArangPlanner"/"Textures"
out.mkdir(parents=True,exist_ok=True)
im.save(out/"ap-logo.tga")
web=root/"docs"/"assets"
web.mkdir(parents=True,exist_ok=True)
im.save(web/"ap-logo.png")
print("AP logo emitted",out/"ap-logo.tga",web/"ap-logo.png")
