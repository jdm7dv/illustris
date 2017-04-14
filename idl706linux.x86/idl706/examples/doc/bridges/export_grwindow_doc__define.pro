;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/export_grwindow_doc__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       export_grwindow_doc__define.pro
;
;  CALLING SEQUENCE: none
;
;  PURPOSE:
;       Shows how to create an IDL drawable export object. This object,
;       which generates histogram plot(s) of RGB and monochrome data
;       inherits from IDLgrWindow. Thus it is capable of receiving
;       graphical output from IDL when it is exported to a COM or Java
;       application.
;
;       To use this object, you must export it using the Export Bridge
;       Assistant. Search for the name of this file in the Online Help index
;       for instructions on how to set the object parameters during export.
;
;  MAJOR TOPICS: Bridges
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       com_export_grwindow_doc.txt: COM sample application using this object
;       export_grwindow_doc_example.java: Java sample application using this object
;       glowing_gas.jpg: initial file used to generate plot
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       12/05,   SM - written
;-
;------------------------------------------------------------------------------
FUNCTION export_grwindow_doc::Init, _REF_EXTRA = _extra

; Some video cards experience problems when using
; OpenGL hardware rendering. We set the window to use
; IDL's software rendering by default. To use hardware
; rendering instead, set renderer=0.
renderer = 1
IF (~self->IDLgrWindow::Init(RENDERER=renderer, $
    _EXTRA=_extra)) THEN RETURN, 0
        
; Define file to initially open.
sFile=FILEPATH('glowing_gas.jpg', SUBDIR=['examples', 'data'])
self->Open, sFile

RETURN, 1

END

;------------------------------------------------------------------------------
PRO export_grwindow_doc::OPEN, sFile

; If file is not passed in, or if an empty string is passed in,
; open dialog for selection of file from which the histogram
; plot will be generated.
filters = ['*.jpg', '*.tif', '*.png', '*.dcm']
IF ~ARG_PRESENT(sFile) THEN BEGIN
   sFile = DIALOG_PICKFILE(PATH=FILEPATH('',SUBDIR=['examples','data']), $
      TITLE='Choose file for plot generation', FILTER=filters)
ENDIF
IF sFile EQ '' THEN BEGIN
   sFile = DIALOG_PICKFILE(PATH=FILEPATH('',SUBDIR=['examples','data']), $
      TITLE='Choose file for plot generation', FILTER=filters)
ENDIF

; If no file is selected, return to the previous  
; level.  
IF (sFile EQ '') THEN RETURN

; Retrieve image information and pixel data.
queryStatus = QUERY_IMAGE(sFile, imageInfo)
imgSize = imageInfo.DIMENSIONS
image = READ_IMAGE(sFile)
imgDims = SIZE(image, /DIMENSIONS)

; Determine whether or not the image is RGB. If RGB,
; determine type of interleaving.
If imageInfo.Channels EQ 3 THEN BEGIN
   vRGB=1
   interleaving = WHERE((imgDims NE imgSize[0]) AND $
      (imgDims NE imgSize[1]))
   IF interleaving EQ 0 THEN Begin
      vRows=imgDims[1]
      vCols=imgDims[2]
   ENDIF
   IF interleaving EQ 1 THEN BEGIN
      vRows=imgDims[0]
      vCols=imgDims[2]
   ENDIF
   IF interleaving EQ 2 THEN BEGIN
      vRows=imgDims[0]
      vCols=imgDims[1]
   ENDIF
ENDIF ELSE BEGIN
   ; Image is monochrome.
   vRGB=0
   vRows=imgDims[0]
   vCols=imgDims[1]
ENDELSE

; Call procedure to create plots and plot components.
self->CreatePlots, image, vRows, vCols, vRGB

END


;------------------------------------------------------------------------------
PRO export_grwindow_doc::CREATEPLOTS, image, vRows, vCols, vRGB
; Create histogram plot(s) and plot components for image data.

; Get objects and define object characteristics.
self->GetProperty, oXaxis=oXaxis, oYaxis=oYaxis, $
   oXtext=oXtext, oYtext=oYtext, oPlotColl=oPlotColl, $
   oModel=oModel, oView=oView

