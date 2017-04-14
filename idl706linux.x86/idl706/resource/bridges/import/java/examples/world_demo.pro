;
; Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: Demonstrate interaction between an IDL GUI and a Java GUI.
;
; Usage:
;    IDL> world_demo
;

PRO turn_world, event
   ; pro to respond to trackball movements (turn the globe via the mouse)
   WIDGET_CONTROL, event.top,get_uvalue = state
   state.opModel-> GetProperty, TRANSFORM = old
   h = state.oTrack-> Update(event,TRANSFORM = new)
   IF h THEN BEGIN
      state.opModel-> SetProperty, TRANSFORM = old#new
      state.oWindow-> Draw, state.oView
   ENDIF
END


PRO day_time, event
   ; applies a new frame from the blended image stack to show next hour of
   ; dark/light globe

   ; get local copy of structure
   WIDGET_CONTROL, event.top, get_uvalue  = state
   ; select hours past Noon GMT
   WIDGET_CONTROL, event.id, get_uvalue  = uval

   IF uval EQ '7' Then $
      state.oImage->SetProperty, data =  (*state.pBlock)[*,*,*,0] $
   ELSE  $
       state.oImage->SetProperty, data =  (*state.pBlock)[*,*,*,1]

   state.oWindow->Draw, state.oView
   WIDGET_CONTROL, event.top, set_uvalue = state
END

PRO world_demo_event, event
   ;timer pro to get values of lat & lon and translate these into a radial
   ; visualization
   ; calls the Java object and get last java window mouse coords
   ; (in IDL image units)


   ; get the Java image mouse x,y
   WIDGET_CONTROL, event.top, get_Uvalue = state
   xyTrans = state.JObj->getLastCursorPos(1)

   lat  = xyTrans[1]*!PI/360 - !PI/2      ; calc latitude  in radians
   lon   = xyTrans[0]*!PI/360 - !PI       ; calc longitude in radians

   ; make lat/lon strings for display
   LonStr  = STRMID(STRTRIM(FIX(lon*180/!PI),2), 0,4)
   IF Lat LT 0 THEN LatStr = STRMID(STRTRIM(lat*180/!PI,2), 0,5) $
   ELSE LatStr  = STRMID(STRTRIM(lat*180/!PI,2), 0,4)
   location   = LonStr + ' , '+LatStr

   ; =========================================================================
   ; == Put a pin in the globe at the lon, lat position. Do this by making a polyline which==
   ; == Intercepts the centre of the Earth.
   ; Calc the x,y, z of the top of the pin              ==
   Rl = state.r*COS(lat)           ; radius of circle (parallel)
   x    = Rl*Cos(90*!Pi/180-lon)
   y    = state.R*Sin(lat)
   z    = Rl*Sin(90*!PI/180-lon)
   state.oPline-> SetProperty, data = [[0,0,0], [x,y,z]]  ; update the pin
   state.oMarkMod-> Reset          ; pin head
   state.oMarkMod-> Translate, x,y,z        ; put it on the pin

   ; == Check to see if click lon has changed - move globe if so =============
   IF ABS(lon - state.lon) GT 0.02 THEN BEGIN
      state.opModel-> Reset
      FOR i = 0, 9 DO BEGIN           ; loop to show the move
         ; motion catches the eye
         state.opModel-> Rotate,[0,1,0], -lon*180/!Pi/10
         state.oWindow-> Draw, state.oView
      ENDFOR
      state.lon  = lon           ; update the stored lon value
   ENDIF

   ; == Put the lon, lat labels on the graphic ===============================
   state.oText2-> SetProperty, locations =[0.56,y-0.04,1.1]
   state.oText-> SetProperty, STRINGS = location, locations =[0.1,y-0.05,1.1]
   state.oWindow-> Draw, state.oView
   WIDGET_CONTROL, event.top, set_Uvalue = state
   WIDGET_CONTROL, event.top, timer = 0.1       ; set the alarm
END

