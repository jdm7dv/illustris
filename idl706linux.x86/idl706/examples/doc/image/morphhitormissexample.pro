;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/morphhitormissexample.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO MorphHitorMissExample

; Prepare the display device and load a grayscale color
; table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and open an image of the parasitic protozoa.
file = FILEPATH('r_seeberi.jpg', $
   SUBDIRECTORY=['examples','data'])
READ_JPEG, file, img, /GRAYSCALE

; Pad the image to avoid discounting edge objects.
dims = SIZE(img, /DIMENSIONS)
padImg = REPLICATE(0B, dims[0]+10, dims[1]+10)
padImg[5, 5] = img

; Get the image dimensions.
dims = SIZE(padImg, /DIMENSIONS)

; Prepare a window and display the image.
WINDOW, 0, XSIZE=3*dims[0], YSIZE=2*dims[1], $
   TITLE='Displaying Hit-or-Miss Matches'
TVSCL, padImg, 0

; Define and create a structuring element for the
; opening operator.
radstr = 7
strucElem = SHIFT(DIST(2*radstr+1), $
   radstr, radstr) LE radstr

; Apply the opening operator for a smoothing effect.
openImg = MORPH_OPEN(padImg, strucElem, /GRAY)
TVSCL, openImg, 1

; Use an intensity histogram as a guide for
; thresholding.
WINDOW, 2, XSIZE = 400, YSIZE = 300
PLOT, HISTOGRAM(openImg)

; Threshold the image.
threshImg = openImg GE 150
WSET, 0
TVSCL, threshImg, 2

; Create the structuring elements for the hit-or-miss
; operator.
radhit = 7
radmiss = 23
hit = SHIFT(DIST(2*radhit+1), radhit, radhit) LE radhit
miss = SHIFT(DIST(2*radmiss+1), $
   radmiss, radmiss) GE radmiss

; Using structuring elements, define matching regions.
matches = MORPH_HITORMISS(threshImg, hit, miss)

; Display the regions matching hit and miss conditions.
; Dilate the matches to the radius of a 'hit'.
dmatches = DILATE(matches, hit)
TVSCL, dmatches, 3

; Display the original image overlaid with the matching
; regions.
padImg [WHERE (dmatches EQ 1)] = 1
TVSCL, padImg, 4

END