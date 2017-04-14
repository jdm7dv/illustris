;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/shader_lut_doc__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       shader_lut_doc__define.pro
;
;  CALLING SEQUENCE: shader_lut_doc
;
;  PURPOSE: Show how a simple shader program can change the color
;           tables in an image processing application. Implement a
;           software based fallback in the FILTER method in case there
;           is not a suitable graphics card.
;
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
;        created, 6/2006
;
;-
;-----------------------------------------------------------------

;-----------------------------------------------------------------
; Software fallback.
Function shader_lut_doc::Filter, Image

; Allocate return array of same dimension and type.
sz = SIZE(Image)
newImage = FLTARR(sz[1:3], /NOZERO)

; Get the LUT uniform variable
self->GetUniformVariable, 'lut', oLUT

; Read the LUT data from the 1-D image.
oLUT->GetProperty, DATA=lut
FOR y=0, sz[3]-1 DO BEGIN
    FOR x=0, sz[2]-1 DO BEGIN
        ; Read from the image
        idr = Image[0,x,y]
        ; Convert from 0.0-1.0 back to 0-255.
        idr *= 255

        ; Get the number of image channels.
        szlut = SIZE(lut)
        IF szlut[0] EQ 1 THEN BEGIN
            ; Greyscale LUT, only 1 channel.
            grey = lut[idr]
            fgrey = FLOAT(grey) / 255.0
            newImage[0,x,y] = fgrey
            newImage[1,x,y] = fgrey
            newImage[2,x,y] = fgrey
            newImage[3,x,y] = 1.0
        ENDIF ELSE BEGIN
            ;; RGB LUT.
            rgb = lut[*, idr]
            frgb = FLOAT(rgb) / 255.0
            newImage[0:2,x,y] = frgb
            newImage[3,x,y] = 1.0
        ENDELSE
    ENDFOR
ENDFOR
RETURN, newImage
END
;
;-----------------------------------------------------------------
PRO shader_lut_doc::cleanup

self->IDLgrShader::Cleanup

END
;
;;-----------------------------------------------------------------
;;
;;  Purpose: Event handler
;;
PRO shader_lut_doc_event, sEvent

WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
self = (*pState).self