self.oXaxis=OBJ_NEW("IDLgrAxis")
self.oYaxis=OBJ_NEW("IDLgrAxis")
self.oXtext=OBJ_NEW("IDLgrText", "Bin Number")
self.oYtext=OBJ_NEW("IDLgrText", "Density per Bin")
self.oXaxis->SetProperty, DIRECTION=0, TITLE=self.oXtext
self.oYaxis->SetProperty, DIRECTION=1, TITLE=self.oYtext

; Generate histogram plots for RGB image data:
IF vRGB EQ 1 Then Begin
	vPixelData = REFORM(image)

	; Calculate the histogram of each channel within the
	; RGB image.
	vRedHistogram = HISTOGRAM(REFORM(vPixelData[0, *, *]))
	vGreenHistogram = HISTOGRAM(REFORM(vPixelData[1, *, *]))
	vBlueHistogram = HISTOGRAM(REFORM(vPixelData[2, *, *]))
	; Determine the parameters of the histogram data.
	vMinHistogram = MIN([MIN(vRedHistogram), $
	   MIN(vGreenHistogram), $
	   MIN(vBlueHistogram)])
	vBins = FINDGEN(N_ELEMENTS(vRedHistogram)) + vMinHistogram
	vMinBins = MIN(vBins)
	vMaxBins = MAX(vBins)
	vMaxHistogram = MAX([MAX(vRedHistogram), $
	   MAX(vGreenHistogram), $
	   MAX(vBlueHistogram)])
	; Using the derived data parameters, determine the plot
	; display parameters.
	vLocation = [vMinBins, vMinHistogram, 0.]
	vXRange = [vMinBins, vMaxBins]
	vYRange = [vMinHistogram, vMaxHistogram]
	; Set the location  and ranges of the axes.
	self.oXAxis -> SetProperty, LOCATION=vLocation, $
	   RANGE=vXRange
	self.oYAxis -> SetProperty, LOCATION=vLocation, $
	   RANGE=vYRange

	; Use the data dimensions to determine tick mark length.
	; Set the size of the tick mark label text. Define the
	; x- and y-axis to be the exact length as specified by
	; the range.
	vXTickLength = 0.05*(vYRange[1] - vYRange[0])
	self.oXAxis -> SetProperty, TICKLEN=vXTickLength, $
	   COLOR=[0,0,255], EXACT=1

	vYTickLength = 0.05*(vXRange[1] - vXRange[0])
	self.oYAxis -> SetProperty, TICKLEN=vYTickLength, $
	   COLOR=[0,0,255], EXACT=1

	; Create plot objects:
	; Red channel histogram curve.
	oPlotRed = OBJ_NEW("IDLgrPlot")
	oPlotRed->SetProperty, DATAY=vRedHistogram, $
	   HISTOGRAM=1, COLOR=[255, 0, 0], $
	   DATAX=vBins, XRANGE=vXRange, YRANGE=vYRange

	; Green channel histogram curve.
	oPlotGreen = OBJ_NEW("IDLgrPlot")
	oPlotGreen->SetProperty, DATAY=vGreenHistogram, $
	   HISTOGRAM=1, COLOR=[0,255,0], $
	   DATAX=vBins, XRANGE=vXRange, YRANGE=vYRange

	; Blue channel histogram curve.
	oPlotBlue = OBJ_NEW("IDLgrPlot")
	oPlotBlue->SetProperty, DATAY=vBlueHistogram, $
	   HISTOGRAM=1, COLOR=[0,0,255], $
	   DATAX=vBins, XRANGE=vXRange, YRANGE=vYRange

	; Create model and add plots and axes.
	self.oModel = OBJ_NEW("IDLgrModel")
	self.oModel->Add, oPlotRed
	self.oModel->Add, oPlotGreen
	self.oModel->Add, oPlotBlue
	self.oModel->Add, self.oXaxis
	self.oModel->Add, self.oYaxis

	; Create display objects.
	self.oView = OBJ_NEW("IDLgrView")
	self.oView->Add, self.oModel
	
	; Set the GRAPHICS_TREE property as required for export objects
	; inheriting from IDLgrWindow.
	self->SetProperty, GRAPHICS_TREE = self.oView

	; Determine and set viewplane rectangle using SET_VIEW.
	SET_VIEW, self.oView, self, XRANGE=vXrange, YRANGE=vYrange, $
	   ISOTROPIC=0, DO_ASPECT=1

	;Display the plots.
	self->Draw, self.oView

	; Create a collection.
	self.oPlotColl = OBJ_NEW("IDL_Container")

	; Add objects that may need to be accessed to the collection.
	self.oPlotColl->Add, oPlotRed
	self.oPlotColl->Add, oPlotGreen
	self.oPlotColl->Add, oPlotBlue
