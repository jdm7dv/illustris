;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/mj2_tile_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       mj2_tile_doc.pro
;
;  CALLING SEQUENCE: mj2_tile_doc
;
;  PURPOSE:
;       Demonstrates how to create and read RGB tiles in a MJ2
;       file from a tiled, RGB JPEG2000 image.
;
;  MAJOR TOPICS: Language
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       ohare.jpg.
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
PRO mj2_tile_doc

; Create the JPEG2000 file, if not already generated, from a
; 5000 by 5000 RBG image.
;------------------------------------------------------------------------------
filename = FILEPATH('ohare.jpg', $
   SUBDIRECTORY=['examples', 'data'])
jp2filename = FILEPATH('ohareJP2tile.jp2', /TMP)
IF ~FILE_TEST(jp2filename) THEN BEGIN

   ; Notify user that processing is occurring.
   void = DIALOG_MESSAGE(['The application creates a JPEG2000 file from a ' $
      +'5000x5000 pixel JPEG file. ', ' ', ' The new file, ohareJP2tile.jp2, ' $
      +'will be created in your temporary directory, ', $
      ' ',  + FILEPATH('', /TMP)+'.', $
      ' ', $
      + 'This might take a noticeable ' $
      +'amount of time, depending on your system speed.'], /INFORMATION, $
      Title='Image Tile Creation Time Required')
   WIDGET_CONTROL, /HOURGLASS

   ; Get data stored in a regular JPEG file.
   READ_JPEG, filename, jpegImg, TRUE=1
   imageDims = SIZE(jpegImg, /DIMENSIONS)

   ; Prepare JPEG2000 object property values.
   ncomponents = 3
   nLayers = 20
   nLevels = 6
   offset = [0,0]
   jp2TileDims = [1000, 1000]
   jp2TileOffset = [0,0]
   bitdepth = [8,8,8]

   ; Create the JPEG2000 image object.
   oJP2File = OBJ_NEW('IDLffJPEG2000',jp2filename , WRITE=1)
   oJP2File->SetProperty, N_COMPONENTS=nComponents, $
      N_LAYERS=nLayers, $
      N_LEVELS=nLevels, $
      OFFSET=offset, $
      TILE_DIMENSIONS=JP2TileDims, $
      TILE_OFFSET=JP2TileOffset, $
      BIT_DEPTH=bitDepth, $
      DIMENSIONS=[imageDims[1],ImageDims[2]]

   ; Set image data, and then destroy the object. You must
   ; create and completely close the jp2 file object before
   ; you can access the data..
   oJP2FILE->SetData, jpegImg
   OBJ_DESTROY, oJP2FILE
ENDIF
;---------------------------------------------------------------------------

; Indicate processing while program creates and accesses data
; in three separate objects.
WIDGET_CONTROL, /HOURGLASS

; Access the JPEG2000 image and get properties.
jp2file = FILEPATH('ohareJP2tile.jp2', /TMP)
oJP2 = OBJ_NEW('IDLffJPEG2000', jp2file, /PERSISTENT)
oJP2->GetProperty, N_COMPONENTS=nComponents, $
   N_LAYERS=nLayers, $
   N_LEVELS=nLevels, $
   N_TILES=nTiles, $
   TILE_DIMENSIONS=JP2TileDims, $
   BIT_DEPTH=bitDepth, $
   DIMENSIONS= imageDims

; Create the example MJ2 image file in the temporary directory.
file = FILEPATH("mj2_tile_ex.mj2", /TMP)

; Create the MJ2 file from the JPEG2000 file.
; Set MJ2 properties for a tiled image, based on JP2 tiled image.
; Set other size and quality properties to match the JP2 file.
oMJ2Write = OBJ_NEW('IDLffMJPEG2000', file, /WRITE)
oMJ2Write->SetProperty, DIMENSIONS=[imageDims[0],ImageDims[1]], $
   Tile_Dimensions=[JP2TileDims[0], JP2TileDims[1]], $
   N_COMPONENTS=nComponents
oMJ2Write->SetProperty, N_Levels=nLevels, N_Layers=nLayers

; Set each JP2 tile to the MJ2 file in a separate SetData call.
FOR i=0, nTiles-1 DO BEGIN
   jp2Data = oJP2->GetData(Tile_Index=i)
   result = oMJ2Write->SetData(jp2Data, TILE_INDEX=i)
ENDFOR

; Commit the MJ2 file and cleanup.
result = oMJ2Write->Commit(10000)
OBJ_DESTROY, [oMJ2Write, oJP2]

; Create object to read new MJ2 file. Set PERSISTENT to access
; tiled data. Set DISCARD_LEVELS to display smaller versions of
; the tiles.
oMJ2read = OBJ_NEW('IDLffMJPEG2000', file, /PERSISTENT)
oMJ2read->GetProperty, N_TILES=nTiles, TILE_DIMENSIONS=tileDims
WINDOW, 0, xsize=625, ysize=625
For j=0, nTiles-1 DO BEGIN
   data = oMJ2read->GetData(0, DISCARD_LEVELS=3, TILE_INDEX=j, /RGB)
   TVSCL, data, j, TRUE=1
   WAIT, 0.3
ENDFOR

; Cleanup.
OBJ_DESTROY, oMJ2read

END
