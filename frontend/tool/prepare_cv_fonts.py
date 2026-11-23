"""Convert official Latin Modern OTF outlines for Dart pdf's TrueType parser.

Usage: python prepare_cv_fonts.py /path/to/official/lm/otf-directory
Requires fonttools. Original glyph widths and optical sizes are preserved.
Derived fonts carry a new family name as requested by the GUST Font License.
"""
from pathlib import Path
import sys
from fontTools.ttLib import TTFont
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.pens.cu2quPen import Cu2QuPen

source = Path(sys.argv[1])
destination = Path(__file__).resolve().parents[1] / 'assets' / 'cv_fonts'
for stem in ['lmroman10-regular', 'lmroman10-bold', 'lmroman10-italic',
             'lmroman10-bolditalic', 'lmroman12-bold', 'lmroman9-regular',
             'lmroman9-italic']:
    font = TTFont(source / (stem + '.otf'))
    glyph_set = font.getGlyphSet()
    glyphs = {}
    for name in font.getGlyphOrder():
        pen = TTGlyphPen(glyph_set)
        glyph_set[name].draw(Cu2QuPen(pen, max_err=0.5, reverse_direction=True))
        glyphs[name] = pen.glyph()
    del font['CFF ']
    if 'VORG' in font:
        del font['VORG']
    font.sfntVersion = '\x00\x01\x00\x00'
    builder = FontBuilder(font=font)
    builder.isTTF = True
    builder.setupGlyf(glyphs)
    builder.setupMaxp()
    # pdfLaTeX's Latin Modern Type 1 metrics, rather than OTF accent extents.
    font['hhea'].ascent = 694
    font['hhea'].descent = -194
    font['hhea'].lineGap = 0
    font['post'].formatType = 3.0
    for record in font['name'].names:
        if record.nameID in (1, 3, 4, 6, 16):
            value = record.toUnicode().replace('LMRoman', 'CareerBridgeLMRoman')
            value = value.replace('Latin Modern Roman', 'Career Bridge LM Roman')
            font['name'].setName(value, record.nameID, record.platformID,
                                 record.platEncID, record.langID)
    font.save(destination / (stem + '.ttf'))
