"""OCR a PNG read from stdin with RapidOCR; print the text, one line per visual row."""
import io
import sys

from PIL import Image, ImageOps
from rapidocr import RapidOCR

img = Image.open(io.BytesIO(sys.stdin.buffer.read())).convert("RGB")
img = ImageOps.expand(img, 40, fill=img.getpixel((0, 0)))
out = RapidOCR(params={"Global.log_level": "error"})(img)
if not out.txts:
    sys.exit(0)

boxes = []
for box, txt in zip(out.boxes, out.txts):
    ys = [p[1] for p in box]
    boxes.append((min(ys), max(ys), min(p[0] for p in box), txt))
boxes.sort()

rows = []
for top, bottom, left, txt in boxes:
    mid = (top + bottom) / 2
    if rows and rows[-1]["top"] <= mid <= rows[-1]["bottom"]:
        rows[-1]["items"].append((left, txt))
    else:
        rows.append({"top": top, "bottom": bottom, "items": [(left, txt)]})

print("\n".join(" ".join(t for _, t in sorted(r["items"])) for r in rows))
