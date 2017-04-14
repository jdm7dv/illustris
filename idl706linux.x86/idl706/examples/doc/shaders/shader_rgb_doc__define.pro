;  $Id: //depot/idl/IDL_70/idldir/examples/doc/shaders/shader_rgb_doc__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
;+
;  FILE:
;       shader_rgb_doc__define.pro
;
;  CALLING SEQUENCE: shader_rgb_doc
;
;  PURPOSE: Show how a simple shader program can change the color
;           levels in an image processing application. Implement a
;           software based fallback in the FILTER method in case there
;           is not a suitable graphics card.
;
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
;        created, 5/2006
;
;-
;-----------------------------------------------------------------
;
;

;-----------------------------------------------------------------
;;
Function shader_rgb_doc::Filter, Image

newImage=Image
self->GetUniformVariable, 'scl', s
newImage[0,*,*] *= s[0]
newImage[1,*,*] *= s[1]
newImage[2,*,*] *= s[2]

RETURN, newImage

END
;
;-----------------------------------------------------------------
PRO shader_rgb_doc::cleanup

self->IDLgrShader::Cleanup
heap_gc

END
;
;-----------------------------------------------------------------
; Purpose: Event handler
;
PRO shader_rgb_doc_event, sEvent

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

'RED_SCL': BEGIN
   (*pState).red = sEvent.value
   (*pState).oWindow->Draw, (*pState).oView
   END
'BLUE_SCL': BEGIN
   (*pState).blue = sEvent.value
   (*pState).oWindow->Draw, (*pState).oView
   END
'GREEN_SCL': BEGIN
   (*pState).green = sEvent.value
   (*pState).oWindow->Draw, (*pState).oView
   END

'RESET': Begin
   (*pState).red = 1.0
   (*pState).blue = 1.0
   (*pState).green = 1.0
   WIDGET_CONTROL, (*pState).wRslider, SET_VALUE=1.0
   WIDGET_CONTROL, (*pState).wGslider, SET_VALUE=1.0
   WIDGET_CONTROL, (*pState).wBslider, SET_VALUE=1.0
   ; Read in file.
   filename = FILEPATH('rose.jpg', $
      SUBDIRECTORY=['examples', 'data'])
   ;  Get data stored in a regular JPEG file.
   READ_JPEG, filename, jpegImg, TRUE=1, /ORDER
   (*pState).oImage = OBJ_NEW("IDLgrImage", jpegImg, ORDER=1, SHADER=self)
   (*pState).oModel->Add,(*pState).oImage
   (*pState).oWindow->Draw, (*pState).oView
   END

'CAPTURE': BEGIN
   data = (*pState).oImage->ReadFilteredData((*pState).oWindow)
   IIMAGE, data, /ORDER
   END
ELSE:BEGIN
END
ENDCASE

; Update uniform variable, which triggers filter update.
self->SetUniformVariable, 'scl', [(*pState).red, $
   (*pState).green, (*pState).blue]
(*pState).oWindow->Draw, (*pState).oView
END


;;-----------------------------------------------------------------
;;
FUNCTION shader_rgb_doc::Init, _EXTRA=_extra

IF NOT self->IDLgrShader::Init(_EXTRA=_extra) $
   THEN $
      RETURN, 0

; Read in file, get image data and dimensions.
filename = FILEPATH('rose.jpg', $
   SUBDIRECTORY=['examples', 'data'])
READ_JPEG, filename, jpegImg, TRUE=1, /ORDER
imageDims = SIZE(jpegImg, /DIMENSIONS)
oImage = OBJ_NEW("IDLgrImage", jpegImg, ORDER=1)

; Set the size of the drawing window.
windowDims = [imageDims[1], $
              imageDims[2]]
oImage->GetProperty, DIMENSIONS=imageDims

