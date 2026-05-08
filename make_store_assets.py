"""
Generate 512x512 app icons and 1024x500 feature graphics
for each Ireland Visa embassy app.
Output: store_assets/<embassy>/icon_512.png
        store_assets/<embassy>/feature_1024x500.png
"""

from PIL import Image, ImageDraw, ImageFont
import os, math

# â”€â”€ Embassy definitions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

EMBASSIES = [
    {
        "key":      "newdelhi",
        "name":     "New Delhi",
        "country":  "India",
        "cadence":  "Updated daily",
        # India: saffron + navy chakra blue; Ireland: green
        "ireland_color":  (22, 155, 98),
        "country_color":  (255, 153, 51),    # India saffron
        "accent_color":   (0, 56, 168),      # Ashoka Chakra blue
        "stripe_colors":  [(255,153,51),(255,255,255),(19,136,8)],  # IN flag stripes
    },
    {
        "key":      "beijing",
        "name":     "Beijing",
        "country":  "China",
        "cadence":  "Updated daily",
        "ireland_color":  (22, 155, 98),
        "country_color":  (222, 41, 16),     # China red
        "accent_color":   (255, 222, 0),     # China yellow
        "stripe_colors":  [(222,41,16),(222,41,16),(222,41,16)],
    },
    {
        "key":      "abuja",
        "name":     "Abuja",
        "country":  "Nigeria",
        "cadence":  "Updated weekly",
        "ireland_color":  (22, 155, 98),
        "country_color":  (255, 255, 255),   # Nigeria white (green-WHITE-green flag)
        "accent_color":   (0, 135, 81),      # Nigeria green
        "stripe_colors":  [(0,135,81),(255,255,255),(0,135,81)],
    },
    {
        "key":      "abudhabi",
        "name":     "Abu Dhabi",
        "country":  "UAE",
        "cadence":  "Updated weekly",
        "ireland_color":  (22, 155, 98),
        "country_color":  (255, 0, 0),       # UAE red
        "accent_color":   (0, 115, 47),      # UAE green
        "stripe_colors":  [(255,0,0),(255,255,255),(0,115,47)],
    },
    {
        "key":      "ankara",
        "name":     "Ankara",
        "country":  "TÃ¼rkiye",
        "cadence":  "Updated weekly",
        "ireland_color":  (22, 155, 98),
        "country_color":  (227, 10, 23),     # Turkey red
        "accent_color":   (255, 255, 255),
        "stripe_colors":  [(227,10,23),(227,10,23),(227,10,23)],
    },
]

IRELAND_GREEN  = (22, 155, 98)
IRELAND_DARK   = (14, 110, 68)
WHITE          = (255, 255, 255)

try:
    FONT_BOLD = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 1)
    FONT_REG  = ImageFont.truetype("C:/Windows/Fonts/arial.ttf",  1)
    HAS_FONTS = True
except:
    HAS_FONTS = False


def load_font(bold=False, size=24):
    try:
        path = "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf"
        return ImageFont.truetype(path, size)
    except:
        return ImageFont.load_default()


def draw_rounded_rect_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)
    return mask


def draw_document(draw, cx, cy, w, h, bg, fold_color, line_color):
    """Draw a document icon centred at (cx,cy)."""
    x1, y1 = cx - w//2, cy - h//2
    x2, y2 = cx + w//2, cy + h//2
    fold = int(w * 0.28)
    r = int(w * 0.08)
    # body
    draw.rounded_rectangle([x1, y1, x2, y2], radius=r, fill=bg)
    # fold triangle
    tri = [(x2-fold, y1), (x2, y1+fold), (x2-fold, y1+fold)]
    draw.polygon(tri, fill=fold_color)
    # lines
    lx1, lx2 = x1 + int(w*0.18), x2 - int(w*0.18)
    for i, frac in enumerate([0.38, 0.52, 0.64, 0.76]):
        ly = y1 + int(h * frac)
        end = lx2 if i < 2 else lx1 + int((lx2-lx1)*0.65)
        draw.rounded_rectangle([lx1, ly, end, ly+int(h*0.045)], radius=3, fill=line_color)


def draw_checkmark(draw, cx, cy, r, bg_color, check_color):
    """Filled circle with checkmark."""
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=bg_color)
    # inner lighter circle
    ir = int(r * 0.85)
    light = tuple(min(255, c+30) for c in bg_color)
    draw.ellipse([cx-ir, cy-ir, cx+ir, cy+ir], fill=light)
    # checkmark points
    s = int(r * 0.45)
    pts = [(cx-s, cy), (cx-int(s*0.25), cy+int(s*0.85)), (cx+s, cy-int(s*0.85))]
    draw.line([pts[0], pts[1]], fill=check_color, width=max(3, int(r*0.18)))
    draw.line([pts[1], pts[2]], fill=check_color, width=max(3, int(r*0.18)))
    for pt in pts:
        rr = max(2, int(r*0.09))
        draw.ellipse([pt[0]-rr, pt[1]-rr, pt[0]+rr, pt[1]+rr], fill=check_color)


# â”€â”€ Icon generator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

