"""Draws the app icon: a floating island hanging on a golden thread.

Run: python3 tool/draw_icon.py  (needs Pillow). Writes assets/branding/*.png.
"""
import math
from PIL import Image, ImageDraw, ImageFilter

S = 1024
SS = 4  # supersampling for smooth edges
W = S * SS


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def background():
    img = Image.new('RGBA', (W, W))
    d = ImageDraw.Draw(img)
    top, mid, bottom = (14, 18, 54), (35, 42, 107), (141, 120, 200)
    for y in range(W):
        t = y / W
        c = lerp(top, mid, t / 0.6) if t < 0.6 else lerp(mid, bottom, (t - 0.6) / 0.4)
        d.line([(0, y), (W, y)], fill=c + (255,))
    return img


def foreground(scale=1.0):
    """Island, thread and glowing node on transparency, centred."""
    img = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    glow = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    g = ImageDraw.Draw(glow)
    cx, cy = W / 2, W * 0.56
    w = W * 0.52 * scale
    h = w * 0.2
    gold = (242, 196, 109, 255)
    # Thread from the top edge down to the node.
    node = (cx, cy - h * 0.55)
    d.line([(cx, 0), node], fill=(255, 227, 163, 255), width=int(W * 0.012 * scale))
    # Underside: inverted cone.
    under = [(cx - w / 2, cy), (cx - w * 0.28, cy + w * 0.33), (cx - w * 0.03, cy + w * 0.62),
             (cx + w * 0.02, cy + w * 0.64), (cx + w * 0.3, cy + w * 0.3), (cx + w / 2, cy)]
    d.polygon(under, fill=(42, 36, 99, 255))
    d.polygon([(cx - w * 0.12, cy + w * 0.1), (cx + w * 0.18, cy + w * 0.1), (cx + w * 0.02, cy + w * 0.64), (cx - w * 0.03, cy + w * 0.62)],
              fill=(58, 50, 128, 255))
    # Pastel top.
    d.ellipse([cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2], fill=(217, 207, 242, 255))
    # Glowing node.
    r = W * 0.055 * scale
    g.ellipse([node[0] - r * 2.6, node[1] - r * 2.6, node[0] + r * 2.6, node[1] + r * 2.6], fill=(242, 196, 109, 150))
    glow = glow.filter(ImageFilter.GaussianBlur(W * 0.03))
    d.ellipse([node[0] - r, node[1] - r, node[0] + r, node[1] + r], fill=gold)
    d.ellipse([node[0] - r * 0.45, node[1] - r * 0.45, node[0] + r * 0.45, node[1] + r * 0.45], fill=(255, 246, 220, 255))
    return Image.alpha_composite(glow, img)


def stars(img):
    d = ImageDraw.Draw(img)
    pts = [(0.16, 0.18), (0.8, 0.14), (0.27, 0.38), (0.86, 0.42), (0.12, 0.62), (0.68, 0.27), (0.42, 0.12)]
    for i, (x, y) in enumerate(pts):
        r = W * (0.006 + 0.003 * (i % 3))
        d.ellipse([x * W - r, y * W - r, x * W + r, y * W + r], fill=(255, 255, 255, 200))
    return img


def save(img, name):
    img.resize((S, S), Image.LANCZOS).save(f'assets/branding/{name}')


full = stars(background())
save(Image.alpha_composite(full, foreground()), 'icon.png')
save(full, 'icon_background.png')
# Adaptive-icon foreground must keep its art inside the central safe zone.
save(foreground(scale=0.72), 'icon_foreground.png')
# Splash mark: smaller art on transparency.
save(foreground(scale=0.8), 'splash.png')
