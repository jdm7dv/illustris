
;  Copyright (c)  2003, Research Systems, Inc. All rights reserved.
;       Unauthorized reproduction prohibited.
;
;+
;  FILE:
;       panorama.pro
;
;  CALLING SEQUENCE: panorama
;
;  PURPOSE:
;       VIEW TERAIN FROM POSITION SET ON PLAN VIEW
;
;
;  MAJOR TOPICS: Object graphics visualisation/investigation
;
;  CATEGORY:
;       IDL graphics pro
;
;  INTERNAL FUNCTIONS, PROCEDURES and FILES:
;
;     FILES: elevbin.dat & elev_t.jpg in the examples/data directory
;
;     PANORAMA:
;     main pro which sets up the widgets, reads in the surface & image,
;     creates objects and a structure (state) which is tied to the
;     top level base for passing variables and lobject references around
;
;     PICKIT:
;     Pro which responds to draw/mouse events in the left hand window.
;     Its purpose is to move a red marker to the mouse position and
;     translate the terain model to th eeye position in the right window.
;     It also alows a right mouse event to rotate th eview by 360 degrees.
;
;     VD:
;     Radio buttons call this event pro to give a N,S,E,W view from the
;     marker position. Further motion in the left window resets the view
;     to north.
;
;     ABOUTMENU_EVENT:
;     Called from the menu bar, gives a brief explanation of the concept
;     in a text box.
;
;     ABOUT_EVENT:
;     Unmaps the information box above
;
;     TEX_INTERP:
;     Radio buttons call this to swith texture interpolation on the image
;     on or off. Performance is faster in th eoff position.
;
;     CLEANUP:
;     Destroys objects and pointers to clean up.
;
;  EXTERNAL FUNCTIONS, PROCEDURES and FILES:
;       None
;  NAMED STRUCTURES:
;       none
;  ANON  STRUCTURES:
;       state - holds variables used in event procedures
;  COMMON BLOCKS:
;       none.
;
;  MODIFICATION HISTORY:
;       8th June 2003
;


PRO Cleanup, wID
  WIDGET_CONTROL, wID, GET_UVALUE = psState
  for i=0,n_tags((*psState))-1 do begin
    case size((*psState).(i), /TNAME) of
      'POINTER': $
        ptr_free, ((*psState)).(i)
      'OBJREF': $
        obj_destroy, ((*psState)).(i)
      else:
    endcase
  end
  ptr_free, psState
END

;---------------------------------------------------------------------

PRO File_Event, event
  WIDGET_CONTROL, event.top, /DESTROY
END

;---------------------------------------------------------------------

PRO About_Event, event
  WIDGET_CONTROL, event.top, MAP=0
END

;---------------------------------------------------------------------

PRO AboutMenu_Event, event
  WIDGET_CONTROL, event.top, GET_UVALUE = psState
  WIDGET_CONTROL, event.id, get_uvalue = uvalue
  CASE uvalue OF
    'concept': BEGIN
      text = STRARR(9)
      text[0] = 'The display is an object graphic surface of a ' + $
        'digital elevation array'
      text[1] = 'with an image of the region texture mapped on the surface.'
      text[2] = 'The XYZ mouse position is returned from the left window'
      text[3] = 'via a PICKDATA object. This model has the Z direction'
      text[4] = 'towards the viewer. The view on the right has the model'
      text[5] = 'rotated by 90 degrees so that the viewer sees it from ' + $
        'the side.'
      text[6] = 'The X,Y,Z coordinates returned from the left window (marker)'
      text[7] = 'are used to translate the model in the right window in ' + $
        'such that'
      text[8] = 'the X,Y,Z position is put right in front of the viewers eye.'
    END
    'file':   BEGIN
      text = STRARR(4)
      text[0] = 'To use this application with your own data, you will ' + $
        'need an image '
      text[1] = 'file and a digital elevation model (dem) file in the ' + $
        'ENVI format.'
      text[2] = 'Alternatively, edit the procedures GET_IMAGE_FILE & ' + $
        'GET_DEM_FILE'
      text[3] = 'to read in your own file formats.'
    END
  ENDCASE
  WIDGET_CONTROL, (*psState).wText, SET_VALUE=text
  WIDGET_CONTROL, (*psState).wtlb1, MAP=1
