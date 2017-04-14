;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/shader_filterchain_doc__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       shader_filterchain_doc__define.pro
;
;  CALLING SEQUENCE: shader_filterchain_doc
;
;  PURPOSE:
;       The following example creates an object that inherits from the IDLgrFilterChain
;       object, loads grayscale image data and lets you interactively add and remove
;       convolution shader objects (instances of IDLgrShaderConvol3) to this specialized
;       container. You can also modify the parameters of the convolution shaders.
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY: Shaders
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
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
; Cleanup.
;
PRO shader_filterchain_doc::cleanup

; Just call superclass.
self->IDLgrFilterChain::Cleanup


END

;-----------------------------------------------------------------
; Event handler:
; When Input range or Output range slider values change, update
; associated IDLgrShaderBytscl properties.
;
PRO shader_filterchain_doc_event, sEvent

WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
self = (*pState).self

; Cleanup widget and object array when closing.
IF TAG_NAMES(sevent, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
   OBJ_DESTROY, (*pstate).objarray
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

'SHADER_SELECTION': BEGIN
   widget_control, (*pState).wShaders, Get_VALUE=value
  (*pstate).oImage->SetProperty, Data = (*pstate).imagedata

   ; Remove all items from the collection and add back selected shaders.
   self->Remove, /ALL
   selected = WHERE (value EQ 1)
   IF N_ELEMENTS(selected) GT 1 || selected NE -1 THEN BEGIN
      self->Add, (*pstate).objarray[where (value EQ 1)]
   ENDIF

   ; Update base and convolution factors for all selected shaders.
   shaderObjs=self->Get(/ALL, COUNT=count)
   FOR i =0, count-1 DO BEGIN
     shaderObjs[i]->SetProperty, BASE_BLEND_FACTOR=(*pState).basefactor, $
        CONVOL_BLEND_FACTOR=(*pState).convolfactor
   ENDFOR
   (*pState).oWindow->Draw, (*pState).oView
   END

'BASE_BLEND':BEGIN
   (*pState).basefactor = sEvent.value
   shaderObjs=self->Get(/ALL, COUNT=count)
   FOR i=0, count-1 DO BEGIN
     shaderObjs[i]->SetProperty, BASE_BLEND_FACTOR=(*pState).basefactor
   ENDFOR
   (*pState).oWindow->Draw, (*pState).oView
   END

'CONVOL_BLEND':BEGIN
   (*pState).convolfactor = sEvent.value
   shaderObjs=self->Get(/ALL, COUNT=count)
   FOR i=0, count-1 DO BEGIN
     shaderObjs[i]->SetProperty, CONVOL_BLEND_FACTOR=(*pState).convolfactor
   ENDFOR
   (*pState).oWindow->Draw, (*pState).oView
   END

'RESET': BEGIN
   ; Reset sliders.
   WIDGET_CONTROL, (*pState).wBaseSlider, SET_VALUE=0.0
   WIDGET_CONTROL, (*pState).wConvolSlider, SET_VALUE=1.0
   (*pstate).basefactor=0.0
   (*pstate).convolfactor=1.0

   ; Update image with initial data.
   (*pstate).oImage->SetProperty, Data=(*pstate).imagedata

   ; Make "Identity" checkbox selected
   WIDGET_CONTROL, (*pState).wShaders, SET_VALUE=(*pstate).initial
   WIDGET_CONTROL, (*pState).wShaders, Get_VALUE=value

   ; Remove all items from the collection and add back selected shaders.
   self->Remove, /ALL
   selected = where (value EQ 1)
   IF n_elements(selected) GT 1 || selected NE -1 THEN BEGIN
      self->Add, (*pstate).objarray[where (value EQ 1)]
   ENDIF

   ; Update base and convolution factors for all selected shaders.
   shaderObjs=self->Get(/ALL, COUNT=count)
   FOR i =0, count-1 DO BEGIN
     shaderObjs[i]->SetProperty, BASE_BLEND_FACTOR=(*pState).basefactor, $
        CONVOL_BLEND_FACTOR=(*pState).convolfactor
   ENDFOR

   (*pState).oWindow->Draw, (*pState).oView
   END
ELSE:BEGIN
   END
ENDCASE

END


;-----------------------------------------------------------------
; Verify that selected image is 2-D only.
;
PRO shader_filterchain_doc::VerifyDims, imageDims

IF N_ELEMENTS(imageDims) NE 2 THEN BEGIN
   void = DIALOG_MESSAGE('Please select grayscale image')
ENDIF ELSE BEGIN
   RETURN
ENDELSE

END


;-----------------------------------------------------------------
; Open selected image.
;
FUNCTION shader_filterchain_doc::OpenImage


sFile = DIALOG_PICKFILE( $
    PATH=FILEPATH('',SUBDIRECTORY=['examples','data']), $
    TITLE='Select Image File', GET_PATH=path)
If sFile EQ '' THEN Return, 0

imageData = READ_IMAGE(sFile)
imageDims = SIZE(imageData, /DIMENSIONS)

; Make sure 2-D data is selected.
self->VerifyDims, imageDims

RETURN, imageData

END


;-----------------------------------------------------------------
;
FUNCTION shader_filterchain_doc::Init, _EXTRA=_extra

IF ~( self->IDLgrFilterChain::Init(_EXTRA=_extra)) THEN $
   RETURN, 0

; Is image data grayscale? If not, open image.
WHILE (N_ELEMENTS(SIZE(imageData, /DIMENSIONS)) NE 2) DO BEGIN
   imageData = self->OpenImage()
ENDWHILE

; Return current image dimensions.
imageDims = SIZE(imageData, /DIMENSIONS)

; Create image object.
oImage = OBJ_NEW("IDLgrImage", imageData)

; Set the size of the drawing window.
windowDims = [imageDims[0], imageDims[1]]

; Create widget interface.
wBase = WIDGET_BASE(TITLE='Filter Chain Image Shader', ROW=2, $
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
wControls = WIDGET_BASE(wBase, COL=2)

; Add convolution shaders.
wBaseShader = WIDGET_BASE(wControls, /col)
values = ['Identity', 'Smooth', 'Sharpen', 'Edge Detection']
;uvals  = [ 'oIdentity', 'oSmooth', 'oSharpen', 'oEdge']
initial = [1,0,0,0]
wShaders = CW_BGROUP(wBaseShader, values, /COLUMN, /NONEXCLUSIVE, $
  LABEL_TOP='Convolution Shaders', /FRAME, SET_VALUE=initial, $
  UVALUE="SHADER_SELECTION") ;, BUTTON_UVALUE=uvals,

; Add convolution controls.
wShaderProp = WIDGET_BASE(wControls, /COL)
wLabelIn = WIDGET_LABEL(wShaderProp, $
   VALUE="Base blend factor")
wBaseSlider = cw_fslider(wShaderProp, /DRAG, $
   MINIMUM=0.0, MAXIMUM=1.0, VALUE = 0.0, UVALUE="BASE_BLEND")
wLabelOut = WIDGET_LABEL(wShaderProp, $
   VALUE="Convolution blend factor")
wConvolSlider = cw_fslider(wShaderProp, /DRAG, $
   MINIMUM=0.0, MAXIMUM=1.0, VALUE=1.0, UVALUE="CONVOL_BLEND")
wLabelBlank = WIDGET_LABEL(wShaderProp, VALUE='')
wButtonReset = WIDGET_BUTTON(wShaderProp, VALUE='Reset', UVALUE='RESET')

WIDGET_CONTROL, wBase, /REALIZE
WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

; Create the view with the upper left corner initially visible.
oView = OBJ_NEW('IDLgrView', COLOR=[0,0,0], $
   VIEWPLANE_RECT=[0,imageDims[1]-windowDims[1], windowDims[0],windowDims[1]])
oWindow->SetProperty, GRAPHICS_TREE=oView
oModel = OBJ_NEW('IDLgrModel')
oModel->Add, oImage
oView->Add, oModel

; Create convolution shaders and add to object array.
oIdentity = OBJ_NEW("IDLgrShaderConvol3", KERNEL=0)
oSmooth = OBJ_NEW("IDLgrShaderConvol3", KERNEL=1)
oSharpen = OBJ_NEW("IDLgrShaderConvol3", KERNEL=2)
oEdge = OBJ_NEW("IDLgrShaderConvol3", KERNEL=3)
objarray = [oIdentity, oSmooth, oSharpen, oEdge]

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
          wBaseSlider:wBaseSlider, $
          wConvolSlider:wConvolSlider, $
          wShaders:wShaders, $
          initial:initial, $
          objarray:objarray, $
          basefactor: 0.0, $
          convolfactor: 1.0 $
         }

pState = PTR_NEW(sState, /NO_COPY)

WIDGET_CONTROL, wBase, SET_UVALUE=pState
XMANAGER, 'shader_filterchain_doc', wBase, /NO_BLOCK

; Set initial convolution shader to identity, which leaves image unchanged.
self->Add, oIdentity

; Set shader property after all needed elements are in place.
oImage->SetProperty, SHADER=self

oWindow->Draw, oView

RETURN, 1

END

PRO shader_filterchain_doc__define

Compile_opt hidden
struct  = {shader_filterchain_doc, $
          INHERITS IDLgrFilterChain, $
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
          wBaseSlider:'', $
          wConvolSlider:'', $
          pState:PTR_NEW() $
          }

END
