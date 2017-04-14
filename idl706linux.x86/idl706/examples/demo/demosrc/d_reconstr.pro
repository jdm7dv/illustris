;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_reconstr.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_reconstr.pro
;
;  CALLING SEQUENCE: d_reconstr
;
;  PURPOSE:
;       Shows reconstruction techniques for images.
;       (Computerized tomography)
;
;  MAJOR TOPICS: Visualization and data analysis
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_reconstrMenuChoice          -  Identify the menu button choice
;       pro d_reconstrMenuCreate          -  Create the menu bar
;       pro d_reconstrNone                -  Set the filter to none
;       pro d_reconstrRamlak              -  Compute the Ramlak filter
;       pro d_reconstrShepp_Logan         -  Compute the Shepp_Logan filter
;       pro d_reconstrLp_Cosine           -  Compute the Lp_Cosine filter
;       pro d_reconstrGen_Hamming         -  Compute the Gen_Hamming filter
;       pro d_reconstrDEllipse            -  Draw an ellipse
;       pro d_reconstrDCircle             -  Draw a circle
;       pro d_reconstrDPoly               -  Draw a polygon
;       pro d_reconstrMakePhantom         -  Create a phantom object
;       pro d_reconstrReconstructIt       -  Do the image reconstruction
;       pro d_reconstrRedraw              -  Redraw the windows
;       pro d_reconstrColorMapCallback    -  Redraw after colormap change
;       pro d_reconstrEvent               -  Event handler
;       pro d_reconstrCleanup             -  Cleanup
;       pro d_reconstr                    -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro demo_gettips        - Read the tip file and create widgets
;       pro demo_puttips        - Change tips text
;       reconstr.tip
;       ctscan.dat
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       tomodemo_com
;
;  MODIFICATION HISTORY:
;       1/94,   DS   - Written.
;       1/97,   DAT  - New GUI, IDL Style Guide.
;-
;--------------------------------------------------------------------
;
;    PURPOSE  Given a uservalue from a menu button created
;             by MenuCreate, the function returns  the index
;             of the choice within the category.  Set the
;             selected menu button  to insensitive to signify
;             selection, and set all other choices for the
;             category to sensitive.

function d_reconstrMenuChoice, $
    Eventval, $   ; IN: uservalue from seleted menu button
    MenuItems, $  ; IN: menu item array, as returned by MenuCreate
    MenuButtons   ; IN: button array as returned by MenuCreate

    ;  Get the name less the last qualifier.
    ;
    i = STRPOS(eventval, '|', 0)
    while (i ge 0) do begin
        j = i
        i = STRPOS(eventval, '|', i+1)
    endwhile

    base = STRMID(eventval, 0, j+1) ;common buttons, includes last |

    ;  Get the button sharing this basename.
    ;
    buttons = WHERE(STRPOS(MenuItems, base) eq 0)

    ;  Get the index of selected item.
    ;
    this = (WHERE(eventval eq MenuItems))[0]

    ;  For each button in category, sensitize.
    ;
    for i=0, N_ELEMENTS(buttons)-1 do begin
        index = buttons[i]
        WIDGET_CONTROL, MenuButtons[buttons[i]], SENSITIVE=index ne this
    endfor

    ;  Return the Selected button's index.
    ;
    RETURN, this - buttons[0]

end

;--------------------------------------------------------------------
;
;    PURPOSE  Create a menu from a string descriptor (MenuItems).
;             Return the parsed menu items in MenuItems (overwritten),
;             and the array of corresponding menu buttons in MenuButtons.
;
;  MenuItems = (input/output), on input the menu structure in the form of
;          a string array.  Each button is an element, encoded as follows:
;  Character 1 = integer bit flag.  Bit 0 = 1 to denote a button with
;       children.  Bit 1 = 2 to denote this is the last child of its
;       parent.  Bit 2 = 4 to show that this button should initially
;       be insensitive, to denote selection.  Any combination of bits
;       may be set.
;       On RETURN, MenuItems contains the fully qualified button names.
; Characters 2-end = Menu button text.  Text should NOT contain the character
;       |, which is used to delimit menu names.
; MenuButtons = (output) button widget id's of the created menu.
; Bar_base = (input) ID of menu base.
; Prefix = prefix for this menu's button names.  If omitted, no
;   prefix.
;
;
; Example:
;  MenuItems = ['1File', '0Save', '2Exit', $
;       '1Edit', '3Cut', $
;       '3Help']
;  Creates a menu with three top level buttons (file, edit and help).
;  File has 2 choices (save and exit), Edit has one choice, and help has none.
;  On RETURN, MenuItems contains the fully qualified menu button names
;  in a string array of the form: ['<Prefix>|File', '<Prefix>|File|Save',
;   '<Prefix>|File|Exit', '<Prefix>|Edit',..., etc. ]
;
pro d_reconstrMenuCreate, $
    MenuItems, $    ; IN/OUT: menu structure/button names
    MenuButtons, $  ; OUT: button widget identifier
    Bar_base,  $    ; IN: menu bar base identifier
    Prefix=prefix   ; IN: (opt) prefix of the menu's button names

    ;  Initialize working variables and arrays.
    ;
    level = 0
    parent = [bar_base, 0, 0, 0, 0, 0]
    names = STRARR(5)
    lflags = INTARR(5)
    MenuButtons = LONARR(N_ELEMENTS(MenuItems))

    if (N_ELEMENTS(prefix)) then begin
        names[0] = prefix + '|'
    endif else begin
        names[0] = '|'
    endelse

    for i = 0, N_ELEMENTS(MenuItems)-1 do begin
        flag = FIX(STRMID(MenuItems[i], 0, 1))
    txt = STRMID(MenuItems[i], 1, 100)
    uv = ''

    for j = 0, level do uv = uv + names[j]

        ;  Set the fully qualified name in the menuItems array.
        ;
        MenuItems[i] = uv + txt

        ;  Create the menu bar buttons.
        ;
        MenuButtons[i] = WIDGET_BUTTON(parent[level], $
            VALUE=txt, UVALUE=uv+txt, $
            MENU=flag and 1, HELP=txt eq 'About')

        if ((flag and 4) ne 0) then begin
            WIDGET_CONTROL, MenuButtons[i], SENSITIVE=0
        endif

        if (flag and 1) then begin
            level = level + 1
            parent[level] = MenuButtons[i]
            names[level] = txt + '|'
            lflags[level] = (flag AND 2) ne 0
        endif else if ((flag and 2) NE 0) then begin

            ;  Pop the previous levels.
            ;
            while (lflags[level]) do level = level-1

            ;  Pop this level.
            ;
            level = level - 1
        endif
    endfor