END

;---------------------------------------------------------------------

PRO Pick_Event, event
; =|=|=|=|=|=
; PRO TO RESPOND TO MOUSE EVENTS IN THE PLAN VIEW WINDOW,
; THIS IS THE HEART OF THIS APPLICATION
; =|=|=|=|=|=
;
  WIDGET_CONTROL, event.top, get_uvalue = psState
  WIDGET_CONTROL, (*psState).wVDbutton1, SET_BUTTON = 1
  obSel       = (*psState).oWindow1 -> $ ; Get the object the mouse is on
    Select((*psState).oView1, [event.x, event.y])
  IF OBJ_VALID(obSel[0]) THEN BEGIN ; Check it's actually an object

    IF event.press eq 4 THEN BEGIN ; Check for right mouse, rotate 360
      FOR i = 0,359 DO BEGIN    ; on perspective view
        (*psState).oModel2        -> ROTATE, [0,1,0], 1
        (*psState).oWindow2       -> DRAW, (*psState).oView2
      ENDFOR
    ENDIF

    IF obsel[0] NE (*psState).oMarker THEN BEGIN ; don't pick the marker ball
      ;; get the XYZ position that the mouse is on
      pick = (*psState).oWindow1 ->Pickdata((*psState).oView1, obsel[0],$ 
                                            [event.x, event.y],dataxyz)
      (*psState).oMarker -> SetProperty, HIDE = 1 ; hide the ball
      (*psState).oMarkerMod -> translate, -(*psState).xpos , $
        -(*psState).ypos, -(*psState).zpos ; take off the current translation
      ;; Now translate omodel2 to origin
      (*psState).oModel2 -> translate, (*psState).xpos ,(*psState).zpos, $
        -(*psState).ypos -0.02
      (*psState).xpos = dataxyz[0]*(*psState).xScale[1] + $
        (*psState).xscale[0]    ; calc position in Model coords
      (*psState).ypos = dataxyz[1]*(*psState).yScale[1] + (*psState).yscale[0]
      (*psState).zpos = dataxyz[2]*(*psState).zScale[1] + (*psState).zscale[0]
      (*psState).oMarkerMod -> translate, (*psState).xpos, (*psState).ypos, $
        (*psState).zpos         ; translate marker to cursor pos
      (*psState).oMarker -> SetProperty, HIDE = 0 ; unhide it
      (*psState).oWindow1 -> Draw, (*psState).oView1 ; draw the left window
      ;; Now translate omodel2 to this position
      (*psState).oModel2 -> translate, -(*psState).xpos, -(*psState).zpos, $
        (*psState).ypos +0.02   ; MOVE THE SURFACE TO THE EYE POSITION
      (*psState).oWindow2 -> Draw, (*psState).oView2 ; draw the right window
    ENDIF
  ENDIF
END

;---------------------------------------------------------------------

PRO TEX_INTERP, event
  ;; PRO TO INTERPOLATE THE IMAGE THE IMAGE PIXELS FOR A NICER RENDERING
  WIDGET_CONTROL, event.top, get_uValue = psState
  WIDGET_CONTROL, event.ID,  get_uValue = uValue
  CASE uValue OF
    'on':  BEGIN
      (*psState).oSurf1     -> SetProperty, TEXTURE_INTERP = 1
      (*psState).oSurf2     -> SetProperty, TEXTURE_INTERP = 1
    END
    'off': BEGIN
      (*psState).oSurf1       -> SetProperty, TEXTURE_INTERP = 0
      (*psState).oSurf2       -> SetProperty, TEXTURE_INTERP = 0
    END
  ENDCASE
  (*psState).oWindow1          -> Draw, (*psState).oView1
  (*psState).oWindow2          -> Draw, (*psState).oView2
END

;------------------------------------------------------------------------

