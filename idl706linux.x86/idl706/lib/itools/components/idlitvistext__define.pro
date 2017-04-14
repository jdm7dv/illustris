; $Id: //depot/idl/IDL_70/idldir/lib/itools/components/idlitvistext__define.pro#5 $
;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
; CLASS_NAME:
;    IDLitVisText
;
; PURPOSE:
;    The IDLitVisText class is the iTools implementation of a text
;    object.
;
; CATEGORY:
;    Components
;
; SUPERCLASSES:
;    IDLitVisualization
;
;-


;----------------------------------------------------------------------------
;+
; METHODNAME:
;    IDLitVisText::Init
;
; PURPOSE:
;    Initialize this component
;
; CALLING SEQUENCE:
;
;    Obj = OBJ_NEW('IDLitVisText')
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;   All keywords that can be used for IDLgrFont
;
; OUTPUTS:
;    This function method returns 1 on success, or 0 on failure.
;
;-
function IDLitVisText::Init, _REF_EXTRA=_extra
    compile_opt idl2, hidden

    ; Initialize superclass
    if (~self->IDLitVisualization::Init(NAME="Text", $
        /MANIPULATOR_TARGET, $
        TYPE='IDLTEXT', $
        DESCRIPTION="A Text Visualization", $
        ICON='text', $
        IMPACTS_RANGE=0, $
        SELECTION_PAD=10, $ ; pixels
        _EXTRA=_extra))then $
      return, 0

    self._oText = OBJ_NEW("IDLgrTextEdit", /REGISTER_PROPERTIES,$
        /ENABLE_FORMATTING, /KERNING, $
        RECOMPUTE_DIMENSIONS=2, $
        VERTICAL_ALIGNMENT=1, /PRIVATE, $
        STRING='', $
        _EXTRA=_extra)


    ; Add in our special manipulator visual.  This allows translation
    ; but doesn't allow scaling.  We don't want to allow scaling because
    ; it causes problems with the font sizing.
    oSelectBox = OBJ_NEW('IDLitManipVisSelect', /HIDE)
    oSelectBox->Add, OBJ_NEW('IDLgrPolyline', COLOR=[0,150,0], $
        DATA=[[-1,-1],[1,-1],[1,1],[-1,1],[-1,-1]])
    self->SetDefaultSelectionVisual, oSelectBox


    self->Add, self._oText, /AGGREGATE, /NO_NOTIFY, /NO_UPDATE

    ; Registered our properties.
    self._oText->RegisterProperty, 'TRANSPARENCY', /INTEGER, $
        NAME='Transparency', $
        DESCRIPTION='Text transparency', $
        VALID_RANGE=[0,100,5]


    ; Hide some text properties.
    self->SetPropertyAttribute, ['ALIGNMENT', $
        'ALPHA_CHANNEL', $
        'ENABLE_FORMATTING', $
        'KERNING', $
        'ONGLASS', $
        'RECOMPUTE_DIMENSIONS', $
        'RENDER_METHOD', $
        'PALETTE',$
        'VERTICAL_ALIGNMENT'], /HIDE

    ; Register text properties.
    ; Hide until we have a real string (needed for Styles).
    self->RegisterProperty, '_STRING', /STRING, $
        NAME='Text string', $
        DESCRIPTION='Text string', $
        /HIDE

    self->RegisterProperty, '_HORIZONTAL_ALIGN', $
        ENUMLIST=['Left', 'Center', 'Right'], $
        NAME='Horizontal alignment', $
        DESCRIPTION='Horizontal alignment'

    ; Use the current zoom factor of the tool window as the
    ; initial font zoom factor.  Likewise for the view zoom, and normalization
    ; factor.
    oTool = self->GetTool()
    if (OBJ_VALID(oTool) && OBJ_ISA(oTool, 'IDLitTool')) then begin
        oWin = oTool->GetCurrentWindow()
        if (OBJ_VALID(oWin)) then begin
            oWin->GetProperty, CURRENT_ZOOM=fontZoom
            oView = oWin->GetCurrentView()
            if (OBJ_VALID(oView)) then begin
                oView->GetProperty, CURRENT_ZOOM=viewZoom
                normViewDims = oView->GetViewport(UNITS=3,/VIRTUAL)
                fontNorm = MIN(normViewDims)
            endif
        endif
    endif

    self._oFont = OBJ_NEW('IDLitFont', FONT_ZOOM=fontZoom, VIEW_ZOOM=viewZoom, $
        FONT_NORM=fontNorm)
    self._oText->SetProperty, FONT=self._oFont->GetFont()
    self->Aggregate, self._oFont

    ; Set any properties
    if(n_elements(_extra) gt 0)then $
      self->IDLitVisText::SetProperty, _EXTRA=_extra

    ;; Register our parameter. This is the location of the text
    ;; object!
    self->RegisterParameter, 'LOCATION', DESCRIPTION='Text Location', $
                            /INPUT, TYPES=['IDLPOINT','IDLVECTOR']

    RETURN, 1 ; Success
