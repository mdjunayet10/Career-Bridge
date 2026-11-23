# CV template fonts

The CV renderer follows the supplied main.tex (LaTeX article, lmodern,
fontawesome5). Latin Modern Roman optical sizes 10, 12 bold and 9 are
from the GUST Latin Modern project:
https://ctan.org/texarchive/fonts/lm

Official OTF files were converted to quadratic TrueType outlines by
`tool/prepare_cv_fonts.py`, with unchanged advance widths and at most
0.5/1000 em outline approximation. Vertical layout uses pdfLaTeX Latin
Modern Type 1 ascender/descender metrics (694/-194). Derived fonts are
renamed CareerBridgeLMRoman and distributed under GUST-FONT-LICENSE.txt.

Font Awesome Free 5.15.4 solid/brand icons:
https://github.com/FortAwesome/Font-Awesome/tree/5.15.4
See FontAwesome-LICENSE.txt.

profile-placeholder.png is the user's supplied template image.
The earlier Arial assets are unused by the current reference renderer.
