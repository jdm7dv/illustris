;
; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/decimate.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;	DECIMATE
;
; PURPOSE:
;	This procedure serves as an example of using the MESH_DECIMATE
;	and MESH_CLIP functions to simplify a polygonal mesh object.
;
; CATEGORY:
;	Object graphics.
;
; CALLING SEQUENCE:
;	DECIMATE
;
; MODIFICATION HISTORY:
; 	Written by:	KS, September 1999
;-

;----------------------------------------------------------------------------
FUNCTION Toggle_State, wid

    WIDGET_CONTROL, wid, GET_VALUE=name

    s = STRPOS(name, '(off)')
    IF (s NE -1) THEN BEGIN
        STRPUT, name, '(on) ', s
        ret = 1
    ENDIF ELSE BEGIN
        s = STRPOS(name, '(on) ')
        STRPUT, name, '(off)',s
        ret = 0
    ENDELSE

    WIDGET_CONTROL, wid, SET_VALUE=name
    RETURN, ret
END

;----------------------------------------------------------------------------
PRO read_model_file, filename, verts, faces

	dim = 64
	heightField = BYTARR(dim*dim, /NOZERO)
	OPENR, lun, /GET_LUN, filename, ERROR=err
	IF (err NE 0) THEN BEGIN
		PRINTF, -2, !ERR_STRING
		RETURN
	ENDIF
	READU, lun, heightField
	CLOSE, lun
	FREE_LUN, lun

	; Generate 2D grid for X and Y.
	; Fill in Z with height data.
	coords = (FINDGEN(dim)/(dim-1)) # REPLICATE(1, dim)
	verts = FLTARR(3, dim*dim)
	verts[0,*] = REFORM(coords, dim*dim)
	verts[1,*] = REFORM(TRANSPOSE(coords), dim*dim)
	verts[2,*] = FLOAT(heightField) / (1.5 * MAX(heightField))

	; generate quad mesh connectivity list
	i = 0L
	faces = LONARR(5 * (dim-1) * (dim-1))
	FOR y = 0, dim-2 DO BEGIN
		FOR x = 0, dim-2 DO BEGIN
			basevert = y * dim + x
			faces[i] = [4,basevert, basevert+1, basevert+dim+1, basevert+dim]
			i = i + 5
		ENDFOR
	ENDFOR

END

