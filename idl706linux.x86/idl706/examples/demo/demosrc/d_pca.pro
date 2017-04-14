;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_pca.pro#1 $
;
;  Copyright (c) 1997-2006, ITT VIS, All rights reserved.
;       Unauthorized reproduction prohibited.
;
;+
;  FILE:
;       d_pca.pro
;
;  CALLING SEQUENCE: d_pca
;
;  PURPOSE:
;       This demo shows the various plots in IDL made from 2-D data.
;
;  MAJOR TOPICS: Data analysis and plotting
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_pcaEvent            -  Event handler
;       pro d_pcaDRAW1      -  Mouse rotation for window 1
;       pro d_pcaDRAW2      -  Mouse rotation for window 2
;       pro d_pcaCleanup          -  Cleanup
;       pro d_pca                 -  Main procedure
;   function Normalize     -  function that takes graphics coordinates and returns
;              device coodinates
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pca.tip
;       pro demo_gettips            - Read the tip file and create widgets
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       98,   ACY        - Written.
;       04,   ASW        Ported graphics to objects graphics system.
;+/

; -----------------------------------------------------------------------------
; Purpose: normalize coordinates into device coordinates for object
; From IDL Power Graphics Book.
FUNCTION Normalize, range, Position=position
  On_Error, 1
  IF N_Params() EQ 0 THEN Message, 'Please pass range vector as argument.'
  IF (N_Elements(position) EQ 0) THEN position = [0.0, 1.0] ELSE $
    position=Float(position)
  range = Float(range)
  scale = [((position[0]*range[1])-(position[1]*range[0])) / (range[1]-range[0]), $
           (position[1]-position[0])/(range[1]-range[0])]
  RETURN, scale
END