end         ;  of d_reconstrMenuCreate


;--------------------------------------------------------------------
;
;    PURPOSE  Create the reconstruction filter : none
;
function d_reconstrNone, $
    x, $           ; IN: x coordinates
    pointSpacing   ; IN: point spacing

    RETURN, [1.0]
end      ;   of d_reconstrNone

;--------------------------------------------------------------------
;
;    PURPOSE  Create the reconstruction filter : RAMLAK
;
function d_reconstrRamlak, $    ;Discrete form of Ram-Lak
    x, $           ; IN: x coordinates
    pointSpacing   ; IN: point spacing

    zero = where(x EQ 0.0, count)
    q = x
    if (count NE 0) then q[zero] = .01
    y = -SIN(!pi*x/2)^2 / (!pi^2 * q^2 * pointSpacing)
    if (count NE 0) then y[zero] = 1./(4.*pointSpacing)
    RETURN, y
end

function d_reconstrSinc, x      ;Sinc function = sin(!pi*x)/(!pi*x), =1 for x=0
z = where(x eq 0, count)
t = !pi*x
if count ne 0 then t[z] = 1.
t = sin(t)/t
if count ne 0 then t[z] = 1.
return, t
end

function d_reconstrRLC, x, d    ;Continuous impulse response of Ram-Lak
e0 = 1.0/(2*d)
return, e0^2 * (2*d_reconstrSinc(2*e0*x) - d_reconstrSinc(e0*x)^2)
end


;--------------------------------------------------------------------
;
;    PURPOSE  Create the reconstruction filter : Shepp_Logan
;
function d_reconstrShepp_Logan,$
    x, $           ; IN: x coordinates
    pointSpacing   ; IN: point spacing

    pointSpacing = !pi^2 * pointSpacing * (1.-4.*x^2)
    zeros = where(abs(pointSpacing) LE 1.0e-6, count)
    if (count ne 0) then pointSpacing[zeros] = .001
    RETURN, 2./pointSpacing
end

;--------------------------------------------------------------------
;
;    PURPOSE  Create the reconstruction filter : Lp_Cosine
;
function d_reconstrLp_Cosine, $
    x, $           ; IN: x coordinates
    pointSpacing   ; IN: point spacing

RETURN, 0.5*(d_reconstrRLC(x-0.5, pointSpacing) + $
             d_reconstrRLC(x+0.5, pointSpacing))
end

;--------------------------------------------------------------------
;
;    PURPOSE  Create the reconstruction filter : Gen_Hamming
;
function d_reconstrGen_Hamming, $
    x, $              ; IN: x coordinates
    pointSpacing, $   ; IN: point spacing
    alpha             ; IN: alpha attenuation factor

    if (N_ELEMENTS(alpha) LE 0) then alpha = 0.5
    RETURN, alpha * d_reconstrRLC(x, pointSpacing) + ((1.-alpha)/2) * $
        (d_reconstrRLC(x-1, pointSpacing) + d_reconstrRLC(x+1, pointSpacing))
end


;--------------------------------------------------------------------
;
;    PURPOSE  Fill an elliptical area within an array with a given value.
;
pro d_reconstrDEllipse, $
    regionArray, $      ; IN/OUT: array
    x0, $               ; IN: x loaction of the ellipse center
    y0, $               ; IN: y loaction of the ellipse center
    rx, $               ; IN: radius in x of the ellipse
    ry, $               ; IN: radius in y of the ellipse
    theta, $            ; IN: angle of the major axis
    value               ; IN: value given to a point within the ellipse.

    s = SIZE(regionArray)
    nx = s[1]
    ny = s[2]
    n = 64        ;# of points around ellipse
    x = FINDGEN(n) * (2 * !pi / n)
    y = ry * SIN(x)
    x = rx * COS(x)
    t = theta * !dtor
    yp = (COS(t) * y + SIN(t) * x + y0) * (ny/2) + (ny/2)
    x = (COS(t) * x - SIN(t) * y + x0) * (nx/2) + (nx/2)
    regionArray[POLYFILLV(x, yp, nx, ny)] = value
end

;--------------------------------------------------------------------
;
;    PURPOSE  Fill a circular area within an array with a given value.
;
pro d_reconstrDCircle, $
    regionArray, $      ; IN/OUT: array
    r, $                ; IN: radius of the circle
    x0, $               ; IN: x location of the circle center
    y0, $               ; IN: y location of the circle center
    value               ; IN; value

    s = SIZE(regionArray)
    n = 100
    x = FINDGEN(n) * (2 * !pi / n)
    y = r * SIN(x) + y0
    x = r * COS(x) + x0
    regionArray[POLYFILLV(x, y, s[1], s[2])] = value
