;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/inversewavelet.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO InverseWavelet

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
waveletTransform = WTN(image, 20)

; Compute the power spectrum.
powerSpectrum = ABS(waveletTransform)^2

; Apply a logarithmic scale to the power spectrum.
scaledPowerSpectrum = ALOG10(powerSpectrum)

; Create a window and display the transform.
WINDOW, 0, XSIZE = displaySize[0], YSIZE = displaySize[1], $
   TITLE = 'Power Spectrum Image'
TVSCL, CONGRID(scaledPowerSpectrum, displaySize[0], $
  displaySize[1])

; Compute the inverse
waveletInverse = WTN(waveletTransform, 20, /INVERSE)

; Create another window and display the inverse
; transform as an image
WINDOW, 1, XSIZE = displaySize[0], YSIZE = displaySize[1], $
   TITLE = 'Wavelet: Inverse Transform'
TVSCL, CONGRID(waveletInverse, displaySize[0], $
   displaySize[1])

END