end

;;----------------------------------------------------------------------------
;; IDLitVisText::Cleanup
;;
;; Purpose:
;;    Cleanup method for the text object.
;;
pro IDLitVisText::Cleanup
    compile_opt idl2, hidden

    OBJ_DESTROY, self._oFont

    ; Cleanup superclass
    self->IDLitVisualization::Cleanup
end

;----------------------------------------------------------------------------
; IDLitVisPlot::Restore
;
; Purpose:
;   This procedure method performs any cleanup work required after
;   an object of this class has been restored from a save file to
;   ensure that its state is appropriate for the current revision.
;
pro IDLitVisText::Restore
    compile_opt idl2, hidden

    ; Call superclass restore.
    self->_IDLitVisualization::Restore

    ; In IDL 7.06 we changed self._oText from an IDLgrText object
    ; to a new subclass of IDLgrText; IDLgrTextEdit.
    ; We basically just need to redo a lot of the construction work,
    ; but copying over properties from the old to the new.
    if (self.idlitcomponentversion lt 706) then begin
      ; Get the old object's properties and then dispose of it
      self._oText->GetProperty, ALL=all
      self->Remove, self._oText
      obj_destroy,  self._oText
      
      self._oText = OBJ_NEW("IDLgrTextEdit", $
        /REGISTER_PROPERTIES, /PRIVATE)
      self._oText->SetProperty, _extra=all
  
      self->Add, self._oText, /AGGREGATE, /NO_NOTIFY, /NO_UPDATE
      
      ; Register our properties.
      self._oText->RegisterProperty, 'TRANSPARENCY', /INTEGER, $
        NAME='Transparency', $
        DESCRIPTION='Text transparency', $
        VALID_RANGE=[0,100,5]
  
      ; Hide some text properties.
      self->SetPropertyAttribute, ['ALIGNMENT', $
        'ALPHA_CHANNEL', $
        'ENABLE_FORMATTING', $
        'KERNING', $
        'ONGLASS', $
        'RECOMPUTE_DIMENSIONS', $
        'RENDER_METHOD', $
        'PALETTE',$
        'VERTICAL_ALIGNMENT'], /HIDE

      ; We do this just so the properties appear in the same order as usual.
      self->Remove, self._oFont
      self->Aggregate, self._oFont
    endif
    
end

;;---------------------------------------------------------------------------
;; IDLitVisText::BeginEditing
;;
;; Purpose:
;;    Called to put this string in text edit mode. This must be
;;    followed by a called to EndEditing
;;
;; Parameters:
;;    oWin   - The Window the editing is being performed on.
;;
pro IDLitVisText::BeginEditing, oWin
  compile_opt idl2, hidden

  self._oText->SetProperty, DRAW_CURSOR=1
end