PRO world_demo
   ; pro reads in a block of image data
   ; block is a set of 24 true colour images representing the world through 24 hours of illumination by the sun
   ; the block was created from an alpha-blend of earthcyl3.jpg and earthlightsbig.jpg by progressivly shifting the
   ; alpha-plane
   ;
   ; ok   = DIALOG_MESSAGE(/info, $
   ; 'Java bridge demo. Click in the Java window map to report in IDL graphic. Drag the globe to rotate,'+ $
   ; ' IDL requires noon_GMT_7.jpg & noon_GMT_19.jpg, Java requires c:\rsi\idl60\examples\data\avhrr.JPG')


   ; === CHECK JVM version on Solaris ===
   ;
   ; We only run on Solaris for Java1.5 and later due to limitations in the AWT
   ; libraries.

   ; System is a static class, so create an IDLJavaObject STATIC object
   oSystem = OBJ_NEW("IDLJavaObject$STATIC$JAVA_LANG_SYSTEM", "java.lang.System")

   ; Print some of java.lang.System's properties
   javaVersion = oSystem->getProperty("java.version")
   osName      = oSystem->getProperty("os.name")

   ; delete the object
   OBJ_DESTROY, oSystem

   IF (javaVersion LT '1.4.0')  THEN BEGIN
      PRINT, 'This example only with Java 1.4 or later'
      RETURN
   ENDIF

   IF (osName EQ 'SunOS') AND (javaVersion LT '1.5.0')  THEN BEGIN
      PRINT, 'This example only runs on Solaris with a JVM of version 1.5 or later'
      RETURN
   ENDIF



   ; === READ THE DATA BLOCK ===
   m   = 1024
   n   = 512
   pBlock  = PTR_NEW(BYTARR(3, m, n, 2))
   file1   = FILEPATH('noon_GMT_7.jpg', $
                      SUBDIRECTORY=['resource', 'bridges','import','java', 'examples'])
   file2   = FILEPATH('noon_GMT_19.jpg', $
                      SUBDIRECTORY=['resource', 'bridges','import','java', 'examples'])

   READ_JPEG, file1, image1 , TRUE=1
   READ_JPEG, file2, image2 , TRUE=1
   (*pBlock)[*,*,*,0] = image1
   (*pBlock)[*,*,*,1] = image2

   ; %%%%%%%%   WIDGET CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   tlb   = WIDGET_BASE(/col, title =        $
           'IDL Application  . Click in Java window to translate coordinates')
   draw  = WIDGET_DRAW(tlb, XS = 600, YS = 600,      $
                       graphics_level = 2, /button_events,  $
                       /motion_events, event_pro = 'turn_world')
   rb_base = WIDGET_BASE(tlb, /row, /exclusive)
   rb1  = WIDGET_BUTTON(rb_base, event_pro = 'day_time',    $
                        value = 'Noon GMT + 7 Hrs', uvalue = '7')
   rb2  = WIDGET_BUTTON(rb_base, event_pro = 'day_time',    $
                        value = 'Noon GMT + 19 Hrs',uvalue = '19')
   s ='Click in Java window for Lat/Lon positioning. Drag to rotate globe.'
   label  = WIDGET_LABEL(tlb,  /Dynamic_resize,      $
                         xsize = n, /align_cent, value =s)
   WIDGET_CONTROL, tlb, /realize
   WIDGET_CONTROL, rb1, SET_BUTTON = 1
   WIDGET_CONTROL, draw, get_value = oWindow

  ; |||||||||   OBJECTS |||||||||||||||||||||||||||||||||||||||||||||||
   oView  = OBJ_NEW('IDLgrView', color = [0,0,20],     $
                    zclip = [3.9, -3.9],        $
                    VIEWPLANE_RECT = [-1.05, -1.05, 2.1,2.1])
   oModel  = OBJ_NEW('IDLgrModel')           ; model for the orb
   oImage  = OBJ_NEW('IDLgrImage', (*pBlock)[*,*,*,0])
   oGlobe  = OBJ_NEW('Orb', radius = 0.95, density = 4,    $
                     color = [255, 255, 255],      $
                     TEXTURE_MAP = oImage, /TEX_COORDS)

   ; a radial pin to mark lat/lon from J window
   oPline  = OBJ_NEW('IDLgrPolyLine', [[0,0,0],      $
                     [0.1,0.1,0.1]],    $
                     color = [255,100,0], thick = 1.5)
   ; The pin head (small orb)
   oMarker = OBJ_NEW('Orb', radius = 0.015, Color = [255,255,0],  $
                     style =2, density =0.5)
   oMarkMod = OBJ_NEW('IDLgrModel')
   oMarkMod-> Add, oMarker
   oPModel = OBJ_NEW('IDLgrModel')
   opModel-> Add, oPline
   ; lon, lat text object
   oText  = OBJ_NEW('IDLgrText', ' ', color = [255,255,0],   $
                    char_d = [0.1,0.1])
   ; label for above
   oText2  = OBJ_NEW('IDLgrText', 'Long, Lat ',      $
                    color = [255,255,0], char_d = [0.05,0.05])
   oTModel = OBJ_NEW('IDLgrModel')           ; model to hold lon, lat text
   oTmodel-> Add, oText
   oTmodel-> Add, oText2
   oModel-> Add, oGlobe
   oModel-> ROTATE, [1,0,0], -90     ; view Earth with pole up
   Lon  =  0.0                       ; inital rotation of globe wrt 0 Lon
   oModel-> ROTATE, [0,1,0], 90      ; view Earth from * degrees longitude
   oPModel-> Add, oModel
   oPModel-> Add, oMarkMod
   oView-> Add, oPModel
   oView-> Add, oTmodel
   oWindow-> Draw, oView
   ; trackball to rotate globe about Y axis
   oTrack  =  OBJ_NEW('TrackBall', [n/2,n/2], n/2, axis = 1,/constrain)

   ; The java object
   JObj      = OBJ_NEW("IDLJavaObject$RSIImageFrame", "RSIImageFrame", $
                       "world_demo.pro : demonstrate IDL-Java interaction", $
                      FILEPATH('avhrr.png', SUBDIRECTORY=['examples','data']), $
                      720, 360)

   state  = { pBlock  : pBlock   ,$    ; pointer to image data
      oImage  : oImage   ,$            ; Image object
      oWindow  : oWindow   ,$          ; window object ref
      oView  :  oView   ,$             ; view obj ref
      oModel  : oModel   ,$            ; main container object ref
      oMarkMod : oMarkMod  ,$          ; marker ball for end of radial vector
      opModel  :  oPmodel   ,$         ; general model to rotate the globe
      oText  : oText   ,$              ; text to show lon/lat
      oText2  : oText2   ,$            ; text for title to oText
      oTrack  : oTrack   ,$            ; trackball object ref
      R   : 1.025   ,$                 ; radius of Earth vector
      oPline  : oPLine   ,$            ; radial poly line
      JObj  : JObj   ,$                ; Java Object
      Lon   : Lon      $               ; click longitude
   }

   ; tie structure to tlb for use in event pros
   WIDGET_CONTROL, tlb, set_uvalue = state
   WIDGET_CONTROL, tlb, timer = 0.5           ; set the alarm
   XMANAGER, 'world_demo', tlb


   ; === CLEAN UP ON Xit ===
   OBJ_DESTROY, state.oView
   OBJ_DESTROY, state.oTrack
   OBJ_DESTROY, Jobj
   OBJ_DESTROY, oImage
   PTR_FREE, state.pBlock
   HEAP_GC

END

