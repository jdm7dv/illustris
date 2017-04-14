;
; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/tetra.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   TETRA
;
; PURPOSE:
;   This procedure serves as an example of using tetrahedral meshes
;	with IDL Object Graphics.
;
; CATEGORY:
;   Object graphics.
;
; CALLING SEQUENCE:
;   TETRA
;
;
; MODIFICATION HISTORY:
;   Written by:  RJF, 1999
;-

;----------------------------------------------------------------------------
; Generate the block and cylinder geometry
;
PRO build_geom,vert1,conn1,vert2,conn2
	s = lonarr(8)
	quad = [[[0,1,2,4],[4,5,7,1],[1,2,3,7],[2,4,6,7],[1,2,4,7]], $
		[[0,1,3,5],[3,5,6,7],[0,5,6,4],[6,0,2,3],[6,5,0,3]]]
	prism = [[[1,3,4,5],[0,2,1,5],[0,3,1,5]], $
		[[0,1,2,4],[2,3,4,5],[0,2,3,4]]]
	nspine = 20
	dtheta = 360.0/nspine
	radius = 1.0
	thick = 0.2
	nblock = radius/thick
	nvert = 2 + nspine*nblock*2  ; Disk
	nvert = nvert + (nspine*nblock*2)  ; Cylinder
	vert1 = FLTARR(3,nvert)
	npie = nspine
	nrect = (nblock)*(nspine) + (nspine)*(nblock)
	conn1 = LONARR(4,(5*nrect+3*npie))
	; inner two points
	z = radius
	vert1[0,0] = 0
	vert1[1,0] = 0
	vert1[2,0] = z
	vert1[0,1] = 0
	vert1[1,1] = 0
	vert1[2,1] = z - thick
	c = 2
	d = 0
	; top disk
	FOR i=0,1 DO BEGIN
		r = thick
		FOR j=1, nblock DO BEGIN
			ang = 0.0
			FOR k=1, nspine DO BEGIN
				vert1[0,c] = cos(ang*!PI/180.0)*r
				vert1[1,c] = sin(ang*!PI/180.0)*r
				vert1[2,c] = z
				c = c + 1
				ang = ang + dtheta
			END
			IF (i EQ 1) THEN BEGIN
				wh = j AND 1
				IF (j EQ 1) THEN BEGIN
					; pie elements
					s[0] = 0
					s[3] = 1
					s[5] = (nspine*nblock)*i + (nspine)*(j-1) + 2
					s[4] = s[5] + (nspine-1)
					FOR k=1,nspine DO BEGIN
						s[1] = s[4] - (nspine*nblock)
						s[2] = s[5] - (nspine*nblock)
						FOR l = 0, 2 DO BEGIN
							conn1[0,d] = s[prism[0,l,wh]]
							conn1[1,d] = s[prism[1,l,wh]]
							conn1[2,d] = s[prism[2,l,wh]]
							conn1[3,d] = s[prism[3,l,wh]]
							d = d + 1
						END
						s[1] = s[2]
						s[4] = s[5]
						s[2] = s[2] + 1
						s[5] = s[5] + 1
						wh = wh XOR 1
					END
				END ELSE BEGIN
					; rect elements
					s[1] = (nspine*nblock)*i + nspine*(j-1) + 2
					s[3] = s[1] - nspine
					s[0] = s[1] + (nspine-1)
					s[2] = s[3] + (nspine-1)
					FOR k=1,nspine DO BEGIN
						s[4] = s[0] - (nspine*nblock)
						s[5] = s[1] - (nspine*nblock)
						s[6] = s[2] - (nspine*nblock)
						s[7] = s[3] - (nspine*nblock)
						FOR l = 0, 4 DO BEGIN
							conn1[0,d] = s[quad[0,l,wh]]
							conn1[1,d] = s[quad[1,l,wh]]
							conn1[2,d] = s[quad[2,l,wh]]
							conn1[3,d] = s[quad[3,l,wh]]
							d = d + 1
						END
						s[0] = s[1]
						s[2] = s[3]
						s[1] = s[1] + 1
						s[3] = s[3] + 1
						wh = wh XOR 1
					END
				END
			END
			r = r + thick
		END
		z = z - thick
	END
	; cylinder
	base = c
	FOR i=1, nblock DO BEGIN
		r = radius - thick
		FOR j=0,1 DO BEGIN
			ang = 0.0
			FOR k=1, nspine DO BEGIN
				vert1[0,c] = cos(ang*!PI/180.0)*r
				vert1[1,c] = sin(ang*!PI/180.0)*r
				vert1[2,c] = z
				c = c + 1
				ang = ang + dtheta
			END
			IF (j EQ 1) THEN BEGIN
				wh = (i+1) AND 1
				; rect elements
				s[1] = (nspine*2)*(i-1) + base + nspine
				s[3] = s[1] - nspine
				s[0] = s[1] + (nspine-1)
				s[2] = s[3] + (nspine-1)
				FOR k=1,nspine DO BEGIN
					s[4] = s[0] - (nspine*2)
					s[5] = s[1] - (nspine*2)
					s[6] = s[2] - (nspine*2)
					s[7] = s[3] - (nspine*2)
					FOR l = 0, 4 DO BEGIN
						conn1[0,d] = s[quad[0,l,wh]]
						conn1[1,d] = s[quad[1,l,wh]]
						conn1[2,d] = s[quad[2,l,wh]]
						conn1[3,d] = s[quad[3,l,wh]]
						d = d + 1
					END
					s[0] = s[1]
					s[2] = s[3]
					s[1] = s[1] + 1
					s[3] = s[3] + 1
					wh = wh XOR 1
				END
			END
			r = r + thick
		END
		z = z - (thick*1.5)
	END

	; now the sleeve
	z = radius * 1.5
	vert2 = FLTARR(3,nblock*nspine*2)
	conn2 = LONARR(4,(nblock-1)*(nspine)*5)
	c = 0
	d = 0
	wei = 1.5
	FOR i=1, nblock DO BEGIN
		; outer edges
		num = nspine/4
		p = [radius*wei,radius*wei]
		dp = [-(radius*(wei*2))/num,0.0]
		FOR k=1,num DO BEGIN
			vert2[0,c] = p[0]
			vert2[1,c] = p[1]
			vert2[2,c] = z
			c = c + 1
			p = p + dp
		END
		dp = [0.0,-(radius*(wei*2))/num]
		FOR k=1,num DO BEGIN
			vert2[0,c] = p[0]
			vert2[1,c] = p[1]
			vert2[2,c] = z
			c = c + 1
			p = p + dp
		END
		dp = [(radius*(wei*2))/num,0.0]
		FOR k=1,num DO BEGIN
			vert2[0,c] = p[0]
			vert2[1,c] = p[1]
			vert2[2,c] = z
			c = c + 1
			p = p + dp
		END
		dp = [0.0,(radius*(wei*2))/num]
		FOR k=1,num DO BEGIN
			vert2[0,c] = p[0]
			vert2[1,c] = p[1]
			vert2[2,c] = z
			c = c + 1
			p = p + dp
		END
		; inner circle
		ang = 45.0
		FOR k=1, nspine DO BEGIN
			vert2[0,c] = cos(ang*!PI/180.0)*radius
			vert2[1,c] = sin(ang*!PI/180.0)*radius
			vert2[2,c] = z
			c = c + 1
			ang = ang + dtheta
		END
		IF (i GT 1) THEN BEGIN
			s[1] = (i-1)*(nspine*2)
			s[3] = s[1] + (nspine)
			s[0] = s[1] + (nspine-1)
			s[2] = s[3] + (nspine-1)
			wh = i AND 1
			FOR k=1, nspine DO BEGIN
				s[5] = s[1] - (nspine*2)
				s[7] = s[3] - (nspine*2)
				s[4] = s[0] - (nspine*2)
				s[6] = s[2] - (nspine*2)

				FOR l = 0, 4 DO BEGIN
					conn2[0,d] = s[quad[0,l,wh]]
					conn2[1,d] = s[quad[1,l,wh]]
					conn2[2,d] = s[quad[2,l,wh]]
					conn2[3,d] = s[quad[3,l,wh]]
					d = d + 1
				END
				wh = wh XOR 1

				s[0] = s[1]
				s[2] = s[3]
				s[1] = s[1] + 1
				s[3] = s[3] + 1
			END
		END
		z = z - (thick*2.0*1.5)
	END
	vert1 = vert1*0.35
	vert2 = vert2*0.35