end

;--------------------------------------------------------------------
;
;    PURPOSE Draw a polygon within an array
;
pro d_reconstrDPoly, $
    regionArray, $      ; IN/OUT: array
    x, $                ; IN: x location of the polygon center
    y, $                ; IN: y location of the polygon center
    value               ; IN: value

    s =size(regionArray)
    regionArray[POLYFILLV(x, y, s[1], s[2])] = value
end

;--------------------------------------------------------------------
;
;    PURPOSE  Create the phantom (image) objects.
;
function d_reconstrMakePhantom, $
    imageSize, $     ; IN: Image size
    object           ; IN: Object identifier, see list below

    case object of

        ;  Create squares.
        ;
        0: Begin
            rslt = FLTARR(imageSize, imageSize)
            rslt[imageSize/2, imageSize/2] = 1.0
        endcase

        ;  Create ellipses.
        ;
        1:  begin
            rslt = FLTARR(imageSize, imageSize)
            d_reconstrDEllipse, rslt,    0,     0,   .69,   .92,    0,  1.0 ;a
            d_reconstrDEllipse, rslt,    0,-.0184, .6624, .8740,    0,  0.34 ;b
            d_reconstrDEllipse, rslt,  .22,    0.,   .11,   .31,  -18,  0. ;c
            d_reconstrDEllipse, rslt, -.22,    0.,   .16,   .41,   18,  0. ;d
            d_reconstrDEllipse, rslt,   0.,   .35,   .21,   .25,   0.,  0.67 ;e
            d_reconstrDEllipse, rslt,   0.,   .35,   .05,   .05,   0.,  0.57 ;Extra
            d_reconstrDEllipse, rslt,   0.,    .1,  .046,  .046,   0.,   .67 ;f
            d_reconstrDEllipse, rslt,   0.,   -.1,  .046,  .046,   0.,   .67 ;g
            d_reconstrDEllipse, rslt, -.08, -.605,  .046,  .023,   0.,   .67 ;h
            d_reconstrDEllipse, rslt,   0., -.606,  .023,  .023,   0.,   .67 ;i
            d_reconstrDEllipse, rslt, 0.06, -.605,  .023,  .046,   0.,   .67 ;j
            d_reconstrDEllipse, rslt, -.49, -.470,  .050,  .050,   0.,  1.00 ;j
        endcase

        ;  Create circles.
        ;
        2: begin
            rslt = FLTARR(imageSize, imageSize)
            d_reconstrDCircle, rslt, imageSize/4,  .5*imageSize,  .5*imageSize, .5
            d_reconstrDCircle, rslt, imageSize/12, .6*imageSize,  .6*imageSize, 0.0
            d_reconstrDCircle, rslt, imageSize/12, .38*imageSize, .37*imageSize, 1.
            d_reconstrDCircle, rslt, imageSize/12, .7*imageSize,  .2*imageSize, 1.
            d_reconstrDCircle, rslt, 3, .28*imageSize, .60*imageSize, 0.0
            d_reconstrDPoly, rslt, imageSize*[.55, .60, .65], imageSize * [.37, .45, .37], 0
            rslt[imageSize*[.117, .195], imageSize*[.781, .855]] = .5
        endcase

        ;  Create polygons.
        ;
        3: begin
            rslt = FLTARR(imageSize, imageSize)
            x = imageSize/3
            y = 2 * imageSize / 3
            s = 2
            rslt[x-s:x+s, y-s:y+s] = 1.0
            rslt[y,x]=1.0
            s = 4
            rslt[x-s:x+s, x-s:x+s] = 0.5
            d_reconstrDPoly, rslt, [y-s, y+s, y], [y-s, y-s, y+s], 1.0
        endcase

        ;  Download the CT scan image (slice), resize, and scale it.
        ;
        4: begin
            OPENR,unit, demo_filepath('ctscan.dat', $
                SUBDIR=['examples','data']), $
                /GET_LUN
            imageArray=BYTARR(256,256)
            READU, unit, imageArray
            CLOSE, unit
            FREE_LUN, unit
            imageArray = (imageArray < 200b)/ 200.    ;Normalize
            if (imageSize LT 256) then rslt = CONGRID(imageArray, $
                imageSize, imageSize, /INTERP) $
            else if (imageSize GT 256) then begin
                rslt = FLTARR(imageSize, imageSize)
                rslt[(imageSize-256)/2, (imageSize-256)/2] = imageArray ;Insert
            endif else rslt = imageArray     ;already correct size.
        endcase
    endcase

    RETURN, rslt

end       ;  of d_reconstrMakePhantom

;--------------------------------------------------------------------
;
;    PURPOSE   Reconstruct (recompute) the image and display it.
;
pro d_reconstrReconstructIt

    COMMON tomodemo_com, base, imageSize, $
      interp, nangles, kernelSize, filter, $
      draw, window, labels, lnames, top, shiftValue, pointSpacing, $
      filters, obj_button, object, zoomFactor, maxa, mina, ocolors, $
      MenuItems, MenuButtons, wReconstructButton, wAngleButton, $
      wFilterButton, $
      wKernelButton, wInterpButton, drawErrorID, errorBase, $
      Bar_Base, wSubBase, $     ; base ID to desensitize when computing.
      ReconstructFlag, $        ; 0 = Go button has not  been pushed yet
      originalImage, reconImage, sinogramImage, $ ; Images
      sText, $                  ; structure for tips.
      pimage, pimagestr, nimages, comp_view ;history

    ;  Desensitize the bases during reconstruction.
    ;
    WIDGET_CONTROL, Bar_base, SENSITIVE=0
    WIDGET_CONTROL, wSubBase, SENSITIVE=0

    ;  Initialize the windows labels (names).
    ;
    lnames2 = ['Original (Click window)', $
              'Reconstruction          ', $
              'Sinogram (Click window) ', $
              'Error (Click window)    ']
    ;  Create the widgets starttin g with the top level base.
    for i=0,3 do begin
