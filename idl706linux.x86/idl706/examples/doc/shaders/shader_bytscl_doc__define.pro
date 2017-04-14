;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/shader_bytscl_doc__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       shader_rgb_doc__define.pro
;
;  CALLING SEQUENCE: shader_rgb_doc
;
;  PURPOSE:
;       The following example creates an object that inherits from the IDLgrShaderBytscl
;       object, loads grayscale image data and lets you interactively adjust the input
;       and output data ranges using two sliders. Note the when using the IDLgrShaderBytscl
;       object with non-byte data, you should set the IDLgrImage
;       INTERNAL_DATA_TYPE property to avoid having your data truncated to a byte (0-255) range.
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY: Shaders
;
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;
;-
;-----------------------------------------------------------------
;
;-----------------------------------------------------------------
; Cleanup.
;
PRO shader_bytscl_doc::cleanup

; Just call superclass
self->IDLgrShaderBytscl::Cleanup

END


;-----------------------------------------------------------------
; Event handler:
; When Input range or Output range slider values change, update
; associated IDLgrShaderBytscl properties.
;
PRO shader_bytscl_doc_event, sEvent



WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
self = (*pState).self

; Cleanup widget and object array when closing.
IF TAG_NAMES(sevent, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
   OBJ_DESTROY, (*pState).oImage
   WIDGET_CONTROL, sEvent.top, /DESTROY
   OBJ_DESTROY, self ; calls cleanup
   PTR_FREE, pstate
   RETURN
ENDIF

CASE uval OF
'DRAW': BEGIN
   CASE sEvent.Type OF
    ; Expose
    4: BEGIN
        (*pState).oWindow->Draw, (*pState).oView
    END

    ; Handle anything else.
    ELSE: BEGIN
    END
   ENDCASE
 END

'IN_RANGE_LOW':BEGIN
   range = (*pState).inrange
   IF (sEvent.value LT range[1]) THEN BEGIN
      range[0] = sEvent.value
   ENDIF ELSE BEGIN
      range[0] = range[1]-1
      WIDGET_CONTROL, (*pState).wInSliderLow, SET_VALUE=range[0]
   ENDELSE
   (*pState).inrange = range
   self->SetProperty, IN_RANGE=(*pState).inrange
   (*pState).oWindow->Draw, (*pState).oView
   END

'IN_RANGE_HIGH':BEGIN
   range = (*pState).inrange
   IF (sEvent.value GT range[0]) THEN BEGIN
      range[1] = sEvent.value
   ENDIF ELSE BEGIN
      range[1] = range[0]+1
      WIDGET_CONTROL, (*pState).wInSliderHigh, SET_VALUE=range[1]
   ENDELSE
   (*pState).inrange = range
   self->SetProperty, IN_RANGE=(*pState).inrange
   (*pState).oWindow->Draw, (*pState).oView
   END

'OUT_RANGE_LOW':BEGIN
   range = (*pState).outrange
   IF (sEvent.value LT range[1]) THEN BEGIN
      range[0] = sEvent.value
   ENDIF ELSE BEGIN
      range[0] = range[1]-1
      WIDGET_CONTROL, (*pState).wOutSliderLow, SET_VALUE=range[0]
   ENDELSE
   (*pState).outrange = range
   self->SetProperty, OUT_RANGE=(*pState).outrange
   (*pState).oWindow->Draw, (*pState).oView
   END

'OUT_RANGE_HIGH':BEGIN
   range = (*pState).outrange
   IF (sEvent.value GT range[0]) THEN BEGIN
      range[1] = sEvent.value
   ENDIF ELSE BEGIN
      range[1] = range[0]+1
      WIDGET_CONTROL, (*pState).wOutSliderHigh, SET_VALUE=range[1]
   ENDELSE
   (*pState).outrange = range
   self->SetProperty, OUT_RANGE=(*pState).outrange
   (*pState).oWindow->Draw, (*pState).oView
   END

'RESET': BEGIN
   (*pState).inrange = [(*pState).imageMin, (*pState).imageMax]
   (*pState).outrange = [0,255]
   ; Reset sliders.
   WIDGET_CONTROL, (*pState).wInSliderLow, SET_VALUE=(*pState).imageMin
   WIDGET_CONTROL, (*pState).wInSliderHigh, SET_VALUE=(*pState).imageMax
   WIDGET_CONTROL, (*pState).wOutSliderLow, SET_VALUE=0
   WIDGET_CONTROL, (*pState).wOutSliderHigh, SET_VALUE=255

   ; Read in file and set shader-related elements.
   data = (*pState).imageData
   (*pState).oImage = OBJ_NEW("IDLgrImage", data, SHADER=self, $
      INTERNAL_DATA_TYPE=(*pState).internalType)
   ; Calling SetProperty triggers updates.
   self->SetProperty, IN_RANGE=(*pState).inrange
   self->SetProperty, OUT_RANGE=(*pState).outrange
   (*pState).oModel->Add,(*pState).oImage
   (*pState).oWindow->Draw, (*pState).oView
   END
ELSE:BEGIN
   END
ENDCASE

END


;-----------------------------------------------------------------
; Verify that selected image is 2-D only.
;
PRO shader_bytscl_doc::VerifyDims, imageDims

IF N_ELEMENTS(imageDims) NE 2 THEN BEGIN
   void = DIALOG_MESSAGE('Please select grayscale image')
ENDIF ELSE BEGIN
   RETURN
ENDELSE

END


;-----------------------------------------------------------------
; Open selected image.
;
FUNCTION shader_bytscl_doc::OpenImage

sFile = DIALOG_PICKFILE( $
    PATH=FILEPATH('',SUBDIRECTORY=['examples','data']), $
    TITLE='Select Image File', GET_PATH=path)
If sFile EQ '' THEN Return, 0

imageData = READ_IMAGE(sFile)
imageDims = SIZE(imageData, /DIMENSIONS)

; Make sure 2-D data is selected.
self->VerifyDims, imageDims

RETURN, imageData

End


;-----------------------------------------------------------------
;
FUNCTION shader_bytscl_doc::Init, _EXTRA=_extra

IF ~( self->IDLgrShaderBytscl::Init(_EXTRA=_extra)) THEN $
   RETURN, 0

; Is image data grayscale? If not, open image.
WHILE (N_ELEMENTS(SIZE(imageData, /DIMENSIONS)) NE 2) DO BEGIN
   imageData = self->OpenImage()
ENDWHILE

; Return current image dimensions.
imageDims = SIZE(imageData, /DIMENSIONS)

; Retrieve image data type to set INTERNAL_DATA_TYPE on image and
; UNITS_IN_RANGE on IDLgrShaderBytscl.
; Get min and max for input range slider top and bottom values.
type = SIZE(imageData, /TYPE)
imageMin = MIN(imageData)
imageMax = MAX(imageData)

CASE type OF

    ;BYTE range 0-255
   1: BEGIN
      ; Set to 8-bit Byte (truncate) for byte data
      internalType=0
      END

   ;INT range +/- 32768
   2: BEGIN
   print, 'int'
      ; Set to float16 type (+/- 2048 with no loss). Stores
      ; maximum of +/- 65504 with some loss of precision.
      ; If greater precision needed, set to float32, type 3
      ; (+/- 16,777,216).
      internalType=2
      END

   ;;FLOAT
   ;4: BEGIN
       ;; Not supported in this simple example. Use float32 with
       ;; floating point data (+/- 16,777,216).
       ;; internalType=3
   ;   END

   ;UINT range 0-65535
   12:BEGIN
   print, 'uint'
      ; Set to float16 type (+/- 2048 with no loss). Stores
      ; maximum of +/- 65504 with some loss of precision.
      ; If greater precision needed, set to float 32, type 3
      ; (+/- 16,777,216).
      internalType=2
      END

   ELSE:BEGIN
      void = DIALOG_MESSAGE ("Image type not supported.")
      RETURN,0
      END
ENDCASE

; To avoid having non-byte data cast/truncated to byte, set
; the INTERNAL_DATA_TYPE property.
oImage = OBJ_NEW("IDLgrImage", imageData, $
   INTERNAL_DATA_TYPE=internalType)

; Set the size of the drawing window.
windowDims = [imageDims[0], imageDims[1]]

; Create widget interface.
wBase = WIDGET_BASE(TITLE='Byte-scale Image Shader', ROW=2, $
   /TLB_KILL_REQUEST_EVENTS)
wDraw = WIDGET_DRAW( $
            wBase, $
            XSIZE=windowDims[0], $
            YSIZE=windowDims[1], $
            GRAPHICS_LEVEL=2, $
            RENDERER=0, $
            RETAIN=0, $
            /EXPOSE_EVENTS,$
            UVALUE='DRAW' $
            )

; Add Controls.
wBottom = WIDGET_BASE(wBase, /COL)
wLabelIn = WIDGET_LABEL(wBottom, VALUE="Original image input range")
wLabelInBase = WIDGET_BASE(wBottom, /ROW)
wInSliderLow = WIDGET_SLIDER(wLabelInBase, TITLE="Lowest input value", $
                               MINIMUM=imageMin, MAXIMUM=imageMax, $
                               VALUE=imageMin, UVALUE="IN_RANGE_LOW", $
                               XSIZE=125, /DRAG)
wInSliderHigh= WIDGET_SLIDER(wLabelInBase, TITLE="Highest input value", $
                               MINIMUM=imageMin, MAXIMUM=imageMax, $
                               VALUE=imageMax, UVALUE="IN_RANGE_HIGH", $
                               XSIZE=125, /DRAG)

wLabelBlank = WIDGET_LABEL(wBottom, VALUE='')
wLabelOut = WIDGET_LABEL(wBottom, VALUE="Byte-scaled output range")
wLabelOutBase = WIDGET_BASE(wBottom, /ROW)
wOutSliderLow = WIDGET_SLIDER(wLabelOutBase, TITLE="Lowest output value", $
                               MINIMUM=0, MAXIMUM=255, $
                               VALUE=0, UVALUE="OUT_RANGE_LOW", $
                               XSIZE=125, /DRAG)
wOutSliderHigh= WIDGET_SLIDER(wLabelOutBase, TITLE="Highest output value", $
                               MINIMUM=0, MAXIMUM=255, $
                               VALUE=255, UVALUE="OUT_RANGE_HIGH", $
                               XSIZE=125, /DRAG)

wLabelBlank = WIDGET_LABEL(wBottom, VALUE='')
wButtonReset = WIDGET_BUTTON(wBottom, VALUE='Reset', $
                               UVALUE='RESET')

WIDGET_CONTROL, wBase, /REALIZE
WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

; Create the view with the upper left corner initially visible.
oView = OBJ_NEW('IDLgrView', COLOR=[0,0,0], $
                VIEWPLANE_RECT=[0,imageDims[1]-windowDims[1],$
                                windowDims[0],windowDims[1]])
oWindow->SetProperty, GRAPHICS_TREE=oView
oModel = OBJ_NEW('IDLgrModel')
oModel->Add, oImage
oView->Add, oModel

; Set up state structure.
sState = {self: self,$
          wBase: wBase, $
          wDraw: wDraw, $
          oWindow: oWindow, $
          oView: oView, $
          oModel: oModel, $
          oImage: oImage, $
          windowDims: windowDims, $
          imageDims: imageDims, $
          imageData: imageData, $
          imageMin: imageMin, $
          imageMax: imageMax, $
          internalType:internalType, $
          wInSliderLow:wInSliderLow, $
          wInSliderHigh:wInSliderHigh, $
          wOutSliderLow:wOutSliderLow, $
          wOutSliderHigh:wOutSliderHigh, $
          inrange: [imageMin, imageMax], $
          outrange: [0,255] $
         }

pState = PTR_NEW(sState, /NO_COPY)

WIDGET_CONTROL, wBase, SET_UVALUE=pState
XMANAGER, 'shader_bytscl_doc', wBase, /NO_BLOCK

; Set initial inrange, outrange and units in range values.
self->SetProperty, $
  IN_RANGE=[(*pState).inrange], $
  OUT_RANGE=[(*pState).outrange]
self->SetProperty, UNITS_IN_RANGE=type

; Set shader property after all needed elements are in place.
oImage->SetProperty, SHADER=self

oWindow->Draw, oView

RETURN, 1

END

PRO shader_bytscl_doc__define

Compile_opt hidden
struct  = {shader_bytscl_doc, $
          INHERITS IDLgrShaderBytscl, $
          wBaseID: 0, $
          wBase: '', $
          wDraw: '', $
          oWindow: '', $
          oView: '', $
          oModel: '', $
          oImage: '', $
          windowDims: 0, $
          imageDims: 0, $
          imageData: 0, $
          imageMin: 0,$
          imageMax: 0,$
          wInSliderLow:'', $
          wInSliderHigh:'', $
          wOutSliderLow:'', $
          wOutSliderHigh:'', $
          pState:PTR_NEW() $
          }

END