;;---------------------------------------------------------------------------
;; IDLitVisText::EndEditing
;;
;; Purpose:
;;    Called to end the editing session in the text editor. This will
;;    hide the entry point and the shadow text string.
;;
pro IDLitVisText::EndEditing
  compile_opt hidden, idl2

  self._oText->SetProperty, SELECTION_LENGTH=0, DRAW_CURSOR=0
end

;;---------------------------------------------------------------------------
;; IDLitVisText::SetSelection
;;
;; Purpose:
;;   This routine is used to set the selection of text and equivalently,
;;   the location of the insertion cursor (when length=0).
;;
;; Parameters:
;;  start  - The string index of the start of the selected region
;;  length - The length of the selected region
pro IDLitVisText::SetSelection, start, length
    compile_opt idl2, hidden

    if (n_elements(length) eq 0) then length=0
    self._oText->SetProperty, SELECTION_START=start, SELECTION_LENGTH=length
end

;;---------------------------------------------------------------------------
;; IDLitVisText::MoveCursor
;;
;; Purpose:
;;   This routine is used to move the cursor in a given direction
;;
;; Parameters:
;;  direction  - 
;;  select     - 
pro IDLitVisText::MoveCursor, window, DIRECTION=direction, SELECT=select
    compile_opt idl2, hidden

    self._oText->MoveCursor, window, DIRECTION=direction, SELECT=select
end

;;---------------------------------------------------------------------------
;; IDLitVisText::WindowPositionToOffset
;;
;; Purpose:
;;   Determine an insert point from a given window x, y location.
;;
;; Parameters:
;;   oWin   - the associated Window
;;   x      - X coord (Window)
;;   y      - Y Coord (Window)
;;
;; Return Value:
;;   The offset in the string that is the closest to the given
;;   location.
function IDLitVisText::WindowPositionToOffset, oWin, x, y
    compile_opt hidden, idl2

    ;; First, validate the point is in the text range
    self->WindowToVis, x, y, x1, y1
    x1 = x1[0]
    y1 = y1[0]

    ; Get the coordinate as a value scaled 0-1 across the object
    self._oText->GetProperty, location=loc
    textdims = oWin->GetTextDimensions(self._oText,descent=descent)
    x1 = (x1 - loc[0]) / textdims[0]
    y1 = (y1 - loc[1]) / textdims[1] + 1

    return, self._oText->GetIndexAtCoord(oWin, x1, y1)
end

;;---------------------------------------------------------------------------
;; IDLitVisText::Insert
;;
;; Purpose:
;;   Inserts text into the string at the current cursor position.  If text
;;   is selected, it overwrites the selected text and sets the selection
;;   length to zero.
;;
;; Parameters:
;;   text - text to insert
pro IDLitVisText::Insert, text
  compile_opt idl2, hidden
  
  self._oText->Insert, text

  ; Have to update the selection, since the bounding box may have changed
  self->UpdateSelectionVisual
end

;;---------------------------------------------------------------------------
;; IDLitVisText::Delete
;;
;; Purpose:
;;   Deletes text.  If text is selected, deletes the selected region and 
;;   sets selection length to zero.  Otherwise, deletes a single character 
;;   in the direction indicated by DELETE.
;;
;; Parameters:
;;   DELETE - If set, deletes the character after the cursor.  (e.g. delete key)
;;            Otherwise, the character before.  (e.g. backspace key)
;;   TEXT   - If present, is set to the text that was removed from the string.
pro IDLitVisText::Delete, AFTER=after, TEXT=text
  compile_opt idl2, hidden

  self._oText->Delete, AFTER=after, TEXT=text

  ; Have to update the selection, since the bounding box may have changed
  self->UpdateSelectionVisual
end