;-------------------------------------------------------------------------
;  Purpose:  Event handler
;
pro d_pcaEvent, $
  sEvent                        ; IN: event structure

    ;  Quit the application using the close box.
    ;
  if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
      'WIDGET_KILL_REQUEST') then begin
    WIDGET_CONTROL, sEvent.top, /DESTROY
    RETURN
  endif

    ;  Determine which event.

  WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventval

    ;  Take the following action based on the corresponding event.

  case eventval of
    'flat' : begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sstate.oSurface2->SetProperty, shading=0, style=2
      sstate.window2->draw, sstate.oview2
      sstate.oSurface1->SetProperty, shading=0, style=2
      sstate.window1->draw, sstate.oview1
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState,/NO_COPY
    end
    'gouraud' : begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState,  /NO_COPY
      sstate.oSurface2->SetProperty, shading=1, style=2
      sstate.window2->draw, sstate.oview2
      sstate.oSurface1->SetProperty, shading=1, style=2
      sstate.window1->draw, sstate.oview1
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end
    'Net' : begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /hourglass,/NO_COPY
      sstate.oSurface2->SetProperty, style=1
      sstate.window2->draw, sstate.oview2
      sstate.oSurface1->SetProperty, style=1
      sstate.window1->draw, sstate.oview1
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end
    'Gray' : begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /hourglass,/NO_COPY
      sstate.oView1->SetProperty, color=[155,155,155]
      sstate.window1->draw, sstate.oview1
      sstate.oview2->SetProperty, color=[155,155,155]
      sstate.Window2->draw, sstate.oview2
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end
    'White' : begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /hourglass,/NO_COPY
      sstate.oView1->SetProperty, color=[255,255,255]
      sstate.window1->draw, sstate.oview1
      sstate.oview2->SetProperty, color=[255,255,255]
      sstate.Window2->draw, sstate.oview2
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end
    'Biege' : begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /hourglass,/NO_COPY
      sstate.oView1->SetProperty, color=[238,232,170]
      sstate.window1->draw, sstate.oview1
      sstate.oview2->SetProperty, color=[238,232,170]
      sstate.Window2->draw, sstate.oview2
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end
    'Open in iSurface' : begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /hourglass, /NO_COPY
      isurface, sstate.pcadata
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end
    'EigenValues': begin
         ;  Check if the  plot already exists
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState,  /hourglass, /NO_COPY
      errorStatus = WIDGET_INFO(sState.drawEigenValID, /VALID_ID)
      if (errorStatus EQ 0) then begin

            ;  Create a new window that displays the eigenvalue plot.
            ;
        eigenValBase = WIDGET_BASE(TLB_FRAME_ATTR=1, $
                                   TITLE ='Eigenvalue Plot', $
                                   XOFFSET=700, YOFFSET=75, $
                                   GROUP_LEADER=sState.wTopBase)
        
        sState.drawEigenValID = WIDGET_DRAW(eigenValBase, /frame,$
                                            SCR_XSIZE=250, SCR_YSIZE=200, graphics_level=2, $
                                            /motion_events, /button_events,/expose_events)
        
        WIDGET_CONTROL, eigenValBase, /REALIZE
      endif
      
      WIDGET_CONTROL, sState.drawEigenValID, GET_VALUE=eigenValWindow
      
      eigenvalwindow->draw, sstate.oView
      
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end

    'Pcomp': begin
  ;  Check if the  plot already exists
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState,  /hourglass, /NO_COPY
      errorStatus = WIDGET_INFO(sState.drawPcompid, /VALID_ID)

      if (errorStatus EQ 0) then begin
     ;  Create a new window that displays the eigenvalue plot.
        pcompBase = WIDGET_BASE(TLB_FRAME_ATTR=1, $
                                TITLE ='Principal Components Plot', $
                                XOFFSET=700, YOFFSET=400, $
                                GROUP_LEADER=sState.wTopBase)

        sState.drawPcompid = WIDGET_DRAW(pcompBase, /frame,$
                                         SCR_XSIZE=250, SCR_YSIZE=200, graphics_level=2, $
                                         /motion_events, /button_events,/expose_events)
        WIDGET_CONTROL, pcompBase, /REALIZE
      endif

      WIDGET_CONTROL, sState.drawPcompid, GET_VALUE=pcompWindow
      pcompWindow->draw, sstate.oView3
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end

  ;Create PCA plot

    'Variances': begin

      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState,  /hourglass, /NO_COPY
      void = DIALOG_MESSAGE([$
             ['Variance Summary'], $
             [' '], $
             ['1st Derived Variable: ' + STRING(sstate.variances[0])], $
             [' '], $
             ['2nd Derived Variable: ' + STRING(sstate.variances[1])], $
             [' '], $
             ['3rd Derived Variable: ' + STRING(sstate.variances[2])], $
             [' '], $
             ['4th Derived Variable: ' + STRING(sstate.variances[3])], $
             [' '], $
             ['5th Derived Variable: ' + STRING(sstate.variances[4])], $
             [' '], $
             ['TOTAL Variance: ' + STRING(TOTAL(sstate.variances[0:4]))]], $
                            title = 'Principal Components Analysis', /information)
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end

    "ABOUT": begin

      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState,  /hourglass, /NO_COPY
            ;  Display the information.
            ;
      ONLINE_HELP, 'd_pca', $
                   book=demo_filepath("idldemo.adp", $
                                      SUBDIR=['examples','demo','demohelp']), $
                   /FULL_PATH
            ;  Restore the info structure
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY

    end

    "QUIT": begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState,  /hourglass, /NO_COPY

            ;  Restore the info structure before destroying event.top
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY

            ;  Destroy widget hierarchy.
      WIDGET_CONTROL, sEvent.top, /DESTROY

    end

    ELSE : begin

      PRINT, 'Case Statement found no matches'

            ; Restore the info structure
      WIDGET_CONTROL, sEvent.top, Set_UValue=sstate, /No_Copy
    end

  endcase

end                             ; of d_pcaEvent

;----------------------------------------------------------------------------

