;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/inversefft.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO InverseFFT

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

; Transform the image into the frequency domain.
ffTransform = FFT(image)

; Shift the zero frequency location from (0, 0) to
; the center of the display.
center = imageSize/2 + 1
fftShifted = SHIFT(ffTransform, center)

; Compute the power spectrum of the transform.
powerSpectrum = ABS(fftShifted)^2

; Apply a logarithmic scale to the power spectrum.
scaledPowerSpect = ALOG10(powerSpectrum)

; Create a window and display the power spectrum.
WINDOW, 0, XSIZE = displaySize[0], YSIZE = displaySize[1], $
   TITLE = 'Power Spectrum Image'
TVSCL, CONGRID(scaledPowerSpect, displaySize[0], $
   displaySize[1])

; Compute the inverse
fftInverse = REAL_PART(FFT(ffTransform, /INVERSE))

; Create another window and display the inverse
; transform as an image
WINDOW, 1, XSIZE = displaySize[0], YSIZE = displaySize[1], $
   TITLE = 'FFT: Inverse Transform'
TVSCL, CONGRID(fftInverse, displaySize[0], $
   displaySize[1])

END