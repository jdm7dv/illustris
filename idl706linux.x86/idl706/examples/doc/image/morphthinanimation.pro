;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/morphthinanimation.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO morphThinAnimation

; Prepare the display device and load grayscale color table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Load an image.
file = FILEPATH('pollens.jpg', SUBDIR=['examples','demo','demodata'])
READ_JPEG, file, img, /GRAYSCALE
dims = SIZE(img, /DIMENSIONS)
WINDOW, 0, XSIZE=2*dims[0], YSIZE=2*dims[1], $
	TITLE='Original, Binary and Thinned Images'
TVSCL, img, 0

; Generate a thresholded binary image.
binaryImg = img GE 140B
TVSCL, binaryImg, 1

; Prepare hit and miss structures for thinning.
    h0 = [[0b,0,0], [0,1,0], [1,1,1]]

    m0 = [[1b,1,1], [0,0,0], [0,0,0]]

    h1 = [[0b,0,0], [1,1,0], [1,1,0]]

    m1 = [[0b,1,1], [0,0,1], [0,0,0]]

    h2 = [[1b,0,0], [1,1,0], [1,0,0]]

    m2 = [[0b,0,1], [0,0,1], [0,0,1]]

    h3 = [[1b,1,0], [1,1,0], [0,0,0]]

    m3 = [[0b,0,0], [0,0,1], [0,1,1]]

    h4 = [[1b,1,1], [0,1,0], [0,0,0]]

    m4 = [[0b,0,0], [0,0,0], [1,1,1]]

    h5 = [[0b,1,1], [0,1,1], [0,0,0]]

    m5 = [[0b,0,0], [1,0,0], [1,1,0]]

    h6 = [[0b,0,1], [0,1,1], [0,0,1]]

    m6 = [[1b,0,0], [1,0,0], [1,0,0]]

    h7 = [[0b,0,0], [0,1,1], [0,1,1]]

    m7 = [[1b,1,0], [1,0,0], [0,0,0]]

; Prepare a structuring element for dilation of hit/miss results.
radius = 4
strucEl = SHIFT(DIST(2*radius+1), radius, radius) LE radius

; Iterate until the thinned image is identical to the input image
; for a given iteration.
bCont = 1b
iIter = 1
thinImg = binaryImg

WHILE bCont eq 1b do begin
	PRINT,'Iteration: ', iIter
    inputImg = thinImg

; For illustration purposes only, show the hit/miss results for the
; 1st pair of structuring elements.
hmImg = MORPH_HITORMISS(inputImg, h0, m0)
TVSCL, DILATE(hmImg, strucEl), 2

; Perform the thinning using the first pair of structuring elements.
thinImg = MORPH_THIN(inputImg, h0, m0)

; For illustration purposes only, show the hit/miss results.
hmImg = MORPH_HITORMISS(thinImg, h1, m1)
TVSCL, DILATE(hmImg, strucEl), 2

; Perform the thinning using the 2nd pair of structuring elements.
thinImg = MORPH_THIN(thinImg, h1, m1)

; For illustration purposes only, show the hit/miss results.
hmImg = MORPH_HITORMISS(thinImg, h2, m2)
TVSCL, DILATE(hmImg, strucEl), 2

; Perform the thinning using the 3rd pair of structuring elements.
thinImg = MORPH_THIN(thinImg, h2, m2)

; For illustration purposes only, show the hit/miss results.
hmImg = MORPH_HITORMISS(thinImg, h3, m3)
TVSCL, DILATE(hmImg, strucEl), 2

; Perform the thinning using the 4th pair of structuring elements.
thinImg = MORPH_THIN(thinImg, h3, m3)

; For illustration purposes only, show the hit/miss results.
hmImg = MORPH_HITORMISS(thinImg, h4, m4)
TVSCL, DILATE(hmImg, strucEl), 2

; Perform the thinning using the 5th pair of structuring elements.
thinImg = MORPH_THIN(thinImg, h4, m4)

; For illustration purposes only, show the hit/miss results.
hmImg = MORPH_HITORMISS(thinImg, h5, m5)
TVSCL, DILATE(hmImg, strucEl), 2

; Perform the thinning using the 6th pair of structuring elements.
thinImg = MORPH_THIN(thinImg, h5, m5)

; For illustration purposes only, show the hit/miss results.
hmImg = MORPH_HITORMISS(thinImg, h6, m6)
TVSCL, DILATE(hmImg, strucEl), 2

; Perform the thinning using the 7th pair of structure elements.
thinImg = MORPH_THIN(thinImg, h6, m6)

; For illustration purposes only, show the hit/miss results.
hmImg = MORPH_HITORMISS(thinImg, h7, m7)
TVSCL, DILATE(hmImg, strucEl), 2

; Perform the thinning using the 8th pair of structuring elements.
thinImg = MORPH_THIN(thinImg, h7, m7)

  ; Display the image.
  TVSCL, thinImg

  ; Update the iteration controls.
  bCont = MAX(inputImg - thinImg)
  iIter = iIter + 1

ENDWHILE

; Show final result.
TVSCL, thinImg, 3

END