;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/mj2_palette_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       mj2_palette_doc.pro
;
;  CALLING SEQUENCE: mj2_palette_doc
;
;  PURPOSE:
;       Demonstrates how to create and a MJ2 that has a palette.
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
PRO mj2_palette_doc

; Set up display for indexed image with palette.
DEVICE, RETAIN = 2, DECOMPOSED = 0

; Access image data and associated palette.
world = READ_PNG (FILEPATH ('avhrr.png', $
   SUBDIRECTORY = ['examples', 'data']), R, G, B)
dims = SIZE(world, /DIMENSIONS)

; Create a MJ2 file in the temporary directory. Assign the
; palette arrays to the PALETTE property.
file =FILEPATH("mj2_palette_ex.mj2", /TMP)
oMJ2write = OBJ_NEW('IDLffMJPEG2000', file, /WRITE, $
   PALETTE=[[R], [G], [B]])

; Set initial size by which to shrink image.
vSize = 20

; Create animation.
FOR i = 1, 20 DO BEGIN

   ; Write the initial and "shrunken" image frames.
   result = oMJ2write->SetData(world)
   newX=dims[0]-(i*vSize)
   newY=dims[1]-((i*vSize)/2)

   ; Decreas the size of the existing image array.
   world = CONGRID(world, newX, newY)

   ; Create an image array equal to the original array size
   ; and add the smaller world image array into the padded array
   ; at the specified location (the lower-left corner of the
   ; smaller world array will be place here).
   padworld = REPLICATE(255, ((newX + i*vSize)), $
     (newY + ((i*vSize)/2)))
   padworld [(i*vSize)/4,(i*vSize)/4] = world
   world = padworld
ENDFOR

; Close the background processing thread and destroy the object.
result = oMJ2write->Commit(1000)
OBJ_DESTROY, oMJ2write

; Create a new IDLffMJPEG2000 object to access MJ2 file.
oMJ2read=OBJ_NEW("IDLffMJPEG2000", file)
oMJ2read->GetProperty,N_FRAMES=nFrames, DIMENSIONS=dims, $
   PALETTE=palette

; Save existing palette.
TVLCT, old_red, old_green, old_blue, /GET

; Load the image palette.
TVLCT, palette[*, 0], palette [*, 1], palette[*, 2]

; Make sure the max color is white (aesthetic reasons only).
maxColor = !D.TABLE_SIZE - 1
TVLCT, 255, 255, 255, maxColor

WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1]
; Display the frames of data.
FOR i=0, nFrames-1 DO BEGIN
   ; Return data and displayed magnified version. Use WAIT to
   ; pause between each frame for visibility. Unless a timer
   ; is used in conjunction with the FRAME_PERIOD and
   ; TIMESCALE properties, the default playback rate will be
   ; as fast as the frames can be decompressed.
   data = oMJ2read->GetData(i)
   TV,   data
   WAIT, 0.2
ENDFOR

; Cleanup.
OBJ_DESTROY, oMJ2read

; Restore color palette.
TVLCT, old_red, old_green, old_blue

END