from PIL import Image, ImageDraw, ImageFont
import sys
txt=open(sys.argv[1]).read().rstrip().split("\n")
f=ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",15)
w=max(len(l) for l in txt)*9+30; h=len(txt)*20+30
im=Image.new("RGB",(w,h),(30,30,30)); d=ImageDraw.Draw(im)
for i,l in enumerate(txt):
    c=(120,220,120) if l.startswith("$") else (255,215,0) if "FLAG" in l or "flag is" in l else (220,220,220)
    d.text((15,15+i*20),l,font=f,fill=c)
im.save(sys.argv[2])
