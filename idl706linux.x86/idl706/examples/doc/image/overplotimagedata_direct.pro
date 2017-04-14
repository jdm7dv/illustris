;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/overplotimagedata_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 

PRO overplotImageData_Direct

; Initialize color table.
DEVICE, DECOMPOSED = 0
LOADCT, 5

; Create image to represent color table.
image = BINDGEN(256) # REPLICATE(1B, 256)

; Display image.
WINDOW, 0, XSIZE = 512, YSIZE = 384
TV, image, 150, 75

; Obtain red, green, and blue vectors, which form the
; color table.
TVLCT, red, green, blue, /GET

; Display axes.
PLOT, red, /NODATA, /NOERASE, /XSTYLE, /YSTYLE, $
   POSITION = [140, 65, 416,  341], /DEVICE, $
   XRANGE = [-10, 265], YRANGE = [-10, 265], $
   XTITLE = 'Index', YTITLE = 'Value', $
   TITLE = 'Color Table #5:  STD GAMMA-II'

; Modify color table to define the colors of red, green,
; and blue.
red[1] = 255 & green[1] = 0 & blue[1] = 0 ; red
red[2] = 0 & green[2] = 255 & blue[2] = 0 ; green
red[3] = 0 & green[3] = 0 & blue[3] = 255 ; red
TVLCT, red, green, blue

; Display color vectors over image.
index = BINDGEN(252) + 4B
OPLOT, index, red[4:*], THICK = 2., COLOR = 1
OPLOT, index, green[4:*], THICK = 2., COLOR = 2
OPLOT, index, blue[4:*], THICK = 2., COLOR = 3

END