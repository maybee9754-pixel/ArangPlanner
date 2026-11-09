#!/usr/bin/env python3
"""Independent visual skin for ArangPlanner v1.2.0.
Generate visually identical PNG/TGA assets for preview and World of Warcraft.
Requires Pillow. UI elements themselves remain clickable Lua frames.
"""
from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path
import sys, math

destination=Path(sys.argv[1] if len(sys.argv)>1 else "ArangPlanner/Textures")
destination.mkdir(parents=True,exist_ok=True)

def rgba(hex_color, a=255):
    s=hex_color.lstrip("#")
    return tuple(int(s[i:i+2],16) for i in (0,2,4))+(a,)

def save(name,im):
    im=im.convert("RGBA")
    im.save(destination/(name+".tga"),format="TGA")
    im.save(destination/(name+".png"),format="PNG",optimize=True)
    print("generated:",name,im.size)

def face(name,w,h,top,bottom,outline,glow_strength=0,hot=False):
    im=Image.new("RGBA",(w,h))
    px=im.load()
    for y in range(h):
        t=y/max(1,h-1)
        halo=max(0.0,1.0-abs(y-h*.06)/(h*.33))
        for x in range(w):
            centre=max(0,1-abs(x-w*.31)/(w*.75))
            shimmer=halo*centre*(12 if not hot else 21)
            rgb=[round(top[k]*(1-t)+bottom[k]*t+shimmer) for k in range(3)]
            px[x,y]=tuple(min(255,max(0,z)) for z in rgb)+(255,)
    base=Image.new("RGBA",(w,h))
    if glow_strength:
        g=Image.new("RGBA",(w,h),(0,0,0,0))
        dg=ImageDraw.Draw(g)
        dg.rounded_rectangle((7,7,w-8,h-8),radius=min(h//4,16),
            outline=(151,106,207,glow_strength),width=6)
        base.alpha_composite(g.filter(ImageFilter.GaussianBlur(10)))
    base.alpha_composite(im)
    d=ImageDraw.Draw(base)
    d.rectangle((0,0,w-1,h-1),outline=outline,width=2)
    d.line((6,4,w-7,4),fill=(195,157,227,125 if hot else 67),width=2)
    d.line((8,7,w-9,7),fill=(172,125,226,78 if hot else 35),width=1)
    if hot:
        d.line((7,h-4,w-8,h-4),fill=(218,170,249,205),width=2)
        d.line((8,h-8,w-9,h-8),fill=(143,92,200,72),width=3)
    save(name,base)

# Scaled independently by the game, never used as a screenshot/background with baked-in text.
face("header",1024,128,(40,35,53),(18,18,28),(114,93,138,218),16)
face("panel-header",512,64,(47,42,58),(26,25,37),(87,75,108,200),4)
face("panel-body",512,512,(24,24,36),(13,14,23),(63,58,79,160))
face("button-idle",256,64,(49,47,60),(28,29,43),(82,77,98,208))
face("button-active",256,64,(100,69,129),(60,38,87),(164,120,196,242),25,True)
face("button-hover",256,64,(116,89,143),(66,48,91),(184,146,217,255),34,True)
face("row",512,64,(38,36,49),(22,23,36),(76,71,95,170))
face("row-hover",512,64,(63,49,79),(37,31,54),(145,106,172,225),5)