pro d_pcaDRAW1, event

    ; add track ball to first(left) window
  WIDGET_CONTROL, Event.top, GET_UVALUE=sState

      ; update trackball and renderview
      ; handle trackball updates for window 1 (left)

  bHaveTransform = sState.oTrack1->Update(Event, TRANSFORM=qmat1)
  IF (bHaveTransform NE 0) THEN BEGIN
    sState.omodel1->GetProperty, TRANSFORM=t1
    sState.omodel1->SetProperty, TRANSFORM=t1#qmat1
    sState.window1->Draw, sState.oView1
  ENDIF
end

;______________________________________________________________________________________

pro d_pcaDRAW2, event

   ; Handle trackball updates. for window 2 (right)

  WIDGET_CONTROL, Event.top, GET_UVALUE=sState
  bHaveTransform = sState.oTrack2->Update(Event, TRANSFORM=qmat2)
  IF (bHaveTransform NE 0) THEN BEGIN
    sState.omodel2->GetProperty, TRANSFORM=t2
    sState.omodel2->SetProperty, TRANSFORM=t2#qmat2
    sState.window2->Draw, sState.oView2
  ENDIF
end

; ----------------------------------------------------------------------------
;
;  Purpose:  Cleanup procedure
;
pro d_pcaCleanup, $
  wTopBase                      ; IN: top level base associated with the cleanup

  Compile_opt idl2

  WIDGET_CONTROL, wTopBase, GET_UVALUE=sState,/No_Copy

    ;  Map the group leader base if it exists.
    ;
  if (WIDGET_INFO(sState.groupBase, /VALID_ID)) then $
    WIDGET_CONTROL, sState.groupBase, /MAP
  obj_destroy, sstate.oContainer1
  obj_destroy, sstate.oContainer2
  obj_destroy, sstate.oView     ;eigenval plot window
  obj_destroy, sstate.oView3    ;pcomp plot window
end                             ; of d_pcaCleanup

; -----------------------------------------------------------------------------
;
;  Purpose:  Main procedure of the pca demo
;
pro d_pca, $
  GROUP=group, $                ; IN: (opt) group identifier
  RECORD_TO_FILENAME=record_to_filename, $
  APPTLB = appTLB, $            ; OUT: (opt) TLB of this application
  _EXTRA=_extra
  
  compile_opt idl2

    ; Check the validity of the group identifier
    ;
  ngroup = N_ELEMENTS(group)
  if (ngroup NE 0) then begin
    check = WIDGET_INFO(group, /VALID_ID)
    if (check NE 1) then begin
      print,'Error, the group identifier is not valid'
      print, 'Return to the main application'
      RETURN
    endif
    groupBase = group
  endif else groupBase = 0L

