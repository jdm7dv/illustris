;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/idlbridge_img_processing.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       idlbridge_img_processing.pro
;
;  CALLING SEQUENCE: idlbridge_img_processing
;
;  PURPOSE:
;       This procedure is designed to be called from the Execute
;       method in idlbridge_simple_doc.pro or from idlbridge_tiling2_doc.pro. The
;       idlbridge_simple_doc.pro file shows how to call this procedure in a
;       child process and return status. The second file, idlbridge_tiling2_doc.pro,
;       incorporates this ability into a more complex image tiling application.
;       This more effectively demonstrates the ability to do computationally
;       intensive tasks in the interactive main process as well
;       as in a child process (this procedure).
;
;       This procedure takes a JP2 filename as an argument and performs
;       edge enhancement on each of the three JP2 file components. It
;       then creates a new JPEG2000 file containing the filtered data. A
;       progress bar shows what percentage of the task has been completed. The
;       IDL_IDLBridge object Status method (in the calling program) returns
;       overall process status (idle, executing, completed, aborted, or error).
;       A text file (success.dat) is written to indicate start and end of processing
;       time. This is not needed for any IDL_IDLBridge status information.
;
;  MAJOR TOPICS: Language
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       ohareJP2.jp2,
;       idlbridge_simple_doc or idlbridge_tilingjp2_doc.pro
;
;  NAMED STRUCTURES:
;       None
;
;  COMMON BLOCS:
;       shareWidID
;
;  MODIFICATION HISTORY:
;       8/05,   SM - written
;-
;-----------------------------------------------------------------
;
;
;-----------------------------------------------------------------
; Update a status bar with percentage of processing task completed
; in child process.
PRO idlbridge_img_processing_update, pState

	wDrawProgress = (*pState).wDrawProgress
	vProgress = (*pState).vProgress
	(*pState).xpos = 300*(vProgress/100.0)
	ERASE, 255
	POLYFILL, [0,0,5+(*pState).xpos,5+(*pState).xpos], $
	   [0, 19, 19,0], /device, color=80

END

;-----------------------------------------------------------------
; Remove progress bar display if user aborts or if there is an error.
PRO idlbridge_img_processing_abort_cleanup

    ; Access common block value and cleanup.
    COMMON shareWidID, wChildBase

    WIDGET_CONTROL, wChildBase, GET_UVALUE=pState
	WIDGET_CONTROL,  wChildBase, /DESTROY
	PTR_FREE, pState

END

;-----------------------------------------------------------------
; Stub only. No need for default event as there is no user
; interaction with the widget.
PRO idlbridge_img_processing_event
END