;        WIDGET_CONTROL, labels[i], SET_VALUE=lnames[i]
        WIDGET_CONTROL, labels[i], SET_VALUE=lnames2[i]
    endfor

    ;  Redraw the original image by showing the angle line.
    ;
    WSET, window[0]
    TV, BYTSCL(originalImage, TOP=top, MAX=maxa, MIN=mina)

    ;  Draw a circle.
    ;
    x = FINDGEN(60) * (!pi * 2 / 59)
    na2 = imageSize/2.
    PLOTS, na2 * COS(x) +na2, na2*SIN(x) +na2, /DEVICE, COLOR=top+1
    comp_view = 0

    ;  Sort indices by i,j, where k = nangles * j / 2^i
    ;
    ind = INDGEN(nangles)   ;Indices of projections
    if (0) then begin
        j=1
        mm = CEIL(ALOG(nangles) / ALOG(2.0))

        for k=1, mm do for i=1,2L^k-1,2 do begin
            kk = i*2L^mm/2L^k
            if (kk LT nangles) then begin
                ind[j] = kk
                j = j+1
            endif
        endfor
    endif

    ;  Compute the filter function.
    ;
    x = FINDGEN(2*kernelSize+1)-kernelSize
    ; Point spacing is 1.0
    ker = call_function('d_reconstr'+filters[filter], x, 1.0)
    ker = ker / (TOTAL(ker) * nangles * SQRT(imageSize)) ; Normalize it

    np = FIX(SQRT(2.) * imageSize/pointSpacing + kernelSize + 4)
    sinogramImage = FLTARR(np, nangles)
    convolvedSinogramImage = FLTARR(np, nangles)
    t0 = 0.
    shiftValue = -(np-imageSize)/2
    WIDGET_CONTROL, labels[3], SET_VALUE='Convolved Sinogram      '
    chunk = nangles/32 > 1
    first = 1

    ;; erase other windows
    FOR i=1,3 DO BEGIN
      wset, window[i]
      erase
    ENDFOR

    ;; create the sinogram
    sinogramImageOrig = radon(originalImage, ntheta=nangles, nrho=350, $
                              linear=interp EQ 1, rho=rho, theta=theta)
    ;; rotate and resize image to fit window
    sinogramImage = bytscl(congrid(transpose(sinogramImageOrig), $
                                   !d.x_size, nangles), top=top)
    ;; display the sinogram
    wset, window[2]
    tv, sinogramImage

    ;; convolve image
    IF (min(size(sinogramImage,/dimensions)) LT max(size(ker,/dimensions))) THEN BEGIN
      ;; if kernel is bigger than the height of the sinogram then we
      ;; must convolve each line separately
      FOR i=0,nangles-1 DO BEGIN
        convolvedSinogramImageOrig = sinogramImageOrig
        convolvedSinogramImage = sinogramImage
        convolvedsinogramImageOrig[i,*] = $
          convol(reform(convolvedSinogramImageOrig[i,*]),ker)
        convolvedSinogramImage[*,i] = $
          convol(reform(convolvedSinogramImage[*,i]),ker)
      ENDFOR
    ENDIF ELSE BEGIN
      convolvedSinogramImageOrig = convol(sinogramImageOrig, ker)
      convolvedSinogramImage = convol(sinogramImage, ker)
    ENDELSE

    zoomFactor = 1                  ;Zoom factor

    ;  Compute and draw the reconstructed image.
    ;
    WSET, window[1]

    ;; reconstruct
    reconImage = radon(convolvedSinogramImageOrig, /backproject, rho=rho, $
                       theta=theta, nx=imageSize, ny=imageSize, linear=interp EQ 1)
    scaledReconImage =  BYTSCL(reconImage, TOP=top)
    tv, scaledReconImage

    meana = TOTAL(originalImage)/N_ELEMENTS(originalImage)
    meanb = TOTAL(reconImage)/N_ELEMENTS(reconImage)
    ss = SQRT(TOTAL((originalImage-meana)^2) / TOTAL((reconImage-meanb)^2))
    reconImage = (reconImage-meanb) * ss + meana
    errorImage = abs(originalImage-reconImage)
    errtot = LONG(TOTAL(errorImage^2))

    str2 = "error norm : "+ string(errtot, FORMAT="(i8)")
    demo_putTips, 0, [str2,''], [11,12], NOSTATE=sText

    ;  Draw the error image.
    ;
    WSET, window[3]
    WIDGET_CONTROL, labels[3], $
        SET_VALUE='Error (Click window)'
    TV, BYTSCL(errorImage, MAX=maxa, MIN=0, TOP=top)

    if (nimages EQ 0) then begin      ;Save history
        pimage = BYTARR(imageSize, imageSize, 4, /NOZERO)
        pimagestr = STRARR(4)
    endif

    pimage[0, 0, nimages MOD 4] = scaledReconImage
    pimagestr[nimages MOD 4] = STRING(filters[filter], STRTRIM(nangles,2), $
        ([ 'NN', 'In','Cu'])[interp], STRTRIM(kernelSize*2+1,2), STRTRIM(errtot,2),$
        FORMAT="(a4, ',V',a, ',',a, ',K',a,',E',a)")
    nimages = nimages+1

    ;  Resensitze the bases when reconstruction is done.
    ;
    WIDGET_CONTROL, Bar_base, SENSITIVE=1
    WIDGET_CONTROL, wSubBase, SENSITIVE=1