ENDIF

; Generate histogram plot for monochrome image data:
IF  vRGB EQ 0 Then Begin

	; Display a histogram for the first monochrome image.
	vPixelData = REFORM(image, vcols, vrows)
	vpixledata = REFORM(vPixelData)
	vHistogram = HISTOGRAM(vPixelData)

	; Determine the parameters of the histogram data.
	vMinHistogram = MIN(vHistogram)
	vBins = FINDGEN(N_ELEMENTS(vHistogram)) + MIN(vPixelData)
	vMinBins = MIN(vBins)
	vMaxBins = MAX(vBins)
	vMaxHistogram = MAX(vHistogram)

	; Using the derived data parameters, determine the plot
	; display parameters.
	vLocation = [vMinBins, vMinHistogram, 0.]
	vXRange = [vMinBins, vMaxBins]
	vYRange = [vMinHistogram, vMaxHistogram]

	; Set the location and range of the axes.
	self.oXAxis->SetProperty, LOCATION=vLocation, $
	   RANGE=vXRange
	self.oYAxis->SetProperty, LOCATION=vLocation, $
	   RANGE=vYRange


	; Use the data dimensions to determine tick mark length.
	; Set the size of the tick mark label text. Define the
	; x- and y-axis to be the exact length as specified by
	; the range.
	vXTickLength = 0.05*(vYRange[1] - vYRange[0])
	self.oXAxis->SetProperty, TICKLEN=vXTickLength, $
       COLOR=[0,0,255], EXACT=1
	vYTickLength = 0.05*(vXRange[1] - vXRange[0])
	self.oYAxis->SetProperty, TICKLEN=vYTickLength, $
	   COLOR=[0,0,255], EXACT=1

	; Create the histogram plot for monochrome data and
	; configure plot characteristics.
	oPlotHistogram = OBJ_NEW("IDLgrPlot")
	oPlotHistogram->SetProperty,  HISTOGRAM=1, $
	   DATAY=vHistogram, DATAX=vBins, XRANGE=vXRange, $
	   YRANGE=vYRange

	; Add the plot and axes to the model.
	self.oModel = OBJ_NEW("IDLgrModel")
	self.oModel->Add, oPlotHistogram
	self.oModel->Add, self.oXaxis
	self.oModel->Add, self.oYaxis
	self.oView = OBJ_NEW("IDLgrView")
	self.oView->Add, self.oModel
	
	; Set the GRAPHICS_TREE property as required for export objects
	; inheriting from IDLgrWindow.
	self->SetProperty, GRAPHICS_TREE = self.oView

	; Determine and set the viewplane rectangle before
	; displaying the plot. .
	SET_VIEW, self.oView, self, XRANGE=xrange, YRANGE=yrange, $
	   ISOTROPIC=0, DO_ASPECT=1
	self->Draw, self.oView

	; Create a collection and add the plot.
	self.oPlotColl = OBJ_NEW("IDL_Container")
	self.oPlotColl->Add, oPlotHistogram
ENDIF

END

;------------------------------------------------------------------------------
PRO export_grwindow_doc::CLEANUP
; Clean up objects. Plots are contained in the plot collection
; object.

self->GetProperty, oPlotColl=oPlotColl, oModel=oModel, $
   oView=oView, oXtext=oXtext, oYtext=oYtext, $
   oXaxis=oXaxis, oYaxis=oYaxis