;----------------------------------------------------------------------------
; IIDLProperty Interface
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;+
; METHODNAME:
;      IDLitVisText::GetProperty
;
; PURPOSE:
;      This procedure method retrieves the
;      value of a property or group of properties.
;
; CALLING SEQUENCE:
;      Obj->[IDLitVisText::]GetProperty
;
; INPUTS:
;      There are no inputs for this method.
;
; KEYWORD PARAMETERS:
;      Any keyword to IDLitVisText::Init followed by the word "Get"
;      can be retrieved using IDLitVisText::GetProperty.
;
;-
pro IDLitVisText::GetProperty, $
             _HORIZONTAL_ALIGN=_horizAlign, $
             ALIGNMENT=horizAlign, $
             _STRING=_string, $
             STRINGS=strings, $
             FONT_OBJECT=fontObject, $
             TRANSPARENCY=transparency, $
             _REF_EXTRA=_extra
   compile_opt idl2, hidden

    ; Get text
    self._oText->GetProperty,  ALIGNMENT=horizAlign, $
        ALPHA_CHANNEL=alphaChannel, $
         STRINGS=strings, $
         FONT=fontObject
    
    if ARG_PRESENT(transparency) then $
        transparency = (1 - alphaChannel)*100

    ; Convert from 0, 0.5, 1 to 0, 1, 2
    if ARG_PRESENT(_horizAlign) then $
        _horizAlign = FIX(horizAlign*2)

    ; Extract the first string only.
    ; Watch out for undefined STRINGS property.
    if ARG_PRESENT(_string) then $
        _string = (SIZE(strings, /TYPE) eq 7) ? strings[0] : ''

    if (N_ELEMENTS(_extra) gt 0) then $
        self->_IDLitVisualization::GetProperty, _EXTRA=_EXTRA
end


;----------------------------------------------------------------------------
;+
; METHODNAME:
;      IDLitVisText::SetProperty
;
; PURPOSE:
;      This procedure method sets the value
;      of a property or group of properties.
;
; CALLING SEQUENCE:
;      Obj->[IDLitVisText::]SetProperty
;
; INPUTS:
;      There are no inputs for this method.
;
; KEYWORD PARAMETERS:
;      Any keyword to IDLitVisText::Init followed by the word "Set"
;      can be set using IDLitVisText::SetProperty.
;-