end    ;  d_reconstrReconstructIt


;--------------------------------------------------------------------
;
;    PURPOSE  Redraw the phanton, sinogram, etc.
;
pro d_reconstrRedraw, $
    force     ; IN: flag indicator

    common tomodemo_com

    ;  Do nothing (return) under certain conditions.
    ;
    if ( (NOT comp_view) AND (force eq 0)) then RETURN

    ;  Reset the original window titles.
    ;
    for  i= 0,3 do WIDGET_CONTROL, labels[i], SET_VALUE=lnames[i]

    WSET, window[0]
    TV, BYTSCL(originalImage, TOP=top, MIN=mina, MAX=maxa)

    if (ReconstructFlag EQ 0) then begin
        WSET, window[2]
        erase
        WSET, window[1]
        erase
        WSET, window[3]
        erase
    endif

    if (N_ELEMENTS(sinogramImage) GT 1) then begin
        WSET, window[2]
        erase

        if (force EQ 1) then begin
            TV, REBIN(sinogramImage, imageSize, zoomFactor*nangles)
        endif

        WSET, window[1]
        erase

        if (force EQ 1) then begin
            TV, BYTSCL(reconImage, TOP=top)
        endif

        WSET, window[3]
        erase

        if (force EQ 1) then begin
            TV, BYTSCL(ABS(originalImage-reconImage), MAX=maxa, MIN=0, TOP=top)
        endif
    endif

    comp_view = 0
end   ;  of  d_reconstrRedraw


pro d_reconstrColorMapCallback

; For visuals with static colormaps, update the graphics
; after a change by XLOADCT.  This routine will be specified
; as the UPDATECALLBACK routine and will be called by XLOADCT.
; See the call of XLOADCT, below.
if ((colormap_applicable(redrawRequired) GT 0) AND $
    (redrawRequired GT 0)) then begin
   d_reconstrRedraw, 1
endif

end