END

;----------------------------------------------------------------------------
; Updates the vertex colors for the vertex coloring option for the cylinder.
;
PRO updatedistance,sState
	d = size(sState.v1,/DIMENSIONS)
	FOR i=0,sState.nFrames-1 DO BEGIN
		FOR j=0,d[1]-1 DO BEGIN
			dv = sState.v1[*,j,i] - sState.pointloc
			dd = SQRT(TOTAL(dv*dv))*200.0 + 25.0
			dd = dd < 255
			dd = dd > 0
			sState.vv[j,i] = dd
			sState.vc[*,j,i] = sState.rgb[*,dd]
		END
	END
END
;----------------------------------------------------------------------------
; Update the objects after clipping plane moved.
;
PRO updateplane,sState
	sState.oPlane->getproperty, TRANSFORM=t
	; update plane equation for clipping
	; this clips the cylinder on the front side of plane
	p = [0,0,1,1] # t
	up = p
	pt = p * sState.trans
	p[3] = -(pt[0]*p[0] + pt[1]*p[1] + pt[2]*p[2])
	; clip with new plane
	IF (sState.useCont) THEN BEGIN ; contouring
   		j = TETRA_CLIP(p,sState.v1[*,*,sState.Frame],sState.c1,ov,oc,CUT_VERTS=cv, $
   			AUXDATA_IN=sState.vv[*,sState.Frame],AUXDATA_OUT=auxout)
	END ELSE BEGIN
		IF (sState.vcolored) THEN BEGIN
   			j = TETRA_CLIP(p,sState.v1[*,*,sState.Frame],sState.c1,ov,oc,CUT_VERTS=cv, $
   				AUXDATA_IN=sState.vc[*,*,sState.Frame],AUXDATA_OUT=auxout)
		END ELSE BEGIN
   			j = TETRA_CLIP(p,sState.v1[*,*,sState.Frame],sState.c1,ov,oc,CUT_VERTS=cv)
   			auxout=1
   		END
   	END
   	; update graphic objects with new geometry
	IF (j LT 1) THEN BEGIN ; nothing remains after clipping
		c = [-1]
		IF (sState.useCont) THEN BEGIN
       		sState.oCont->SetProperty,POLYGONS=c
		END ELSE BEGIN
       		sState.oScyl->SetProperty,POLYGONS=c
   		END
	END ELSE BEGIN ; generate new surface
   	  	c = TETRA_SURFACE(ov,oc)
		IF (sState.useCont) THEN BEGIN
			sState.oCont->SetProperty,DATA=auxout, FILL=1, $
          		GEOMX=ov[0,*],GEOMY=ov[1,*],GEOMZ=ov[2,*],POLYGONS=c
		END ELSE BEGIN
			normals = COMPUTE_MESH_NORMALS(ov,c)
			IF (cv[0] GE 0) THEN BEGIN
				normals[0,cv] = up[0]
				normals[1,cv] = up[1]
				normals[2,cv] = up[2]
			END
          	sState.oScyl->SetProperty,DATA=ov,POLYGONS=c,NORMALS=normals,VERT_COLORS=auxout
		END
	END
    ; Set up clipping plane to clip the back of cylinder (just flip plane around)
	p = -p
	p[3] = -(pt[0]*p[0] + pt[1]*p[1] + pt[2]*p[2])
   	j = TETRA_CLIP(p,sState.v1[*,*,sState.Frame],sState.c1,ov,oc,CUT_VERTS=cv)
	IF (j LT 1) THEN BEGIN ; everything clipped away
		c = [-1]
       	sState.oTcyl->SetProperty,POLYGONS=c
    END ELSE BEGIN ; make a surface
   		c = TETRA_SURFACE(ov,oc)
		normals = COMPUTE_MESH_NORMALS(ov,c)
		IF (cv[0] GE 0) THEN BEGIN
			normals[0,cv] = up[0]
			normals[1,cv] = up[1]
			normals[2,cv] = up[2]
		END
        sState.oTcyl->SetProperty,DATA=ov,POLYGONS=c,NORMALS=normals
    END
    ; Set up clipping plane for the block
    sState.oPlane->getproperty, TRANSFORM=t
	p = [0,0,1,1] # t
	pt = p * sState.trans
	p[3] = -(pt[0]*p[0] + pt[1]*p[1] + pt[2]*p[2])
   	j = TETRA_CLIP(p,sState.v2,sState.c2,ov,oc,CUT_VERTS=cv)
	IF (j LT 1) THEN BEGIN ; nothing left
		c = [-1]
        sState.oBlck->SetProperty,POLYGONS=c
   	END ELSE BEGIN ; make the surface
   	  	c = TETRA_SURFACE(ov,oc)
		normals = COMPUTE_MESH_NORMALS(ov,c)
		IF (cv[0] GE 0) THEN BEGIN
			normals[0,cv] = up[0]
			normals[1,cv] = up[1]
			normals[2,cv] = up[2]
		END
		sState.oBlck->SetProperty,DATA=ov,POLYGONS=c,NORMALS=normals
	END