; Cleanup widget and object array when closing.
IF TAG_NAMES(sevent, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
   OBJ_DESTROY, [(*pstate).oPalette, (*pState).oImage, (*pState).oLUT]
   WIDGET_CONTROL, sEvent.top, /DESTROY
   OBJ_DESTROY, self ; calls cleanup
   PTR_FREE, pstate
   RETURN
ENDIF

CASE uval of
'DRAW': Begin
   Case sEvent.Type OF
    ; Expose
    4: BEGIN
        (*pState).oWindow->Draw, (*pState).oView
    END

    ; Handle anything else.
    ELSE: BEGIN
    END
   ENDCASE
 END

'LUT_SLD': BEGIN
   (*pState).palette = sEvent.value
   (*pState).oPalette->LoadCT, (*pState).palette
   (*pState).oPalette->GetProperty, red_values=red, $
      green_values=green, blue_values=blue
   (*pState).oLut->SetProperty, Data=TRANSPOSE([[red],[green],[blue]])
   (*pState).oWindow->Draw, (*pState).oView
   END

'RESET': Begin
   ; Reset slider.
   (*pState).palette = 0
   WIDGET_CONTROL, (*pState).wLUTslider, SET_VALUE=0

    ; Create enhanced grayscale LUT.
    x = 2*!PI/256 * FINDGEN(256) ;; 0 to 2 pi
    lut = BYTE(BINDGEN(256) - sin(x)*30) ;; Create 256 entry
    (*pState).oLut->SetProperty, Data=lut
  END
ELSE:BEGIN
END
ENDCASE

; Update uniform variable, which triggers filter update.
self->SetUniformVariable, 'lut', (*pstate).oLUT
(*pState).oWindow->Draw, (*pState).oView
END


;;-----------------------------------------------------------------
;;
FUNCTION shader_lut_doc::Init, _EXTRA=_extra

IF NOT self->IDLgrShader::Init(_EXTRA=_extra) $
   THEN $
      RETURN, 0

; Read in file, get image data and dimensions.
filename = FILEPATH('md5290fc1.jpg', $
   SUBDIRECTORY=['examples', 'data'])
READ_JPEG, filename, jpegImg
imageDims = SIZE(jpegImg, /DIMENSIONS)
oImage = OBJ_NEW("IDLgrImage", jpegImg)

; Create initial palette object.
oPalette = OBJ_NEW("IDLgrPalette")

; Set the size of the drawing window.
windowDims = [imageDims[0], imageDims[1]]

; Create widget interface.
wBase = WIDGET_BASE(TITLE='LUT Shader Demo',ROW=2, $
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
wLUTBase = WIDGET_BASE(wBottom, /COL)
wSpace =  WIDGET_LABEL(wLUTBase, VALUE="", /ALIGN_LEFT)
wLabelLUT = WIDGET_LABEL(wLUTBase, VALUE="Select LUT Colortable:", /ALIGN_LEFT)
wSpace =  WIDGET_LABEL(wLUTBase, VALUE="", /ALIGN_LEFT)
wLUTslider = WIDGET_SLIDER(wLUTBase, MINIMUM=0, MAXIMUM=40, $
   VALUE=0, UVALUE="LUT_SLD", /DRAG)
wSpace =  WIDGET_LABEL(wLUTBase, VALUE="", /ALIGN_LEFT)
wButtonReset = WIDGET_BUTTON(wLUTBase, VALUE='Reset Enhance Greyscale', UVALUE='RESET')

WIDGET_CONTROL, wBase, /REALIZE
WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

; Create the view with the upper left corner initially visible.
; Zoom is 1:1
oView = OBJ_NEW('IDLgrView', COLOR=[0,0,0], $
   VIEWPLANE_RECT=[0,imageDims[1]-windowDims[1],$
   windowDims[0],windowDims[1]])
oWindow->SetProperty, GRAPHICS_TREE=oView
oModel = OBJ_NEW('IDLgrModel')
oModel->Add, oImage
oView->Add, oModel
oWindow->Draw, oView

; Initialize variable used in updating widget control values.
infoTime = SYSTIME(1)

; Set shader property after all needed elements are in place.
oImage->SetProperty, SHADER=self

; Create enhanced grayscale LUT and store in 1-D IDLgrImage.
x = 2*!PI/256 * FINDGEN(256) ;; 0 to 2 pi
lut = BYTE(BINDGEN(256) - sin(x)*30) ;; Create 256 entry
oLUT = OBJ_NEW('IDLgrImage', lut, /IMAGE_1D)

; Store LUT in uniform variable named lut.
self->SetUniformVariable, 'lut', oLUT

vertexFile=filepath('LUTShaderVert.txt', $
   SUBDIRECTORY=['examples','doc', 'shaders'])
fragmentFile=filepath('LUTShaderFrag.txt', $
   SUBDIRECTORY=['examples','doc', 'shaders'])

self->IDLgrShader::SetProperty, $
   VERTEX_PROGRAM_FILENAME=vertexFile, $
   FRAGMENT_PROGRAM_FILENAME=fragmentFile

sState = {self: self,$
          wBase: wBase, $
          wDraw: wDraw, $
          oWindow: oWindow, $
          oView: oView, $
          oModel: oModel, $
          oImage: oImage, $
          oPalette: oPalette, $
          palette: 0, $
          oLUT: oLUT, $
          windowDims: windowDims, $
          imageDims: imageDims, $
          wLUTslider:wLUTslider $
         }

pState = PTR_NEW(sState, /NO_COPY)

WIDGET_CONTROL, wBase, SET_UVALUE=pState
XMANAGER, 'shader_lut_doc', wBase, /NO_BLOCK

RETURN, 1

END

PRO shader_lut_doc__define

Compile_opt hidden
struct  = {shader_lut_doc, $
          INHERITS IDLgrShader, $
          wBaseID: 0, $
          wBase: '', $
          wDraw: '', $
          oWindow: '', $
          oView: '', $
          oModel: '', $
          oImage: '', $
          oPalette: '', $
          palette: 0, $
          oLUT: '', $
          windowDims: 0, $
          imageDims: 0, $
          pState:PTR_NEW() $
          }

END
