;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/drawroiex.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO DrawROIex

; Prepare the display device.
DEVICE, DECOMPOSED = 0, RETAIN = 2
LOADCT, 0

; Select and open the image file and get its size.
kneeImg = READ_DICOM(FILEPATH('mr_knee.dcm',$
   SUBDIRECTORY = ['examples','data']))
dims = SIZE(kneeImg, /DIMENSIONS)

; Flip the image vertically.
kneeImg = ROTATE(BYTSCL(kneeImg), 2)

; Open the file in the XROI utility to select the femur region.
XROI, kneeImg, REGIONS_OUT = femurROIout, $
   ROI_GEOMETRY = femurGeom,$
   STATISTICS = femurStats, /BLOCK

; Open the file in XROI to select tibia region.
XROI, kneeImg, REGIONS_OUT = tibiaROIout, $
   ROI_GEOMETRY = tibiaGeom, $
   STATISTICS = tibiaStats, /BLOCK

; Create a window and display the original image.
WINDOW, 0, XSIZE = dims[0], YSIZE = dims[1]
TVSCL, kneeImg

; Load the 16-level colortable to display regions in color
; and draw them in a Direct Graphics window.
LOADCT, 12
DRAW_ROI, femurROIout, /LINE_FILL, COLOR = 80, SPACING = 0.1, $
   ORIENTATION = 315, /DEVICE
DRAW_ROI, tibiaROIout, /LINE_FILL, COLOR = 42, SPACING = 0.1, $
   ORIENTATION = 30, /DEVICE

; Print selected stats for the femur and tibia.
PRINT, 'FEMUR Region Geometry and Statistics'
PRINT, 'area =', femurGeom.area, $
   '    perimeter = ', femurGeom.perimeter, $
   '    population =',  femurStats.count
PRINT, ' '
PRINT, 'TIBIA Region Geometry and Statistics'
PRINT, 'area =', tibiaGeom.area, $
   '    perimeter = ', tibiaGeom.perimeter, $
   '    population =', tibiaStats.count

; Destroy object references.
OBJ_DESTROY, [femurROIout, tibiaROIout]

END