;;;;;; Generate the PCA data from the data in EXAMPLES
  filename = demo_filepath("pca_med.dat", $
                           SUBDIR=['examples','demo','demodata'])
  N_Variables = 50  &  N_Samples = 230
  data = FLTARR(N_Variables, N_Samples, /NOZERO)
  OPENR, lun, /GET_LUN, filename, /XDR
  READU, lun, data
  FREE_LUN, lun

  variances = 1  &  eigenvalues = 1

    ;Since PCOMP is an iterative routine, floating underflow
    ;of a result is expected.  Floating underflow occurs when
    ;a result is so close to zero that it cannot be represented
    ;as a normalized floating point value.  This occurs during
    ;convergence in the iterative routine since the delta between
    ;two steps will be very small.
    ;Silently accumulate any subsequent math errors and ignore them.

  orig_except = !except
  !except = 0
  pcadata = PCOMP(standardize(data, /double), $
                  eigenvalues = eigenvalues, variances = variances, /double)
  ignore = check_math()         ; Get status and reset.
  pcadata=float(pcadata)
  variances=variances[0:5]

    ; Restore original math error behavior.
  !except = orig_except

    ;  Create the starting up message.
  if (ngroup EQ 0) then begin
    drawbase = demo_startmes()
  endif else begin
    drawbase = demo_startmes(GROUP=group)
  endelse

    ;  Get the screen size.
  Device, GET_SCREEN_SIZE = screenSize

    ;  Set up dimensions of the drawing (viewing) area.
  xdim = screenSize[0]*0.8 / 2.0
  ydim = xdim
    ; Define a main widget base.
  if (N_ELEMENTS(group) EQ 0) then begin
    wTopBase = WIDGET_BASE(TITLE="Pca Plotting", /COLUMN, $
                           /TLB_KILL_REQUEST_EVENTS, $
                           MAP=0, $
                           TLB_FRAME_ATTR=1, MBAR=barBase)
  endif else begin
    wTopBase = WIDGET_BASE(TITLE="Pca Plotting", /COLUMN, $
                           /TLB_KILL_REQUEST_EVENTS, $
                           MAP=0, $
                           GROUP_LEADER=group, $
                           TLB_FRAME_ATTR=1, MBAR=barBase)
  endelse

        ;  Create the quit button
        ;
  wFileButton = WIDGET_BUTTON(barBase, VALUE= 'File', /MENU)

  wQuitButton = WIDGET_BUTTON(wFileButton, $
                              VALUE='Quit', UVALUE='QUIT')

  ;create options button
  wOptionButton = WIDGET_BUTTON(barBase, VALUE='Options', /MENU)

  wEigenval = WIDGET_BUTTON(wOptionButton, $
                            VALUE="Show Eigenvalues", $
                            UVALUE='EigenValues')
  wPcomp = WIDGET_BUTTON(wOptionButton, $
                         VALUE="Show Significant Components", $
                         UVALUE='Pcomp')
  wDescripButton = WIDGET_BUTTON(wOptionButton, $
                                 VALUE="Show Variances", $
                                 UVALUE='Variances')
  wStyle = WIDGET_BUTTON(wOptionButton,MENU=2, $
                         VALUE="Style", $
                         UVALUE='style')
  wButton=WIDGET_BUTTON(wStyle, VALUE='Net', UVALUE='Net')
  wButton=WIDGET_BUTTON(wStyle, VALUE='Flat', UVALUE='flat')
  wButton=WIDGET_BUTTON(wStyle, VALUE='Gouraud-Default', UVALUE='gouraud')
  wBackground=WIDGET_BUTTON(wOptionButton, MENU=2,$
                            VALUE="Background",$
                            UVALUE='background')
  wButton=WIDGET_BUTTON(wBackground, VALUE='Gray', UVALUE='Gray')
  wButton=WIDGET_BUTTON(wBackground, VALUE='White', UVALUE='White')
  wButton=WIDGET_BUTTON(wBackground, VALUE='Biege', UVALUE='Biege')
;   wItoolbutton=WIDGET_BUTTON(wOptionButton, $
;                              VALUE="Open in iSurface",$
;                              UVALUE='Open in iSurface')
  
        ; Create the help button
  wHelpButton = WIDGET_BUTTON(barBase, /HELP, $
                              VALUE='About', /MENU)

  wAboutButton = WIDGET_BUTTON(wHelpButton, $
                               VALUE='About Principal Components Analysis', UVALUE='ABOUT')

        ; Create the first child of the top level base
  wTopRowBase = WIDGET_BASE(wTopBase, COLUMN=2, /FRAME)

;;;;;;;;;;LEFT DRAW

    ; Create a base for the left column
  wLeftBase = WIDGET_BASE(wTopRowBase, /COLUMN)

  label = WIDGET_LABEL(wLeftBase, value = 'Multivariate Data',$
                       /align_center)

  wDraw1 = WIDGET_DRAW(wLeftBase, scr_xsize = xdim, graphics_level=2, $
                       scr_ysize = ydim, /frame, /motion_events, renderer=1,$
                       event_pro='d_pcaDRAW1', /expose_events,/button_events, retain=0)

  clabels = STRARR(N_Variables)
  for k = 1, N_Variables do clabels[k-1] = 'Variable ' + $
                                           STRTRIM(STRING(k),2)

  rlabels = STRARR(N_Samples)
  for k = 1, N_Samples do rlabels[k-1] = 'Sample ' + $
                                         STRTRIM(STRING(k),2)

  table = WIDGET_TABLE(wLeftBase, value = data, $
                       frame = 10, column_labels = clabels, $
                       row_labels = rlabels, $
                       x_scroll_size = 2, y_scroll_size = 3, /scroll)

