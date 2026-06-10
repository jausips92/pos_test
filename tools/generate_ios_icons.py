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
    img = Image.new("RGB", (size, size), "#080604")
    draw = ImageDraw.Draw(img)

    for y in range(size):
        ratio = y / max(1, size - 1)
        r = int(6 + 18 * ratio)
        g = int(5 + 9 * ratio)
        b = int(4 + 3 * ratio)
        draw.line((0, y, size, y), fill=(r, g, b))

    gold = "#f5c338"
    dark_gold = "#a56f16"
    margin = int(size * 0.09)
    for inset, width, color in (
        (margin, max(2, int(size * 0.013)), gold),
        (int(size * 0.125), max(1, int(size * 0.004)), dark_gold),
    ):
        draw.ellipse(
            (inset, inset, size - inset, size - inset),
            outline=color,
            width=width,
        )

    f = font(max(18, int(size * 0.245)), True)
    chars = "湖南味"
    bboxes = [draw.textbbox((0, 0), ch, font=f) for ch in chars]
    widths = [box[2] - box[0] for box in bboxes]
    heights = [box[3] - box[1] for box in bboxes]
    gap = int(size * 0.035)
    total_height = sum(heights) + gap * (len(chars) - 1)
    y = (size - total_height) / 2 - size * 0.01

    for ch, box, tw, th in zip(chars, bboxes, widths, heights):
        x = (size - tw) / 2 - box[0]
        draw.text((x + size * 0.01, y - box[1] + size * 0.012), ch, font=f, fill="#5a3308")
        draw.text((x, y - box[1]), ch, font=f, fill=gold)
        y += th + gap

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
