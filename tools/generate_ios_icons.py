from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ICON_DIR = Path("ipad_pos_app/ios/Runner/Assets.xcassets/AppIcon.appiconset")
FONT_BOLD = "C:/Windows/Fonts/msjhbd.ttc"
FONT_REGULAR = "C:/Windows/Fonts/NotoSansTC-VF.ttf"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REGULAR, size)


def icon(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size), "#15543d")
    draw = ImageDraw.Draw(img)

    pad = size * 0.14
    ticket = (pad, size * 0.18, size - pad, size * 0.74)
    radius = max(4, int(size * 0.085))
    draw.rounded_rectangle(ticket, radius=radius, fill="#fffdfa")

    notch_r = size * 0.06
    cy = size * 0.46
    draw.ellipse((pad - notch_r, cy - notch_r, pad + notch_r, cy + notch_r), fill="#15543d")
    draw.ellipse((size - pad - notch_r, cy - notch_r, size - pad + notch_r, cy + notch_r), fill="#15543d")

    line_color = "#217a59"
    for y in (0.31, 0.42, 0.53):
        yy = int(size * y)
        draw.rounded_rectangle((size * 0.27, yy, size * 0.73, yy + max(2, size * 0.018)), radius=max(1, int(size * 0.009)), fill=line_color)

    label = "yupos"
    f = font(max(8, int(size * 0.145)), True)
    bbox = draw.textbbox((0, 0), label, font=f)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text(((size - tw) / 2, size * 0.79 - th / 2), label, font=f, fill="#ffffff")

    return img


def filename_size(name: str, declared_size: str, scale: str) -> int:
    base = float(declared_size.split("x")[0])
    mult = int(scale.replace("x", ""))
    return int(round(base * mult))


def main() -> None:
    contents = json.loads((ICON_DIR / "Contents.json").read_text(encoding="utf-8"))
    for entry in contents["images"]:
        name = entry.get("filename")
        if not name:
            continue
        size = filename_size(name, entry["size"], entry["scale"])
        icon(size).save(ICON_DIR / name)


if __name__ == "__main__":
    main()