END

;----------------------------------------------------------------------------
; Simple util to handle menu button text
;
FUNCTION Toggle_state,wid

    WIDGET_CONTROL,wid,GET_VALUE=name

    s = STRPOS(name,'(off)')
    IF (s NE -1) THEN BEGIN
		STRPUT,name,'(on )',s
        ret = 1
    END ELSE BEGIN
        s = STRPOS(name,'(on )')
        STRPUT,name,'(off)',s
        ret = 0
    END

    WIDGET_CONTROL,wid,SET_VALUE=name
    RETURN,ret
END

;----------------------------------------------------------------------------
; Main event handler
;
PRO tetra_event, sEvent

    ; Handle events.
	WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY

    CASE uval OF
	'TIMER' : BEGIN
		IF (sState.Animate) THEN BEGIN
			; Handles in/out movement of piston
	    	sState.Frame = sState.Frame + sState.dir
	        IF (sState.Frame GE sState.nFrames) THEN BEGIN
	      		sState.dir = -1
	      		sState.Frame = sState.Frame + sState.dir*2
	      	END
	        IF (sState.Frame LT 0) THEN BEGIN
	      		sState.dir = 1
	      		sState.Frame = sState.Frame + sState.dir*2
	        END
	        updateplane,sState
	        sState.oWindow->Draw
	        WIDGET_CONTROL, sState.wTimer, TIMER=sState.timer
	    END
	END

    'DTIME' : BEGIN
		sState.timer = sEvent.value
	END

    'POINT' : BEGIN
    	a = sEvent.value * !DTOR
	    sState.pointloc[1] = 0.5*SIN(a)
	    sState.pointloc[2] = 0.5*COS(a)
	    updatedistance,sState
	    updateplane,sState
	    sState.oWindow->Draw
	END

	'VCOLOR' : BEGIN
		j = Toggle_State(sEvent.id)
	    sState.VColored = j
	    updateplane,sState
	    sState.oWindow->Draw
	    WIDGET_CONTROL, sState.wPoint, SENSITIVE=sState.VColored+sState.useCont
	END

   'ANIMATE' : BEGIN
		j = Toggle_State(sEvent.id)
	    sState.animate = j
	    IF (sState.Animate) THEN BEGIN
	    	WIDGET_CONTROL, sState.wTimer, TIMER=sState.timer
	    END
	    WIDGET_CONTROL, sState.wDTime, SENSITIVE=sState.animate
	END

    'CONTOUR' : BEGIN
		j = Toggle_State(sEvent.id)
		sState.oScyl->Setproperty,HIDE=j
	    sState.oCont->Setproperty,HIDE=1-j
	    sState.useCont = j
	    updateplane,sState
        sState.oWindow->Draw
	    WIDGET_CONTROL, sState.wPoint, SENSITIVE=sState.VColored+sState.useCont
	END

    'PCLIPWIRE' : BEGIN
		j = Toggle_State(sEvent.id)
	    sState.oTcyl->Setproperty,STYLE=2-j
        sState.oWindow->Draw
	END

    'PCLIPHIDE' : BEGIN
		j = Toggle_State(sEvent.id)
	    sState.oTcyl->Setproperty,HIDE=j
        sState.oWindow->Draw
	END

    'WIRE' : BEGIN
		j = Toggle_State(sEvent.id)
	    sState.oBlck->Setproperty,STYLE=2-j
        sState.oWindow->Draw
	END

    'SWIRE' : BEGIN
		j = Toggle_State(sEvent.id)
	    o=sState.oTrans->Get()
	    o->Setproperty,STYLE=2-j
        sState.oWindow->Draw
	END

    'TRANS' : BEGIN
		sState.oTrans->translate,0,0,-sState.trans
	    sState.trans = sEvent.value
	    sState.oTrans->translate,0,0,sState.trans
	    updateplane,sState
        sState.oWindow->Draw
	END

	'QUIT': BEGIN
	    WIDGET_CONTROL, sEvent.top, /DESTROY
	    RETURN
	END

    'DRAW': BEGIN
		draw = 0

        ; Expose.
        IF (sEvent.type EQ 4) THEN BEGIN
			draw = 1
		END ELSE BEGIN
			; Handle trackball updates.
            bHaveTransform = sState.oTrack1->Update( sEvent, TRANSFORM=qmat )
            IF (bHaveTransform NE 0) THEN BEGIN
            	sState.oGroup->getproperty, TRANSFORM=t
                mt = t # qmat
                sState.oGroup->setproperty,TRANSFORM=mt
		   		draw = 1
            ENDIF
            bHaveTransform = sState.oTrack2->Update( sEvent, TRANSFORM=qmat )
            IF (bHaveTransform NE 0) THEN BEGIN
				; we really want the trackball to change the ctm, so we apply qmat to
				; the ctm and then figure out what xform would be needed to change the
				; ctm to match the new ctm.  got it?  you can work out the matrix algebra...

                sState.oPlane->getproperty, TRANSFORM=t
		        ctm=sState.oPlane->GetCTM()
		        nctm = ctm # qmat
		        x = invert(t) # ctm
		        mt = nctm # invert(x)
                sState.oPlane->setproperty,TRANSFORM=mt
		        draw = 1
	            updateplane,sState
			ENDIF

	        IF (sEvent.type EQ 2) THEN BEGIN
		    	IF (sState.bdown EQ 1b) THEN BEGIN
		        	sState.oWindow->GetProperty,DIMENSIONS=dim
		       		del = float(sEvent.x - sState.bloc[0])/float(dim[0])
		       		del = del + sState.bloc[1]
		       		WIDGET_CONTROL,sState.wTrans,SET_VALUE=del
	  	       		sState.oTrans->translate,0,0,-sState.trans
	                sState.trans=del
	                sState.oTrans->translate,0,0,sState.trans
		       		draw = 1
	                updateplane,sState
		   		END
	       	END

           	IF (sEvent.type EQ 0) THEN BEGIN
           		WIDGET_CONTROL, sState.wDraw,/DRAW_MOTION
			   	IF (sEvent.press EQ 2) THEN BEGIN
			    	sState.bloc = [sEvent.x,sState.trans]
			        sState.bdown = 1b
			    END
			END

	        IF (sEvent.type EQ 1) THEN BEGIN
	        	WIDGET_CONTROL, sState.wDraw,DRAW_MOTION=0
			    sState.bdown = 0b
		    END

		END

	    IF (draw) THEN sState.oWindow->Draw
 	END
    ELSE: PRINT, 'Unknown event.'
    ENDCASE

    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
