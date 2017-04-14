;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/removingnoisewithwavelet.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO RemovingNoiseWithWavelet

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

; Create a window and display the original image.
WINDOW, 0, XSIZE = 2*displaySize[0], YSIZE = displaySize[1], $
   TITLE = 'Original Image and Power Spectrum'
TVSCL, CONGRID(image, displaySize[0], displaySize[1]), 0

; Determine the transform of the image.
waveletTransform = WTN(image, 20)

; Display the power spectrum.
TVSCL, CONGRID(ALOG10(ABS(waveletTransform^2)), $
   displaySize[0], displaySize[1]), 1

; Crop the transform to only include data close to
; the spike in the lower-left corner.
croppedTransform = FLTARR(imageSize[0], imageSize[1])
croppedTransform[0, 0] = waveletTransform[0:(imageSize[0]/2), $
   0:(imageSize[1]/2)]

; Create another window and display the power spectrum
; of the cropped transform as an image.
WINDOW, 1, XSIZE = 2*displaySize[0], YSIZE = displaySize[1], $
   TITLE = 'Power Spectrum of Cropped Transform and Results'
TVSCL, CONGRID(ALOG10(ABS(croppedTransform^2)), $
   displaySize[0], displaySize[1]), 0, /NAN

; Apply the inverse transformation to cropped transform.
inverseTransform = WTN(croppedTransform, 20, /INVERSE)

; Display results of inverse transformation.
TVSCL, CONGRID(inverseTransform, displaySize[0], $
   displaySize[1]), 1

END