;;;;;;;;;;RIGHT DRAW

  wRightBase = WIDGET_BASE(wTopRowBase, /COLUMN)

  label = WIDGET_LABEL(wRightBase, $
                       value = 'Principal Components Data', $
                       /align_center)

  wDraw2 = WIDGET_DRAW(wRightBase, scr_xsize = xdim, renderer=1,$
                       scr_ysize = ydim,graphics_level=2, /frame,event_pro='d_pcadraw2',$
                       /expose_events, /motion_events, /button_events, retain=0)

  table = WIDGET_TABLE(wRightBase, value = pcadata, $
                       frame = 10, column_labels = clabels, $
                       row_labels = rlabels, $
                       x_scroll_size = 2, y_scroll_size = 3, /scroll)

     ;  Create tips texts.
     ;
  wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
  WIDGET_CONTROL, wTopBase, /REALIZE


  widget_control, wDraw1, get_value=window1

;;;;;;;;Draw data in fist(right) view
    ; Create a view.
  oView1 = OBJ_NEW('IDLgrView', color=[255,255,255], VIEWPLANE_RECT=[-1,-1,2.0,2.0],$
                   projection=2,zclip=[4,-4],eye=10,location=[0,0])

    ; Create a model.
  oModel1 = OBJ_NEW('IDLgrModel' )
  oView1->Add, oModel1

    ;create color table
  oPalette=obj_new('IDLgrPalette')
  oPalette->loadct, 10

    ; Create a surface of original data
  num_verts=n_variables*n_samples
  oSurface1 = OBJ_NEW('IDLgrSurface', Data,  style=2, shading=1)
  oSurface1->setProperty, palette=opalette,vert_colors=reform(bytscl(data), num_verts)

    ; Add the surface to the model.
  oModel1->Add, oSurface1

  ; Create some lights.
  oLight = OBJ_NEW('IDLgrLight', LOCATION=[2,2,2], TYPE=2)
  oModel1->Add, oLight
  oLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
  omodel1->Add, oLight
    ; Get the data range of the surface.
  oSurface1->GetProperty,XRANGE=xrange,YRANGE=yrange,ZRANGE=zrange

    ; Scale surface to normalized units and center.
  xs = norm_coord(xrange)
  ys = norm_coord(yrange)
  zs = norm_coord(zrange)
  xs[0] = xs[0]-0.5
  ys[0] = ys[0]-0.5
  zs[0] = zs[0]-0.5
  oSurface1->SetProperty,XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs

    ; Rotate model to standard view.
  oModel1->Rotate,[1,0,0], -90
  oModel1->Rotate,[0,1,0], 30
  oModel1->Rotate,[1,0,0], 30

  oView1->setProperty,projection=2 ;perspective projection so you can feelike you're flying in.
  oTrack1=OBJ_NEW('trackball', [200, 200], 200)

    ; create titles and axis
  xTitleObj = Obj_New('IDLgrText', 'Variables', Color=[0,0,0])
  yTitleObj = Obj_New('IDLgrText', 'Samples', Color=[0,0,0])
  zTitleObj = Obj_New('IDLgrText', 'Magnitude', Color=[0,0,0])

  ; set axis ranges
  xr1=[0,50]
  yr1=[0,230]
  zr1=[min(data), max(data)]

  ; normalize the ranges to device coordinates
  xr1norm=normalize(xr1, position=[-.5, .5])
  yr1norm=normalize(yr1, position=[-.5, .5])
  zr1norm=normalize(zr1, position=[-.5, .5])

  helvetica6pt = Obj_New('IDLgrFont', 'Helvetica', Size=6)

  ; Create Axis objects, set ranges and device coords.
  xAxis = Obj_New("IDLgrAxis", 0, Color=[0,0,0], Ticklen=0.1, $
                  Minor=4, Title=xtitleObj,XCOORD_CONV=xr1norm, Range=xr1,$
                  location=[1000, -.5,-.5], Exact=1)
  xAxis->GetProperty, Ticktext=xAxisText
  xAxisText->SetProperty, Font=helvetica6pt, Recompute_Dimensions=2

  yAxis = Obj_New("IDLgrAxis", 1, Color=[0,0,0], Ticklen=0.1, $
                  Minor=4, Title=ytitleObj, Range=yr1, Exact=1,$
                  location=[-0.5, 1000, -0.5], YCOORD_CONV=yr1norm)
  yAxis->GetProperty, Ticktext=yAxisText
  yAxisText->SetProperty, Font=helvetica6pt, Recompute_Dimensions=2

  zAxis = Obj_New("IDLgrAxis", 2, Color=[0,0,0], Ticklen=0.1, $
                  Minor=4, Title=ztitleObj, Range=zr1, Exact=1,$
                  location=[-0.5, 0.5, 1000], ZCOORD_CONV=zr1norm)
  zAxis->GetProperty, Ticktext=zAxisText
  zAxisText->SetProperty, Font=helvetica6pt, Recompute_Dimensions=2

  omodel1->add, xAxis
  omodel1->add, yaxis
  omodel1->add, zaxis

  ; draw object graphics to window1
  window1->draw,  oView1

  ; create a container object for easy cleanup
  oContainer1=obj_new('IDL_Container')
  oContainer1->Add, oView1
  oContainer1->Add,oTrack1

