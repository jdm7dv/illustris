; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_isurface.pro#2 $
;
;  Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
;  NAME:
;       d_isurface
;
;  CALLING SEQUENCE:
;       d_isurface
;
;  PURPOSE:
;       iSurface demo
;
;  ARGUMENTS:
;       NONE
;
;  KEYWORDS:
;       _EXTRA - Needed to trap keywords being passed from the demo
;                system calling routine
;
;  MODIFICATION HISTORY:
;       AGEH, June 2003, Original
;
;---------------------------------------------------------------------

PRO d_isurface, _EXTRA=_extra

  ;; get data for surface
  datafile = filepath('elevbin.dat',SUBDIR=['examples','data'])
  data = read_binary(datafile,DATA_DIMS=[64,64])
  ;; get image for texture map to be placed on surface
  imagefile = filepath('elev_t.jpg',SUBDIR=['examples','data'])
  read_jpeg, imagefile, image

  ;; display the surface
  isurface, data, TEXTURE_IMAGE=image, IDENTIFIER=identifier, /NO_SAVEPROMPT

  ;; flush events to force the iTool to draw
  void = WIDGET_EVENT(/nowait)

  ; Retrieve reference to the image tool.
  idTool = ITGETCURRENT(TOOL=oTool)

  ;; get the current visualization
  oSurface = (oTool->getSelectedItems())[0]
  ;; get the current window
  oWin = oTool->getCurrentWindow()

  ;; get the line profile manipulator
  LinePro = oTool->GetByIdentifier('MANIPULATORS/PROFILE')

  ;; convert vis coordinates to window coords for the endpoints of the
  ;; line profile
  oSurface->visToWindow, 5,20,data[ 5,20],x1,y1,z
  oSurface->visToWindow,53,16,data[53,16],x2,y2,z

  ;; create a new line profile
  LinePro->onMouseDown,  oWin,x1[0],y1[0],1,0,1
  LinePro->onMouseMotion,oWin,x2[0],y2[0],0
  LinePro->onMouseUp,    oWin,x2[0],y2[0],1

END
