;  $Id: //depot/idl/IDL_70/idldir/examples/doc/bridges/idlbridge_simple_doc.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       idlbridge_simple_doc.pro
;
;  CALLING SEQUENCE: idlbridge_simple_doc
;
;  PURPOSE:
;       Demonstrates how the IDL_IDLBridge object, executes a
;       procedure in a child process and receives status
;       from the executing process. This is a distillation of
;       the bridge code that starts a child process from within
;       the image tiling application, idlbridge_tilingjp2_doc.pro.
;
;  MAJOR TOPICS: Language
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       ohare.jpg, idlbridge_img_processing.pro
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       8/05,   SM - written
;-
;-----------------------------------------------------------------
; The callback procedure is automatically called when the child
; process is completed, aborted, or ends due to an error.
PRO simple_callback, status, error, oIDLBridge, userdata

   ; Access pointer data.
   pState = userdata

   ; Write out status, manually setting standard IDL_IDLBridge
   ; status values.
   CASE status of
      2: str="Completed"
      3: str="Error: " + error
      4: str=error ; Aborted message
   ENDCASE

   ; Update status message.
   WIDGET_CONTROL, (*pState).wStatus, SET_VALUE=str

   ; When execution ends, desensitize Abort button and
   ; sensitize Process Image button.
   WIDGET_CONTROL, (*pState).wAbort, SENSITIVE=0
   WIDGET_CONTROL, (*pState).wProcess, /SENSITIVE

   ; If error occurs (3),dismiss progress bar.
   IF (Status EQ 3) THEN $
      ; Call a child process routine to remove the progress bar.
      (*pState).oIDLBridge->Execute, 'idlbridge_img_processing_abort_cleanup'

   ; If process aborted (4), adjust UI controls.
   IF (Status EQ 4) THEN $
      ; Call a child process routine to remove the progress bar.
      (*pState).oIDLBridge->Execute, 'idlbridge_img_processing_abort_cleanup'

END
;
;------------------------------------------------------------------
; Abort an executing process before destroying corresponding bridge
; object on cleanup.
PRO idlbridge_simple_doc_cleanup, id

   WIDGET_CONTROL, id, GET_UVALUE=pState

   IF OBJ_VALID((*pState).oIDLBridge) THEN BEGIN
      IF((*pState).oIDLBridge->Status() EQ 1)THEN $
         (*pState).oIDLBridge->Abort
      OBJ_DESTROY, (*pState).oIDLBridge
   ENDIF

   PTR_FREE, pState

END

;-----------------------------------------------------------------
; Abort child process execution per user request.
PRO idlbridge_simple_doc_abort, pState

   WIDGET_CONTROL, (*pstate).wStatus, SET_VALUE='Aborting'
   (*pState).oIDLBridge->Abort

END

;-----------------------------------------------------------------
; Access bridge object and execute a .pro file in a child
; process.
PRO idlbridge_simple_doc_exec, sEvent, pState

   WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
   WIDGET_CONTROL, (*pState).wProcess, SENSITIVE=0

   ; Make sure the bridge object is available.
   oBridge=(*pState).oIDLBridge
   IF(~OBJ_VALID(oBridge))THEN BEGIN
       void=DIALOG_MESSAGE(/ERROR,'Unable to access ' $
          + 'an IDL_IDLBridge object')
       RETURN
   ENDIF

   ; Use SetVar to pass the filename argument (the name of the
   ; JP2 file) to the filtering procedure. Specify the NOWAIT
   ; keyword to execute the statement asynchronously.
   oBridge->SetVar, 'filename', (*pState).jp2filename
   oBridge->Execute, 'idlbridge_img_processing, filename', /NOWAIT

   ; Update UI.
   WIDGET_CONTROL, (*pState).wAbort, /SENSITIVE

    status = (*pState).oIDLBridge->Status()
   IF status EQ 1 THEN $
      WIDGET_CONTROL, (*pState).wStatus, SET_VALUE="Executing"

END

;-----------------------------------------------------------------
; Determine action from uval in general widget event.
PRO idlbridge_simple_doc_event, sEvent

   WIDGET_CONTROL, sEvent.top, GET_UVALUE=pstate
   WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

   CASE uval OF
      "EXEC": BEGIN
         idlbridge_simple_doc_EXEC, sEvent, pState
         WIDGET_CONTROL, sEvent.handler, SET_UVALUE=pState
         END
      "ABORT": idlbridge_simple_doc_abort, pState
   ELSE:
   ENDCASE

END

;-----------------------------------------------------------------
; Create a JPEG2000 file and simple widget interface.
PRO idlbridge_simple_doc

; Create the JPEG2000 file, if not already generated.
filename = FILEPATH('ohare.jpg', $
   SUBDIRECTORY=['examples', 'data'])