;;;;Draw data in second (right) window

  widget_control, wdraw2, get_value=window2

    ; Create a view.
  oView2 = OBJ_NEW('IDLgrView', color=[255,255,255], VIEWPLANE_RECT=[-1.0,-1.0,2.0,2.0],$
                   projection=2, zclip=[4,-4],eye=10,location=[0,0])

    ; Create a model.
  oModel2 = OBJ_NEW('IDLgrModel' )
  oView2->Add, oModel2

    ; create color table
  oPalette=obj_new('IDLgrPalette')
  oPalette->loadct,10
  oPalette->setProperty, bottom_stretch=25, top_stretch=55

    ; Create a surface
  num_verts=n_variables*n_samples
  oSurface2 = OBJ_NEW('IDLgrSurface', pcaData,  style=2, shading=1)
  oSurface2->setProperty, palette=opalette,vert_colors=reform(bytscl(pcadata), num_verts)

    ; Add the surface to the model.
  oModel2->Add, oSurface2

  ; Add some lights
  oLight = OBJ_NEW('IDLgrLight', LOCATION=[2.0,2.0, 2.0], TYPE=2) ;directional light
  oModel2->Add, oLight
  oLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.40) ;ambient light
  omodel2->Add, oLight

    ; Get the data range of the surface.
  oSurface2->GetProperty,XRANGE=xrange,YRANGE=yrange,ZRANGE=zrange

    ; Scale surface to normalized units and center.
  xs = norm_coord(xrange)
  ys = norm_coord(yrange)
  zs = norm_coord(zrange)
  xs[0] = xs[0]-0.5
  ys[0] = ys[0]-0.5
  zs[0] = zs[0]-0.5
  oSurface2->SetProperty,XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs

    ; Rotate model to standard view.
  oModel2->Rotate,[1,0,0], -90
  oModel2->Rotate,[0,1,0], 30
  oModel2->Rotate,[1,0,0], 30

  oView2->setProperty,projection=2 ;perspective projection so you can feelike you're flying in.
  oTrack2=OBJ_NEW('trackball', [xdim/2, ydim/2], 256)

    ; create titles and axis
  xTitleObj = Obj_New('IDLgrText', 'Variables', Color=[0,0,0])
  yTitleObj = Obj_New('IDLgrText', 'Samples', Color=[0,0,0])
  zTitleObj = Obj_New('IDLgrText', 'Magnitude', Color=[0,0,0])
  xr2=[0,50]
  yr2=[0,230]
  zr2=[min(pcadata), max(pcadata)]
  xr2norm=normalize(xr2, position=[-.5, .5])
  yr2norm=normalize(yr2, position=[-.5, .5])
  zr2norm=normalize(zr2, position=[-.5, .5])
  helvetica6pt = Obj_New('IDLgrFont', 'Helvetica', Size=6)

  ; Create Axis Objects
  xAxis = Obj_New("IDLgrAxis", 0, Color=[0,0,0], Ticklen=0.1, $
                  Minor=4, Title=xtitleObj,XCOORD_CONV=xr2norm, Range=xr2,$
                  location=[1000, -.5,-.5], Exact=1)
  xAxis->GetProperty, Ticktext=xAxisText
  xAxisText->SetProperty, Font=helvetica6pt, Recompute_Dimensions=2

  yAxis = Obj_New("IDLgrAxis", 1, Color=[0,0,0], Ticklen=0.1, $
                  Minor=4, Title=ytitleObj, Range=yr2, Exact=1,$
                  location=[-0.5, 1000, -0.5], YCOORD_CONV=yr2norm)
  yAxis->GetProperty, Ticktext=yAxisText
  yAxisText->SetProperty, Font=helvetica6pt, Recompute_Dimensions=2

  zAxis = Obj_New("IDLgrAxis", 2, Color=[0,0,0], Ticklen=0.1, $
                  Minor=4, Title=ztitleObj, Range=zr2, Exact=1,$
                  location=[-0.5, 0.5, 1000], ZCOORD_CONV=zr2norm)
  zAxis->GetProperty, Ticktext=zAxisText
  zAxisText->SetProperty, Font=helvetica6pt, Recompute_Dimensions=2

  omodel2->add, xAxis
  omodel2->add, yaxis
  omodel2->add, zaxis

    ; add view to window2 of the widget
  window2->draw,  oView2

  ;  Create a container object for easy destruction
   ; create a container object for easy cleanup
  oContainer2=obj_new('IDL_Container')
  oContainer2->Add, oView2
  oContainer2->Add, oTrack2

