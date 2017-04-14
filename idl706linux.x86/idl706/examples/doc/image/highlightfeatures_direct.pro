;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/highlightfeatures_direct.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO HighlightFeatures_Direct

; Determine path to "mineral.png" file.
mineralFile = FILEPATH('mineral.png', $
   SUBDIRECTORY = ['examples', 'data'])

; Import image from file into IDL.
mineralImage = READ_PNG(mineralFile, $
   red, green, blue)

; Determine size of imported image.
mineralSize = SIZE(mineralImage, /DIMENSIONS)

; Apply imported color vectors to current color table.
DEVICE, DECOMPOSED = 0
TVLCT, red, green, blue

; Initialize display.
WINDOW, 0, XSIZE = mineralSize[0], YSIZE = mineralSize[1], $
   TITLE = 'mineral.png'

; Display image.
TV, mineralImage

; Load "RAINBOW" color table and display image in
; another window.
LOADCT, 13
WINDOW, 1, XSIZE = mineralSize[0], YSIZE = mineralSize[1], $
   TITLE = 'RAINBOW Color'
TV, mineralImage

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

; Make the new color table current.
TVLCT, newRed, newGreen, newBlue

; Display image in another window.
WINDOW, 2, XSIZE = mineralSize[0], $
   YSIZE = mineralSize[1], TITLE = 'Cube Corner Colors'
TV, mineralImage

END