;-----------------------------------------------------------------
; Accept the filename to be filtered .
PRO idlbridge_img_processing, filename

	; Enable the program to be run outside of being called from
	; idlbridge_simple_doc.pro or idlbridge_tilingjp2_doc.pro.
	; in the main IDL process. Requires the presence of
	; ohareJP2.jp2 file in the IDL temporary directory.
	IF ~FILE_TEST(FILEPATH('ohareJP2.jp2', /TMP)) $
	   THEN BEGIN
	   void = DIALOG_MESSAGE(['Required file, ohareJP2.jp2 does' $
	      + ' not exist in ' +  FILEPATH('', /TMP), ' ', $
	      + ' You must run  idlbridge_simple_doc.pro or ' $
	      + ' idlbridge_tilingjp2_doc.pro to create the file.'], $
	      /ERROR, TITLE='Missing File')
	   RETURN
	ENDIF
	IF ~ARG_PRESENT('filename') THEN BEGIN
     filename = FILEPATH('ohareJP2.jp2', /TMP)
    ENDIF

	; Mark start time.
	startstring = 'started ' + SYSTIME()

    ; Create a common block to hold the widget ID, wChildBase. This
    ; is used to cleanup if processing is completed, the user aborts
    ; or execution ends due to an error.
    COMMON shareWidID, wChildBase

    ; Make simple widget interface.
	wChildBase = WIDGET_BASE(TITLE='Process Progress', /COLUMN, $
	   XOFFSET=680)
	wLabel = WIDGET_LABEL(wChildBase, VALUE='Completion Status:', $
	   UVALUE='LABEL')
	wDrawProgress = WIDGET_DRAW(wChildBase, xsize=300, ysize=20, $
	   uvalue="PROGRESS")

    ; Set initial color table for draw widget.
    DEVICE, DECOMPOSED=0
    LOADCT, 39

	State = {wChildBase:wChildBase, wDrawProgress:wDrawProgress, $
	   vProgress:0, xpos:0}
	pState = PTR_NEW(State)
	WIDGET_CONTROL, wChildBase, SET_UVALUE=pState
	WIDGET_CONTROL, wChildBase, /REALIZE
	WIDGET_CONTROL, /HOURGLASS

    ; Update progress bar.
	(*pState).vProgress=8
	idlbridge_img_processing_update, pState

	; Open the JP2 file and get image properties, which will be
	; duplicated in the filtered image.
	oJP2File = OBJ_NEW('IDLffJPEG2000', filename, PERSISTENT=0)
	oJP2File->GetProperty, N_COMPONENTS=nComponents, $
	   N_LAYERS=nLayers, $
	   N_LEVELS=nLevels, $
	   OFFSET=offset, $
	   TILE_DIMENSIONS=JP2TileDims, $
	   TILE_OFFSET=JP2TileOffset, $
	   BIT_DEPTH=bitDepth, $
	   DIMENSIONS=imageDims
	(*pState).vProgress=10
	idlbridge_img_processing_update, pState

	; Get data and destroy the JPEG2000 object.
	data = oJP2File->GetData()
	(*pState).vProgress=30
	idlbridge_img_processing_update, pState

	OBJ_DESTROY, oJP2File
	(*pState).vProgress=35
	idlbridge_img_processing_update, pState

	; It is known that this file has three components. Retrieve and
	; filter the data associated with each component.
	data1=reform(data[0,*,*])
	data2=reform(data[1,*,*])
	data3=reform(data[2,*,*])

	result1 = ROBERTS(data1)
	(*pState).vProgress=40
	idlbridge_img_processing_update, pState

	result2 = ROBERTS(data2)
	(*pState).vProgress=45
	idlbridge_img_processing_update, pState

	result3 = ROBERTS(data3)
	(*pState).vProgress=50
	idlbridge_img_processing_update, pState

	; Designate a new filename.
	jp2filename_roberts = FILEPATH('ohareJP2_roberts.jp2', /TMP)

	(*pState).vProgress=55
	idlbridge_img_processing_update, pState

	; Create the JPEG2000 image object.
	oJP2FileRoberts = OBJ_NEW('IDLffJPEG2000', jp2filename_roberts , WRITE=1)
	oJP2FileRoberts->SetProperty, N_COMPONENTS=nComponents, $
	   N_LAYERS=nLayers, $
	   N_LEVELS=nLevels, $
	   OFFSET=offset, $
	   TILE_DIMENSIONS=JP2TileDims, $
	   TILE_OFFSET=JP2TileOffset, $
	   BIT_DEPTH=bitDepth, $
	   DIMENSIONS=[imageDims[0],imageDims[1]]
	(*pState).vProgress=65
	idlbridge_img_processing_update, pState

	; Set image data, and then destroy the object. You must
	; create and completely close the jp2 file object before
	; you can access the data.
	oJP2FileRoberts->SetData, result1, result2, result3
	(*pState).vProgress=85
	idlbridge_img_processing_update, pState

	OBJ_DESTROY, oJP2FileRoberts
	(*pState).vProgress=95
	idlbridge_img_processing_update, pState

	; If you run this procedure in the main IDL session,
	; the print statement appears. When you run this procedure
	; as a child process, the print statement does not appear.
	; There is no connection between a child process and
	; the IDL development environment.
	PRINT, "executed"

	; Create the text file with start and end times - only for
	; reference. This is not necessary.
	endstring ="  success " + SYSTIME()
	file = FILEPATH('successfile.dat', /TMP)
	OPENW, unit, file, /GET_LUN
	WRITEU, unit, startstring
	WRITEU, unit, endstring
	CLOSE, unit

	(*pState).vProgress=100
	idlbridge_img_processing_update, pState

    ; Clean up once processing is finished.
	idlbridge_img_processing_abort_cleanup

END
