#!/usr/bin/env python3
"""Generate Runmote logo and app icons from the provided design."""

from PIL import Image, ImageDraw
import os


def draw_logo(size: int, bg_color: tuple, fg_color: tuple) -> Image.Image:
    """Draw the Runmote robot-chat logo at the given size."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Rounded square background
    radius = int(size * 0.22)
    margin = 0
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=radius,
        fill=bg_color,
    )

    # Speed lines on the left
    line_color = fg_color
    line_y1 = int(size * 0.38)
    line_y2 = int(size * 0.46)
    line_y3 = int(size * 0.54)
    line_y4 = int(size * 0.62)
    line_x_start = int(size * 0.12)
    line_x_long = int(size * 0.30)
    line_x_short = int(size * 0.22)
    line_x_dot = int(size * 0.18)
    line_width = max(1, int(size * 0.026))

    draw.line(
        [(line_x_start, line_y1), (line_x_long, line_y1)],
        fill=line_color,
        width=line_width,
    )
    draw.line(
        [(line_x_start, line_y2), (line_x_short, line_y2)],
        fill=line_color,
        width=line_width,
    )
    # dot
    dot_r = max(1, int(size * 0.018))
    draw.ellipse(
        [line_x_dot - dot_r, line_y3 - dot_r, line_x_dot + dot_r, line_y3 + dot_r],
        fill=line_color,
    )
    draw.line(
        [(line_x_dot + dot_r + int(size * 0.02), line_y3), (line_x_short, line_y3)],
        fill=line_color,
        width=line_width,
    )
    draw.line(
        [(line_x_start + int(size * 0.03), line_y4), (line_x_short, line_y4)],
        fill=line_color,
        width=line_width,
    )

    # Speech bubble / robot head
    # Center the icon
    cx = int(size * 0.58)
    cy = int(size * 0.48)
    bubble_w = int(size * 0.46)
    bubble_h = int(size * 0.38)
    bubble_rx = int(size * 0.19)
    bubble_ry = int(size * 0.19)

    # Speech bubble outline
    outline_width = max(1, int(size * 0.035))
    # Draw bubble body (rounded rectangle with tail)
    # We draw a filled rounded rectangle for the bubble, then the inner cutout
    bubble_left = cx - bubble_w // 2
    bubble_top = cy - bubble_h // 2
    bubble_right = cx + bubble_w // 2
    bubble_bottom = cy + bubble_h // 2

    # Create a mask for the bubble shape
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [bubble_left, bubble_top, bubble_right, bubble_bottom],
        radius=bubble_rx,
        fill=255,
    )
    # Tail
    tail_x = int(size * 0.37)
    tail_y = int(size * 0.68)
    tail_w = int(size * 0.12)
    tail_h = int(size * 0.10)
    mask_draw.polygon(
        [
            (bubble_left + bubble_w // 4, bubble_bottom - outline_width),
            (tail_x, tail_y),
            (bubble_left + bubble_w // 4 + tail_w, bubble_bottom - outline_width),
        ],
        fill=255,
    )

    # Draw outline by dilating the mask
    outline = Image.new("RGBA", (size, size), fg_color)
    outline.putalpha(mask)
    img.alpha_composite(outline)

    # Inner cutout (background color) to make it an outline
    inner_margin = outline_width
    inner_mask = Image.new("L", (size, size), 0)
    inner_draw = ImageDraw.Draw(inner_mask)
    inner_draw.rounded_rectangle(
        [
            bubble_left + inner_margin,
            bubble_top + inner_margin,
            bubble_right - inner_margin,
            bubble_bottom - inner_margin,
        ],
        radius=max(1, bubble_rx - inner_margin),
        fill=255,
    )
    # Tail inner cutout
    inner_draw.polygon(
        [
            (
                bubble_left + bubble_w // 4 + inner_margin,
                bubble_bottom - outline_width - inner_margin,
            ),
            (tail_x, tail_y - inner_margin),
            (
                bubble_left + bubble_w // 4 + tail_w - inner_margin,
                bubble_bottom - outline_width - inner_margin,
            ),
        ],
        fill=255,
    )

    inner = Image.new("RGBA", (size, size), bg_color)
    inner.putalpha(inner_mask)
    img.alpha_composite(inner)

    # Robot face (dark visor inside the bubble)
    face_left = cx - int(size * 0.16)
    face_top = cy - int(size * 0.08)
    face_right = cx + int(size * 0.16)
    face_bottom = cy + int(size * 0.08)
    face_radius = int(size * 0.08)
    draw.rounded_rectangle(
        [face_left, face_top, face_right, face_bottom],
        radius=face_radius,
        fill=fg_color,
    )

    # Eyes (background color circles)
    eye_r = int(size * 0.035)
    eye_y = cy
    eye_left_x = cx - int(size * 0.08)
    eye_right_x = cx + int(size * 0.08)
    draw.ellipse(
        [eye_left_x - eye_r, eye_y - eye_r, eye_left_x + eye_r, eye_y + eye_r],
        fill=bg_color,
    )
    draw.ellipse(
        [eye_right_x - eye_r, eye_y - eye_r, eye_right_x + eye_r, eye_y + eye_r],
        fill=bg_color,
    )

    # Antenna
    antenna_x = cx
    antenna_base_y = bubble_top - int(size * 0.02)
    antenna_top_y = bubble_top - int(size * 0.12)
    antenna_ball_r = int(size * 0.035)
    draw.line(
        [(antenna_x, antenna_base_y), (antenna_x, antenna_top_y)],
        fill=fg_color,
        width=outline_width,
    )
    draw.ellipse(
        [
            antenna_x - antenna_ball_r,
            antenna_top_y - antenna_ball_r,
            antenna_x + antenna_ball_r,
            antenna_top_y + antenna_ball_r,
        ],
        fill=fg_color,
    )

    return img


def save_ico(sizes, path, bg_color, fg_color):
    """Save a multi-resolution ICO file."""
    imgs = [draw_logo(s, bg_color, fg_color).convert("RGBA") for s in sizes]
    imgs[0].save(path, format="ICO", sizes=[(s, s) for s in sizes])


def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(base_dir, "assets")
    os.makedirs(out_dir, exist_ok=True)

    bg = (248, 244, 236, 255)  # warm cream
    fg = (26, 26, 26, 255)  # near-black

    # Desktop app icons
    desktop_icons_dir = os.path.join(base_dir, "..", "desktop", "src-tauri", "icons")
    os.makedirs(desktop_icons_dir, exist_ok=True)

    draw_logo(32, bg, fg).save(os.path.join(desktop_icons_dir, "32x32.png"))
    draw_logo(128, bg, fg).save(os.path.join(desktop_icons_dir, "128x128.png"))
    draw_logo(256, bg, fg).save(os.path.join(desktop_icons_dir, "128x128@2x.png"))
    save_ico([16, 24, 32, 48, 64, 128, 256], os.path.join(desktop_icons_dir, "icon.ico"), bg, fg)

    # Generic logo assets
    draw_logo(512, bg, fg).save(os.path.join(out_dir, "logo-512.png"))
    draw_logo(256, bg, fg).save(os.path.join(out_dir, "logo-256.png"))
    draw_logo(64, bg, fg).save(os.path.join(out_dir, "logo-64.png"))
    draw_logo(1024, bg, fg).save(os.path.join(out_dir, "logo-1024.png"))

    print("Generated icons in", out_dir)


if __name__ == "__main__":
    main()