PRO VD, event
  ;; OFFERS N,S,E,W view from marker position.
  ;; Resets to North on mouse movement
  WIDGET_CONTROL, event.top, get_uvalue = psState
  WIDGET_CONTROL, event.id, get_uValue = name

  CASE name OF
    'VDN': BEGIN
      (*psState).oModel2    -> ROTATE, [0,1,0], 0
      (*psState).oWindow2   -> DRAW, (*psState).oView2
    END
    'VDS': BEGIN
      (*psState).oModel2     -> ROTATE, [0,1,0], 180
      (*psState).oWindow2   -> DRAW, (*psState).oView2
      (*psState).oModel2     -> ROTATE, [0,1,0], -180
    END
    'VDE': BEGIN
      (*psState).oModel2    -> ROTATE, [0,1,0], 90
      (*psState).oWindow2   -> DRAW, (*psState).oView2
      (*psState).oModel2     -> ROTATE, [0,1,0], -90
    END
    'VDW': BEGIN
      (*psState).oModel2    -> ROTATE, [0,1,0], -90
      (*psState).oWindow2   -> DRAW, (*psState).oView2
      (*psState).oModel2     -> ROTATE, [0,1,0], 90
    END
  ENDCASE
END

;---------------------------------------------------------------------

PRO D_PANORAMA_EVENT, event
  WIDGET_CONTROL, event.top, GET_UVALUE = psState
END

;---------------------------------------------------------------------