def make_icon(emb, size=512):
    img = Image.new("RGBA", (size, size), (0,0,0,0))
    draw = ImageDraw.Draw(img)

    ic  = emb["ireland_color"]
    cc  = emb["country_color"]
    acc = emb["accent_color"]

    # Diagonal split background: top-left = Ireland green, bottom-right = country
    for y in range(size):
        for x in range(size):
            img.putpixel((x, y), ic + (255,) if (x + y) < size else cc + (255,))

    # Much faster: draw two triangles
    img2 = Image.new("RGBA", (size, size), (0,0,0,0))
    d2 = ImageDraw.Draw(img2)
    d2.polygon([(0,0),(size,0),(0,size)], fill=ic+(255,))
    d2.polygon([(size,0),(size,size),(0,size)], fill=cc+(255,))
    img = img2

    draw = ImageDraw.Draw(img)

    # Thin diagonal separator line
    sep_w = max(3, size//60)
    draw.line([(0, size), (size, 0)], fill=WHITE+(180,), width=sep_w)

    # Apply rounded rect mask
    mask = draw_rounded_rect_mask(size, radius=size//5)
    img.putalpha(mask)

    draw = ImageDraw.Draw(img)

    # Document
    doc_w = int(size * 0.42)
    doc_h = int(size * 0.50)
    draw_document(draw, size//2, int(size*0.44),
                  doc_w, doc_h,
                  bg=WHITE,
                  fold_color=tuple(max(0,c-40) for c in ic),
                  line_color=(180, 220, 200))

    # Checkmark badge — use accent if country color is too light
    bx = size//2 + int(doc_w*0.38)
    by = int(size*0.44) + int(doc_h*0.32)
    br = int(size * 0.13)
    is_light = sum(cc) > 600
    badge_bg = tuple(max(0,c-20) for c in acc) if is_light else tuple(max(0,c-20) for c in cc)
    badge_fg = (30,30,30) if sum(badge_bg) > 600 else WHITE
    draw_checkmark(draw, bx, by, br, bg_color=badge_bg, check_color=badge_fg)

    # Accent dot strip (top stripe from country flag)
    stripe_h = max(6, size//35)
    stripe_y = size - stripe_h - size//20
    stripes = emb["stripe_colors"]
    sw = size // len(stripes)
    for i, col in enumerate(stripes):
        draw.rounded_rectangle(
            [i*sw + size//10, stripe_y,
             (i+1)*sw - size//60, stripe_y + stripe_h],
            radius=stripe_h//2, fill=col+(220,))

    return img.convert("RGB")


# â”€â”€ Feature graphic generator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

def make_feature(emb, w=1024, h=500):
    ic  = emb["ireland_color"]
    cc  = emb["country_color"]
    acc = emb["accent_color"]

    img = Image.new("RGB", (w, h), ic)
    draw = ImageDraw.Draw(img)

    # Right panel in country color
    split = int(w * 0.42)
    draw.rectangle([split, 0, w, h], fill=cc)

    # Diagonal cut between panels
    draw.polygon([(split-60, 0), (split+60, 0), (split-20, h), (split-100, h)],
                 fill=tuple(max(0, c-20) for c in ic))

    # Subtle diagonal lines on left
    for i in range(-h, split, 55):
        draw.line([(i, 0), (i+h, h)],
                  fill=tuple(max(0, c-15) for c in ic), width=1)

    # Ireland flag micro-stripe at bottom
    stripe_h = 8
    third = w // 3
    draw.rectangle([0, h-stripe_h, third, h],          fill=(255,255,255))
    draw.rectangle([third, h-stripe_h, 2*third, h],     fill=(255,255,255))
    draw.rectangle([2*third, h-stripe_h, w, h],         fill=(255, 130, 50))

    # Left: icon
    icon_img = make_icon(emb, size=300)
    icon_img = icon_img.convert("RGBA")
    backing = Image.new("RGBA", (300, 300), (*ic, 255))
    composite = Image.alpha_composite(backing, icon_img).convert("RGB")
    paste_x = int(split * 0.5) - 150
    paste_y = h//2 - 150
    img.paste(composite, (paste_x, paste_y))

    # Right panel text
    tx = split + 55
    f_title  = load_font(bold=True, size=48)
    f_sub    = load_font(bold=False, size=26)
    f_small  = load_font(bold=False, size=22)
    f_tiny   = load_font(bold=False, size=19)

    text_color = WHITE if sum(cc) < 400 else (30, 30, 30)
    muted = tuple(max(0, c-60) for c in WHITE) if sum(cc) < 400 else (80,80,80)

    draw.text((tx, 55),  f"Ireland Visa",          font=f_title, fill=WHITE if sum(cc)<400 else (20,20,20))
    draw.text((tx, 110), emb["name"],               font=f_title, fill=WHITE if sum(cc)<400 else (20,20,20))

    draw.text((tx, 182), 'Ireland Embassy - ' + emb['country'], font=f_sub, fill=muted)
    draw.text((tx, 215), emb["cadence"],             font=f_small, fill=muted)

    features = [
        "Instant decision lookup",
        "Approved / Refused status",
        "Nearest number if not found",
        "Data from ireland.ie",
    ]
    y = 262
    for feat in features:
        # bullet dot
        draw.ellipse([tx, y+9, tx+10, y+19],
                     fill=WHITE if sum(cc)<400 else IRELAND_GREEN)
        draw.text((tx+20, y), feat, font=f_small,
                  fill=WHITE if sum(cc)<400 else (30,30,30))
        y += 36

    draw.text((tx, h-50), 'Free  |  No login  |  ireland.ie',
              font=f_tiny, fill=muted)

    return img


# â”€â”€ Main â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

out_root = os.path.join(os.path.dirname(__file__), "store_assets")

for emb in EMBASSIES:
    folder = os.path.join(out_root, emb["key"])
    os.makedirs(folder, exist_ok=True)

    icon_path    = os.path.join(folder, "icon_512.png")
    feature_path = os.path.join(folder, "feature_1024x500.png")

    print(f"Generating {emb['name']}...", end=" ")

    icon = make_icon(emb)
    icon.save(icon_path)

    feat = make_feature(emb)
    feat.save(feature_path)

    print(f"icon + feature saved â†’ store_assets/{emb['key']}/")

print("\nDone! All assets saved to store_assets/")