;----------------------------------------------------------------------------
PRO DECIMATE_EVENT, sEvent

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval

    ; Handle KILL requests.
    IF TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState

       ; Destroy the objects.
       OBJ_DESTROY, sState.oHolder
       WIDGET_CONTROL, sEvent.top, /DESTROY
       RETURN
    ENDIF

    ; Handle other events.
    CASE uval OF
        'STYLE': BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            sState.oMesh->SetProperty, STYLE=sEvent.index
            CASE sEvent.index OF
                0: BEGIN ; Point
                       WIDGET_CONTROL, sState.wHide, SENSITIVE=1
                       WIDGET_CONTROL, sState.wShading, SENSITIVE=0
                   END
                1: BEGIN ; Wire
                       WIDGET_CONTROL, sState.wHide, SENSITIVE=1
                       WIDGET_CONTROL, sState.wShading, SENSITIVE=0
                   END
                2: BEGIN ; Solid
                       WIDGET_CONTROL, sState.wHide, SENSITIVE=0
                       WIDGET_CONTROL, sState.wShading, SENSITIVE=1
                   END
            ENDCASE
            sState.oWindow->Draw, sState.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          END
        'SHADE_FLAT': BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            sState.oMesh->SetProperty, SHADING=0
            sState.oWindow->Draw, sState.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          END
        'SHADE_GOURAUD': BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            sState.oMesh->SetProperty, SHADING=1
            sState.oWindow->Draw, sState.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          END
        'HIDE_OFF': BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            wParent = WIDGET_INFO(sEvent.id, /PARENT)
            j = Toggle_State(wParent)
            sState.oMesh->SetProperty, HIDDEN_LINES=0
            sState.oWindow->Draw, sState.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          END
        'HIDE_ON': BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            wParent = WIDGET_INFO(sEvent.id, /PARENT)
            j = Toggle_State(wParent)
            sState.oMesh->SetProperty, HIDDEN_LINES=1
            sState.oWindow->Draw, sState.oView
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          END
        'DRAGQ0' : BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            sState.dragq = 0
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          END
        'DRAGQ1' : BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            sState.dragq = 1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          END

        'DRAW': BEGIN
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY

            ; Expose.
            IF (sEvent.type EQ 4) THEN BEGIN
                sState.oWindow->Draw, sState.oView
                WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
                RETURN
            ENDIF

           ; Handle trackball updates.
           bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat )
           IF (bHaveTransform NE 0) THEN BEGIN
               sState.oGroup->GetProperty, TRANSFORM=t
               sState.oGroup->SetProperty, TRANSFORM=t#qmat
               sState.oWindow->Draw, sState.oView
           ENDIF

           ; Handle other events: PICKING, quality changes, etc.
           ;  Button press.
           IF (sEvent.type EQ 0) THEN BEGIN
               IF (sEvent.press EQ 4) THEN BEGIN ; Right mouse.
	           pick = sState.oWindow->PickData(sState.oView,$
                                                   sState.oMesh, $
                                                   [sEvent.x,sEvent.y],dataxyz)
	           IF (pick EQ 1) THEN BEGIN
		       str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
		        FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
		       WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
	           ENDIF ELSE BEGIN
		       WIDGET_CONTROL, sState.wLabel, $
                            SET_VALUE="Data point: In background."
                   ENDELSE

                   sState.btndown = 4b
	           WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
               ENDIF ELSE BEGIN ; other mouse button.
                   sState.btndown = 1b
                   sState.oWindow->SetProperty, QUALITY=sState.dragq
                   WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
                   sState.oWindow->Draw, sState.oView
               ENDELSE
          ENDIF

         ; Button motion.
         IF (sEvent.type EQ 2) THEN BEGIN
             IF (sState.btndown EQ 4b) THEN BEGIN ; Right mouse button.
	         pick = sState.oWindow->PickData(sState.oView, $
                                                 sState.oMesh, $
                                                 [sEvent.x,sEvent.y], dataxyz)
	         IF (pick EQ 1) THEN BEGIN
                     str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
		        FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
		     WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
                 ENDIF ELSE BEGIN
                     WIDGET_CONTROL, sState.wLabel, $
                         SET_VALUE="Data point: In background."
                 ENDELSE

             ENDIF
        ENDIF

        ; Button release.
        IF (sEvent.type EQ 1) THEN BEGIN
            IF (sState.btndown EQ 1b) THEN BEGIN
      	        sState.oWindow->SetProperty, QUALITY=2
      	        sState.oWindow->Draw, sState.oView
            ENDIF
            sState.btndown = 0b
            WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
        ENDIF
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END

	  ; Handle clip plane or decimation changes here.
	  ELSE: BEGIN
      	IF (uval EQ	'XSLICE' OR uval EQ 'YSLICE' OR $
      	    uval EQ 'ZSLICE' OR uval EQ 'DEC') THEN BEGIN

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
            WIDGET_CONTROL,HOURGLASS=1
		    WIDGET_CONTROL, sState.wLabel, SET_VALUE="Generating Mesh..."

            CASE uval OF
				'XSLICE'  : sState.xplane[3] = -(((sEvent.value / 100.0) * $
				            (sState.xrange[1]-sState.xrange[0])) + (sState.xrange[0]))
				'YSLICE'  : sState.yplane[3] = -(((sEvent.value / 100.0) * $
				            (sState.yrange[1]-sState.yrange[0])) + (sState.yrange[0]))
		        'ZSLICE'  : sState.zplane[3] = -(((sEvent.value / 100.0) * $
		                    (sState.zrange[1]-sState.zrange[0])) + (sState.zrange[0]))
		        'DEC'     : sState.decValue = sEvent.value
			ENDCASE

			; Clip model to each of the three planes.
			result = MESH_CLIP(sState.xplane, sState.verts, sState.faces, new_verts, new_faces)
			if (N_ELEMENTS(new_faces) GT 1) THEN $
				result = MESH_CLIP(sState.yplane, new_verts, new_faces, new_verts, new_faces)
			if (N_ELEMENTS(new_faces) GT 1) THEN $
				result = MESH_CLIP(sState.zplane, new_verts, new_faces, new_verts, new_faces)

            ; Decimate model, if requested
		 	IF (sState.decValue ne 100 AND N_ELEMENTS(new_faces) GT 1) THEN BEGIN
   		       numTris = MESH_DECIMATE(new_verts, new_faces, new_faces, $
                  VERTICES=new_verts, PERCENT_VERTICES=sState.decValue)
   			END ELSE BEGIN
   			   numTris = MESH_NUMTRIANGLES(new_faces)
   			ENDELSE

			; Update the mesh with the new vertices and polygons for display
            sState.oMesh->SetProperty, DATA = new_verts, POLYGONS=new_faces
            sState.oWindow->Draw, sState.oView

			; Update stats widget
       	    str = STRING(N_ELEMENTS(new_verts[0,*]), numTris, $
			    FORMAT='("Model has ",I0," vertices and ",I0," faces.")')
	        WIDGET_CONTROL, sState.wLabel, SET_VALUE=str

			; Done
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
            WIDGET_CONTROL,HOURGLASS=0
        END
        END

    ENDCASE
