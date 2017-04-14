; $Id: //depot/idl/IDL_70/idldir/examples/doc/dicom/dicom_example.pro#2 $
;
; Copyright (c) 1995-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME: dicom_example
;
; PURPOSE: This widget application illustrates the use of the IDL DICOM
;          procedural and object interfaces.
;
; MAJOR TOPICS: DICOM
;
; CALLING SEQUENCE: dicom_example
;
; PROCEDURE: dicom_example
;
; MAJOR FUNCTIONS and PROCEDURES:
;
; MODIFICATION HISTORY:  Written by:  RJF, RSI, Oct 1998
;-

;
;	Use the DICOM object API to get specific image information
;
PRO Dicom_ExampleInfo, wBase

   WIDGET_CONTROL, wBase, GET_UVALUE=sData, /NO_COPY

   iIndex = WIDGET_INFO(sData.wSel, /LIST_SELECT)

   sFile = FILEPATH(sData.sNames[iIndex],SUBDIR=['examples','data'])

   ; Create a DICOM object and read in a DICOM file
   oObj = OBJ_NEW("IDLffDICOM")

   IF (oObj->Read(sFile)) THEN BEGIN

     ; Create a list of group,element DICOM tags to be inspected.
     ;
     ; Note that these decimal number pairs should be converted into hex numbers in
     ; order to look them up in the DICOM Standard Part 6: Data Dictionary, PS 3.6.
     ;
     ; For example:
     ;  Decimal number pair 16,16 would be 10,10 in hex. Looking up 10,10 in the DICOM
     ;  Standard Data Dictionary reveals that this tag represents the Patient's Name.
     ;
     ;  decimal  hex value  data dictionary field
     ;  -------  ---------  ---------------------
     ;  16, 16   0010,0010  Patient's Name
     ;  16, 32   0010,0020  Patient ID
     ;  16, 48   0010,0030  Patient's Birth Date
     ;  16, 64   0010,0040  Patient's Sex
     ;   8, 32   0008,0020  Study Date
     ;   8, 96   0008,0060  Modality
     ;   8,112   0008,0070  Manufacturer
     ;   8,128   0008,0080  Institution Name
     ;
	 tags = [ [16,16],[16,32],[16,48],[16,64], $
		 [8,32],[8,96],[8,112],[8,128] ]

         infoText = [ "Information for the file:",sFile,"" ]

	 FOR i=0,(N_ELEMENTS(tags)/2)-1 DO BEGIN
		desc = oObj->GetDescription(tags[0,i],tags[1,i])
		pval = oObj->GetValue(tags[0,i],tags[1,i])
		infoText = [ infotext, desc[0]+":"+(*pval[0])]
	 END

   END ELSE BEGIN

	 infoText = [ $
	  "Unable to read the file:"+sFile+" as a DICOM file."]

   END

   OBJ_DESTROY, oObj

   ShowInfo, TITLE="Image Information", GROUP=wBase, $
           WIDTH=60, HEIGHT=12, INFOTEXT=infoText

   WIDGET_CONTROL, wBase, SET_UVALUE=sData, /NO_COPY

END

;
;	Use the Procedural DICOM API to read and display the images
;
PRO Dicom_ExampleDraw, wBase

   WIDGET_CONTROL, wBase, GET_UVALUE=sData, /NO_COPY

   WIDGET_CONTROL, sData.wDraw, GET_VALUE=nwin

   ; Grab some useful information
   swin = !D.WINDOW
   WSET, nwin
   DEVICE, GET_DECOMPOSED=dcomp

   DEVICE, DECOMPOSED=0

   iIndex = WIDGET_INFO(sData.wSel, /LIST_SELECT)

   sFile = FILEPATH(sData.sNames[iIndex],SUBDIR=['examples','data'])

   ; Check that the image is a DICOM file
   IF (QUERY_DICOM(sFile,sInfo) EQ 1) THEN BEGIN

	IF (sData.iLast NE iIndex) THEN BEGIN
		iSlice = 0
		IF (sInfo.NUM_IMAGES EQ 1) THEN BEGIN
			WIDGET_CONTROL, sData.wSlide, SENSITIVE=0
		END ELSE BEGIN
			WIDGET_CONTROL, sData.wSlide, SENSITIVE=1, $
				SET_SLIDER_MAX=sInfo.NUM_IMAGES-1
		END
		WIDGET_CONTROL, sData.wSlide, SET_VALUE=iSlice
		sData.iLast = iIndex
	END ELSE BEGIN
		WIDGET_CONTROL, sData.wSlide, GET_VALUE=iSlice
	END

	; Read the image
   	Img = READ_DICOM(sFile,R,G,B,IMAGE_INDEX=iSlice)

	; Resize to fit
	IF ((sInfo.DIMENSIONS[0] NE 256) OR $
	    (sInfo.DIMENSIONS[1] NE 256)) THEN BEGIN
		WIDGET_CONTROL, wBase, /HOURGLASS
		IF (sInfo.CHANNELS NE 1) THEN BEGIN
			Img = CONGRID(Img,sInfo.CHANNELS,256,256)
		END ELSE BEGIN
			Img = CONGRID(Img,256,256)
		END
	END

	; Display the image using Direct Graphics
	IF (sInfo.CHANNELS EQ 1) THEN BEGIN
   		LOADCT,0,/SILENT
		TVSCL, Img, /ORDER
	END ELSE BEGIN
		DEVICE, GET_VISUAL_DEPTH=depth
		IF (DEPTH LE 8) THEN BEGIN
			WIDGET_CONTROL, wBase, /HOURGLASS
			Img = COLOR_QUAN(Img,1,R,G,B)
			TVLCT,R,G,B
			TV, Img, /ORDER
		END ELSE BEGIN
			TV, Img, /TRUE, /ORDER
		END
	END

   END ELSE BEGIN

	ERASE

   END

   ; Restore things
   DEVICE, DECOMPOSED=dcomp
   WSET, swin

   WIDGET_CONTROL, wBase, SET_UVALUE=sData, /NO_COPY

