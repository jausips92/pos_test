from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


OUT = Path("app_store_screenshots")
FONT = "C:/Windows/Fonts/NotoSansTC-VF.ttf"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    path = "C:/Windows/Fonts/msjhbd.ttc" if bold else FONT
    return ImageFont.truetype(path, size)


def rounded(draw: ImageDraw.ImageDraw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def text(draw: ImageDraw.ImageDraw, xy, value, size, fill="#23211d", bold=False, anchor=None):
    draw.text(xy, value, fill=fill, font=font(size, bold), anchor=anchor)


def wrap(draw: ImageDraw.ImageDraw, value: str, size: int, max_width: int) -> list[str]:
    f = font(size)
    lines: list[str] = []
    current = ""
    for ch in value:
        trial = current + ch
        if draw.textlength(trial, font=f) <= max_width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = ch
    if current:
        lines.append(current)
    return lines


def base(width: int, height: int, title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (width, height), "#f5f2ec")
    draw = ImageDraw.Draw(img)
    margin = int(width * 0.06)
    text(draw, (margin, int(height * 0.052)), "yupos", int(width * 0.065), "#15543d", True)
    text(draw, (margin, int(height * 0.095)), title, int(width * 0.052), "#23211d", True)
    for i, line in enumerate(wrap(draw, subtitle, int(width * 0.027), width - margin * 2)):
        text(draw, (margin, int(height * 0.135) + i * int(width * 0.04)), line, int(width * 0.027), "#736d64")
    return img, draw


def draw_pos(width: int, height: int, name: str):
    img, draw = base(width, height, "快速點餐 POS", "為餐廳現場點餐、結帳與出單設計，商品大按鈕清楚好操作。")
    m = int(width * 0.055)
    top = int(height * 0.205)
    sidebar_w = int(width * 0.15)
    rounded(draw, (m, top, m + sidebar_w, height - m), 18, "#242a25")
    for idx, label in enumerate(["點餐", "商品", "印表機"]):
        y = top + 45 + idx * int(width * 0.13)
        fill = "#f8f1df" if idx == 0 else "#394039"
        txt = "#15543d" if idx == 0 else "#ffffff"
        rounded(draw, (m + 16, y, m + sidebar_w - 16, y + int(width * 0.085)), 14, fill)
        text(draw, (m + sidebar_w / 2, y + int(width * 0.043)), label, int(width * 0.024), txt, True, "mm")
    x = m + sidebar_w + int(width * 0.035)
    y = top
    w = width - x - m
    cart_w = int(w * 0.36)
    grid_w = w - cart_w - int(width * 0.025)
    rounded(draw, (x, y, x + grid_w, height - m), 18, "#fffdfa", "#ded7cb", 3)
    text(draw, (x + 32, y + 36), "熱門品項", int(width * 0.035), bold=True)
    products = [("雞腿便當", "$120"), ("滷肉飯", "$55"), ("紅茶", "$30"), ("燙青菜", "$40"), ("荷包蛋", "$15"), ("湯品", "$35")]
    cols = 2 if width < 1600 else 3
    gap = 20
    card_w = (grid_w - 64 - gap * (cols - 1)) // cols
    card_h = int(width * 0.18)
    for i, (p, price) in enumerate(products):
        cx = x + 32 + (i % cols) * (card_w + gap)
        cy = y + 105 + (i // cols) * (card_h + gap)
        rounded(draw, (cx, cy, cx + card_w, cy + card_h), 16, "#f9f5ed", "#ded7cb", 2)
        text(draw, (cx + 24, cy + 24), p, int(width * 0.03), bold=True)
        text(draw, (cx + 24, cy + card_h - 54), price, int(width * 0.031), "#15543d", True)
    cx = x + grid_w + int(width * 0.025)
    rounded(draw, (cx, y, cx + cart_w, height - m), 18, "#ebe4d9", "#ded7cb", 3)
    text(draw, (cx + 28, y + 38), "購物車", int(width * 0.034), bold=True)
    text(draw, (cx + cart_w - 28, y + 45), "$230", int(width * 0.04), "#15543d", True, "ra")
    for i, (p, q) in enumerate([("雞腿便當", "x1"), ("紅茶", "x2"), ("荷包蛋", "x1")]):
        ry = y + 120 + i * int(width * 0.095)
        rounded(draw, (cx + 24, ry, cx + cart_w - 24, ry + int(width * 0.075)), 14, "#fffdfa")
        text(draw, (cx + 44, ry + 22), p, int(width * 0.026), bold=True)
        text(draw, (cx + cart_w - 48, ry + 22), q, int(width * 0.026), "#15543d", True, "ra")
    rounded(draw, (cx + 24, height - m - 92, cx + cart_w - 24, height - m - 24), 14, "#217a59")
    text(draw, (cx + cart_w / 2, height - m - 58), "結帳並列印", int(width * 0.026), "#ffffff", True, "mm")
    img.save(OUT / name)


def draw_receipt(width: int, height: int, name: str):
    img, draw = base(width, height, "清楚列印小票", "出單內容包含單號、品項、數量、單價與列印時間，適合廚房與櫃台快速確認。")
    m = int(width * 0.08)
    top = int(height * 0.22)
    paper_w = int(width * 0.56)
    paper_h = int(height * 0.58)
    px = (width - paper_w) // 2
    rounded(draw, (px, top, px + paper_w, top + paper_h), 8, "#ffffff", "#ded7cb", 2)
    line = "#23211d"
    text(draw, (px + paper_w // 2, top + 72), "單號:2606010005", int(width * 0.038), line, True, "mm")
    draw.line((px + 60, top + 120, px + paper_w - 60, top + 120), fill=line, width=3)
    text(draw, (px + 80, top + 175), "品項", int(width * 0.032), line, True)
    text(draw, (px + paper_w - 240, top + 175), "數量", int(width * 0.032), line, True)
    text(draw, (px + paper_w - 110, top + 175), "單價", int(width * 0.032), line, True)
    rows = [("雞腿便當", "x1", "120"), ("紅茶", "x2", "30"), ("荷包蛋", "x1", "15")]
    for i, (p, q, price) in enumerate(rows):
        y = top + 255 + i * int(width * 0.09)
        text(draw, (px + 80, y), p, int(width * 0.044), line, True)
        text(draw, (px + paper_w - 220, y), q, int(width * 0.044), line, True)
        text(draw, (px + paper_w - 60, y), price, int(width * 0.044), line, True, "ra")
    draw.line((px + 60, top + paper_h - 150, px + paper_w - 60, top + paper_h - 150), fill=line, width=3)
    text(draw, (px + paper_w // 2, top + paper_h - 92), "列印時間:2026-06-01 22:15:00", int(width * 0.026), line, True, "mm")
    rounded(draw, (m, height - int(height * 0.16), width - m, height - int(height * 0.085)), 18, "#217a59")
    text(draw, (width // 2, height - int(height * 0.122)), "支援網路熱感印表機", int(width * 0.032), "#ffffff", True, "mm")
    img.save(OUT / name)


def draw_admin(width: int, height: int, name: str):
    img, draw = base(width, height, "商品與印表機管理", "在同一台 iPad 管理分類、品項、價格與印表機 IP，維持店內流程簡單穩定。")
    m = int(width * 0.06)
    top = int(height * 0.22)
    panel_h = int(height * 0.58)
    gap = int(width * 0.035)
    left_w = (width - m * 2 - gap) // 2
    right_w = left_w
    rounded(draw, (m, top, m + left_w, top + panel_h), 18, "#fffdfa", "#ded7cb", 3)
    text(draw, (m + 36, top + 44), "商品管理", int(width * 0.035), bold=True)
    items = [("分類", "便當 / 飲料 / 加點"), ("雞腿便當", "$120"), ("紅茶", "$30"), ("荷包蛋", "$15")]
    for i, (a, b) in enumerate(items):
        y = top + 115 + i * int(width * 0.09)
        rounded(draw, (m + 32, y, m + left_w - 32, y + int(width * 0.067)), 12, "#f9f5ed", "#ded7cb", 2)
        text(draw, (m + 55, y + 22), a, int(width * 0.026), bold=True)
        text(draw, (m + left_w - 55, y + 22), b, int(width * 0.024), "#736d64", True, "ra")
    rx = m + left_w + gap
    rounded(draw, (rx, top, rx + right_w, top + panel_h), 18, "#fffdfa", "#ded7cb", 3)
    text(draw, (rx + 36, top + 44), "印表機設定", int(width * 0.035), bold=True)
    rounded(draw, (rx + 36, top + 125, rx + right_w - 36, top + 205), 12, "#ffffff", "#ded7cb", 2)
    text(draw, (rx + 58, top + 150), "Printer IP", int(width * 0.022), "#736d64", True)
    text(draw, (rx + 58, top + 182), "192.168.1.120", int(width * 0.026), bold=True)
    rounded(draw, (rx + 36, top + 235, rx + right_w - 36, top + 315), 12, "#ffffff", "#ded7cb", 2)
    text(draw, (rx + 58, top + 260), "Port", int(width * 0.022), "#736d64", True)
    text(draw, (rx + 58, top + 292), "9100", int(width * 0.026), bold=True)
    rounded(draw, (rx + 36, top + 365, rx + right_w - 36, top + 440), 14, "#217a59")
    text(draw, (rx + right_w / 2, top + 403), "儲存設定", int(width * 0.026), "#ffffff", True, "mm")
    img.save(OUT / name)


def main():
    OUT.mkdir(exist_ok=True)
    for prefix, width, height in [("iphone_65", 1242, 2688), ("ipad_129", 2048, 2732)]:
        draw_pos(width, height, f"{prefix}_01_order.png")
        draw_receipt(width, height, f"{prefix}_02_receipt.png")
        draw_admin(width, height, f"{prefix}_03_admin.png")


if __name__ == "__main__":
    main()
