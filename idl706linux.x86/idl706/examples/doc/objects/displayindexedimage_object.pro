;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/displayindexedimage_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DisplayIndexedImage_Object

; Determine the path to the file.
file = FILEPATH('avhrr.png', $
   SUBDIRECTORY = ['examples', 'data'])

; Query the file to determine image parameters.
queryStatus = QUERY_IMAGE(file, imageInfo)

; Output the results of the query.
PRINT, 'Query Status = ', queryStatus
HELP, imageInfo, /STRUCTURE

; Set the image size parameter.
imageSize = imageInfo.dimensions

; Import in the image.
image = READ_IMAGE(file, red, green, blue)

; Initialize the display objects.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize, TITLE = 'An Indexed Image')
oView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = [0., 0., imageSize])
oModel = OBJ_NEW('IDLgrModel')

; Initialize the image's palette object.
oPalette = OBJ_NEW('IDLgrPalette', red, green, blue)

; Initialize the image object with the resulting
; palette object.
oImage = OBJ_NEW('IDLgrImage', image, $
   PALETTE = oPalette)

; Add the image object to the model, which is added to
; the view, then display the view in the window.
oModel -> Add, oImage
oView -> Add, oModel
oWindow -> Draw, oView

; Use the colorbar object to display the associated
; color table in another window.
oCbWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = [256, 48], $
   TITLE = 'Original Color Table')
oCbView = OBJ_NEW('IDLgrView', $
   VIEWPLANE_RECT = [0., 0., 256., 48.])
oCbModel = OBJ_NEW('IDLgrModel')
oColorbar = OBJ_NEW('IDLgrColorbar', PALETTE = oPalette, $
   DIMENSIONS = [256, 16], SHOW_AXIS = 1)
oCbModel -> Add, oColorbar
oCbView -> Add, oCbModel
oCbWindow -> Draw, oCbView

; Change the palette (color table) to the EOS B
; pre-defined color table.
oPalette -> LoadCT, 27

; Redisplay the image with the other color table in
; another window.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = imageSize, TITLE = 'An Indexed Image')
oWindow -> Draw, oView

; Redisplay the colorbar with the other color table
; in another window.
oCbWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = [256, 48], $
   TITLE = 'EOS B Color Table')
oCbWindow -> Draw, oCbView

; Clean up object references.
OBJ_DESTROY, [oView, oCbView, oPalette]

END