;;;;;;;; create the view for eigen values plot. Notice the size of the view so that
; ;;;;;; we will be in normalized coords
  oView = obj_new('IDLgrView',viewplane_rect=[-0.5, -0.5, 1.75, 1.75],$
                  color=[255,255,255])

  ; create a model to hold the plot object
  oModel = obj_new('IDLgrModel')

  ; create the plot object
  oPlot = obj_new('IDLgrPlot',bindgen(50),eigenvalues)
  oPlot->getProperty, xrange=xrange, yrange=yrange
  xs = normalize(xrange)        ;makes the range fit to the window
  ys = normalize(yrange)
  oPlot->setProperty,xcoord_conv=xs, ycoord_conv=ys

  ; add symbols
  oSymbol=obj_new('IDLgrSymbol', 4, color=[255,0,0], size=[0.5,0.5] )
  oPlot->setProperty, symbol=oSymbol

  ; create a text object
  oTextX = obj_new('IDLgrText','Variable')

  ; create an axis object
  oAxisX = obj_new('IDLgrAxis',0,range=xrange,xcoord_conv=xs,extend=1, $
                   title=oTextX, ticklen=.05)

  ; add it to the model
  oModel->add, oAxisX

  ; create a text object
  oTextY = obj_new('IDLgrText','Eigenvalue')

  ; create an axis object
  oAxisY = obj_new('IDLgrAxis',1,range=yrange,ycoord_conv=ys,exact=1, $
                   title=oTextY, ticklen=.05)
  oModel->add, oAxisY

  ; add the plot object to the model so that it will be displayed
  oModel->add,oPlot

  ; add the model to the view
  oView->add, oModel

