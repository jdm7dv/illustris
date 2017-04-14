;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/removingnoisewithfft.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO RemovingNoiseWithFFT

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

; Transform the image into the frequency domain.
ffTransform = FFT(image)

; Shift the zero frequency location from (0, 0) to
; the center of the display.
center = imageSize/2 + 1
fftShifted = SHIFT(ffTransform, center)

; Calculate the horizontal and vertical frequency
; values, which will be used as the values for the
; axes of the display.
interval = 1.
hFrequency = INDGEN(imageSize[0])
hFrequency[center[0]] = center[0] - imageSize[0] + $
   FINDGEN(center[0] - 2)
hFrequency = hFrequency/(imageSize[0]/interval)
hFreqShifted = SHIFT(hFrequency, -center[0])
vFrequency = INDGEN(imageSize[1])
vFrequency[center[1]] = center[1] - imageSize[1] + $
   FINDGEN(center[1] - 2)
vFrequency = vFrequency/(imageSize[1]/interval)
vFreqShifted = SHIFT(vFrequency, -center[1])

; Compute the power spectrum of the transform.
powerSpectrum = ABS(fftShifted)^2

; Apply a logarithmic scale to the power spectrum.
scaledPowerSpect = ALOG10(powerSpectrum)

; Display the log-scaled power spectrum.
TVSCL, CONGRID(scaledPowerSpect, displaySize[0], $
   displaySize[1]), 1

; Scale the power spectrum to a zero maximum.
scaledPS0 = scaledPowerSpect - MAX(scaledPowerSpect)

; Create another window and display the scaled transform
; as a surface.
WINDOW, 1, $
   TITLE = 'Power Spectrum Scaled to a Zero Maximum'
SHADE_SURF, scaledPS0, hFreqShifted, vFreqShifted, $
   /XSTYLE, /YSTYLE, /ZSTYLE, $
   TITLE = 'Zero Maximum Power Spectrum', $
   XTITLE = 'Horizontal Frequency', $
   YTITLE = 'Vertical Frequency', $
   ZTITLE = 'Max-Scaled(Log(Power Spectrum))', $
   CHARSIZE = 1.5

; Threshold the image using -5.25, which is just below
; the peak of the transform, to remove the noise.
mask = REAL_PART(scaledPS0) GT -5.25

; Mask the transform to exclude the noise.
maskedTransform = fftShifted*mask

; Create another window and display the power spectrum
; of the masked transform.
WINDOW, 2, XSIZE = 2*displaySize[0], YSIZE = displaySize[1], $
   TITLE = 'Power Spectrum of Masked Transform and Results'
TVSCL, CONGRID(ALOG10(ABS(maskedTransform^2)), $
   displaySize[0], displaySize[1]), 0, /NAN

; Shift the masked transform to the position of the
; original transform.
maskedShiftedTrans = SHIFT(maskedTransform, -center)

; Apply the inverse transformation to masked transform.
inverseTransform = REAL_PART(FFT(maskedShiftedTrans, $
   /INVERSE))

; Display results of inverse transformation.
TVSCL, CONGRID(inverseTransform, displaySize[0], $
   displaySize[1]), 1

END