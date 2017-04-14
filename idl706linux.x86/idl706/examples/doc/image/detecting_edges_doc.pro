;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/detecting_edges_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO detecting_edges_doc

; Read in image data from the binary file nyny.dat
file = FILEPATH('nyny.dat', SUBDIRECTORY = ['examples', 'data'])
imageSize = [768, 512]
image = READ_BINARY(file, DATA_DIMS = imageSize)

; Crop the image to focus on the bridges
croppedSize = [96, 96]
croppedImage = image[200:(croppedSize[0] - 1) + 200, $
   180:(croppedSize[1] - 1) + 180]

; Specify the size of the final displayed images
displaySize = [150, 150]

; Apply various edge detection filters and resize the images to the
; final display size, the display using iImage.

unfilteredimage = CONGRID(croppedImage, displaySize[0], displaySize[1])

IIMAGE, unfilteredimage, DIMENSIONS=[700,700], VIEW_GRID=[4,2], $
   VIEW_TITLE='Original', /NO_SAVEPROMPT, $
   TITLE='Comparison of Edge Detection Filters'

robertsfilteredImage = CONGRID(ROBERTS(croppedImage), $
   displaySize[0], displaySize[1])

IIMAGE, robertsfilteredImage, /VIEW_NEXT , /OVERPLOT, $
   VIEW_TITLE='ROBERTS Filter'

sobelfilteredimage = CONGRID(SOBEL(croppedImage), $
   displaySize[0], displaySize[1])

IIMAGE, sobelfilteredimage, /VIEW_NEXT, /OVERPLOT, $
   VIEW_TITLE='SOBEL Filter'

prewittfilteredimage = CONGRID(PREWITT(croppedImage), $
   displaySize[0], displaySize[1])

IIMAGE, prewittfilteredimage, /VIEW_NEXT, /OVERPLOT, $
   VIEW_TITLE='PREWITT Filter'

shiftdifffilteredimage = CONGRID(SHIFT_DIFF(croppedImage), $
   displaySize[0], displaySize[1])

IIMAGE, shiftdifffilteredimage, /VIEW_NEXT, /OVERPLOT, $
   VIEW_TITLE='SHIFT_DIFF Filter'

edgedogfilteredimage = CONGRID(EDGE_DOG(croppedImage), $
   displaySize[0], displaySize[1])

IIMAGE, edgedogfilteredimage, /VIEW_NEXT, /OVERPLOT, $
   VIEW_TITLE='EDGE_DOG Filter'

laplacianfilteredimage = CONGRID(LAPLACIAN(croppedImage), $
   displaySize[0], displaySize[1])

IIMAGE, laplacianfilteredimage, /VIEW_NEXT, /OVERPLOT, $
   VIEW_TITLE='LAPLACIAN Filter'

embossfilteredimage = CONGRID(EMBOSS(croppedImage), $
   displaySize[0], displaySize[1])

IIMAGE, embossfilteredimage, /VIEW_NEXT, /OVERPLOT, $
   VIEW_TITLE='EMBOSS Filter'

; The following segment resizes the titles of the individual iImage views
; for greater legibility.

void = ITGETCURRENT(TOOL=imageTool)

FOR i = 1, 8 DO BEGIN

	view_id = '*view_'+STRTRIM(i, 2)+'*text'

	view_title_id = imageTool->FindIdentifiers(view_id)
	view_title_obj = imageTool->GetByIdentifier(view_title_id)
	void = view_title_obj->GetPropertyByIdentifier('FONT_SIZE', font_size)
	void = imageTool->DoSetProperty(view_title_id, 'FONT_SIZE', font_size*4)

	void = view_title_obj->GetPropertyByIdentifier('LOCATIONS', locations)
	locations[1] = locations[1]*1.1
	void = imageTool->DoSetProperty(view_title_id, 'LOCATIONS', locations)

ENDFOR

imageTool->CommitActions

END
