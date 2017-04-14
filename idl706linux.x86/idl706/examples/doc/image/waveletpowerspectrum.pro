;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/waveletpowerspectrum.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO WaveletPowerSpectrum

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

; Determine the power spectrum of the image.
powerSpectrum = ALOG10(ABS(WTN(image, 20)))

; Create another window and display the power spectrum
; as a surface.
WINDOW, 1, TITLE = 'Wavelet: Power Spectrum (surface)'
SHADE_SURF, powerSpectrum, /XSTYLE, /YSTYLE, $
   /ZSTYLE, TITLE = 'Power Spectrum of Image', $
   CHARSIZE = 1.5

; Create another window and display the power spectrum
; as an image.
WINDOW, 2, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], $
   TITLE = 'Wavelet: Power Spectrum (image)'
TVSCL, CONGRID(powerSpectrum, displaySize[0], $
   displaySize[1])

END