END


;----------------------------------------------------------------------------
; Main procedure

PRO tetra,RENDERER=renderer

    xdim = 640
    ydim = 480

    IF (N_ELEMENTS(renderer) EQ 0) THEN renderer = 0

    ; Create widgets.
    wBase = WIDGET_BASE(/COLUMN,TITLE='Tetrahedral Mesh Piston Demo')

    wTimer = WIDGET_BASE(wBase, COLUMN=1, UVALUE='TIMER')

    wDraw = WIDGET_DRAW(wTimer, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW',$
		RENDERER=renderer, GRAPHICS_LEVEL=2, RETAIN=0, /EXPOSE_EV, /BUTTON_EV)

    wUIBase = WIDGET_BASE(wBase, /row )

    wTrans = CW_FSLIDER(wUIBase, VALUE = 0.0, MIN=-1.0, MAX=1.0, $
		UVALUE = 'TRANS', TITLE="Clipping Plane Location", /DRAG)
    wDTime = CW_FSLIDER(wUIBase, VALUE = 0.2, MIN=0.025, MAX=1.0, $
		UVALUE = 'DTIME', TITLE="Animation Delay(sec)")
    wPoint = CW_FSLIDER(wUIBase, VALUE = 0.0, MIN=-120., MAX=120., $
		UVALUE = 'POINT', TITLE="Piston Coloring")
	WIDGET_CONTROL, wDTime, SENSITIVE=0
	WIDGET_CONTROL, wPoint, SENSITIVE=0

    wOptions = WIDGET_BUTTON(wUIBase,MENU=2,VALUE="Options",/FRAME)
    tWire = WIDGET_BUTTON(wOptions,VALUE="Block Wire (off)",UVAL='WIRE')
    tSWire = WIDGET_BUTTON(wOptions,VALUE="Clip Plane Wire (on )",UVAL='SWIRE')
    tVCol = WIDGET_BUTTON(wOptions,VALUE="Vertex Colored (off)",UVAL='VCOLOR')
    tPwire = WIDGET_BUTTON(wOptions,VALUE="Piston Clip Wire (off)",UVAL='PCLIPWIRE')
    tPhide = WIDGET_BUTTON(wOptions,VALUE="Piston Clip Hide (off)",UVAL='PCLIPHIDE')
    tCont = WIDGET_BUTTON(wOptions,VALUE="Use Contour (off)",UVAL='CONTOUR')

    tAnimate = WIDGET_BUTTON(wUIBase,VALUE="Animate (off)",UVAL='ANIMATE',/FRAME)

    wQuit = WIDGET_BUTTON(wUIBase,VALUE=" Quit ",UVAL='QUIT',/FRAME)

	wLabel = WIDGET_LABEL(wBase, $
		VALUE="Mouse: Left: Manipulate entire model.  Middle: Move clip plane along piston axis.  " + $
			"Right: Rotate clip plane." )

	; Create a view.
	aspect = FLOAT(xdim)/FLOAT(ydim)
    IF (aspect > 1) THEN $
    	viewRect = [(-aspect)/2.0, -0.5, aspect, 1.0] $
   	ELSE $
    	viewRect = [-0.5, (-(1.0/aspect))/2.0, 1.0, (1.0/aspect)]
   	oView = OBJ_NEW('IDLgrView',PROJ=2,VIEW=viewRect*2.0,COLOR=[100,100,150])

	;--- The Tree ---------------------------------------------------------------
	; Create model tree Top.
    oTopModel = OBJ_NEW('IDLgrModel')
    oView->Add, oTopModel

    oGroup = OBJ_NEW('IDLgrModel')
    oTopModel->Add, oGroup

    oObj = OBJ_NEW('IDLgrPolyline',[[0,0,0],[0.75,0,0],[0,0.75,0],[0,0,0.75]], $
		POLYLINES=[2,0,1,2,0,2,2,0,3],$
		VERT_COLORS=[[0,0,0],[255,0,0],[0,255,0],[0,0,255]]);
    oGroup->Add,oObj

	; Set up the clipping plane models and polygon
    oPlane = OBJ_NEW('IDLgrModel')
    oGroup->Add, oPlane

    oTrans = OBJ_NEW('IDLgrModel')
    oPlane->Add, oTrans

    oObj = OBJ_NEW('IDLgrPolygon', $
		[[-0.5,-0.5,0],[0.5,-0.5,0],[0.5,0.5,0],[-0.5,0.5,0]]*1.2, $
		POLYGON=[5,0,1,2,3,0],$
		COLOR=[255,255,255], STYLE=1)
    oTrans->Add,oObj

	; initial data
    build_geom,v0,c1,v2,c2

    nFrames = 10
    d = SIZE(v0,/DIMENSIONS)
    v1 = FLTARR(d[0],d[1],nFrames)
    FOR i=0,nFrames-1 DO BEGIN
   		v1[0,*,i] = v0[0,*]
   		v1[1,*,i] = v0[1,*]
   		v1[2,*,i] = v0[2,*] + (0.02*FLOAT(i-5))
    END
    vc = BYTARR(d[0],d[1],nFrames)
    vv = BYTARR(d[1],nFrames)
    oPal = OBJ_NEW('IDLgrPalette')
    oPal->LoadCT,5
    oPal->GetProperty,RED=r,GREEN=g,BLUE=b
    OBJ_DESTROY,oPal
    rgb = BYTARR(3,256)
    rgb[0,*] = r
    rgb[1,*] = g
    rgb[2,*] = b

	; where we will display the results

    c = TETRA_SURFACE(v1[*,*,0],c1)
    oScyl = OBJ_NEW('IDLgrPolygon',v1[*,*,0],POLYGONS=c,COLOR=[40,40,255], $
   		SHADING=1, REJECT=1)
    oTcyl = OBJ_NEW('IDLgrPolygon',v1[*,*,0],POLYGONS=[-1],COLOR=[40,40,90], $
   		SHADING=1, REJECT=1)
    c = TETRA_SURFACE(v2,c2)
    oBlck = OBJ_NEW('IDLgrPolygon',v2,POLYGONS=c,COLOR=[255,80,80], $
   		SHADING=1, REJECT=1)
    nlevels = 16
    col = bytarr(3,nlevels)
    col[0,*] = r[(indgen(nlevels)+1)*15]
    col[1,*] = g[(indgen(nlevels)+1)*15]
    col[2,*] = b[(indgen(nlevels)+1)*15]
    oCont = OBJ_NEW('IDLgrContour',DIST(5),N_LEVELS=nlevels,C_COLOR=col,HIDE=1, $
   		SHADING=1,MIN_VALUE=0,MAX_VALUE=250)
    oGroup->Add,oScyl
    oGroup->Add,oBlck
    oGroup->Add,oTcyl
    oGroup->Add,oCont

    data = BYTARR(4,16,16)
    data[0:2,*,*] = 255
    data[3,*,*] = 128
    oTexture = OBJ_NEW('IDLgrImage',data,HIDE=1)
    tc = FLTARR(2,N_ELEMENTS(v1/3))
