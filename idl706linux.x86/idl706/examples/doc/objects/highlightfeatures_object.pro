;  $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/highlightfeatures_object.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO HighlightFeatures_Object

; Determine path to "mineral.png" file.
mineralFile = FILEPATH('mineral.png', $
   SUBDIRECTORY = ['examples', 'data'])

; Import image from file into IDL.
mineralImage = READ_PNG(mineralFile, $
   red, green, blue)

; Determine size of imported image.
mineralSize = SIZE(mineralImage, /DIMENSIONS)

; Initialize objects.
; Initialize display.
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = [mineralSize[0], mineralSize[1]], $
   TITLE = 'mineral.png')
oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT = [0., 0., $
   mineralSize[0], mineralSize[1]])
oModel = OBJ_NEW('IDLgrModel')
; Initialize palette and image.
oPalette = OBJ_NEW('IDLgrPalette', red, green, blue)
oImage = OBJ_NEW('IDLgrImage', mineralImage, $
   PALETTE = oPalette)

; Add image to model, then model to view, and draw final
; view in window.
oModel -> Add, oImage
oView -> Add, oModel
oWindow -> Draw, oView

; Update palette with RAINBOW color table and then
; display image in another instance of the window object.
oPalette -> LoadCT, 13
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = [mineralSize[0], mineralSize[1]], $
   TITLE = 'RAINBOW Color')
oWindow -> Draw, oView

; Define colors for a new color table.
colorLevel = [[0, 0, 0], $ ; black
   [255, 0, 0], $ ; red
   [255, 255, 0], $ ; yellow
   [0, 255, 0], $ ; green
   [0, 255, 255], $ ; cyan
   [0, 0, 255], $ ; blue
   [255, 0, 255], $ ; magenta
   [255, 255, 255]] ; white

; Derive levels for each color in the new color table.
; NOTE: some displays may have less than 256 colors.
numberOfLevels = CEIL(!D.TABLE_SIZE/8.)
level = INDGEN(!D.TABLE_SIZE)/numberOfLevels

; Place each color level into its appropriate range.
newRed = colorLevel[0, level]
newGreen = colorLevel[1, level]
newBlue = colorLevel[2, level]

; Include the last color in the last level.
newRed[!D.TABLE_SIZE - 1] = 255
newGreen[!D.TABLE_SIZE - 1] = 255
newBlue[!D.TABLE_SIZE - 1] = 255

; Update palette with new color table and then
; display image in another instance of the window object.
oPalette -> SetProperty, RED_VALUES = newRed, $
   GREEN_VALUES = newGreen, BLUE_VALUES = newBlue
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   DIMENSIONS = [mineralSize[0], mineralSize[1]], $
   TITLE = 'Cube Corner Colors')
oWindow -> Draw, oView

; Clean-up object references.
OBJ_DESTROY, [oView, oPalette]

END