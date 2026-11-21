"""Reconstruct the supplied SCOM reference as pixel art; Python standard library only."""
from pathlib import Path
import struct
import zlib

WIDTH, HEIGHT, SCALE = 64, 96, 7

def frame(active=False):
    pixels = [[(6, 4, 7, 255) for _ in range(WIDTH)] for _ in range(HEIGHT)]

    def rect(x, y, w, h, color):
        rgb = tuple(bytes.fromhex(color)) + (255,)
        for row in range(y, min(y + h, HEIGHT)):
            for col in range(x, min(x + w, WIDTH)):
                pixels[row][col] = rgb

    # Top cap, green-grey metal crossbar, purple inner edges.
    rect(5, 0, 54, 3, "130e19")
    rect(8, 3, 48, 3, "292b2d")
    rect(11, 3, 13, 3, "3e4849")
    rect(35, 3, 5, 3, "17231f")
    rect(40, 3, 11, 3, "3e4849")
    rect(0, 6, 64, 3, "17231f")
    rect(5, 6, 35, 3, "616e68")
    rect(40, 6, 16, 3, "3e4849")
    rect(0, 9, 64, 3, "130e19")
    rect(8, 9, 48, 3, "17231f")
    rect(11, 9, 45, 3, "2c1111")
    rect(3, 12, 2, 66, "2a202d")
    rect(59, 12, 2, 66, "2a202d")
    # Stone side uprights, matched to the reference's stepped shading.
    for y, h, color in ((12,3,"65615d"),(15,3,"8a8a86"),(18,9,"b4a67c"),
                         (27,9,"8a8a86"),(36,6,"65615d"),(42,6,"494342"),
                         (48,3,"65615d"),(51,6,"8a8a86"),(57,6,"65615d"),
                         (63,3,"8a8a86"),(66,9,"494342"),(75,3,"130e19")):
        rect(0,y,3,h,color)
    for y, h, color in ((12,3,"65615d"),(15,18,"8a8a86"),(33,9,"65615d"),
                         (42,6,"8a8a86"),(48,3,"65615d"),(51,6,"8a8a86"),
                         (57,6,"65615d"),(63,3,"8a8a86"),(66,9,"494342"),
                         (75,3,"130e19")):
        rect(61,y,3,h,color)
    # Lower arc and grille.
    rect(16,69,35,3,"130e19")
    rect(16,69,3,3,"2c1111")
    rect(21,69,3,3,"3e4849")
    rect(24,69,16,3,"616e68")
    rect(40,69,11,3,"3e4849")
    rect(11,72,42,3,"130e19")
    rect(16,72,37,3,"17231f")
    rect(8,75,48,3,"17231f")
    rect(5,78,6,3,"17231f")
    rect(8,78,3,6,"616e68")
    rect(11,75,8,3,"292b2d")
    rect(11,78,5,3,"292b2d")
    rect(11,81,2,9,"130e19")
    rect(5,81,3,9,"3e4849")
    rect(0,78,3,18,"17231f")
    rect(0,81,3,3,"3e4849")
    rect(0,87,3,3,"3e4849")
    rect(3,90,8,3,"292b2d")
    rect(5,93,19,3,"17231f")
    rect(11,93,8,3,"130e19")
    rect(16,93,5,3,"292b2d")
    rect(53,78,6,3,"17231f")
    rect(53,81,3,3,"616e68")
    rect(56,84,3,9,"3e4849")
    rect(53,90,6,3,"292b2d")
    rect(59,78,5,18,"17231f")
    rect(59,81,5,3,"3e4849")
    rect(59,87,5,3,"3e4849")
    rect(51,75,2,3,"292b2d")
    rect(48,78,5,6,"292b2d")
    rect(51,84,2,6,"130e19")
    rect(40,93,19,3,"17231f")
    rect(45,93,8,3,"130e19")
    rect(40,93,5,3,"292b2d")
    if active:
        # Only the grille glows; the rest of the image is identical.
        for x,y,w,h,c in ((13,81,6,9,"a90000"),(16,78,3,3,"8f0000"),
                           (13,84,2,3,"660000"),(17,79,2,2,"bf2222"),
                           (24,75,5,15,"b70000"),(24,76,3,3,"790000"),
                           (27,79,2,3,"860000"),(24,84,2,3,"df2525"),
                           (35,75,5,15,"be0000"),(35,78,3,3,"870000"),
                           (38,82,2,3,"ff5252"),(38,84,2,2,"ffaaaa"),
                           (43,81,8,9,"b42121"),(43,81,3,3,"760000"),
                           (47,82,2,2,"d33636"),(45,88,6,2,"8e1111")):
            rect(x,y,w,h,c)
    # Grille bars sit in front of the glow.
    for x,w in ((19,2),(29,3),(40,3)):
        rect(x,75,w,15,"65615d")
        rect(x,75,w,3,"8a8a86")
    rect(21,75,3,3,"494342")
    rect(21,78,3,6,"b4a67c")
    rect(21,84,3,3,"8a8a86")
    rect(21,87,3,3,"65615d")
    rect(29,78,3,6,"b4a67c")
    rect(29,84,3,3,"8a8a86")
    rect(19,90,24,3,"130e19")
    rect(29,90,3,3,"494342")
    rect(11,90,8,3,"130e19")
    rect(43,90,8,3,"130e19")
    return pixels

def save_png(path, pixels):
    width, height = WIDTH*SCALE, HEIGHT*SCALE
    def chunk(tag, data):
        return struct.pack(">I",len(data))+tag+data+struct.pack(">I",zlib.crc32(tag+data)&0xffffffff)
    rows = bytearray()
    for row in pixels:
        expanded = b"".join(bytes(pixel)*SCALE for pixel in row)
        rows.extend((b"\x00"+expanded)*SCALE)
    path.write_bytes(b"\x89PNG\r\n\x1a\n"+
                     chunk(b"IHDR",struct.pack(">IIBBBBB",width,height,8,6,0,0,0))+
                     chunk(b"IDAT",zlib.compress(rows,9))+chunk(b"IEND",b""))

if __name__ == "__main__":
    here = Path(__file__).resolve().parent
    save_png(here/"scom-frame.png",frame())
    save_png(here/"scom-frame-active.png",frame(True))