;--------------------------------------------------------------------
;
;    PURPOSE  Main event handler
;
pro d_reconstrEvent, $
    sEvent        ; IN: event structure

    common tomodemo_com

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    forward_function d_reconstrMenuChoice

    WIDGET_CONTROL, sEvent.top, /HOURGLASS

    ;  Branch accordingly to the event ID
    ;  (which widget created that event)
    ;
    case sEvent.id of

        ;  Reconstruct the image.
        ;
        wReconstructButton: goto, do_reconstruction

        ;  Button press within the original view area.
        ;  Draw the cursor location with a small square on the original
        ;  image and draw the corresponding curve on the sinogram.
        ;
        draw[0]: begin

            ;  Return if the button  was not the left mouse button or
            ;  the composite view does not exist or the
            ;  sinogram image does not exist.
            ;
            if ((sEvent.press NE 0) OR comp_view) then RETURN
            if (N_ELEMENTS(sinogramImage) LE 1) then RETURN

            ocolors[0] = (ocolors[0]+1) mod 4
            c = ocolors[0] + top + 1
            WSET, window[0]
            PLOTS, sEvent.x, sEvent.y, COLOR=c, /DEVICE, PSYM=6
            x = (sEvent.x - imageSize/2)
            y = (sEvent.y - imageSize/2)
            t = FINDGEN(nangles+1)* (!pi / nangles) ;Rotate by theta
            t = (COS(t) * x + SIN(t) * y) + (imageSize/2)

            ;  Draw the line on the sinogram image.
            ;
            WSET, window[2]
            i = (imageSize /(2* nangles)) > 1

            if (i NE zoomFactor) and (N_ELEMENTS(sinogramImage) GT 1) then begin
                zoomFactor = i
                TV, REBIN(sinogramImage, imageSize, zoomFactor * nangles)
            endif

            PLOTS, t, zoomFactor*FINDGEN(nangles), COLOR=c, /DEVICE

            empty

        endcase   ;  of draw(0)

        ;  Show the error on the horizontal line where the
        ;  left mouse button was pressed on the error view.
        ;  Open an error view window if it does not already exist.
        ;
        draw[3]: begin

            ;  Return if the button  was not the left mouse button or
            ;  the composite view does not exist or the
            ;  reconstructed image does not exist or the
            ;  error or sinogram images do not exist.
            ;
            if ((sEvent.press Ne 0) OR comp_view) then RETURN
            if (N_ELEMENTS(reconImage) LE 1) then RETURN
            if (N_ELEMENTS(sinogramImage) LE 1) then RETURN

            charscale = 8.0/!d.X_CH_SIZE

            ;  Check if the error plot already exist, if so return
            ;
            errorStatus = WIDGET_INFO(drawErrorID, /VALID_ID)
            if (errorStatus EQ 0) then begin

                ;  Create a new window that displays the error plot.
                ;
                errorBase = WIDGET_BASE(TLB_FRAME_ATTR=1, $
                    TITLE ='Error', $
                    XOFFSET=75, YOFFSET=75, $
                    GROUP_LEADER=base)

                    drawErrorID = WIDGET_DRAW(errorBase, $
                        SCR_XSIZE=250, SCR_YSIZE=250)

                WIDGET_CONTROL, errorBase, /REALIZE
            endif

            WIDGET_CONTROL, drawErrorID, GET_VALUE=errorWindow

            WSET, errorWindow
            y = sEvent.y > 0 < (imagesize-1)
            PLOT, originalImage[*,y], YRANGE=[mina, maxa], XSTYLE=3, YSTYLE=2, $
                TITLE='Row '+STRTRIM(y,2), XMARGIN=[4,1], YMARGIN=[2,2], $
                CHARSIZE = 1.0*charscale

            OPLOT, reconImage[*,y], COLOR=top+2, PSYM=3

            empty

        endcase   ;  of draw(3)

        ;  When the left mouse button is pressed within the
        ;  sinogram view area, draw a small square to mark the
        ;  cursor location and draw the corresponding curve on the
        ;  original image.
        ;
        draw[2]: begin

            ;  Return if the button  was not the left mouse button or
            ;  the composite view does not exist or the
            ;  sinogram image does not exist.
            ;
            if ((sEvent.press NE 0) OR comp_view) then RETURN
            if N_ELEMENTS(sinogramImage) le 1 then return
            if N_ELEMENTS(zoomFactor) le 0 then zoomFactor = 1 ;Within image?

            if (sEvent.y GE nangles*zoomFactor) then RETURN

            ocolors[2] = (ocolors[2] + 1) mod 4
            c = ocolors[2] + top + 1
            na2 = imageSize/2
            WSET, window[2]
            PLOTS, sEvent.x, sEvent.y, COLOR=c, /DEVICE, PSYM=6

            s = sEvent.x - na2                 ;  Radial distance
            t = sEvent.y/zoomFactor * !pi / nangles    ;  Angle in radians

            ;  Display the angle and the x distance from center
            ;  informations.
            ;
            str1 = 'Theta :' + string(t*180./!pi, FORMAT="(f5.1)")
            str2 = 'X from center :' + string(s, FORMAT="(f6.1)")
            demo_putTips, 0, [str1,str2], [11,12], NOSTATE=sText

            x = [-na2, 0, na2]
            st = SIN(t)
            ct = COS(t)

            if (t NE 0.0) then begin
                y = (s - x * ct) / st + na2
            endif else begin
                y=[0, imageSize-1]
                x = [sEvent.x, sEvent.x]-na2
            endelse

            ;  Draw the corresponding curve on the original image.
            ;
            WSET, window[0]
            PLOTS, x+na2, y, /DEVICE, COLOR=c     ;Show projection
            py = sinogramImage[*, sEvent.y/zoomFactor] ;Draw the profile, rotated....
            py = py * (imageSize/(5.*max(py)))
            px = FINDGEN(imageSize) - na2
            PLOTS, ct * px - st * py + na2, $
                st * px + ct * py + na2  , /DEVICE, COLOR=c
            empty
        endcase   ;  of draw(2)

        ;  Do nothing (return) when the mouse button is pressed
        ;  on the reconstructed image.
        ;
        draw[1]: RETURN

        ;  Set the number of angles.
        ;
        wAngleButton:   nangles = 2^(sEvent.index+2)

        ;  Set the type of filter.
        ;
        wFilterButton:  filter = sEvent.index

        ;  Set the kernel size.
        ;
        wKernelButton:  kernelSize = 2^sEvent.index

        ;  Set the interpolation method.
        ;
        wInterpButton:  interp = sEvent.index

        ;  Any other event must be a menu button.
        ;
        else: begin

            ;  Get the user value of the button.
            ;
            WIDGET_CONTROL, sEvent.id, GET_UVALUE=uv

            uv1 = STRTOK(uv, "|", /EXTRACT)

            ;  Branch to the appropriate button event.
            ;
            case uv1[0] of
                'File': case uv1[1] of

                    ;  Quit this application.
                    ;
                    'Quit': begin
                        originalImage = 0       ;Remove images & clean up.
                        reconImage=0
                        sinogramImage = 0
                        pimage=0
                        pimagestr=0
                        WIDGET_CONTROL, sEvent.top, /DESTROY
                        RETURN
                    endcase

                    ;  Draw the newly selected object and destroy the
                    ;  previous one and its associated images.
                    ;
                    'Object': begin
                        WSET, window[0]
                        object = d_reconstrMenuChoice(uv, MenuItems, MenuButtons) + 1
                        originalImage = d_reconstrMakePhantom(imageSize, object)
                        maxa = max(originalImage, MIN=mina)
                        sinogramImage = 0
                        ReconstructFlag = 0
                        d_reconstrRedraw, 1

                        ;  Destroy the error window.
                        ;
                        if ( widget_info(errorbase, /VALID_ID)) then begin
                            WIDGET_CONTROL, errorBase, /DESTROY
                        endif
                        nimages = 0

                        ;  Reset the tips text.
                        ;
                        demo_putTips, 0, ['click', 'numer'], [11,12], $
                            /LABEL, NOSTATE=sText

                    endcase

                    'Reconstruct': begin
                        do_reconstruction:
                        WIDGET_CONTROL, base, /HOURGLASS
                        d_reconstrReconstructIt
                        ReconstructFlag = 1

                        ;  Destroy the error window.
                        ;
                        if ( widget_info(errorbase, /VALID_ID)) then begin
                            WIDGET_CONTROL, errorBase, /DESTROY
                        endif
                    endcase

                endcase   ;  of uv1(2)  or File

                ;  Display the information text file.
                ;
                'About': begin
                    ONLINE_HELP, 'd_reconstr', $
                       book=demo_filepath("idldemo.adp", $
                               SUBDIR=['examples','demo','demohelp']), $
                               /FULL_PATH
                endcase

                ;  Load a new color table.
                ;
                'Edit': begin
                    if (Xregistered('XLoadct') NE 0) then  RETURN
                    XLOADCT, NCOLORS=top, GROUP=sEvent.top, $
                             UPDATECALLBACK='d_reconstrColorMapCallback'

                endcase


                'View': case uv1[1] of

                    ;  Redraw all the views.
                    ;
                    'Redraw': begin
                        d_reconstrRedraw, 1
                    endcase

                    ;  Compare the previous reconstructed image with the
                    ;  current one for the same object.
                    ;
                    'Compare': begin
                        if (nimages le 1) then return
                        n = nimages < 4
                        for i=nimages-n, nimages-1 do begin
                            j = i - nimages+n
                            WSET, window[j]
                            WIDGET_CONTROL, labels[j], SET_VALUE=pimagestr[i mod 4]
                            TV, pimage[*,*,i mod 4]
                        endfor
                        comp_view = 1
                    endcase

                endcase             ; of  View

            endcase     ;  of uv1 (menu bar buttons)

        endcase         ;  of else

    endcase             ;  of sEvent.id