END

;----------------------------------------------------------------------------
PRO DECIMATE

    xdim = 600
    ydim = 360
    decValue = 100

    ; Create the widgets.
    wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, $
                        TITLE="Polygonal Mesh Clipping and Decimation Example", $
                        /TLB_KILL_REQUEST_EVENTS)

    wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
                        RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, $
                        GRAPHICS_LEVEL=2)
    wGuiBase = WIDGET_BASE(wBase, /ROW)
    wGuiBase1 = WIDGET_BASE(wGuibase, /COLUMN)
    wStyleDrop = WIDGET_DROPLIST(wGuiBase1, VALUE=['Point','Wire','Solid'], $
    							 /FRAME, TITLE='Style', UVALUE='STYLE')

    wOptions = WIDGET_BUTTON(wGuiBase1, MENU=2, VALUE="Options")

    wDrag = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Drag Quality")
    wButton = WIDGET_BUTTON(wDrag, VALUE='Low', UVALUE='DRAGQ0')
    wButton = WIDGET_BUTTON(wDrag, VALUE='Medium', UVALUE='DRAGQ1')

    wHide = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Hidden Lines (off)")
    wButton = WIDGET_BUTTON(wHide, VALUE='Off', UVALUE='HIDE_OFF')
    wButton = WIDGET_BUTTON(wHide, VALUE='On', UVALUE='HIDE_ON')

    wShading = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Shading")
    wButton = WIDGET_BUTTON(wShading, VALUE='Flat', UVALUE='SHADE_FLAT')
    wButton = WIDGET_BUTTON(wShading, VALUE='Gouraud', UVALUE='SHADE_GOURAUD')

    wGuiBase2 = WIDGET_BASE(wGuibase, /COLUMN, /FRAME)
	wSlider = WIDGET_SLIDER(wGuibase2, VALUE=100, $
		TITLE="Decimation Control (%)", UVALUE='DEC')

    wGuiBase4 = WIDGET_BASE(wGuibase, /COLUMN, /FRAME)
    wSlider1 = WIDGET_SLIDER(wGuibase4, VALUE=100, $
        TITLE="X Clip Control (%)", UVALUE='XSLICE')
    wSlider2 = WIDGET_SLIDER(wGuibase4, VALUE=100, $
        TITLE="Y Clip Control (%)", UVALUE='YSLICE')
    wSlider3 = WIDGET_SLIDER(wGuibase4, VALUE=100, $
        TITLE="Z Clip Control (%)", UVALUE='ZSLICE')


    ; Status line.
    wGuiBase3 = WIDGET_BASE(wGuibase, /COLUMN)
    wLabel = WIDGET_LABEL(wGuiBase3, /FRAME, /ALIGN_LEFT, $
                  VALUE="Left Mouse: Trackball    Right Mouse: Data Picking" )
    wLabel = WIDGET_LABEL(wGuiBase3, /FRAME, /ALIGN_LEFT, $
                  VALUE="Loading model data.", /DYNAMIC_RESIZE)

    WIDGET_CONTROL, wBase, /REALIZE

    ; Get the window id of the drawable.
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

    ; Set default droplist items.
    WIDGET_CONTROL, wStyleDrop, SET_DROPLIST_SELECT=2
    WIDGET_CONTROL, wHide, SENSITIVE=0

    ; Compute viewplane rect based on aspect ratio.
    aspect = FLOAT(xdim) / FLOAT(ydim)
    sqrt2 = SQRT(2.0)
    myview = [ -sqrt2*0.5, -sqrt2*0.5, sqrt2, sqrt2 ]
    IF (aspect GT 1) THEN BEGIN
        myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
        myview[2] = myview[2] * aspect
    ENDIF ELSE BEGIN
        myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
        myview[3] = myview[3] / aspect
    ENDELSE

    ; Create view.
    oView = OBJ_NEW('IDLgrView', PROJECTION=2, EYE=3, ZCLIP=[1.4,-1.4],$
                    VIEWPLANE_RECT=myview, COLOR=[40,40,40])

    ; Create model.
    oTop = OBJ_NEW('IDLgrModel')
    oGroup = OBJ_NEW('IDLgrModel')
    oTop->Add, oGroup

	; Read data
	WIDGET_CONTROL,HOURGLASS=1
	filename = FILEPATH('elevbin.dat', $
            SUBDIR=['examples', 'data'])
	read_model_file, filename, verts, faces

	IF (N_ELEMENTS(verts) EQ 0) THEN BEGIN
        WIDGET_CONTROL, wBase, /DESTROY
		RETURN
	ENDIF

    WIDGET_CONTROL,HOURGLASS=0

	str = STRING(N_ELEMENTS(verts[0,*]), MESH_NUMTRIANGLES(faces), $
	FORMAT='("Model has ",I0," vertices and ",I0," faces.")')
    WIDGET_CONTROL, wLabel, SET_VALUE=str

    ; Compute data bounds.
    xMax = MAX(verts[0,*], MIN=xMin)
    yMax = MAX(verts[1,*], MIN=yMin)
    zMax = MAX(verts[2,*], MIN=zMin)

	; Center normalized object in the viewport.
    xExtent = xMax - xMin
    yExtent = yMax - yMin
    zExtent = zMax - zMin
    Range = MAX([xExtent, yExtent, zExtent], maxindex)
    mins = [xMin, yMin, zMin]
    RangeMin = mins[maxindex]

	Conv = [-RangeMin / Range - 0.5, 1.0 / Range]

    ; Create the mesh.
    oMesh = OBJ_NEW('IDLgrPolygon', verts, STYLE=2, SHADING=1, $
                    COLOR=[60,60,255], BOTTOM=[64,192,128], $
                    POLYGONS=faces, $
                    XCOORD_CONV=Conv, YCOORD_CONV=Conv, ZCOORD_CONV=Conv)
    oGroup->Add, oMesh

  ; Get ranges and planes to use during clipping
    oMesh->GetProperty, XRANGE=xrange, YRANGE=yrange, ZRANGE=zrange
    xplane = [1.0, 0.0, 0.0, -xrange[1]]
	yplane = [0.0, 1.0, 0.0, -yrange[1]]
	zplane = [0.0, 0.0, 1.0, -zrange[1]]

    ; Create some lights.
    oLight = OBJ_NEW('IDLgrLight', LOCATION=[2,2,2], TYPE=1)
    oTop->Add, oLight
    oLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
    oTop->Add, oLight

    ; Place the model in the view.
    oView->Add, oTop

    ; Create a trackball.
    oTrack = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2.)

    ; Create a holder object for easy destruction.
    oHolder = OBJ_NEW('IDL_Container')
    oHolder->Add, oView
    oHolder->Add, oTrack

    ; Save state.
    sState = {btndown: 0b,           $
			  dragq: 0,              $
              oHolder: oHolder,	     $
              oTrack:oTrack,         $
              wDraw: wDraw,          $
              wLabel: wLabel,        $
              wHide: wHide,          $
              wShading: wShading,    $
              oWindow: oWindow,      $
              oView: oView,          $
              oGroup: oGroup,        $
              oMesh: oMesh,          $
              verts: verts,          $
              faces: faces,          $
              decValue: decValue,	 $
              xplane: xplane,		 $
              yplane: yplane,		 $
              zplane: zplane,		 $
              xrange: xrange,		 $
              yrange: yrange,		 $
              zrange: zrange		 $
             }

    WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY

    XMANAGER, 'DECIMATE', wBase, /NO_BLOCK

END
