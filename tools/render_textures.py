#!/usr/bin/env python3
"""Generate one shared art set for WoW TGA textures and web PNG previews.
Only Pillow is required. Deterministic output with no external asset downloads.
Usage: python tools/render_textures.py [output_dir]
"""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import math
import sys

out = Path(sys.argv[1] if len(sys.argv) > 1 else "ArangPlanner/Textures")
out.mkdir(parents=True, exist_ok=True)

def export(img, name):
    img = img.convert("RGBA")
    img.save(out / (name + ".png"), "PNG", optimize=True)
    img.save(out / (name + ".tga"), "TGA")
    print(name, img.size)

def glow(img, base, blur=14):
    overlay = Image.new("RGBA", img.size)
    pen = ImageDraw.Draw(overlay)
    pen.ellipse(base, outline=(158, 91, 246, 120), width=6)
    img.alpha_composite(overlay.filter(ImageFilter.GaussianBlur(blur)))

# Fully opaque interior lets the appearance stay consistent in-game and in web preview.
w = 512
panel = Image.new("RGBA", (w, w))
p = panel.load()
for y in range(w):
    for x in range(w):
        dx = x/w
        dy = y/w
        edge = min(x,y,w-1-x,w-1-y)
        shimmer = max(0, 1-abs(dx-.16)*2.6) * max(0, 1-abs(dy-.05)*1.7)
        tone = int(7*shimmer + 2*(1-dy))
        p[x,y] = (16+tone, 13+tone//2, 26+tone, 251)
draw = ImageDraw.Draw(panel)
draw.rectangle((0,0,w-1,w-1), outline=(111,75,155,112), width=2)
draw.line((4,5,w-6,5),fill=(172,107,232,46),width=2)
draw.line((5,8,5,w-8),fill=(142,95,214,26),width=2)
export(panel,"panel-body")

head = Image.new("RGBA",(512,96))
p=head.load()
for y in range(96):
    for x in range(512):
        fade = 1-y/95
        glowx = max(0, 1-abs(x-78)/320)
        p[x,y]=(28+int(14*fade+7*glowx), 18+int(7*fade+4*glowx), 44+int(18*fade+11*glowx), 252)
d=ImageDraw.Draw(head)
d.rectangle((0,0,511,95),outline=(127,80,184,170),width=2)
d.line((3,3,509,3),fill=(173,109,240,140),width=3)
d.line((3,92,509,92),fill=(88,59,130,110),width=2)
export(head,"panel-header")

size=512
cx=cy=size//2
magic=Image.new("RGBA",(size,size),(0,0,0,0))
glow(magic, (29,29,483,483), 18)
glow(magic, (55,55,457,457), 10)
d=ImageDraw.Draw(magic)
for radius,width,alpha in [(226,3,144),(215,1,95),(193,2,117),(174,1,74),(150,2,100)]:
    d.ellipse((cx-radius,cy-radius,cx+radius,cy+radius),outline=(170,119,255,alpha),width=width)
for i in range(64):
    t=(i/64)*math.tau
    r=222
    a=(cx+math.cos(t)*r,cy+math.sin(t)*r)
    b=(cx+math.cos(t)*(r-(15 if i%4==0 else 6)),cy+math.sin(t)*(r-(15 if i%4==0 else 6)))
    d.line((a,b),fill=(186,143,255,155 if i%4==0 else 66),width=2 if i%4==0 else 1)
# Four interlocking diamonds and small ornamental dots
for rot in [0,math.pi/4]:
    r=148
    corners=[(cx+math.cos(rot+math.pi/2*j)*r,cy+math.sin(rot+math.pi/2*j)*r) for j in range(4)]
    d.line(corners+[corners[0]],fill=(168,117,247,85),width=2)
for i in range(16):
    t=math.tau*i/16
    px,py=cx+math.cos(t)*184,cy+math.sin(t)*184
    r=3 if i%4 else 5
    d.ellipse((px-r,py-r,px+r,py+r),fill=(200,164,255,138))
magic=magic.filter(ImageFilter.GaussianBlur(.35))
export(magic,"arcane-circle")

size=256
ring=Image.new("RGBA",(size,size),(0,0,0,0))
g=Image.new("RGBA",(size,size),(0,0,0,0))
dg=ImageDraw.Draw(g)
dg.arc((21,21,235,235),start=-90,end=360,fill=(163,91,251,135),width=22)
ring.alpha_composite(g.filter(ImageFilter.GaussianBlur(11)))
d=ImageDraw.Draw(ring)
d.arc((25,25,231,231),start=-90,end=270,fill=(66,43,89,230),width=20)
d.arc((25,25,231,231),start=-90,end=-90+259.2,fill=(160,91,248,255),width=20)
d.arc((31,31,225,225),start=-90,end=-90+259.2,fill=(205,164,255,170),width=3)
export(ring,"progress-ring")