PRO D_PANORAMA, $
                GROUP=group, $  ; IN: (opt) group identifier
                RECORD_TO_FILENAME=record_to_filename, $
                APPTLB = appTLB ; OUT: (opt) TLB of this application

  ;; MAIN PRO TO SET UP 2 WINDOWS AND PLACE A SURFACE IN THE LEFT
  ;; (PLAN VIEW) AND ALSO IN RIGHT (ON LOCATION VIEW) 
  ; ===================================================================
  ; ===================================================================

  ;;  Check the validity of the group identifier.
  ngroup = N_ELEMENTS(group)
  if (ngroup NE 0) then begin
    check = widget_INFO(group, /valid)
    if (check NE 1) then begin
      print,'Error, the group identifier is not valid'
      print, 'Return to the main application'
      RETURN
    endif
    groupBase = group
  endif else groupBase = 0L

  ; ###############  S E T    U P    T H E    W I D G E T S   #############
  IF groupBase EQ 0l THEN $
    wtlb = WIDGET_BASE(title='Panorama Demo', /col, mbar=mbar) $
  ELSE $
    wtlb = WIDGET_BASE(title='Panorama Demo', /col, mbar=mbar, $
                       group_leader=groupBase)
  ;; set to return the TLB of this demo
  appTLB = wtlb
  wfmenu = WIDGET_BUTTON(mbar, value = 'File', /menu)
  wamenu = WIDGET_BUTTON(mbar, value = 'About', /menu)
  wquit = WIDGET_BUTTON(wfmenu, value = 'Exit', event_pro = 'File_Event')
  wabutton = WIDGET_BUTTON(wamenu, value   = 'Conceptual description',  $
                           event_pro = 'AboutMenu_Event', uvalue = 'concept')
  wbase1 = WIDGET_BASE(wtlb, /row,/KBRD_FOCUS_EVENTS)
                       ;; left window used for picking observation point
  wdraw1 = WIDGET_DRAW(wbase1, xsize = 400, ysize = 400, $ 
                       /button_events, /motion_events, $
                       graphics_level = 2, keyboard_event = 2, $
                       event_pro = 'Pick_Event')
  ;; right window used for displaying panorama view from point picked in draw1
  wdraw2 = WIDGET_DRAW(wbase1, xsize  = 600, ysize = 400, $ 
                       yoffset = 50, graphics_level = 2)
  wlowbase = WIDGET_BASE(wtlb, /row)
  wbase2 = WIDGET_BASE(wlowbase, /col, xsize = 398, frame = 1)
  wlabel = WIDGET_LABEL(wbase2, value = $
                        'Rove in left image, right mouse for panoramic view')
  wbaseint = WIDGET_BASE(wbase2, /row, /exclusive)
  wbasedir = WIDGET_BASE(wbase2, /row, /exclusive)
  wcontrolbase = WIDGET_BASE(wlowbase, /col, xsize = 598, frame = 1, $
                             /align_cent)
  wbase3 = WIDGET_BASE(wlowbase, /row, /exclusive)
  wtexbutton1 = WIDGET_BUTTON(wbaseint, value = 'Texture Interp off',   $
                              uvalue = 'off',event_pro = 'Tex_interp')
  wtexbutton2 = WIDGET_BUTTON(wbaseint, value = 'Texture Interp on',    $
                              uvalue = 'on',event_pro = 'Tex_interp')
  wbase4 = WIDGET_BASE(wlowbase, /row, /exclusive)
  wlabel2 = WIDGET_LABEL(wcontrolbase, value = 'View Direction')
  wvdbase = WIDGET_BASE(wcontrolbase,/row, /exclusive)
  wvdbutton1 = WIDGET_BUTTON(wvdbase, value = 'North ',            $
                             event_pro = 'VD', uvalue = 'VDN')
  wvdbutton2 = WIDGET_BUTTON(wvdbase, value = 'South ',            $
                             event_pro = 'VD', uvalue = 'VDS')
  vd_but3 = WIDGET_BUTTON(wvdbase, value = 'East ',                $
                          event_pro = 'VD', uvalue = 'VDE')
  vd_but4 = WIDGET_BUTTON(wvdbase, value = 'West ',                $
                          event_pro = 'VD', uvalue = 'VDW')
  ;; Floating help window:
  wtlb1 = WIDGET_BASE(Title = 'About the application', /col, $
                        /FLOATING, GROUP_LEADER=wtlb, $
                        event_pro = 'About_Event')
  wtext = WIDGET_TEXT(wtlb1, value = ' ', xsize = 57, ysize = 9)
  wdonebutton = WIDGET_BUTTON(wtlb1, value = 'Done')
  WIDGET_CONTROL, wtlb, /REALIZE
  WIDGET_CONTROL, wtlb1, /REALIZE
  WIDGET_CONTROL, wtlb1, MAP=0
  WIDGET_CONTROL, wtexbutton1, SET_BUTTON = 1
  WIDGET_CONTROL, wVDbutton1, SET_BUTTON = 1
  WIDGET_CONTROL, wfmenu, SENSITIVE = 1
  WIDGET_CONTROL, wdraw1, get_value = oWindow1
  WIDGET_CONTROL, wdraw2, get_value = oWindow2

  ; !!!!!!!!!!!!!! N O W   S E T   U P   O B J E C T S !!!!!!!!!!!!!!!!!!!!

  data = BYTARR(64,64, /NOZERO)
  ;; Get the elevation data suplied with IDL
  OPENR, lun, demo_filepath('elevbin.dat', $ 
                            SUBDIR=['examples','data']), /GET_LUN
  READU, lun, data
  FREE_LUN, lun
  data = REVERSE(TEMPORARY(data), 2) ; Turn it to the an apropriate orientation
  ;;  Create texture map.
  ;; Get the image for the elevationarray
  READ_JPEG, demo_filepath('elev_t.jpg', $ 
                           SUBDIR=['examples','data']), idata, TRUE=3
  idata = REVERSE(TEMPORARY(idata), 2)
  info = SIZE(idata)
  m = INFO[1]
  n = INFO[2]
  ;; Double the texture map size
  idata = CONGRID(idata,m*2, n*2,info[3] ,cubic = -0.5)
  oImage = OBJ_NEW('IDLgrImage', idata,    INTERLEAVE=2)
  info = SIZE(data)
  m = INFO[1]
  n = INFO[2]

  xscale = [-0.5, 1.0/(m-1)] ; Set the scaling of the surface
  yscale = [-0.5, 1.0/(n-1)]
  zscale = [-0.075, 0.15/MAX(data)]

  ;; this is the plan-view surface
  oSurf1 = OBJ_NEW('IDLgrSurface', data, color = [255,255, 255], $ 
                   XCOORD_CONV =   xscale,               $
                   YCOORD_CONV =   yscale,               $
                   ZCOORD_CONV =   zscale,             $
                   STYLE      = 2,                   $
                   TEXTURE_MAP = oImage,              $
                   shading        = 1     )
  ;; this is the on-location surface
  oSurf2 = OBJ_NEW('IDLgrSurface', data, color = [255,255, 255], $
                   XCOORD_CONV =   xscale,               $
                   YCOORD_CONV =   yscale,               $
                   ZCOORD_CONV =   zscale,             $
                   STYLE      = 2,                   $
                   TEXTURE_MAP = oImage,              $
                   shading        = 1     )

  oLight = OBJ_NEW('IDLgrLight', TYPE = 0, LOCATION =        $
                   [0.25, 1.0, 3.0], COLOR = [255,255,255])
  oLightModel1 = OBJ_NEW('IDLgrModel')
  oLightModel1 -> Add, oLight
  oLightModel2 = OBJ_NEW('IDLgrModel')
  oLightModel2 -> Add, oLight, /ALIAS
  oModel1 = OBJ_NEW('IDLgrModel') ; image/map  model
  oModel2 = OBJ_NEW('IDLgrModel') ; onlocation model
  oCupModel = OBJ_NEW('IDLgrModel')
  oModel1 -> Add, oSurf1
  oModel2 -> Add, oSurf2
  oView1 = OBJ_NEW('IDLgrView', color = [0,0,0],         $
                    viewplane_rect = [-0.5, -0.5, 1.0, 1.0]) ;image plan view
  oView2 = OBJ_NEW('IDLgrView', color = [20,50,75],      $
                   eye = 1.01, zclip = [1, -1],projection = 2,      $
                   viewplane_rect = [-1.5, -1, 3.0, 2]) ;on location view
  oView1 -> Add, oModel1
  oView1 -> Add, oLightModel1

  ;; Create a ball polygons
  MESH_OBJ, 4, Vertex_List1, Polygon_List1, Replicate(0.0075, 36,36)
  oMarker = OBJ_NEW('IDLgrpolygon',vertex_list1,          $
                    polygons=polygon_list1,                    $
                    style=2,shading=1, color = [255,0,0])
  oSphMod = OBJ_NEW('IDLgrModel')
  oMarkerMod = OBJ_NEW('IDLgrModel')
  oSphMod -> Add, oMarker
  oSphMod -> Translate, 0, 0.005,0
  oMarkerMod -> Add, oSphMod
  oModel1 -> Add, oMArkerMod
  oCupModel -> Add, oModel2   ; put the onlocation model in a container
  oView2 -> Add, oCupModel
  oView2 -> Add ,oLightModel2

   ; ^^^^^^^^^^^^^^^^^^ POSITION THE SURFACE IN WINDOW ^^^^^^^^^^^^^^^^^^

  oModel2 -> ROTATE, [1,0,0], -90 ; set the surface upright
  oCupModel -> TRANSLATE, 0,-0.02,0
  oModel1 -> TRANSLATE, 0,0,0.02
  oCupModel -> TRANSLATE, 0, 0,0.995 ; slam the cup up against the eye
  oCupModel -> TRANSLATE, 0,-0.02,0 ; bring world down a bit
  oWindow1 -> Draw, oView1
  oWindow2 -> Draw, oView2
   ; +++++++++++++++++  now make a list of objects    ++++++++++++++++++++

  psState = PTR_NEW({                          $
                      wtlb1      : wtlb1,      $ ; Floating base
                      wText      : wText,      $ ; About text
                      wVDbutton1 : wVDbutton1, $ ; North radio button
                      oModel1    : oModel1,    $ ; Plan surface model
                      oModel2    : oModel2,    $ ; On location surface model
                      oSurf1     : oSurf1,     $ ; dem surface
                      oSurf2     : oSurf2,     $ ; dem surface
                      oImage     : oImage,     $ ; image of terain
                      oView1     : oView1,     $ ; left window view
                      oView2     : oView2,     $ ; right window view
                      oWindow1   : oWindow1,   $ ; left window
                      oWindow2   : oWindow2,   $ ; right window
                      oMarker    : oMarker,    $ ; marker object
                      oMarkerMod : oMarkerMod, $ ;
                      xscale     : xscale,     $ ; scaling factors
                      yscale     : yscale,     $
                      zscale     : zscale,     $
                      xpos       : 0.0,        $ ; xposition of marker 
                                                 ; in norm units 
                      ypos       : 0.0,        $ ; yposition of marker 
                                                 ; in norm units
                      zpos       : 0.0         $ ; zposition of marker
                                                 ; in norm units
                      },/NO_COPY)

  widget_control, wtlb, set_uvalue = psState
  XMANAGER, 'd_panorama', wtlb, CLEANUP='Cleanup', /no_block

END
