; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_iimage.pro#2 $
;
;  Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  NAME:
;       d_iimage
;
;  CALLING SEQUENCE:
;       d_iimage
;
;  PURPOSE:
;       iImage demo
;
;  ARGUMENTS:
;       NONE
;
;  KEYWORDS:
;       _EXTRA - Needed to trap keywords being passed from the demo
;                system calling routine
;
;  MODIFICATION HISTORY:
;       DLD, June 2003, Original
;-

;---------------------------------------------------------------------

PRO d_iimage, _EXTRA=_extra

  ; Load image data.
  fname = FILEPATH('meteor_crater.jpg', SUBDIR=['examples','data'])
  READ_JPEG, fname, imgData

  ; Display the image data in the image tool.
  iimage, imgData, IDENTIFIER=idTool, /no_saveprompt

  ; Flush events to force the iTool to draw.
  void = widget_event(/nowait)

  ; Retrieve reference to the image tool.
  idTool = ITGETCURRENT(TOOL=oTool)

  ; Retrieve a reference to the image visualization.
  oImage = (oTool->GetSelectedItems())[0]

  ; Retrieve a reference to the rectangle ROI manipulator.
  oROIManip = oTool->GetByIdentifier('MANIPULATORS/ROI/RECTANGLE')

  ; Retrieve a reference to the current window
  oWin = oTool->GetCurrentWindow()

  ; Convert visualization coordinates to window coordinates
  ; for the corners of a rectangular ROI.
  oImage->visToWindow, 188,  80, 0, x1, y1, z
  oImage->visToWindow, 240, 126, 0, x2, y2, z

  ; Create a new ROI with those coordinates.
  oROIManip->OnMouseDown,   oWin, x1[0], y1[0], 1, 0, 1
  oROIManip->OnMouseMotion, oWin, x2[0], y2[0], 0
  oROIManip->OnMouseUp,     oWin, x2[0], y2[0], 1

  ; Retrieve a reference to the statistics operation.
  oOpDesc = oTool->GetByIdentifier('OPERATIONS/OPERATIONS/STATISTICS')
  oStatsOp = oOpDesc->GetObjectInstance()

  ; Display statistics for the new ROI.
  result = oStatsOp->DoAction(oTool)

  ; Release the reference to the statistics operation.
  oOpDesc->ReturnObjectInstance, oStatsOp

END