jp2filename = FILEPATH('ohareJP2.jp2', /TMP)
IF ~FILE_TEST(jp2filename) THEN BEGIN

   ; Notify user that processing is occurring.
   void = DIALOG_MESSAGE(['The application creates a JPEG2000 file from a ' $
      +'5000x5000 pixel JPEG file.', ' ', 'This might take a noticeable ' $
      +'amount of time, depending on your system speed.'], /INFORMATION, $
      Title='Image Tile Creation Time Required')
   WIDGET_CONTROL, /HOURGLASS

   ; Get data stored in a regular JPEG file.
   READ_JPEG, filename, jpegImg, TRUE=1
   imageDims = SIZE(jpegImg, /DIMENSIONS)

   ; Prepare JPEG2000 object property values.
   ncomponents = 3
   nLayers = 20
   nLevels = 6
   offset = [0,0]
   jp2TileDims = [1024, 1024]
   jp2TileOffset = [0,0]
   bitdepth = [8,8,8]

   ; Create the JPEG2000 image object.
   oJP2File = OBJ_NEW('IDLffJPEG2000',jp2filename , WRITE=1)
   oJP2File->SetProperty, N_COMPONENTS=nComponents, $
      N_LAYERS=nLayers, $
      N_LEVELS=nLevels, $
      OFFSET=offset, $
      TILE_DIMENSIONS=JP2TileDims, $
      TILE_OFFSET=JP2TileOffset, $
      BIT_DEPTH=bitDepth, $
      DIMENSIONS=[imageDims[1],ImageDims[2]]

   ; Set image data, and then destroy the object. You must
   ; create and completely close the jp2 file object before
   ; you can access the data..
   oJP2FILE->SetData, jpegImg
   OBJ_DESTROY, oJP2FILE

ENDIF

helptext = ['This example utility generates a 15 MB JPEG2000 ' $
   + 'image named ohareJP2.jp2 from the ohare.jpg file in the ' $
   + 'examples/data subdirectory.', $
   ' ', $
   'Click Process Image to process the image in a child ' $
   + 'IDL_IDLBridge process, creating another JPEG2000 file ' $
   + 'named ohareJP2_roberts.jp2. Notice that you can continue ' $
   + 'working in the main IDL process while the child process ' $
   + 'does its work.', $
   ' ', $
   'Both image files will be created in the temporary directory, ', $
   ' ',  + FILEPATH('', /TMP)+'.', $
   ' ', $
   'Click Abort to halt the external child process.', $
      ' ', $
   'Launch IIMAGE and open ohareJP2_roberts.jp2, located in your ' $
   + 'temporary directory, to view the file ' $
   + 'when processing is completed.']

; Create widget interface.
wBase = WIDGET_BASE(TITLE='Simple IDL_IDLBridge Example')
wSessionBase = WIDGET_BASE(wBase, /ROW, /FRAME, /ALIGN_LEFT)
wText = WIDGET_TEXT(wSessionBase, VALUE=helptext, $
   XSIZE = 40, YSIZE=4, /WRAP, /SCROLL)
wButtonCol = WIDGET_BASE(wSessionBase, /COL)
wProcess = WIDGET_BUTTON(wButtonCol, VALUE='Process Image', UVALUE='EXEC', $
   TOOLTIP='Filter image in a child IDL process')
wSpace = WIDGET_BASE(wButtonCol, YSIZE=4)
wAbort = WIDGET_BUTTON(wButtonCol, VALUE='Abort', $
   UVALUE='ABORT', SENSITIVE=0, TOOLTIP='Abort the child IDL process')
wSpace = WIDGET_BASE(wButtonCol, YSIZE=4)
wSpace = WIDGET_BASE(wButtonCol, YSIZE=4)
wLabel = WIDGET_LABEL(wButtonCol, VALUE='Child Process Status:', $
   /ALIGN_LEFT)
wStatus = WIDGET_TEXT(wButtonCol, VALUE='Idle', XSIZE=20)

; Initialize the bridge object and define the callback
; routine that is automatically called when process status
; is complete, aborted, or halts due to an error.
oIDLBridge = OBJ_NEW('IDL_IDLBridge', CALLBACK='simple_callback')

State = { $
   oIDLBridge:oIDLBridge, wStatus:wStatus, wProcess:wProcess, $
   wAbort:wAbort, wSessionBase:wSessionBase, wBase:wBase, jp2filename:jp2filename $
   }
pState = PTR_NEW(State)

WIDGET_CONTROL, wBase, SET_UVALUE=pState
WIDGET_CONTROL, wBase, /REALIZE

; Store the point data in USERDATA property in order
; to access it in the callback routine.
oIDLBridge->SetProperty, USERDATA=pState


XMANAGER,'idlbridge_simple_doc', wBase, $
   CLEANUP='idlbridge_simple_doc_cleanup', /NO_BLOCK

END
