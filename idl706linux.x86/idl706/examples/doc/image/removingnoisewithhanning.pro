;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/removingnoisewithhanning.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO RemovingNoiseWithHANNING

; Import the image from the file.
file = FILEPATH('abnorm.dat', $
   SUBDIRECTORY = ['examples', 'data'])
imageSize = [64, 64]
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Initialize a display size parameter to resize the
; image when displaying it.
displaySize = 2*imageSize

; Initialize the display.
DEVICE, DECOMPOSED = 0
LOADCT, 0

; Create a window and display the original image.
WINDOW, 0, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], $
   TITLE = 'Original Image'
TVSCL, CONGRID(image, displaySize[0], displaySize[1])

; Determine the forward Fourier transformation of the
; image.
transform = SHIFT(FFT(image), (imageSize[0]/2), $
   (imageSize[1]/2))

; Create another window and display the power spectrum.
WINDOW, 1, TITLE = 'Surface of Forward FFT'
SHADE_SURF, (2.*ALOG10(ABS(transform))), $
   /XSTYLE, /YSTYLE, /ZSTYLE, TITLE = 'Power Spectrum', $
   XTITLE = 'Mode', YTITLE = 'Mode', $
   ZTITLE = 'Amplitude', CHARSIZE = 1.5

; Use a Hanning mask to filter out the noise.
mask = HANNING(imageSize[0], imageSize[1])
maskedTransform = transform*mask

; Create another window and display the masked power
; spectrum.
WINDOW, 2, TITLE = 'Surface of Filtered FFT'
SHADE_SURF, (2.*ALOG10(ABS(maskedTransform))), $
   /XSTYLE, /YSTYLE, /ZSTYLE, $
   TITLE = 'Masked Power Spectrum', $
   XTITLE = 'Mode', YTITLE = 'Mode', $
   ZTITLE = 'Amplitude', CHARSIZE = 1.5

; Apply the inverse transformation to masked frequency
; domain image.
inverseTransform = FFT(SHIFT(maskedTransform, $
   (imageSize[0]/2), (imageSize[1]/2)), /INVERSE)

; Create another window and display the results of
; inverse transformation.
WINDOW, 3, XSIZE = displaySize[0], $
   YSIZE = displaySize[1], $
   TITLE = 'Hanning Filtered Image'
TVSCL, CONGRID(REAL_PART(inverseTransform), $
   displaySize[0], displaySize[1])

END