;   oTcyl->SetProperty, TEXTURE_MAP=oTexture, REJECT=1

    pat = LONARR(32)
    FOR i=0,31,2 DO pat[i] = 'aaaaaaaa'xL
    FOR i=1,31,2 DO pat[i] = '55555555'xL
    oPattern = OBJ_NEW('IDLgrPattern',2,PATTERN=pat)
    oTcyl->SetProperty,FILL_PATTERN=oPattern

	;--- The lights ---------------------------------------------------------------
    oLight = OBJ_NEW('IDLgrLight',TYPE=1,LOC=[0,0,1],INTENSITY=0.3,HIDE=0)
    oTopModel->Add, oLight

    oAmbient = OBJ_NEW('IDLgrLight',TYPE=0,INTENSITY=1.0)
    oTopModel->Add, oAmbient

	;---------------------------------------------------------------------------
	; manipulators and cleanup...

    oTrack1 = OBJ_NEW('trackball',[xdim/2, ydim/2.], xdim/2., MOUSE=1)
    oTrack2 = OBJ_NEW('trackball',[xdim/2, ydim/2.], xdim/2., MOUSE=4)
    oTrack3 = OBJ_NEW('trackball',[xdim/2, ydim/2.], xdim/2., MOUSE=4)

    WIDGET_CONTROL, wBase, /REALIZE
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

    oWindow->SetProperty, QUALITY=2, GRAPHICS_TREE=oView
    oBag = OBJ_NEW('IDL_Container')
    oBag->Add, [oTrack1,oTrack2,oTrack3,oTexture,oPattern]
    oView->Add, oBag

    sState = { $
		wDraw:    	wDraw,   	$
	    wTrans:   	wTrans,  	$
	    wTimer:   	wTimer,  	$
	    wDTime:		wDTime,		$
	    wPoint:		wPoint,		$
	    v1:    		v1,			$
	    v2:     	v2,			$
	    c1:      	c1,     	$
	    c2:      	c2,     	$
        oWindow:  	oWindow, 	$
        oGroup:   	oGroup,  	$
        oPlane:   	oPlane,  	$
        oTrans:   	oTrans,  	$
        oTcyl:   	oTcyl,  	$
        oScyl:   	oScyl,  	$
        oBlck:   	oBlck,  	$
        oCont:   	oCont,  	$
	    Trans:    	0.0,     	$
	    bloc:     	[0.,0.], 	$
	    bdown:    	0b,      	$
        oTrack1:  	oTrack1, 	$
        oTrack2:  	oTrack2,  	$
        useCont:	0,			$
        VColored:	0,			$
        vc:			vc,			$
        vv:			vv,			$
        rgb:		rgb,		$
        Frame:		0,			$
        nFrames:	nFrames,	$
        pointloc:	[0.0,0.0,0.5], $
        Dir:       	1,			$
        Timer:     	0.2,		$
        Animate:   	0			$
        }

	updatedistance,sState
    updateplane,sState

    WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY

    XMANAGER, 'tetra', wBase, /NO_BLOCK

END