pro IDLitVisText::SetProperty,  $
                _HORIZONTAL_ALIGN=_horizAlign, $
                ALIGNMENT=swallow1, $
                _STRING=_string, $
                STRINGS=swallow2, $
                FONT_OBJECT=fontObject, $
                NO_UPDATE=NO_UPDATE, $ ;; for interactive editing
                FILL_BACKGROUND=fillBackground, $
                TRANSPARENCY=transparency, $
                _REF_EXTRA=_extra

    compile_opt idl2, hidden


    updateSelVisual = 0b

    if N_ELEMENTS(transparency) then $
        alphaChannel = (100 - transparency)/100d

    ; For horizontal alignment, change the horizontal location
    ; so that the text doesn't move.
    if N_ELEMENTS(_horizAlign) then begin
        _horizAlign = 0 > FIX(_horizAlign) < 2   ; 0, 1, or 2
        self._oText->GetProperty, ALIGNMENT=oldAlign, $
            LOCATION=location
        oldAlign = 0 > FIX(oldAlign*2) < 2   ; 0, 1, or 2
        if (oldAlign ne _horizAlign) then begin
            textDims = self->_GetTextDimensions()
            case _horizAlign of
                0: offset = (oldAlign eq 2) ? -textDims[0] : -textDims[0]/2
                1: offset = (oldAlign eq 0) ? textDims[0]/2 : -textDims[0]/2
                2: offset = (oldAlign eq 0) ? textDims[0] : textDims[0]/2
                else:
            endcase
            location[0] += offset
            ; Don't forget to convert from enumerated to floats.
            self._oText->SetProperty, ALIGNMENT=_horizAlign/2.0, $
                LOCATION=location
        endif
        updateSelVisual = 1b
    endif


    if (N_ELEMENTS(_string) gt 0) then $
        strings = _string

    if (N_ELEMENTS(fillBackground)) then begin
        self._oText->SetPropertyAttribute, 'FILL_COLOR', $
            SENSITIVE=KEYWORD_SET(fillBackground)
    endif

    ; Show once we have a real string (needed for Styles).
    if (N_ELEMENTS(strings) gt 0) then $
        self->SetPropertyAttribute, '_STRING', HIDE=0

    self._oText->SetProperty, $
      FILL_BACKGROUND=fillBackground, $
      STRINGS=strings, $
      FONT=fontObject, ALPHA_CHANNEL=alphaChannel

    ; Set superclass properties
    if (N_ELEMENTS(_extra) gt 0) then begin
        ; Look for font properties so we can set our updateSelVisual flag.
        match = Where(Strmid(_extra, 0, 5) eq 'FONT_', nmatch)
        if (nmatch gt 0) then updateSelVisual = 1b
        self->_IDLitVisualization::SetProperty, _EXTRA=_extra
    endif

    ;; To get the correct selection visual size, the text dimenions
    ;; must be recalculated. To do this the only real method at this
    ;; point in the system is to get the window and call
    ;; GetTextDimensions. This is what this code does.
    ;;
    ;; Note: This must occur after the call to the super calls b/c
    ;;       the font is aggregated.
    ;;
    ;; Note: The NO_UPDATE keyword allows interactive editing to
    ;;       disable the calculation (for performance
    ;; We also make sure that we are part of a Window/View.
    if ((~KEYWORD_SET(NO_UPDATE)) && $
        self->_GetWindowandViewG(oWin, oViewG) && $
        (updateSelVisual || N_ELEMENTS(strings))) then begin
        self->UpdateSelectionVisual
    endif

end
;;---------------------------------------------------------------------------
;; IDLitVisText::OnDataChangeUpdate
;;
;; Purpose:
;;  This routine is called when the data associated with this text is
;;  changed or initially associated this visualization
;;
;; Parameters:
;;   oSubject   - The data object of the parameter that changed. if
;;                parmName is "<PARAMETER SET>", this is an
;;                IDLitParameterSet object
;;
;;   parmName   - The name of the parameter that changed.
;;
;; Keywords:
;;   None.
;;

pro IDLitVisText::OnDataChangeUpdate, oSubject, parmName

    compile_opt idl2, hidden

    SWITCH STRUPCASE(parmName) OF
    '<PARAMETER SET>': begin ;; just the the vertices and fall through
            oSubject = oSubject->GetByName('LOCATION', count=count)
            if(count eq  0)then $
               break;
            ;; fall through
        end
    'LOCATION': BEGIN
            success = oSubject->GetData(Vertex)
            if(success)then $
              self._oText->SetProperty, LOCATION=temporary(vertex)
            BREAK
        END
    ELSE:
    ENDSWITCH

end

;---------------------------------------------------------------------------
; IDLitVisText::OnViewZoom
;
;
; Purpose:
;   This procedure method handles notification that the view's
;   zoom factor has changed.
;
; Arguments:
;   oSubject: A reference to the object sending notification of the
;     view zoom.
;
;   oDestination: A reference to the destination in which the view
;     appears.
;
;   newZoomFactor: A scalar representing the new zoom factor.
;
pro IDLitVisText::OnViewZoom, oSubject, oDestination, newZoomFactor

    compile_opt idl2, hidden

    ; Check if view zoom factor has changed.  If so, update the font.
    self._oFont->GetProperty, VIEW_ZOOM=fontViewZoom

    if (fontViewZoom ne newZoomFactor) then $
        self._oFont->SetProperty, VIEW_ZOOM=newZoomFactor

    self->UpdateSelectionVisual

    ; Allow superclass to notify all children.
    self->_IDLitVisualization::OnViewZoom, oSubject, oDestination, $
        newZoomFactor
end

;---------------------------------------------------------------------------
; IDLitVisText::OnViewportChange
;
; Purpose:
;   This procedure method handles notification that the viewport
;   has changed.
;
; Arguments:
;   oSubject: A reference to the object sending notification of the
;     viewport change.
;
;   oDestination: A reference to the destination in which the view
;     appears.
;
;   viewportDims: A 2-element vector, [w,h], representing the new
;     width and height of the viewport (in pixels).
;
;   normViewDims: A 2-element vector, [w,h], representing the new
;     width and height of the visibile view (normalized relative to
;     the virtual canvas).
;
pro IDLitVisText::OnViewportChange, oSubject, oDestination, $
    viewportDims, normViewDims

    compile_opt idl2, hidden

    ; Check if destination zoom factor or normalized viewport has changed.
    ; If so, update the corresponding font properties.
    self._oFont->GetProperty, FONT_ZOOM=fontZoom, FONT_NORM=fontNorm
    if (OBJ_VALID(oDestination)) then $
        oDestination->GetProperty, CURRENT_ZOOM=zoomFactor $
    else $
        zoomFactor = 1.0

    normFactor = MIN(normViewDims)

    if ((fontZoom ne zoomFactor) || $
        (fontNorm ne normFactor)) then $
        self._oFont->SetProperty, FONT_ZOOM=zoomFactor, FONT_NORM=normFactor

     self->UpdateSelectionVisual

    ; Allow superclass to notify all children.
    self->_IDLitVisualization::OnViewportChange, oSubject, oDestination, $
        viewportDims, normViewDims
end

;;
;;---------------------------------------------------------------------------
;; IDLitVisText::SetLocation
;;
;; Purpose:
;;    Used to set the location of the given text on the screen.
;;
;; Parameters:
;;   x   - X location
;;   y   - Y location
;;   z   - Z location
;;
;; Keywords:
;;  WINDOW    - If set, the provided values are in Window coordinates
;;              and need to be  converted into visualization coords.

pro IDLitVisText::SetLocation, x, y, z, WINDOW=WINDOW
  compile_opt hidden, idl2

  if(keyword_set(WINDOW))then $
    self->_IDLitVisualization::WindowToVis, [x, y, z], Pt $
  else $
    Pt=[x,y,z]

  oDataObj = self->GetParameter("LOCATION")
  if(obj_valid(oDataObj))then $
    iStatus = oDataObj->SetData(Pt)

end


;----------------------------------------------------------------------------
function IDLitVisText::_GetTextDimensions, _REF_EXTRA=_extra

    compile_opt idl2, hidden

    oTool=self->GetTool()

    ; Just make sure we have a parent, and then assume we are in the
    ; current tool hierarchy.
    self->GetProperty, PARENT=oParent

    if (obj_valid(oParent) && OBJ_VALID(oTool)) then begin
        oWin = oTool->GetCurrentWindow()
        if (OBJ_VALID(oWin)) then begin
            return, oWin->GetTextDimensions(self._oText, _EXTRA=_extra)
        endif
    endif

    return, [0, 0, 0]

end


;;----------------------------------------------------------------------------
;; IDLitVisText::UpdateSelectionVisual
;;
;; Purpose:
;;   This routine overrides the method in _IDLItVisualization so that
;;   the text dimensions can be calculated before the selection visual
;;   is updated. This is a non-optimal solution, but because of the
;;   implementation of text in the IDLgrText system, a
;;   GetTextDimensions() call must be made on the Window before the
;;   text size is know. If this isn't done, the selection visual will
;;   be incorrect.

pro IDLitVisText::UpdateSelectionVisual

    compile_opt idl2, hidden

    void = self->_GetTextDimensions()

    ; Call our superclass.
    self->_IDLitVisualization::UpdateSelectionVisual

end


;----------------------------------------------------------------------------
; Object Definition
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;+
; IDLitVisText__Define
;
; PURPOSE:
;    Defines the object structure for an IDLitVisText object.
;
;-
pro IDLitVisText__Define

    compile_opt idl2, hidden

    struct = { IDLitVisText,           $
               inherits IDLitVisualization, $
               _oText: obj_new(), $
               _oFont: OBJ_NEW() $
    }
end