end                     ;  of event handler


;--------------------------------------------------------------------
;
;    PURPOSE  Cleanup procedure.
;
pro d_reconstrCleanup, $
    tlb     ;  IN: top level base identifier

    ;  Get the color table saved in the window's user value.
    ;
    WIDGET_CONTROL, tlb, GET_UVALUE=info, /NO_COPY

    ;  Restore the previous color table.
    ;
    TVLCT, info.colorTable

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(info.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, info.groupBase, /MAP

end              ; Of d_reconstrCleanup

;--------------------------------------------------------------------
;
;    PURPOSE  Cleanup procedure.
;
pro d_reconstr, $
    ImageSizeIn,  $      ; IN: (opt) image size vector
    GROUP=group, $     ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

    common tomodemo_com

    ; Check the validity of the group identifier.
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

    ;  Save the current color table.
    ;
    TVLCT, savedR, savedG, savedB, /GET
    colorTable = [[savedR], [savedG], [savedB]]

    ;  Initialize sizes.
    ;
    if (N_ELEMENTS(ImageSizeIn) LE 0) then begin
        DEVICE, GET_SCREEN = x
        if (x[0] GT 1024) then ImageSize=256 $
            else if x[0] ge 800 then ImageSize=192 $
            else ImageSize = 128
    endif else begin
        imageSize = imageSizeIn
    endelse

    ;  Create the starting up message.
    ;
    if (ngroup EQ 0) then begin
        drawbase = demo_startmes()
    endif else begin
        drawbase = demo_startmes(GROUP=group)
    endelse


    ;  Initialize working parameters and arrays.
    ;
    imageSize = ImageSize           ; Default values
    filter = 2                      ; Shepp Logan
    interp = 1                      ; Linear
    nangles = 32
    kernelSize = 8
    pointSpacing = 1.               ; Point spacing
    zoomFactor = 1
    object = 4
    n = 2 * imageSize
    draw = LONARR(4)
    window = LONARR(4)
    ocolors = INTARR(4)             ; Overlay colors
    pimage=0
    nimages=0
    comp_view = 0                   ; Showing normal view
    ReconstructFlag = 0

    ;  Initialize the filter options, None must be 1st filter....
    ;
    filters=  ['None', 'RamLak', 'Shepp_Logan', $
        'LP_Cosine', 'Gen_Hamming']

    ;  Initialize the windows labels (names).
    ;
    lnames = ['Original                ', $
              'Reconstruction          ', $
              'Sinogram                ', $
              'Error                   ']
    ;  Create the widgets starttin g with the top level base.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        base = WIDGET_BASE(TITLE='Reconstruction Demo', $
            MAP=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            MBAR=bar_base, TLB_FRAME_ATTR=1, /COLUMN)
    endif else begin
        base = WIDGET_BASE(TITLE='Reconstruction Demo', $
            GROUP_LEADER=group, $
            MAP=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            MBAR=bar_base, TLB_FRAME_ATTR=1, /COLUMN)
    endelse

        MenuItems = [ $
            '1File', $
            '1Object', '0Shepp-Logan Phantom', '0Circles', '0Squares','6CT Slice', $
            '0Reconstruct', '2Quit', $
            '1Edit', '2Color Palette', $
            '1View', '0Redraw', '2Compare', $
            '1About', '2About Reconstruction' ]

        ;  Create the menu bar and all its buttons.
        ;
        d_reconstrMenuCreate, MenuItems, MenuButtons, Bar_base

        ;  Create a sub base that has the left and right bases.
        ;
        wSubBase = WIDGET_BASE(base, COLUMN=2)

            ;  Create the base that has options and functionality buttons.
            ;
            wLeftBase = WIDGET_BASE(wSubBase, /COLUMN, /BASE_ALIGN_CENTER)

                ;  Create the angel base.
                ;
                wViewBase = WIDGET_BASE(wLeftBase, /COLUMN)

                    ;  Create the angel base.
                    ;
                    wAngleBase = WIDGET_BASE(wViewBase, $
                        /BASE_ALIGN_LEFT, /COLUMN)

                        ;  Create the number of angles droplist.
                        ;
                        wAnglesLabel = WIDGET_LABEL(wAngleBase, $
                            VALUE='Number of angles :')

                        ;  Droplist to select the nuimber of angles.
                        ;
                        wAngleButton = WIDGET_DROPLIST(wAngleBase, $
                            VALUE= ['4','8','16','32','64','128','256'])

                ;  Create the filter base.
                ;
                wFilterBase = WIDGET_BASE(wLeftBase, /COLUMN, /FRAME)

                    ;  Create the number of angles droplist.
                    ;
                    wFilterLabel = WIDGET_LABEL(wFilterBase, $
                        /ALIGN_CENTER, $
                        VALUE='Filter')

                    ;  Create the sub base of filter base.
                    ;
                    wSubFilterBase = WIDGET_BASE(wFilterBase, $
                    /BASE_ALIGN_LEFT,  /COLUMN)

                        ;  Create the filter type label.
                        ;
                        wTypeLabel = WIDGET_LABEL(wSubFilterBase, $
                            VALUE='Type :')

                        ;  Droplist to select the filter type.
                        ;
                        wFilterButton = WIDGET_DROPLIST(wSubFilterBase, $
                            VALUE=filters)

                        ;  Create the kernel size label.
                        ;
                        wTypeLabel = WIDGET_LABEL(wSubFilterBase, $
                            VALUE='Kernel size :')

                        ;  Droplist to select the kernel size.
                        ;
                        wKernelButton = WIDGET_DROPLIST(wSubFilterBase, $
                            VALUE=['3','5','9','17','33','65'])

                        ;  Create the interpolation label.
                        ;
                        wInterpolationLabel = WIDGET_LABEL(wSubFilterBase, $
                            VALUE='Interpolation :')

                        ;  Droplist to select the interpolation method.
                        ;
                        wInterpButton = WIDGET_DROPLIST(wSubFilterBase, $
                            VALUE=['Nearest Neighbor','Linear'])


                ;  Create the reconstruct button.
                ;
                wReconstructButton = WIDGET_BUTTON(wLeftBase, $
                    VALUE='Reconstruct', /NO_RELEASE)

            ;  Create the base that has options and functionality buttons.
            ;
            wRightBase = WIDGET_BASE(wSubBase, /COLUMN)

                wRow1Base = WIDGET_BASE(wRightBase, /ROW) ;2 x 2 bases
                    temp = LONARR(4)
                    labels = LONARR(4)

                    for i=0,1 do temp[i] = WIDGET_BASE(wRow1Base, /COLUMN)

                wRow2Base = WIDGET_BASE(wRightBase, /ROW)

                    for i=2,3 do temp[i] = WIDGET_BASE(wRow2Base, /COLUMN)

                    for i=0,3 do begin
                        labels[i] = WIDGET_LABEL(temp[i], $
                            /ALIGN_LEFT, $
                            /DYNAMIC_RESIZE, $
                            VALUE=STRING(lnames[i], FORMAT='(a34)'))

                        draw[i] = WIDGET_DRAW(temp[i], /BUTTON, $
                            RETAIN=2, $
                            XSIZE=imageSize, YSIZE=imageSize)
                    endfor

                    for i=0,3 do WIDGET_CONTROL, labels[i], SET_VALUE=lnames[i]

        ;  Create the status line label.
        ;
        wStatusBase = WIDGET_BASE(base, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, base, /REALIZE

    WIDGET_CONTROL, wAngleButton, SET_DROPLIST_SELECT=3
    WIDGET_CONTROL, wFilterButton, SET_DROPLIST_SELECT=filter
    WIDGET_CONTROL, wKernelButton, SET_DROPLIST_SELECT=3
    WIDGET_CONTROL, wInterpButton, SET_DROPLIST_SELECT=1

    ;  Make the angle and filter base the same x dimension.
    ;
    szAngle = WIDGET_INFO(wAngleBase, /GEOMETRY)
    szFilter = WIDGET_INFO(wSubFilterBase, /GEOMETRY)
    xAngle = szAngle.scr_xsize + ( 2* szAngle.margin)
    xFilter = szFilter.scr_xsize + ( 2* szFilter.margin)
    if (xAngle LT xFilter) then begin
        WIDGET_CONTROL, wAngleBase, SCR_XSIZE=xFilter
    endif else begin
        WIDGET_CONTROL, wFilterBase, SCR_XSIZE=xAngle
    endelse

    ; Returns the top level base to the APPTLB keyword.
    ;
    appTLB = base

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('reconstr.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         base, $
                         wStatusBase)

    ;  Get the windows (drawing areas) identifiers.
    ;
    for i=0,3 do begin
        WIDGET_CONTROL, draw[i], GET_VALUE=j
        window[i] = j
    endfor
    top = !D.TABLE_SIZE-6

    ;  Load the grey scale colr table.
    ;
    LOADCT, 0, /SILENT, NCOLORS=top+1

    ;  Allocate working colors : red, green, yellow, blue, white.
    ;
    TVLCT, [255,0,255,0,255],[0,255,255,0,255],[0,0,0,255,255], top+1

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, base, MAP=1

    ;  Load the CT scan image as default.
    ;
    originalImage = d_reconstrMakePhantom(imageSize, object)
    maxa = max(originalImage, MIN=mina)
    WSET, window[0]
    TV, BYTSCL(originalImage, TOP=top, MAX=maxa, MIN=mina)

    ;  Assign an initial value to drawErrorID.
    ;
    drawErrorID = -1L
    errorBase = -1L

    ;  Create the info structure.
    ;
    info = { $
        ColorTable: colorTable, $
        groupBase: groupBase $                        ; Base of Group Leader
    }

    ;  Assign the info structure into the user value of the top level base.
    ;
    WIDGET_CONTROL, base, SET_UVALUE=info, /NO_COPY

    WIDGET_CONTROL, base, /HOURGLASS
    d_reconstrReconstructIt
    ReconstructFlag = 1

    XMANAGER, 'd_reconstr', base, CLEANUP='d_reconstrCleanup',  $
        Event_Handler='d_reconstrEvent', /NO_BLOCK
end