END


PRO Dicom_ExampleEventHdlr, event

; This is the event processing routine that takes care of the events being
; sent to it from the XManager.

   WIDGET_CONTROL, GET_UVALUE=control, event.id

   CASE control OF

     "INFO": Dicom_ExampleInfo, event.top

     "EXIT": WIDGET_CONTROL, event.top, /DESTROY

     "PICK": Dicom_ExampleDraw, event.top

     "SLIDE": Dicom_ExampleDraw, event.top

   ENDCASE
END

PRO Dicom_ExampleCleanUp, wBase

     ; Get the color table saved in the window's user value
   WIDGET_CONTROL, wBase, GET_UVALUE=sData

     ; Restore the previous color table.
   TVLCT, sData.colorTable

END


PRO Dicom_Example

; This is the main program that creates the widgets for the examples and then
; registers it with the xmanager.

     ; Get the current color vectors to restore when this application is exited.
   TVLCT, savedR, savedG, savedB, /GET
     ; Build color table from color vectors
   colorTable = [[savedR],[savedG],[savedB]]

   LOADCT,0,/SILENT

     ; Create a non-sizeable window for the widget application
   wBase = WIDGET_BASE(TITLE="View Dicom images", TLB_FRAME_ATTR=1)

   ; Setting the managed attribute indicates our intention to put this app
   ; under the control of XMANAGER, and prevents our draw widgets from
   ; becoming candidates for becoming the default window on WSET, -1. XMANAGER
   ; sets this, but doing it here prevents our own WSETs at startup from
   ; having that problem.
   WIDGET_CONTROL, /MANAGED, wBase

   wCBase = WIDGET_BASE(wBase, /COLUMN)
   wRBase = WIDGET_BASE(wCBase, /ROW)

   wBBase = WIDGET_BASE(wRBase, /COLUMN)

   imglist = ["mr_abdomen.dcm","mr_brain.dcm","mr_knee.dcm","us_test.dcm"]
   wSel = WIDGET_LIST(wBBase, VALUE = imglist, UVALUE="PICK", YSIZE= 4)
   WIDGET_CONTROL, wSel, SET_LIST_SELECT = 0

   wFoo = WIDGET_LABEL(wBBase,VALUE="Image Number:")

   wSlide = WIDGET_SLIDER(wBBase,UVALUE="SLIDE")

   wFoo = WIDGET_BUTTON(wBBase,VALUE="Image Info",UVALUE="INFO")

   wFoo = WIDGET_BUTTON(wBBase,VALUE="Quit",UVALUE="EXIT")

     ; Create the draw widget
   wDraw = WIDGET_DRAW(wRBase, XSIZE = 256, YSIZE = 256, RETAIN = 2)

     ; Make the window visible
   WIDGET_CONTROL, /REALIZE, wBase

     ; Set cursor to arrow cursor
   DEVICE, /CURSOR_ORIGINAL

     ; Save the previous color table in the user value to retore on exit
   sData = { wSel: wSel,   $
	     wDraw: wDraw, $
	     wSlide: wSlide, $
	     iLast : -1, $
	     sNames: imglist, $
	     colorTable: colorTable }
   WIDGET_CONTROL, wBase, SET_UVALUE=sData, /NO_COPY

   Dicom_ExampleDraw, wBase

     ; Register this application with the xmanager
   XManager, "Dicom_Example", wBase, $
      EVENT_HANDLER="Dicom_ExampleEventHdlr", $
      CLEANUP="Dicom_ExampleCleanUp", /NO_BLOCK

END
