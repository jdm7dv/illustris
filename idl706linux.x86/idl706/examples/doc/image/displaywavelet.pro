;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/displaywavelet.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayWavelet

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

; Transform the image into the time-frequency domain.
waveletTransform = WTN(image, 20)

; Compute the power spectrum.
powerSpectrum = ABS(waveletTransform)^2

; Apply a logarithmic scale to the power spectrum.
scaledPowerSpect = ALOG10(powerSpectrum)

; Create another window and display the log-scaled
; power spectrum as a surface.
WINDOW, 1, TITLE = 'Wavelet Power Spectrum: ' + $
   'Logarithmic Scale (surface)'
SHADE_SURF, scaledPowerSpect, /XSTYLE, /YSTYLE, /ZSTYLE, $
   TITLE = 'Log-scaled Power Spectrum of Image', $
   XTITLE = 'Horizontal Number', $
   YTITLE = 'Vertical Number', $
   ZTITLE = 'Log(Squared Amplitude)', CHARSIZE = 1.5

; Create another window and display the log-scaled
; power spectrum as an image.
WINDOW, 2, XSIZE = displaySize[0], YSIZE = displaySize[1], $
   TITLE = 'Wavelet Power Secptrum: Logarithmic Scale (image)'
TVSCL, CONGRID(scaledPowerSpect, displaySize[0], $
   displaySize[1])

END