; Create widget interface.
wBase = WIDGET_BASE(TITLE='RGB Shader Demo',ROW=2, $
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
wColorBase = WIDGET_BASE(wBottom, /COL)
wLabel = WIDGET_LABEL(wColorBase, VALUE="Change RGB Intensity Scales:", /ALIGN_LEFT)
wLabelRed = WIDGET_LABEL(wColorBase, VALUE="Red:", /ALIGN_LEFT)
wRslider = CW_FSLIDER(wColorBase, MINIMUM=0.0, MAXIMUM=2.0, $
                          VALUE=1.0, UVALUE="RED_SCL", /DRAG)
wLabelGreen = WIDGET_LABEL(wColorBase, VALUE="Green:", /ALIGN_LEFT)
wGslider = CW_FSLIDER(wColorBase, MINIMUM=0.0, MAXIMUM=2.0, $
                          VALUE=1.0, UVALUE="GREEN_SCL", /DRAG)
wLabelBlue = WIDGET_LABEL(wColorBase, VALUE="Blue:", /ALIGN_LEFT)
wBslider = CW_FSLIDER(wColorBase, MINIMUM=0.0, MAXIMUM=2.0, $
                          VALUE=1.0, UVALUE="BLUE_SCL", /DRAG)
wButtonBase = WIDGET_BASE(wColorBase, /ROW)
wButtonReset = WIDGET_BUTTON(wButtonBase, VALUE='Reset', UVALUE='RESET')
wButtonCapture = WIDGET_BUTTON(wButtonBase, Value='Capture Image', UVALUE='CAPTURE')

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

sState = {self: self,$
          wBase: wBase, $
          wDraw: wDraw, $
          oWindow: oWindow, $
          oView: oView, $
          oModel: oModel, $
          oImage: oImage, $
          windowDims: windowDims, $
          imageDims: imageDims, $
          wRslider:wRslider, $
          wGslider:wGslider, $
          wBslider:wBslider,$
          red: 1.0, $
          green: 1.0, $
          blue: 1.0 $
         }

pState = PTR_NEW(sState, /NO_COPY)

WIDGET_CONTROL, wBase, SET_UVALUE=pState
XMANAGER, 'shader_rgb_doc', wBase, /NO_BLOCK

self->SetUniformVariable, 'scl', [(*pState).red, (*pState).green, (*pState).blue]

; Set shader property after all needed elements are in place.
oImage->SetProperty, SHADER=self

; Define vertex shader program. Always use Texture Unit 0 when
vertexProgram = $
    [ $
        'void main (void) {', $
        '  gl_TexCoord[0] = gl_MultiTexCoord0;', $
        '  gl_Position = ftransform();', $
        '}' ]

; Access the texture map associated with the base image's data
; in the IDL reserved uniform variable, _IDL_ImageTexture. This variable
; is automatically created for the base image.
fragmentProgram = $
    [ $
        'uniform sampler2D _IDL_ImageTexture;', $
        'uniform vec3 scl;', $
        'void main(void) {', $
        '    vec4 c = texture2D(_IDL_ImageTexture, gl_TexCoord[0].xy);', $
        '    c.rgb *= scl;', $
        '    gl_FragColor = c;', $
        '}' ]

self->IDLgrShader::SetProperty, $
  VERTEX_PROGRAM_STRING=STRJOIN(vertexProgram, STRING(10B)), $
  FRAGMENT_PROGRAM_STRING=STRJOIN(fragmentProgram, STRING(10B))

RETURN, 1

END

PRO shader_rgb_doc__define

Compile_opt hidden
struct  = {shader_rgb_doc, $
          INHERITS IDLgrShader, $
          wBaseID: 0, $
          wBase: '', $
          wDraw: '', $
          oWindow: '', $
          oView: '', $
          oModel: '', $
          oImage: '', $
          windowDims: 0, $
          imageDims: 0, $
          red: 0.0, $
          green: 0.0, $
          blue: 0.0, $
          pState:PTR_NEW() $
          }

END
