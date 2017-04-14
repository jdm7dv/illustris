;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/mj2_morphthin_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       mj2_morphthin_doc.pro
;
;  CALLING SEQUENCE: mj2_morphthin_doc
;
;  PURPOSE:
;       Demonstrates how to create a MJ2 animation using
;       incremental data captures.
;
;  MAJOR TOPICS: Language
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       none.
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       11/05,   SM - written
;-
;-----------------------------------------------------------------
PRO mj2_morphthin_doc

; Prepare the display device and load grayscale color
; table.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Load an image.
file = FILEPATH('pollens.jpg', $
   SUBDIRECTORY = ['examples', 'demo', 'demodata'])
READ_JPEG, file, img, /GRAYSCALE

; Get the image size, prepare a display window and
; display the image.
dims = SIZE(img, /DIMENSIONS)
WINDOW, 0, XSIZE = 2*dims[0], YSIZE = dims[1], $
   TITLE = 'Original and Thinned Images'
TVSCL, img, 0

; Generate a binary image by thresholding.
binaryImg = img GE 140

; Prepare hit and miss structures for thinning.
h0 = [[0b, 0, 0], [0, 1, 0], [1, 1, 1]]
m0 = [[1b, 1, 1], [0, 0, 0], [0, 0, 0]]
h1 = [[0b, 0, 0], [1, 1, 0], [1, 1, 0]]
m1 = [[0b, 1, 1], [0, 0, 1], [0, 0, 0]]
h2 = [[1b, 0, 0], [1, 1, 0], [1, 0, 0]]
m2 = [[0b, 0, 1], [0, 0, 1], [0, 0, 1]]
h3 = [[1b, 1, 0], [1, 1, 0], [0, 0, 0]]
m3 = [[0b, 0, 0], [0, 0, 1], [0, 1, 1]]
h4 = [[1b, 1, 1], [0, 1, 0], [0, 0, 0]]
m4 = [[0b, 0, 0], [0, 0, 0], [1, 1, 1]]
h5 = [[0b, 1, 1], [0, 1, 1], [0, 0, 0]]
m5 = [[0b, 0, 0], [1, 0, 0], [1, 1, 0]]
h6 = [[0b, 0, 1], [0, 1, 1], [0, 0, 1]]
m6 = [[1b, 0, 0], [1, 0, 0], [1, 0, 0]]
h7 = [[0b, 0, 0], [0, 1, 1], [0, 1, 1]]
m7 = [[1b, 1, 0], [1, 0, 0], [0, 0, 0]]


; Create the sample MJ2 file in the temporary directory.
file = filepath("mj2_thinning_ex.mj2", /TMP)

; Create an IDLffMJPEG2000 object.
oMJ2write = OBJ_NEW('IDLffMJPEG2000', file, /WRITE, /REVERSIBLE)

; Iterate until the thinned image is identical to
; the input image for a given iteration.
bCont = 1b
iIter = 1
thinImg = binaryImg
WHILE bCont EQ 1b DO BEGIN
   PRINT,'Iteration: ', iIter
   inputImg = thinImg

   ; Perform the thinning using the first pair
   ; of structure elements.
   thinImg = MORPH_THIN(inputImg, h0, m0)

   ; Perform the thinning operation using the
   ; remaining structural element pairs.
   thinImg = MORPH_THIN(thinImg, h1, m1)
   thinImg = MORPH_THIN(thinImg, h2, m2)
   thinImg = MORPH_THIN(thinImg, h3, m3)
   thinImg = MORPH_THIN(thinImg, h4, m4)
   thinImg = MORPH_THIN(thinImg, h5, m5)
   thinImg = MORPH_THIN(thinImg, h6, m6)
   thinImg = MORPH_THIN(thinImg, h7, m7)

   ; Add the data to the MJ2 file
   result = oMJ2write->SetData(BYTSCL(thinImg))

   ; Test the condition and increment the loop.
   bCont = MAX(inputImg - thinImg)
   iIter = iIter + 1
ENDWHILE

; Commit and close the MJ2 file
result = oMJ2write->Commit(10000)
OBJ_DESTROY, oMJ2write

; Access the newly created object and display the
; animation.
; Create a new IDLffMJPEG2000 object to access MJ2 file.
oMJ2read=OBJ_NEW("IDLffMJPEG2000", file)
oMJ2read->GetProperty,N_FRAMES=nFrames, DIMENSIONS=dims

print, "Number of MJ2 frames: ", nFrames

FOR i=0, nFrames-1 DO BEGIN
   ; Return data and displayed magnified version. Pause
   ; between each frame for visibility. Unless a timer
   ; is used in conjunction with the FRAME_PERIOD and
   ; TIMESCALE properties, playback will occur as fast
   ; as the frames can be decompressed.
   data = oMJ2read->GetData(i)
   TVSCL, data, 1
   WAIT, 0.2
ENDFOR

; Cleanup.
OBJ_DESTROY, oMJ2read

END