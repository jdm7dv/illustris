;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/forwardwavelet.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO ForwardWavelet

; Import the image from the file.
imageSize = [64, 64]
file = FILEPATH('abnorm.dat', $
   SUBDIRECTORY = ['examples', 'data'])
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize a display size parameter to resize the
; image when displaying it.
displaySize = 2*imageSize

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the image.
WINDOW, 0, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], TITLE = 'Original Image'
TVSCL, CONGRID(image, displaySize[0], $
   displaySize[1])

; Transform the image into the wavelet domain.
waveletTransform = WTN(image, 20)

; Create another window and display the frequency
; transform.
WINDOW, 1, TITLE = 'Wavelet: Transform'
SHADE_SURF, waveletTransform, /XSTYLE, /YSTYLE, $
   /ZSTYLE, TITLE = 'Transform of Image', $
   XTITLE = 'Horizontal Number', $
   YTITLE = 'Vertical Number', $
   ZTITLE = 'Amplitude', CHARSIZE = 1.5

; Create another window and display the frequency
; transform within the data (z) range of 0 to 200.
WINDOW, 2, TITLE = 'Wavelet: Transform (Closer Look)'
SHADE_SURF, waveletTransform, /XSTYLE, /YSTYLE, $
   /ZSTYLE, TITLE = 'Transform of Image', $
   XTITLE = 'Horizontal Number', $
   YTITLE = 'Vertical Number', $
   ZTITLE = 'Amplitude', CHARSIZE = 1.5, $
   ZRANGE = [0., 200.]

END