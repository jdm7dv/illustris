;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/extractcontourinfo.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ExtractContourInfo

; Prepare the display device and load a color table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 5

; Determine the path to the file.
file = FILEPATH('ctscan.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Initialize size parameters.
dims = [256, 256]

; Import the image from the file.
image = READ_BINARY(file, DATA_DIMS = dims)

; Create a window and display the image.
WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1]
TVSCL, image

; Display the filled contour in another window.
WINDOW, 2, TITLE = 'Contour of CT Scan'
CONTOUR, image, /XSTYLE, /YSTYLE, NLEVELS = 255, $
   /FILL

; Use the PATH_* keywords to obtain the vertices (and
; related information) of contour areas occurring at
; level 40.
CONTOUR, image, /XSTYLE, /YSTYLE, LEVELS = 40, $
   PATH_INFO = info, PATH_XY = xy, /PATH_DATA_COORDS

; Plot the level 40 contours over the filled contour
; display.  Use different linestyles for each closed
; contour at level 40.
FOR i = 0, (N_ELEMENTS(info) - 1) DO PLOTS, $
   xy[*, info[i].offset:(info[i].offset + info[i].n - 1)], $
   LINESTYLE = (i < 5), /DATA

; From the previous display, we determined the gas
; pocket we are interested in is the third closed
; contour at level 40, with the number 2, dashed line
; style. Obtain the x and y coordinates for this closed
; contour.
x = REFORM(xy[0, info[2].offset:(info[2].offset + $
   info[2].n - 1)])
y = REFORM(xy[1, info[2].offset:(info[2].offset + $
   info[2].n - 1)])
HELP, (xy[0, info[2].offset:(info[2].offset +$
   info[2].n - 1)])
PRINT, (xy[1, info[2].offset:(info[2].offset + $
   info[2].n - 1)])

; Set the last element of the coordinate vectors to the
; first element to ensure that the contour area is
; completely enclosed.
x = [x, x[0]]
y = [y, y[0]]

; Draw an arrow pointing to the region of interest for
; display purposes only.
ARROW, 10, 10, (MIN(x) + MAX(x))/2, COLOR = 180, $
   (MIN(y) + MAX(y))/2, THICK = 2, /DATA

; Output the resulting vectors.
PRINT, ''
PRINT, '       x       ,       y'
PRINT, [TRANSPOSE(x), TRANSPOSE(y)], FORMAT = '(2F15.6)'

; Compute area of gas pocket and output results.
area = POLY_AREA(x, y)
PRINT, 'area = ', ROUND(area), '  square pixels'

END