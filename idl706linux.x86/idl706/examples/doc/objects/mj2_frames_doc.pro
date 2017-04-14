;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/mj2_frames_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       mj2_frames_doc.pro
;
;  CALLING SEQUENCE: mj2_frames_doc
;
;  PURPOSE:
;       Demonstrates how create a simple MJ2 animation and display
;       a subset of frames and various quality layers. The sample
;       animation is written to the temporary directory.
;
;
;  MAJOR TOPICS: Language
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       none
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
;
PRO mj2_frames_doc

; Read image data, which contains 57 frames.
nFrames = 57
head = READ_BINARY( FILEPATH('head.dat', $
  SUBDIRECTORY=['examples','data']), $
  DATA_DIMS=[80,100, 57])

; Create new MJ2 file in the temporary directory.
file = FILEPATH("mj2_frames_ex.mj2",/TMP)

; Create an IDLffMJPEG2000 object.
oMJ2write=OBJ_NEW('IDLffMJPEG2000', file, /WRITE, /REVERSIBLE, $
   N_LAYERS=10)

; Write the data of each frame into the MJ2 file.
FOR i=0, nFrames-1 DO BEGIN
   data = head[*,*,i]
   result = oMJ2write->SetData(data)
ENDFOR

; Commit and close the IDLffMJPEG2000 object.
return = oMJ2write->Commit(10000)
OBJ_DESTROY, oMJ2write

; Create a new IDLffMJPEG2000 object to access MJ2 file.
oMJ2read=OBJ_NEW("IDLffMJPEG2000", file)
oMJ2read->GetProperty,N_FRAMES=nFrames, DIMENSIONS=dims

; Create a window and display simple animation.
WINDOW, 0, XSIZE=2*dims[0], YSIZE=2*dims[1], TITLE="MJ2 Layers"

; Display all quality layers (j) of a dozen frames (i).
FOR i=25, 36 DO BEGIN
   ; Return data and display magnified version. Pause
   ; between each frame for visibility. Unless a timer
   ; is used in conjunction with the FRAME_PERIOD and
   ; TIMESCALE properties, playback will occur as fast
   ; as the frames can be decompressed.
   FOR j=0, 10 DO BEGIN
      data = oMJ2read->GetData(i, MAX_LAYERS=j)
      TVSCL, CONGRID(data, 2*dims[0], 2*dims[1])
      WAIT, 0.1
   ENDFOR
ENDFOR

; Cleanup.
OBJ_DESTROY, oMJ2read

End