;;;;;;;;;;;Create model for for significant principal components

  oView3 = obj_new('IDLgrView',viewplane_rect=[-.5, -.5, 1.75, 1.75],$
                   color=[255,255,255])

  ; create a model to hold the plot object
  oModel3 = obj_new('IDLgrModel')

  ; create the plot object
  oPlot3 = obj_new('IDLgrPlot',bindgen(230), datay=pcadata[0,*])
  oplot4 = obj_new('IDLgrPlot',bindgen(230), datay=pcadata[1,*], color=[255,0,0])
  oplot5 = obj_new('IDLgrPlot',bindgen(230), datay=pcadata[2,*], color=[0,255,0])
  oplot6 = obj_new('IDLgrPlot',bindgen(230), datay=pcadata[3,*], color=[0,0,255])
  oplot7 = obj_new('IDLgrPlot',bindgen(230), datay=pcadata[4,*], color=[160, 32, 240])

  oPlot3->getProperty, xrange=xrange, yrange=yrange
  xs = normalize(xrange)        ;makes the range fit to the window
  ys = normalize(yrange)
  oPlot3->setProperty, xcoord_conv=xs, ycoord_conv=ys
  oPlot4->setProperty, xcoord_conv=xs, ycoord_conv=ys
  oPlot5->setProperty, xcoord_conv=xs, ycoord_conv=ys
  oPlot6->setProperty, xcoord_conv=xs, ycoord_conv=ys
  oPlot7->setProperty, xcoord_conv=xs, ycoord_conv=ys
  ; create a text object
  oTextX = obj_new('IDLgrText','Variable')

  ; create an axis object
  oAxisX = obj_new('IDLgrAxis',0,range=xrange,xcoord_conv=xs, $
                   title=oTextX, ticklen=.05, exact=1)

  ; add it to the model
  oModel3->add, oAxisX

  ; create a text object
  oTextY = obj_new('IDLgrText','Magnitude')

  ; create an axis object
  oAxisY = obj_new('IDLgrAxis',1,range=yrange,ycoord_conv=ys,exact=1, $
                   title=oTextY, ticklen=.05)
  oModel3->add, oAxisY

  ; add the plot object to the model so that it will be displayed
  oModel3->add, oPlot3
  oModel3->add, oPlot4
  oModel3->add, oPlot5
  oModel3->add, oplot6
  omodel3->add, oplot7

  ; add the model to the view
  oView3->add, oModel3
; Get the PCA tips
  sText = demo_getTips(demo_filepath('pca.tip', $
                                     SUBDIR=['examples','demo', 'demotext']), $
                       wTopBase, wStatusBase)

;  Create the info structure
  sState={wDraw1: wDraw1, $     ; Draw window ID
          wDraw2: wDraw2, $     ; Draw window ID
          WHelpButton: wHelpButton, $ ; Help button ID
          WQuitButton: wQuitButton, $ ; Quit button ID
          WFileButton: wFileButton, $ ; File button ID
          WTopBase: wTopBase, $ ; Top level base ID
          WLeftBase: wLeftBase, $ ; Left base ID
          WStatusBase: wStatusBase, $ ; Statusbase ID
          drawEigenValID: 0L, $ ; id of eigenval draw
          drawPcompid: 0L,$     ; id of the principal components draw
          groupBase: groupBase,$ ; Base of Group Leader
          variances: variances, $
          pcadata: pcadata,$
          Window1: Window1,$    ; Right draw window
          oView1: oView1,$
          oModel1: oModel1,$
          oTrack1: oTrack1,$
          oSurface1: oSurface1,$
          oContainer1: oContainer1,$
          Window2: Window2, $   ; Left Draw Window
          oView2: oView2,$
          oModel2: oModel2,$
          otrack2: oTrack2,$
          oSurface2: osurface2,$
          oContainer2: oContainer2,$
          oView: oView,$        ; eigen Value plot
          oview3: oview3}       ; Principal Components plot.

    ;  Register the info structure in the user value of the top-level base
    ;
  WIDGET_CONTROL, wTopBase, SET_UVALUE=sState, /NO_COPY

  WIDGET_CONTROL, wTopBase, SENSITIVE=1

    ;  Destroy the starting up window.
    ;
  WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
  WIDGET_CONTROL, wTopBase, MAP=1

  XMANAGER, "Template", wTopBase, $
            /NO_BLOCK, $
            EVENT_HANDLER="d_pcaEvent", CLEANUP="d_pcaCleanup"

    ; Set appTLB for the demo harness.
  appTLB = wTopBase

end   ;  main procedure--d_pca.pro