; General cleanup.
OBJ_DESTROY, [self.oPlotColl, self.oModel, self.oView,  $
   self.oXtext, self.oYtext, self.oXaxis, self.oYaxis]

self->IDLgrWindow::Cleanup

END


;------------------------------------------------------------------------------
PRO export_grwindow_doc::CHANGELINE, style
; Change the linestyle of each plot based on the value
; of the style argument.

self->GetProperty, oPlotColl=oPlotColl, $
   oView=oView

count = self.oPlotColl->Count()

; Iterate through the collection of plots and apply
; the linestyle change to each one.
FOR i = 0, count-1 DO BEGIN
   oPlot=self.oPlotColl->Get(POSITION=i)
   oPlot->SetProperty, LINESTYLE=style
ENDFOR

self->Draw, self.oView

END

;------------------------------------------------------------------------------
; Object properties will be extracted from the IDL source
; object by compiling the list of all keywords on either
; or both the SetProperty and GetProperty methods of the
; IDL source object.
PRO export_grwindow_doc::GetProperty, $
   oMODEL=oModel, oVIEW=oView, $
   oPLOTCOLL=oPlotColl,  OXTEXT=oXtext, OYTEXT=oYtext, $
   OXAXIS=oXaxis, OYAXIS=oYaxis, SFILE=sFile, _REF_EXTRA=_extra

; Get any export_grwindow_doc object properties.
IF ARG_PRESENT(oModel) THEN oModel = self.oModel
IF ARG_PRESENT(oView) THEN oView = self.oView
IF ARG_PRESENT(oPlotColl) THEN oPlotColl = self.oPlotColl
IF ARG_PRESENT(oXtext) THEN oXtext = self.oXtext
IF ARG_PRESENT(oYtext) THEN oYtext = self.oYtext
IF ARG_PRESENT(oXaxis) THEN oXaxis = self.oXaxis
IF ARG_PRESENT(oYaxis) THEN oYaxis = self.oYaxis
IF ARG_PRESENT(sFile) THEN sFile = self.sFile

; Get superclass properties
IF (N_ELEMENTS(_extra) GT 0) THEN $
   self->IDLgrWindow::GetProperty, _EXTRA = _extra

END


;------------------------------------------------------------------------------
PRO export_grwindow_doc::SetProperty, $
   oMODEL=oModel, oVIEW=oView, $
   oPLOTCOLL=oPlotColl,  OXTEXT=oXtext, OYTEXT=oYtext, $
   OXAXIS=oXaxis, OYAXIS=oYaxis, sFile=sFile,_REF_EXTRA=_extra

IF (N_ELEMENTS(oModel) GT 0) THEN self.oModel = oModel
IF (N_ELEMENTS(oView) GT 0) THEN self.oView = oView
IF (N_ELEMENTS(oPlotColl) GT 0) THEN self.oPlotColl = oPlotColl
IF (N_ELEMENTS(oXtext) GT 0) THEN self.oXtext = oXtext
IF (N_ELEMENTS(oYtext) GT 0) THEN self.oYtext = oYtext
IF (N_ELEMENTS(oXaxis) GT 0) THEN self.oXaxis = oXaxis
IF (N_ELEMENTS(oYaxis) GT 0) THEN self.oYaxis = oYaxis
IF (N_ELEMENTS(sFile) GT 0) THEN self.sFile = sFile

IF (N_ELEMENTS(_extra) GT 0) THEN $
   self->IDLgrWindow::SetProperty, _EXTRA = _extra

END


;------------------------------------------------------------------------------
PRO export_grwindow_doc__define
; Object definition.

; Define object instance data.
struct={export_grwindow_doc, $
   INHERITS IDLgrWindow, $
 ;  oWindow:OBJ_NEW(), $
   oModel:OBJ_NEW(), $
   oView:OBJ_NEW(), $
   oPlotColl:OBJ_NEW(), $
   oXtext:OBJ_NEW(), $
   oYtext:OBJ_NEW(), $
   oXaxis:OBJ_NEW(), $
   oYaxis:OBJ_NEW(), $
   style:0B, $
   sFile:'' $
   }

END