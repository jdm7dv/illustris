; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_imagproc.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_imagproc.pro
;
;  CALLING SEQUENCE: d_imagproc
;
;  PURPOSE:
;       Demonstrate a few of IDL's image processing features:
;       Fourier filtering, pixel scaling, pixel distribution
;       (histogram), edge enhancement, dilate & erode,
;       convolution, and zooming.
;
;  MAJOR TOPICS: Image processing and widgets
;
;  CATEGORY:
;       IDL Demo System
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:  Written by:  DC, RSI,  1995
;                         Modified by DAT,RSI,  December 1996
;                         Combining tour elements 203, 280 to 284
;-
;--------------------------------------------------------------------


; Copyright (c) 1995-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
; NAME:
;       d_imagprocLPF_ALL
;
; PURPOSE:
;       This function performs Low Pass Filtering (smoothing) on one,
;       two, and three dimensional arrays.   This function is similar
;       to the "Smooth" function except that it smoothes ALL the array
;       elements (even at the edges of the array).   The "Smooth" function
;       does NOT smooth array elements that are within band/2 of any edge
;       of the array (where band is the width of the smoothing window).
;       When smoothing a two dimensional array, d_imagprocLPF_ALL can
;       optionally smooth in one of three ways : rectangular, cylindrical, and
;       spherical.   When smoothing a one dimensional array, d_imagprocLPF_ALL
;       can smooth in either linear or circular mode.
;
; CATEGORY:
;       Filtering.
;
; CALLING SEQUENCE:
;       lpf_array = d_imagprocLPF_ALL(Array, Band)
;
; INPUTS:
;       Array:      The array to smooth.
;                   Data type : Any one, two, or three dimensional array
;                   except string or structure.
;       Band:       The width of the smoothing window.
;                   Data type : Int
;
; KEYWORD PARAMETERS:
;       Wrap_Mode:  The smoothing mode.   If Array has three dimensions,
;                   then Wrap_Mode is ignored.   If Array has two dimensions,
;                   then specify Wrap_Mode=0 for rectangular smoothing,
;                   Wrap_Mode=1 for cylindrical smoothing, and Wrap_Mode=2
;                   for spherical smoothing.   In the cylindrical and
;                   spherical cases, smoothing is performed across the first
;                   and last columns of Array.   In the spherical case,
;                   smoothing is also performed across all the elements in the
;                   top row, and across all the elements in the bottom row.
;                   If Array has one dimension, then specify Wrap_Mode=0 for
;                   linear smoothing, and Wrap_mode=1 for circular smoothing.
;                   In the circular case, smoothing is performed across the
;                   first and last elements in Array.   The default is zero.
;
; OUTPUTS:
;       Lpf_Array:  The low pass filtered array.
;                   Data type : Same as input Array.
;
; PROCEDURE :
;       This function smoothes the edges of the array by extrapolating the
;       values at the edges of the array to a distance of band/2.
;
; EXAMPLE:
;       Smooth a two dimensional array in spherical mode.
;
;          ; *** Create data to smooth.
;          array = REBIN(RANDOMU(s, 8, 8), 512, 512)
;          ; *** Smooth the array in spherical mode.
;          lpf_array = d_imagprocLPF_ALL(array, 64, Wrap_Mode=2)
;
; MODIFICATION HISTORY:
;       Written by:     Daniel Carr. Mon Aug 23 12:46:31 MDT 1993
;-

FUNCTION d_imagprocLPF_ALL, array, band, Wrap_Mode=wrap_mode

lpf_band = LONG(band[0])

IF (N_Elements(wrap_mode) LE 0L) THEN wrap_mode = 0

size_arr = SIZE(array)

CASE (size_arr[0]) OF
   1L: BEGIN ; *** One dimensional array.
      lpf_array = array
      arr_x = size_arr[1]
      arr_xm1 = arr_x - 1L
      lpf_band = lpf_band < (size_arr[1] - 1L)

      wide = lpf_band / 2L
      wide2 = wide * 2L
      wide3 = wide * 3L
      widep1 = wide + 1L
      widem1 = wide - 1L
      wide2p1 = wide2 + 1L
      wide2m1 = wide2 - 1L
      wide3p1 = wide3 + 1L
      wide3m1 = wide3 - 1L

      wrap_mode = (wrap_mode > 0) < 1
      CASE (wrap_mode) OF
         0: BEGIN ; *** Regular (linear) smoothing.
            IF (lpf_band GE 2L) THEN BEGIN
               edge_l = Fltarr(wide3, /Nozero)
               edge_r = Fltarr(wide3, /Nozero)

               edge_l[0:widem1] = lpf_array[0]
               edge_l[wide:*] = lpf_array[0:wide2m1]

               edge_r[0:wide2m1] = lpf_array[(arr_x-wide2):*]
               edge_r[wide2:*] = lpf_array[arr_xm1]

               edge_l = (SMOOTH(edge_l, lpf_band))[wide:wide2m1]
               edge_r = (SMOOTH(edge_r, lpf_band))[wide:wide2m1]

               lpf_array = SMOOTH(lpf_array, lpf_band)

               lpf_array[0:widem1] = Temporary(edge_l)
               lpf_array[(arr_x-wide):*] = Temporary(edge_r)
            ENDIF
         END

         1: BEGIN ; *** Circular smoothing.
            IF (lpf_band GE 2L) THEN BEGIN
               edge_l = Fltarr(wide3, /Nozero)
               edge_r = Fltarr(wide3, /Nozero)

               edge_l[0:widem1] = lpf_array[(arr_x-wide):*]
               edge_l[wide:*] = lpf_array[0:wide2m1]

               edge_r[0:wide2m1] = lpf_array[(arr_x-wide2):*]
               edge_r[wide2:*] = lpf_array[0:widem1]

               edge_l = (SMOOTH(edge_l, lpf_band))[wide:wide2m1]
               edge_r = (SMOOTH(edge_r, lpf_band))[wide:wide2m1]

               lpf_array = SMOOTH(lpf_array, lpf_band)

               lpf_array[0:widem1] = Temporary(edge_l)
               lpf_array[(arr_x-wide):*] = Temporary(edge_r)
            ENDIF
         END
      ENDCASE
   END

   2L: BEGIN ; *** Two dimensional array.
      lpf_array = array
      arr_x = size_arr[1]
      arr_y = size_arr[2]
      arr_xm1 = arr_x - 1L
      arr_ym1 = arr_y - 1L
      lpf_band = lpf_band < (MIN(size_arr[1:2]) - 1L)
      f_arr_x = FLOAT(arr_x)

      wide = lpf_band / 2L
      wide2 = wide * 2L
      wide3 = wide * 3L
      widep1 = wide + 1L
      widem1 = wide - 1L
      wide2p1 = wide2 + 1L
      wide2m1 = wide2 - 1L
      wide3p1 = wide3 + 1L
      wide3m1 = wide3 - 1L
      rep_wide = Replicate(1.0, (wide>1L))

      wrap_mode = (wrap_mode > 0) < 2
      CASE (wrap_mode) OF
         0: BEGIN ; *** Regular (rectangular) smoothing.
            IF (lpf_band GE 2L) THEN BEGIN
               edge_l = Fltarr(wide3, (arr_y + wide2), /Nozero)
               edge_r = Fltarr(wide3, (arr_y + wide2), /Nozero)
               edge_b = Fltarr(arr_x, wide3, /Nozero)
               edge_t = Fltarr(arr_x, wide3, /Nozero)

               edge_l[0:widem1, wide:arr_y+widem1] = rep_wide # lpf_array[0, *]
               edge_l[wide:*, wide:arr_y+widem1] = lpf_array[0:wide2m1, *]
               edge_l[*, 0:widem1] = edge_l[*, wide] # rep_wide
               edge_l[*, arr_y+wide:*] = edge_l[*, arr_y+widem1] # rep_wide

               edge_r[0:wide2m1, wide:arr_y+widem1] = $
                  lpf_array[arr_x-wide2:*, *]
               edge_r[wide2:*, wide:arr_y+widem1] = $
                  rep_wide # lpf_array[arr_xm1, *]
               edge_r[*, 0:widem1] = edge_r[*, wide] # rep_wide
               edge_r[*, arr_y+wide:*] = edge_r[*, arr_y+widem1] # rep_wide

               edge_b[*, wide:wide3m1] = lpf_array[*, 0:wide2m1]
               edge_b[*, 0:widem1] = edge_b[*, wide] # rep_wide

               edge_t[*, 0:wide2m1] = lpf_array[*, arr_y-wide2:*]
               edge_t[*, wide2:*] = edge_t[*, wide2m1] # rep_wide

               edge_l = (SMOOTH(edge_l, lpf_band))[ $
                                wide:wide2m1, wide:arr_y+widem1]
               edge_r = (SMOOTH(edge_r, lpf_band))[ $
                                wide:wide2m1, wide:arr_y+widem1]
               edge_b = (SMOOTH(edge_b, lpf_band))[ $
                                wide:arr_x-widep1, wide:wide2m1]
               edge_t = (SMOOTH(edge_t, lpf_band))[ $
                                wide:arr_x-widep1, wide:wide2m1]

               lpf_array = SMOOTH(lpf_array, lpf_band)

               lpf_array[0:widem1, *] = Temporary(edge_l)
               lpf_array[arr_x-wide:*, *] = Temporary(edge_r)
               lpf_array[wide:arr_x-widep1, 0:widem1] = Temporary(edge_b)
               lpf_array[wide:arr_x-widep1, arr_y-wide:*] = Temporary(edge_t)
            ENDIF
         END

         1: BEGIN ; *** Cylindrical smoothing.
            col_array1 = (lpf_array[0, *] + lpf_array[1, *] + $
                          lpf_array[arr_xm1, *]) / 3.0
            col_array2 = (lpf_array[0, *] + lpf_array[arr_xm1-1L, *] + $
                          lpf_array[arr_xm1, *]) / 3.0
            lpf_array[0, *] = Temporary(col_array1)
            lpf_array[arr_xm1, *] = Temporary(col_array2)

            IF (lpf_band GE 2) THEN BEGIN
               edge_l = Fltarr(wide3, (arr_y + wide2), /Nozero)
               edge_r = Fltarr(wide3, (arr_y + wide2), /Nozero)
               edge_b = Fltarr(arr_x, wide3, /Nozero)
               edge_t = Fltarr(arr_x, wide3, /Nozero)

               edge_l[0:widem1, wide:arr_y+widem1] = lpf_array[arr_x-wide:*, *]
               edge_l[wide:*, wide:arr_y+widem1] = lpf_array[0:wide2m1, *]
               edge_l[*, 0:widem1] = edge_l[*, wide] # rep_wide
               edge_l[*, arr_y+wide:*] = edge_l[*, arr_y+widem1] # rep_wide

               edge_r[0:wide2m1, wide:arr_y+widem1] = $
                  lpf_array[arr_x-wide2:*, *]
               edge_r[wide2:*, wide:arr_y+widem1] = $
                  lpf_array[0:widem1, *]
               edge_r[*, 0:widem1] = edge_r[*, wide] # rep_wide
               edge_r[*, arr_y+wide:*] = edge_r[*, arr_y+widem1] # rep_wide

               edge_b[*, wide:wide3m1] = lpf_array[*, 0:wide2m1]
               edge_b[*, 0:widem1] = edge_b[*, wide] # rep_wide

               edge_t[*, 0:wide2m1] = lpf_array[*, arr_y-wide2:*]
               edge_t[*, wide2:*] = edge_t[*, wide2m1] # rep_wide

               edge_l = (SMOOTH(edge_l, lpf_band))[ $
                                wide:wide2m1, wide:arr_y+widem1]
               edge_r = (SMOOTH(edge_r, lpf_band))[ $
                                wide:wide2m1, wide:arr_y+widem1]
               edge_b = (SMOOTH(edge_b, lpf_band))[ $
                                wide:arr_x-widep1, wide:wide2m1]
               edge_t = (SMOOTH(edge_t, lpf_band))[ $
                                wide:arr_x-widep1, wide:wide2m1]

               lpf_array = SMOOTH(lpf_array, lpf_band)

               lpf_array[0:widem1, *] = Temporary(edge_l)
               lpf_array[arr_x-wide:*, *] = Temporary(edge_r)
               lpf_array[wide:arr_x-widep1, 0:widem1] = Temporary(edge_b)
               lpf_array[wide:arr_x-widep1, arr_y-wide:*] = Temporary(edge_t)

               col_array = (lpf_array[0, *] + lpf_array[arr_xm1, *]) / 2.0
               lpf_array[0, *] = col_array
               lpf_array[arr_xm1, *] = Temporary(col_array)
            ENDIF
         END

         2: BEGIN ; *** Spherical smoothing.
            col_array = (lpf_array[0, *] + lpf_array[arr_xm1, *]) / 2.0
            lpf_array[0, *] = col_array
            lpf_array[arr_xm1, *] = Temporary(col_array)

            lpf_array[*, 0] = TOTAL(lpf_array[*, 0]) / f_arr_x
            lpf_array[*, arr_ym1] = TOTAL(lpf_array[*, arr_ym1]) / f_arr_x

            xwide = $
               COS((!PI * 2.0 * (Findgen(arr_y) / Float(arr_y-1L))) + !PI) + 1.0
            xwide = ((xwide^(0.5) * f_arr_x) > 1.0)
            xsize = CEIL(f_arr_x / xwide)
            xwide = LONG(xwide)
            xsize = xsize * xwide

            arr_xh = arr_x / 2L
            arr_x2 = arr_x * 2L
            arr_xf = arr_x + arr_xh - 1L
            FOR yy=1L, (arr_y-2L) DO BEGIN
               row_arr = SHIFT([REFORM(lpf_array[*, yy]), $
                                REFORM(lpf_array[*, yy])], arr_xh)
               row_arr = $
                  CONGRID(REBIN(CONGRID(row_arr, xsize[yy], $
                  /Interp, /Minus_One), xwide[yy]), arr_x2, $
                  /Interp, /Minus_One)
               lpf_array[0, yy] = row_arr[arr_xh:arr_xf]
            ENDFOR
            row_arr = 0

            xwide = 0
            xsize = 0

            col_array1 = (lpf_array[0, *] + lpf_array[1, *] + $
                          lpf_array[arr_xm1, *]) / 3.0
            col_array2 = (lpf_array[0, *] + lpf_array[arr_xm1-1L, *] + $
                          lpf_array[arr_xm1, *]) / 3.0
            lpf_array[0, *] = Temporary(col_array1)
            lpf_array[arr_xm1, *] = Temporary(col_array2)

            IF (lpf_band GE 2) THEN BEGIN
               edge_l = Fltarr(wide3, (arr_y + wide2), /Nozero)
               edge_r = Fltarr(wide3, (arr_y + wide2), /Nozero)
               edge_b = Fltarr(arr_x, wide3, /Nozero)
               edge_t = Fltarr(arr_x, wide3, /Nozero)

               edge_l[0:widem1, wide:arr_y+widem1] = lpf_array[arr_x-wide:*, *]
               edge_l[wide:*, wide:arr_y+widem1] = lpf_array[0:wide2m1, *]
               edge_l[*, 0:widem1] = edge_l[*, wide] # rep_wide
               edge_l[*, arr_y+wide:*] = edge_l[*, arr_y+widem1] # rep_wide

               edge_r[0:wide2m1, wide:arr_y+widem1] = $
                  lpf_array[arr_x-wide2:*, *]
               edge_r[wide2:*, wide:arr_y+widem1] = $
                  lpf_array[0:widem1, *]
               edge_r[*, 0:widem1] = edge_r[*, wide] # rep_wide
               edge_r[*, arr_y+wide:*] = edge_r[*, arr_y+widem1] # rep_wide

               edge_b[*, wide:wide3m1] = lpf_array[*, 0:wide2m1]
               edge_b[*, 0:widem1] = edge_b[*, wide] # rep_wide

               edge_t[*, 0:wide2m1] = lpf_array[*, arr_y-wide2:*]
               edge_t[*, wide2:*] = edge_t[*, wide2m1] # rep_wide

               edge_l = (SMOOTH(edge_l, lpf_band))[ $
                                wide:wide2m1, wide:arr_y+widem1]
               edge_r = (SMOOTH(edge_r, lpf_band))[ $
                                wide:wide2m1, wide:arr_y+widem1]
               edge_b = (SMOOTH(edge_b, lpf_band))[ $
                                wide:arr_x-widep1, wide:wide2m1]
               edge_t = (SMOOTH(edge_t, lpf_band))[ $
                                wide:arr_x-widep1, wide:wide2m1]

               lpf_array = SMOOTH(lpf_array, lpf_band)

               lpf_array[0:widem1, *] = Temporary(edge_l)
               lpf_array[arr_x-wide:*, *] = Temporary(edge_r)
               lpf_array[wide:arr_x-widep1, 0:widem1] = Temporary(edge_b)
               lpf_array[wide:arr_x-widep1, arr_y-wide:*] = Temporary(edge_t)

               col_array = (lpf_array[0, *] + lpf_array[arr_xm1, *]) / 2.0
               lpf_array[0, *] = col_array
               lpf_array[arr_xm1, *] = Temporary(col_array)
            ENDIF

            lpf_array[0, 0] = TOTAL(lpf_array[*, 0]) / f_arr_x
            lpf_array[0, arr_ym1] = TOTAL(lpf_array[*, arr_ym1]) / f_arr_x
         END
      ENDCASE
      rep_wide = 0
   END

   3L: BEGIN ; *** Three dimensional array.
      IF (lpf_band GE 2) THEN BEGIN
         arr_x = size_arr[1]
         arr_y = size_arr[2]
         arr_z = size_arr[3]
         arr_xm1 = arr_x - 1L
         arr_ym1 = arr_y - 1L
         arr_zm1 = arr_z - 1L

         wide = lpf_band / 2L
         wide2 = wide * 2L
         widem1 = wide - 1L

         CASE (size_arr[size_arr[0]+1L]) OF
            0: RETURN, lpf_array
            1: lpf_array = $
                  Bytarr((arr_x+wide2), (arr_y+wide2), (arr_z+wide2), /Nozero)
            2: lpf_array = $
                  Intarr((arr_x+wide2), (arr_y+wide2), (arr_z+wide2), /Nozero)
            3: lpf_array = $
                  Lonarr((arr_x+wide2), (arr_y+wide2), (arr_z+wide2), /Nozero)
            4: lpf_array = $
                  Fltarr((arr_x+wide2), (arr_y+wide2), (arr_z+wide2), /Nozero)
            5: lpf_array = $
                  Dblarr((arr_x+wide2), (arr_y+wide2), (arr_z+wide2), /Nozero)
            6: lpf_array = $
                  Complexarr((arr_x+wide2), (arr_y+wide2), (arr_z+wide2), $
                     /Nozero)
            7: RETURN, lpf_array
            8: RETURN, lpf_array
         ENDCASE
         wide_x = arr_xm1 + wide
         wide_y = arr_ym1 + wide
         wide_z = arr_zm1 + wide

         lpf_array[wide:wide_x, wide:wide_y, wide:wide_z] = array

         FOR i=0L, widem1 DO $
            lpf_array[wide:wide_x, wide:wide_y, i] = array[*, *, 0L]
         FOR i=(arr_z+wide), (arr_zm1+wide2) DO $
            lpf_array[wide:wide_x, wide:wide_y, i] = array[*, *, arr_zm1]

         FOR i=0L, widem1 DO $
            lpf_array[wide:wide_x, i, *] = lpf_array[wide:wide_x, wide, *]
         FOR i=(arr_y+wide), (arr_ym1+wide2) DO $
            lpf_array[wide:wide_x, i, *] = lpf_array[wide:wide_x, wide_y, *]

         FOR i=0L, widem1 DO $
            lpf_array[i, *, *] = lpf_array[wide, *, *]
         FOR i=(arr_x+wide), (arr_xm1+wide2) DO $
            lpf_array[i, *, *] = lpf_array[wide_x, *, *]

         ; *** Smooth the "enlarged" array.
         lpf_array = SMOOTH(lpf_array, lpf_band)

         ; *** Extract the center of the smoothed array.
         lpf_array = lpf_array[wide:wide_x, wide:wide_y, wide:wide_z]
      ENDIF ELSE BEGIN
         RETURN, array
      ENDELSE
   END

   ELSE:
ENDCASE

RETURN, lpf_array
END



;
;  Purpose:  do the Zooming demo
;
pro d_imagprocMakeZooming, $
    drawXSize, $       ; IN: x dimension of drawing area
    drawYSize, $       ; IN: y dimension of drawing area
    pixmapID, $        ; IN: working pixmap
    drawWindowID, $    ; IN: viewing window
    highColor, $       ; IN: maximun index of the color table
    ZoomStr            ; OUT: structure for zooming (7 items)

    LOADCT, 0, /SILENT
    TEK_COLOR, highColor+1, 16

    nyc_img = BYTARR(768, 512, /Nozero)
    GET_LUN, data_lun
    OPENR, data_lun, demo_filepath('nyny.dat', $
        SUBDIR=['examples','data'])
    READU, data_lun, nyc_img
    CLOSE, data_lun
    FREE_LUN, data_lun

    nyc_img = BYTSCL(nyc_img[0:639, *], TOP=highColor)
    WSET, pixmapID
    Erase, 0
    TV, nyc_img
    WSET, drawWindowID
    Erase
    DEVICE, COPY=[0, 0, drawXSize, drawYSize, 0, 0, pixmapID]
    Empty

    win_size = 64
    win_zoom = 192

    xpos = 195
    ypos = 185

    win_size_h = win_size / 2
    win_zoom_h = win_zoom / 2

    xpos = (xpos > win_size_h) < ((drawXSize - win_size_h) - 1)
    ypos = (ypos > win_size_h) < ((drawYSize - win_size_h) - 1)

    img_x = xpos - win_zoom_h
    img_y = ypos - win_zoom_h

    box_x = [0, win_zoom, win_zoom, 0, 0]
    box_y = [0, 0, win_zoom, win_zoom, 0]

    sub_x = xpos - win_size_h
    sub_y = ypos - win_size_h

    zoom_img = REBIN(nyc_img[(sub_x):(sub_x+win_size-1), $
        (sub_y):(sub_y+win_size-1)], $
        win_zoom, win_zoom)

    TV, zoom_img, img_x, img_y
    PLOTS, box_x+img_x, box_y+img_y, $
        /DEVICE, THICK=3, COLOR=highColor+3
    Empty

    ZoomStr = { $
        Win_Size_h: win_Size_h, $
        Win_Size: win_Size, $
        Win_Zoom_h: win_Zoom_h, $
        Win_Zoom: win_Zoom, $
        Nyc_img: nyc_img, $
        Box_x: box_x, $
        Box_y: box_y $
    }

end      ;  of d_imagprocMakeZooming


;--------------------------------------------------------------------
;
;  Purpose:  Create the filter top 2 images(original image, power spectrum)
;
pro d_imagprocMakeFilter, $
    drawXSize, $       ; IN: x dimension of drawing area
    drawYSize, $       ; IN: y dimension of drawing area
    highColor, $       ; IN: maximun index of the color table
    frequencyImage     ; OUT: frequency image (needed by doFilterSlider)

    previousFont = !P.FONT
    !P.FONT = 0

    tmp_img = BYTARR(768, 512, /Nozero)
    GET_LUN, data_lun
    OPENR, data_lun, demo_filepath('nyny.dat', $
        SUBDIR=['examples','data'])
    READU, data_lun, tmp_img
    o_img = tmp_img[165:228, 150:213]
    CLOSE, data_lun
    FREE_LUN, data_lun

    img_x = 256
    img_y = 256
    max_y = drawYSize / 2
    y_text = 8 + !D.Y_Ch_Size

    img = BYTSCL(REBIN(o_img, img_x, img_y), TOP=highColor)

    if (max_y LT img_y) then begin
       y_diff = (img_y - max_y) / 2
       img = img[*, y_diff:(img_y - (y_diff + 1))]
    endif

    img_pos_x = (drawXSize / 2) - img_x
    img_pos_y = (drawYSize / 2)
    Erase, 0
    TV, img, img_pos_x, img_pos_y

    XYOUTS, img_pos_x+8, img_pos_y+(max_y-y_text), 'Original Image', $
       COLOR=highColor+2, /Device
    Empty

    freq_img = FFT(Temporary(o_img), 1)
    img = REBIN(Shift(BYTSCL(Alog(Abs(freq_img)), TOP=highColor), $
            32, 32), img_x, img_y)

    if (max_y LT img_y) then begin
       y_diff = (img_y - max_y) / 2
       img = img[*, y_diff:(img_y - (y_diff + 1))]
    endif

    img_pos_x = (drawXSize / 2) + 1
    img_pos_y = (drawYSize / 2)

    TV, img, img_pos_x, img_pos_y
    XYOUTS, img_pos_x+8, img_pos_y+(max_y-y_text), 'Power Spectrum', $
       COLOR=highColor+2, /Device
    Empty

    filterWidth = 8
    frequencyImage = freq_img
    d_imagprocDoFilterSlider, drawXSize, drawYSize, highColor, $
         frequencyImage, filterWidth

    !P.Font = previousFont
end     ;  of d_imagprocMakeFilter


;--------------------------------------------------------------------
;
;  Purpose:  Create the filter bottom 2 images
;            (Low pass filter, high pas filter)
;
pro d_imagprocDoFilterSlider, $
    drawXSize, $       ; IN: x dimension of drawing area
    drawYSize, $       ; IN: y dimension of drawing area
    highColor, $       ; IN: maximun index of the color table
    freq_img, $        ; IN: frequency image (needed by doFilterSlider)
    width              ; IN: filter width (slide value)

    previousFont = !P.FONT
    !P.FONT = 0

    img_x = 256
    img_y = 256
    max_y = drawYSize / 2
    y_text = 8 + !D.Y_Ch_Size

    freq = Dist(64)
    filter = 1.0 / (1.0 + (freq / Float(width))^2)
    img = REBIN(BYTSCL(FFT((filter * freq_img), (-1)), TOP=highColor), $
            img_x, img_y)

    if (max_y LT img_y) then begin
       y_diff = (img_y - max_y) / 2
       img = img[*, y_diff:(img_y - (y_diff + 1))]
    endif

    img_pos_x = (drawXSize / 2) - img_x
    img_pos_y = (drawYSize / 2) - (max_y + 1)
    TV, img, img_pos_x, img_pos_y

    XYOUTS, img_pos_x+8, img_pos_y+(max_y-y_text), 'Low Pass Filtered', $
       COLOR=highColor+2, /Device
    Empty

    filter = 1.0 - (1.0 / (1.0 + (freq / (2.0 * Float(width)))^2))
    img = REBIN(BYTSCL(FFT((filter * freq_img), (-1)), TOP=highColor), $
            img_x, img_y)

    if (max_y LT img_y) then begin
       y_diff = (img_y - max_y) / 2
       img = img[*, y_diff:(img_y - (y_diff + 1))]
    endif

    img_pos_x = (drawXSize / 2) + 1
    img_pos_y = (drawYSize / 2) - (max_y + 1)
    TV, img, img_pos_x, img_pos_y
    XYOUTS, img_pos_x+8, img_pos_y+(max_y-y_text), 'High Pass Filtered', $
       COLOR=highColor+2, /Device
    Empty

    !P.FONT = previousFont

end      ;   of d_imagprocDoFilterSlider

;--------------------------------------------------------------------
;
;  Purpose:  Do the pixel scaling
;
pro d_imagprocMakeScaling, $
    drawXSize, $          ; IN: x dimension of drawing area
    drawYSize, $          ; IN: y dimension of drawing area
    highColor, $          ; IN: maximun index of the color table
    wMinScalingSlider, $  ; IN: minimum scaling slider ID
    wMaxScalingSlider,$   ; IN: maximum scaling slider ID
    ImagePositionX, $     ; OUT: scaled image x position
    ImagePositionY, $     ; OUT: scaled image x position
    scalingImage          ; OUT: scaling image

    previousFont = !P.FONT
    !P.FONT = 0

    LOADCT, 0, /SILENT
    TEK_COLOR, highColor+1, 16

    img = BYTARR(768, 200, /Nozero)
    GET_LUN, data_lun
    OPENR, data_lun, demo_filepath('nyny.dat', $
        SUBDIR=['examples','data'])
    READU, data_lun, img
    CLOSE, data_lun
    FREE_LUN, data_lun
    img = img[0:255, *]

    img_pos_x = (drawXSize / 4) - 128
    img_pos_y = (drawYSize / 2) - 100
    Erase, 0
    TV, (img<highColor), img_pos_x, img_pos_y
    XYOUTS, img_pos_x+128, img_pos_y+212, $
        'Original Image', COLOR=highColor+4, /DEVICE, $
        Alignment=0.5
    Empty

    img_pos_x = ((3 * drawXSize) / 4) - 128

    min_img = MIN(img, MAX=max_img)
    min_val = 115
    max_val = 178
    WIDGET_CONTROL, wMinScalingSlider, $
        SET_VALUE=min_val, SET_SLIDER_MIN=(min_img-2)>0, $
        SET_SLIDER_MAX=(max_img-2)>1
    WIDGET_CONTROL, wMaxScalingSlider,  $
        SET_VALUE=max_val, SET_SLIDER_MIN=(min_img+2)<254, $
        SET_SLIDER_MAX=(max_img+2)<255

    img_b = BYTSCL(img, MIN=min_img, MAX=max_img, TOP=highColor)
    TV, img_b, img_pos_x, img_pos_y
    Empty

    XYOUTS, img_pos_x+128, img_pos_y+212, $
        'Byte Scaled Image', COLOR=highColor+4, $
        /DEVICE, Alignment=0.5
    Empty
    scalingImage = img
    imagePositionX = img_pos_x
    imagePositionY = img_pos_y

    !P.FONT = previousFont
end      ;   of d_imagprocMakeScaling


;--------------------------------------------------------------------
;
;  Purpose:  Do the histogram distribution
;
pro d_imagprocMakeHistogram, $
    drawXSize, $          ; IN: x dimension of drawing area
    drawYSize, $          ; IN: y dimension of drawing area
    highColor, $          ; IN: maximun index of the color table
    wMinHistogramSlider, $  ; IN: minimum scaling slider ID
    wMaxHistogramSlider,$   ; IN: maximum scaling slider ID
    ImagePositionX, $     ; OUT: scaled image x position
    ImagePositionY, $     ; OUT: scaled image x position
    scalingImage          ; OUT: scaling image

    previousFont = !P.FONT
    !P.FONT = 0

    LOADCT, 0, /SILENT
    TEK_COLOR, highColor+1, 16

    img = BYTARR(768, 200, /Nozero)
    GET_LUN, data_lun
    OPENR, data_lun, demo_filepath('nyny.dat', $
        SUBDIR=['examples','data'])
    READU, data_lun, img
    CLOSE, data_lun
    FREE_LUN, data_lun
    img = BYTSCL(img[0:255, *], TOP=highColor)

    PLOT, Histogram(img), COLOR=highColor+4, $
        TICKLEN=(-0.02), XRANGE=[0, highColor], $
        POSITION=[0.15, 0.6, 0.50, 0.925], $
        BACKGROUND=0, $
        TITLE='Original Histogram', $
        XSTYLE=1
    Empty

    img_pos_x = (drawXSize / 2) + 32
    img_pos_y = ((3 * drawYSize) / 4) - 100
    TV, img, img_pos_x, img_pos_y
    Empty

    min_img = MIN(img, MAX=max_img)

    WIDGET_CONTROL, wMinHistogramSlider, $
        SET_VALUE=min_img, $
        SET_SLIDER_MIN=(min_img-2)>0, $
        SET_SLIDER_MAX=(max_img-2)>1

    WIDGET_CONTROL, wMaxHistogramSlider, $
        SET_VALUE=max_img, $
        SET_SLIDER_MIN=(min_img+2)<254, $
        SET_SLIDER_MAX=(max_img+2)<255

    scalingImage = img

    !P.FONT = previousFont

    d_imagprocDrawHistogram, $
        drawXSize, drawYSize, highColor, min_img, max_img, $
        img, imagePositionX, imagePositionY

end      ;   of d_imagprocMakeHistogram

;--------------------------------------------------------------------
;
;  Purpose:  Draw the bottomportion of the histogram demo
;
pro d_imagprocDrawHistogram, $
    drawXSize, $          ; IN: x dimension of drawing area
    drawYSize, $          ; IN: y dimension of drawing area
    highColor, $          ; IN: maximun index of the color table
    minValue, $           ; IN: minimum color index value  allowed
    maxValue, $           ; IN: maximum color index value  allowed
    Image, $              ; IN:  image
    ImagePositionX, $     ; OUT: x positon of image
    ImagePositionY        ; OUT: y positon of image

    previousFont = !P.FONT
    !P.FONT = 0

    img1 = Hist_Equal(image, $
        Minv=minValue, Maxv=maxValue, TOP=highColor)
    POLYFILL, [0.0, 0.5, 0.5, 0.0], [0.0, 0.0, 0.5, 0.5], $
        /Normal, T3D=0, COLOR=0

    if (minValue LE 0) then begin
        PLOT, Histogram(Float(img1), MIN=minValue, MAX=maxValue), $
            COLOR=highColor+4, TICKLEN=(-0.02), /NOERASE, $
            POSITION=[0.15, 0.075, 0.50, 0.45], $
            TITLE='Histogram Equalized', $
            BACKGROUND=0, $
            XRANGE=[0, highColor], XSTYLE=1
    endif else begin
        PLOT, [Fltarr(minValue), $
            Histogram(Float(img1), MIN=minValue, MAX=maxValue)], $
            COLOR=highColor+4, TICKLEN=(-0.02), /NOERASE, $
            BACKGROUND=0, $
            POSITION=[0.15, 0.075, 0.50, 0.45], $
            TITLE='Histogram Equalized', XRANGE=[0, highColor], XSTYLE=1
    endelse
    Empty

    img_pos_x = (drawXSize / 2) + 32
    img_pos_y = (drawYSize / 4) - 100
    TV, img1, img_pos_x, img_pos_y
    Empty
    imagePositionX = img_pos_x
    imagePositionY = img_pos_y

    !P.FONT = previousFont

end      ;   of d_imagprocDrawHistogram


;--------------------------------------------------------------------
;
;  Purpose:  Do the edge enhancement demo
;
pro d_imagprocMakeEdge, $
    drawXSize, $          ; IN: x dimension of drawing area
    drawYSize, $          ; IN: y dimension of drawing area
    highColor, $          ; IN: maximun index of the color table
    wEdgeSlider, $        ; IN: minimum scaling slider ID
    scalingImage          ; OUT: scaling image

    previousFont = !P.FONT
    !P.FONT = 0

    LOADCT, 0, /SILENT
    TEK_COLOR, highColor+1, 16

    img = BYTARR(768, 200, /Nozero)
    GET_LUN, data_lun
    OPENR, data_lun, demo_filepath('nyny.dat', $
        SUBDIR=['examples','data'])
    READU, data_lun, img
    CLOSE, data_lun
    FREE_LUN, data_lun

    img = BYTSCL(img[0:255, *], TOP=highColor)

    img_pos_x = (drawXSize / 4) - 128
    img_pos_y = (drawYSize / 2) - 100
    Erase, 0
    TV, img, img_pos_x, img_pos_y
    XYOUTS, img_pos_x+128, img_pos_y+212, $
        'Original Image', COLOR=highColor+4, /DEVICE, $
        Alignment=0.5
    Empty

    smoothValue = 0
    WIDGET_CONTROL, wEdgeSlider, SET_VALUE=smoothValue
    d_imagprocDrawEdge, drawXSize, drawYSize, highColor, $
        smoothValue, img

    img_pos_x = ((3 * drawXSize) / 4) - 128
    XYOUTS, img_pos_x+128, img_pos_y+212, $
        'Edge Enhanced Image', COLOR=highColor+4, $
        /DEVICE, Alignment=0.5
    Empty

    scalingImage = img

    !P.FONT = previousFont

end      ;   of d_imagprocMakeEdge

;--------------------------------------------------------------------
;
;  Purpose:  Draw the smoothed edge enhanced image
;
pro d_imagprocDrawEdge, $
    drawXSize, $          ; IN: x dimension of drawing area
    drawYSize, $          ; IN: y dimension of drawing area
    highColor, $          ; IN: maximun index of the color table
    smoothValue, $        ; IN: minimum color index value  allowed
    Image                 ; IN:  image

    previousFont = !P.FONT
    !P.FONT = 0

    img_pos_x = ((3 * drawXSize) / 4) - 128
    img_pos_y = (drawYSize / 2) - 100

    img1 = BYTSCL(SOBEL(d_imagprocLPF_ALL(image, smoothValue)), TOP=highColor)
    TV, img1, img_pos_x, img_pos_y

    !P.FONT = previousFont

end   ;   of d_imagprocDrawEdge

;--------------------------------------------------------------------
;
;  Purpose:  Do the Dilate & Erode demo
;
pro d_imagprocMakeDltErd, sInfo

    previousFont = !P.FONT
    !P.FONT = 0

    LOADCT, 0, /SILENT
    TEK_COLOR, sInfo.highColor+1, 16

    x0 = 135
    xsize = 256
    y0 = 40
    ysize = 275

    if not PTR_VALID(sInfo.pImage) then begin
        img = BYTARR(768, 512, /Nozero)
        GET_LUN, data_lun
        OPENR, data_lun, demo_filepath('nyny.dat', $
            SUBDIR=['examples','data'])
        READU, data_lun, img
        CLOSE, data_lun
        FREE_LUN, data_lun
        sInfo.pImage = ptr_new( $
            BYTSCL( $
                img[x0:x0+xsize-1, y0:y0+ysize-1], $
                TOP=sInfo.highColor $
                ) $
            )
    end

    img_pos_x = (sInfo.drawXSize / 4) - xsize / 2
    img_pos_y = (sInfo.drawYSize / 2) - ysize / 2
    Erase, 0
    TV, *sInfo.pImage, img_pos_x, img_pos_y
    XYOUTS, img_pos_x + xsize / 2, img_pos_y + ysize + 12, $
        'Original Image', COLOR=sInfo.highColor+4, /DEVICE, $
        Alignment=0.5
    Empty

    WIDGET_CONTROL, sInfo.wBreakButton, SENSITIVE=1
    WIDGET_CONTROL, sInfo.wFuseButton,  SENSITIVE=0
    WIDGET_CONTROL, sInfo.wMinsButton,  SENSITIVE=0
    WIDGET_CONTROL, sInfo.wResetButton, SENSITIVE=0
    if !version.os_family eq 'Windows' then $
        WIDGET_CONTROL, sInfo.wBreakButton, /INPUT_FOCUS ; just a nicety.
    sInfo.step = 3
    d_imagprocDrawDltErd, sInfo

    Empty

    !P.FONT = previousFont

end      ;   of d_imagprocMakeEdge

;--------------------------------------------------------------------
;
;  Purpose:  Draw the dilated and eroded image
;
pro d_imagprocDrawDltErd, sInfo

    previousFont = !P.FONT
    !P.FONT = 0

    sz = size(*sInfo.pImage)
    img_pos_x = ((3 * sInfo.drawXSize) / 4) - sz[1] / 2
    img_pos_y = (sInfo.drawYSize / 2) - sz[2] / 2

    mask_color = sInfo.highColor + 12
    disk_size = 7 ; determined emperically.
    se = shift(dist(disk_size), disk_size/2, disk_size/2) le disk_size/2

    case sInfo.step of
        3 : begin

            ;  Make and display threshold mask..
            ;
            threshold = ceil(.27 * sInfo.highColor) ; determined empirically.
            ptr_free, sInfo.pMask
            sInfo.pMask = ptr_new(*sInfo.pImage lt threshold)

            display_img = *sInfo.pImage
            display_img[where(*sInfo.pMask)] = mask_color
            TV, display_img, img_pos_x, img_pos_y

            img_pos_x = ((3 * sInfo.drawXSize) / 4) - sz[1] / 2
            XYOUTS, img_pos_x + sz[1] / 2, img_pos_y + sz[2] + 12, $
                'Result', COLOR=0, $
                /DEVICE, Alignment=0.5
            XYOUTS, img_pos_x + sz[1] / 2, img_pos_y + sz[2] + 12, $
                'Mask', COLOR=sInfo.highColor+4, $
                /DEVICE, Alignment=0.5
            demo_putTips, sInfo, ['dlterd0', 'dlterd1', 'dlterd2'], $
                [10, 11, 12], /LABEL

            end
        0 : begin

            ;  Break regions. i.e. make and display a binary
            ;  morphological opening of the mask
            ;
            *sInfo.pMask = dilate(erode(*sInfo.pMask, se), se)

            display_img = *sInfo.pImage
            display_img[where(*sInfo.pMask)] = mask_color
            TV, display_img, img_pos_x, img_pos_y

            demo_putTips, sInfo, ['dlterd3', 'dlterd4', 'blank'], $
                [10, 11, 12], /LABEL

            end
        1 : begin

            ;  Fuse regions. i.e. make and display a binary morphological
            ;  closing of the mask
            ;
            *sInfo.pMask = erode(dilate(*sInfo.pMask, se), se)

            display_img = *sInfo.pImage
            display_img[where(*sInfo.pMask)] = mask_color
            TV, display_img, img_pos_x, img_pos_y

            demo_putTips, sInfo, ['dlterd5', 'dlterd6', 'dlterd7'], $
                [10, 11, 12], /LABEL

            end
        2 : begin

            ;  Make a grayscale morphological opening of original image
            ;
            display_image = $
                dilate(erode(*sInfo.pImage, se, /gray), se, /gray)

            ;  Mask and display the result.
            ;
            display_image[where(*sInfo.pMask eq 0)] = $
                (*sInfo.pImage)[where(*sInfo.pMask eq 0)]
            TV, display_image, img_pos_x, img_pos_y

            img_pos_x = ((3 * sInfo.drawXSize) / 4) - sz[1] / 2
            XYOUTS, img_pos_x + sz[1] / 2, img_pos_y + sz[2] + 12, $
                'Mask', COLOR=0, $
                /DEVICE, Alignment=0.5
            XYOUTS, img_pos_x + sz[1] / 2, img_pos_y + sz[2] + 12, $
                'Result', COLOR=sInfo.highColor+4, $
                /DEVICE, Alignment=0.5

            demo_putTips, sInfo, ['dlterd8', 'dlterd9', 'blank'], $
                [10, 11, 12], /LABEL

            end
        else:
        endcase

     sInfo.step = (sInfo.step + 1) mod 4

     !P.FONT = previousFont

end


;--------------------------------------------------------------------
;
;  Purpose:  Do the convolution demo
;
pro d_imagprocMakeConvolution, $
    drawXSize, $          ; IN: x dimension of drawing area
    drawYSize, $          ; IN: y dimension of drawing area
    highColor, $          ; IN: maximun index of the color table
    kernel, $             ; OUT: convolution kernel
    scalingImage          ; OUT: scaling image

    previousFont = !P.FONT
    !P.FONT = 0

    LOADCT, 0, /SILENT
    TEK_COLOR, highColor+1, 16

    kernel = BYTARR(10,10)
    img = BYTARR(768, 200, /Nozero)
    GET_LUN, data_lun
    OPENR, data_lun, demo_filepath('nyny.dat', $
        SUBDIR=['examples','data'])
    READU, data_lun, img
    CLOSE, data_lun
    FREE_LUN, data_lun

    img = BYTSCL(img[0:255, *], TOP=highColor)
    scalingImage=img

    Erase, 0
    d_imagprocDrawGrid, 3,3, drawXSize, drawYSize, $
         highColor, kernel,  /CELL_COORD
    d_imagprocDrawGrid, 3,6, drawXSize, drawYSize, $
         highColor, kernel,  /CELL_COORD
    d_imagprocDrawGrid, 6,3, drawXSize, drawYSize, $
         highColor, kernel,  /CELL_COORD
    d_imagprocDrawGrid, 6,6, drawXSize, drawYSize, $
         highColor, kernel,  /CELL_COORD

    pos_x = (drawXSize / 4)
    img_pos_y = (drawYSize / 2) - 100

    XYOUTS, pos_x, img_pos_y+212, 'Kernel', COLOR=highColor+4, /DEVICE, $
        Alignment=0.5
    Empty

    d_imagprocDrawConvolution, drawXSize, drawYSize, $
         highColor, kernel, img

    img_pos_x = ((3 * drawXSize) / 4) - 128
    XYOUTS, img_pos_x+128, img_pos_y+212, $
        'Convolved Image', COLOR=highColor+4, $
        /DEVICE, Alignment=0.5
    Empty

    !P.FONT = previousFont

end   ;   of d_imagprocMakeConvolution

;--------------------------------------------------------------------
;
;  Purpose:  Draw the kernel
;
pro d_imagprocDrawGrid, $
    x, $                    ; x coordinates
    y, $                    ; y coordinates
    drawXSize, $            ; IN: x dimension of drawing area
    drawYSize, $            ; IN: y dimension of drawing area
    highColor, $            ; IN: maximun index of the color table
    kernel, $               ; IN/OUT: convolution kernel
    Cell_Coord=cell_coord   ; IN: (opt) If x and y are in cell coordinates.

    grid_pos_x = (drawXSize / 4) - 50
    grid_pos_y = (drawYSize / 2) - 50

    if (Keyword_Set(cell_coord)) then begin
       cell_x = x
       cell_y = y
    endif else begin
       cell_x = Float((x - grid_pos_x) / 10.0)
       cell_y = Float((y - grid_pos_y) / 10.0)
       if ((cell_x LT 0.0) OR (cell_y LT 0.0)) then RETURN
       cell_x = Fix(cell_x)
       cell_y = Fix(cell_y)
    ENDelse

    if ((cell_x GE 10) OR (cell_y GE 10)) then RETURN

    box_l = (cell_x * 10) + grid_pos_x
    box_r = box_l + 10
    box_b = (cell_y * 10) + grid_pos_y
    box_t = box_b + 10

    if (kernel[cell_x, cell_y] EQ 1B) then begin
       cell_color = highColor+1
       kernel[cell_x, cell_y] = 0B
    endif else begin
       cell_color = highColor+2
       kernel[cell_x, cell_y] = 1B
    ENDelse

    POLYFILL, [box_l, box_r, box_r, box_l], $
        [box_b, box_b, box_t, box_t], $
        /DEVICE, COLOR=cell_color

    for i=0, 10 DO begin
       x = grid_pos_x + (i * 10)
       y1 = grid_pos_y
       y2 = grid_pos_y + 100
       PLOTS, [x, x], [y1, y2], /DEVICE, COLOR=highColor+3
       x1 = grid_pos_x
       x2 = grid_pos_x + 100
       y = grid_pos_y + (i * 10)
       PLOTS, [x1, x2], [y, y], /DEVICE, COLOR=highColor+3
    endfor

end    ;  of d_imagprocDrawGrid

;--------------------------------------------------------------------
;
;  Purpose:  Draw the convolved image according to the kernel
;
pro d_imagprocDrawConvolution, $
    drawXSize, $            ; IN: x dimension of drawing area
    drawYSize, $            ; IN: y dimension of drawing area
    highColor, $            ; IN: maximun index of the color table
    kernel, $               ; IN: convolution kernel
    Image                   ; IN: original image to be convolved

    img_pos_x = ((3 * drawXSize) / 4) - 128
    img_pos_y = (drawYSize / 2) - 100

    img1 = CONVOL(Float(image), Float(kernel)/(Total(Float(kernel))>1.0), $
       /Edge_Truncate, /Center)
    TV, BYTSCL(img1, TOP=highColor), img_pos_x, img_pos_y

end    ;  of d_imagprocDrawConvolution

;--------------------------------------------------------------------
;
pro d_imagprocEvent, sEvent

    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
    demo_record, sEvent, 'd_imagprocEvent', $
        FILENAME=sInfo.record_to_filename, $
        cw=sInfo.wSelectButton
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventUValue

    ;  Quit this application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    case eventUValue of

        'DRAWING' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wSelectButton, GET_VALUE=index
            sInfo.button = (sInfo.button or sEvent.press) $
                       and (not sEvent.release) ;Maintain button state
            if sInfo.button ne 0 then begin
                case index of

                    ;  handle the zooming
                    ;
                    0 : begin

                        xpos = (sEvent.x > sInfo.zoomStr.win_size_h) < $
                            ((sInfo.drawXSize - sInfo.zoomStr.win_size_h) - 1)
                        ypos = (sEvent.y > sInfo.zoomStr.win_size_h) < $
                            ((sInfo.drawYSize - sInfo.zoomStr.win_size_h) - 1)
                        img_x = xpos - sInfo.zoomStr.win_zoom_h
                        img_y = ypos - sInfo.zoomStr.win_zoom_h

                        sub_x = xpos - sInfo.zoomStr.win_size_h
                        sub_y = ypos - sInfo.zoomStr.win_size_h

                        zoom_img = $
                            REBIN(sInfo.zoomStr.nyc_img[sub_x: $
                                (sub_x+sInfo.zoomStr.win_size-1), $
                                sub_y:(sub_y+sInfo.zoomStr.win_size-1)], $
                                sInfo.zoomStr.win_zoom, sInfo.zoomStr.win_zoom)

                        WSET, sInfo.pixmapArray[1] ; Assemble composite image here
                        DEVICE, COPY=[0, 0, sInfo.drawXSize, $
                            sInfo.drawYSize, 0, 0, sInfo.pixmapArray[0]]
                        TV, zoom_img, img_x, img_y
                        PLOTS, sInfo.zoomStr.box_x+img_x, $
                            sInfo.zoomStr.box_y+img_y, $
                            /DEVICE, THICK=3, COLOR=sInfo.highColor+3
                        WSET, sInfo.drawWindowID

                        DEVICE, COPY=[0, 0, sInfo.drawXSize, $
                            sInfo.drawYSize, 0, 0, sInfo.pixmapArray[1]]
                        Empty

                    end     ;   of 0

                    ;  Handle the Convolution button press
                    ;
                    6 : begin

                        kernel = sInfo.kernel
                        d_imagprocDrawGrid, sEvent.x, sEvent.y, $
                            sInfo.drawXSize, sInfo.drawYSize, $
                            sInfo.highColor, kernel
                        sInfo.kernel = kernel
                    end    ;   of  5

                endcase
            endif
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end     ;  of  DRAWING

        'SELECT' : begin
            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WSET, sInfo.drawWindowID
            case sEvent.value of

                ;  Zooming
                ;
                0 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[0], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[0]
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=1
                    WSET, sInfo.drawWindowID
                    ERASE
                    d_imagprocMakeZooming, sInfo.drawXSize, sInfo.drawYSize, $
                        sInfo.pixmapArray[0], sInfo.drawWindowID, $
                        sInfo.highColor, sInfo.zoomStr

                    demo_putTips, sInfo, ['zoom1', 'zoom2', 'blank'], $
                        [10, 11, 12], /LABEL

                end  ;  of 0

                ;  Fourier filtering
                ;
                1 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[1], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[1]
                    WSET, sInfo.drawWindowID
                    ERASE
                    filterWidth = 8
                    frequencyImage = COMPLEXARR(64,64)
                    WIDGET_CONTROL, sInfo.wFilterSlider, SET_VALUE=filterWidth
                    d_imagprocMakeFilter, sInfo.drawXSize, sInfo.drawYSize, $
                        sInfo.highColor, frequencyImage
                    sInfo.frequencyImage = frequencyImage
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0

                    demo_putTips, sInfo, ['width1', 'width2', 'blank'], $
                        [10, 11, 12], /LABEL
                end   ; of 1

                ;  Pixel scaling
                ;
                2 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[2], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[2]
                    imagePositionX = 0
                    imagePositionY = 0
                    d_imagprocMakeScaling, sInfo.drawXSize, sInfo.drawYSize, $
                        sInfo.highColor, $
                        sInfo.wMinScalingSlider, sInfo.wMaxScalingSlider, $
                        imagePositionX, imagePositionY, scalingImage
                    sInfo.scalingImage = scalingImage
                    sInfo.imagePositionX = imagePositionX
                    sInfo.imagePositionY = imagePositionY
                    scalingImage = 0
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0

                    demo_putTips, sInfo, ['byte1', 'byte2', 'blank'], $
                        [10, 11, 12], /LABEL
                end   ;  of 2

                ;  Histogram of pixel values distribution
                ;
                3 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[3], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[3]
                    WSET, sInfo.drawWindowID
                    ERASE
                    imagePositionX = 0
                    imagePositionY = 0
                    d_imagprocMakeHistogram, sInfo.drawXSize, sInfo.drawYSize, $
                        sInfo.highColor, $
                        sInfo.wMinHistogramSlider, sInfo.wMaxHistogramSlider, $
                        imagePositionX, imagePositionY, scalingImage
                    sInfo.scalingImage = scalingImage
                    sInfo.imagePositionX = imagePositionX
                    sInfo.imagePositionY = imagePositionY
                    scalingImage = 0
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0
                    demo_putTips, sInfo, ['byte1', 'byte2', 'blank'], $
                        [10, 11, 12], /LABEL
                end    ;  of 3

                ;  Edge enhancement
                ;
                4 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[4], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[4]
                    WIDGET_CONTROL, sInfo.wEdgeSlider, SET_VALUE=0
                    smoothValue = 0
                    WSET, sInfo.drawWindowID
                    ERASE
                    d_imagprocMakeEdge , sInfo.drawXSize, sInfo.drawYSize, $
                        sInfo.highColor, $
                        sInfo.wEdgeSlider, $
                        scalingImage
                    sInfo.scalingImage = scalingImage
                    scalingImage = 0
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0
                    demo_putTips, sInfo, ['smooth1', 'smooth2', 'blank'], $
                        [10, 11, 12], /LABEL
                end    ;  of 4

                ;  Dilate and Erode
                ;
                5 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[5], MAP=1
                    sInfo.currentBase = sInfo.wSelectionBase[5]

                    WSET, sInfo.drawWindowID
                    ERASE
                    d_imagprocMakeDltErd, sInfo
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=0

                end    ;  of 5

                ;  Convolution
                ;
                6 : begin
                    WIDGET_CONTROL, sInfo.currentBase, MAP=0
                    WIDGET_CONTROL, sInfo.wSelectionBase[6], MAP=1
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
                    sInfo.currentBase = sInfo.wSelectionBase[6]
                    WSET, sInfo.drawWindowID
                    ERASE
                    d_imagprocMakeConvolution , sInfo.drawXSize, sInfo.drawYSize, $
                        sInfo.highColor, $
                        kernel, $
                        scalingImage
                    sInfo.scalingImage = scalingImage
                    sInfo.Kernel = kernel
                    scalingImage = 0
                    WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
                    demo_putTips, sInfo, ['conv1', 'conv2', 'blank'], $
                        [10, 11, 12], /LABEL
                    WIDGET_CONTROL, sInfo.wAreaDraw, DRAW_BUTTON_EVENTS=1
                end    ;  of 5

            endcase

            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end   ;                      of   SELECT

        'FILTERWIDTH' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wFilterSlider, GET_VALUE=filterWidth
            WSET, sInfo.drawWindowID
            d_imagprocDoFilterSlider, sInfo.drawXSize, sInfo.drawYSize, $
                sInfo.highColor, sInfo.frequencyImage, filterWidth
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  ABOVE


        'MINSCALING' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wMinScalingSlider, GET_VALUE=minValue
            WIDGET_CONTROL, sInfo.wMaxScalingSlider, GET_VALUE=maxValue
            if (maxValue LE minValue) then begin
                maxValue = minValue + 1
                WIDGET_CONTROL, sInfo.wMaxScalingSlider, SET_VALUE=maxValue
            endif
            scaledImage = BYTSCL(sInfo.scalingImage, $
                 MIN=minValue, MAX=maxValue, TOP=sInfo.highColor)
            TV, scaledImage, sInfo.imagePositionX, sInfo.imagePositionY
            Empty
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  MINSCALING


        'MAXSCALING' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wMinScalingSlider, GET_VALUE=minValue
            WIDGET_CONTROL, sInfo.wMaxScalingSlider, GET_VALUE=maxValue
            if (minValue GE maxValue) then begin
                minValue = maxValue - 1
                WIDGET_CONTROL, sInfo.wMinScalingSlider, SET_VALUE=minValue
            endif
            scaledImage = BYTSCL(sInfo.scalingImage, $
                 MIN=minValue, MAX=maxValue, TOP=sInfo.highColor)
            TV, scaledImage, sInfo.imagePositionX, sInfo.imagePositionY
            Empty
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  MAXSCALING


        'MINHISTOGRAM' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wMinHistogramSlider, GET_VALUE=minValue
            WIDGET_CONTROL, sInfo.wMaxHistogramSlider, GET_VALUE=maxValue
            if (maxValue LE minValue) then begin
                maxValue = minValue + 1
                WIDGET_CONTROL, sInfo.wMaxHistogramSlider, SET_VALUE=maxValue
            endif
            d_imagprocDrawHistogram, $
                sInfo.drawXSize, sInfo.drawYSize, sInfo.highColor, $
                minValue, maxValue, $
                sInfo.ScalingImage, sInfo.imagePositionX, sInfo.imagePositionY
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  MINHISTOGRAM


        'MAXHISTOGRAM' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wMinHistogramSlider, GET_VALUE=minValue
            WIDGET_CONTROL, sInfo.wMaxHistogramSlider, GET_VALUE=maxValue
            if (minValue GE maxValue) then begin
                minValue = maxValue - 1
                WIDGET_CONTROL, sInfo.wMinHistogramSlider, SET_VALUE=minValue
            endif
            d_imagprocDrawHistogram, $
                sInfo.drawXSize, sInfo.drawYSize, sInfo.highColor, $
                minValue, maxValue, $
                sInfo.ScalingImage, sInfo.imagePositionX, sInfo.imagePositionY
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  MAXHISTOGRAM


        'EDGE' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wEdgeSlider, GET_VALUE=smoothValue
            d_imagprocDrawEdge, $
                sInfo.drawXSize, sInfo.drawYSize, sInfo.highColor, $
                smoothValue, sInfo.ScalingImage
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  MAXHISTOGRAM


        'BREAK' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wBreakButton, SENSITIVE=0
            WIDGET_CONTROL, sInfo.wFuseButton,  SENSITIVE=1, $
                /INPUT_FOCUS
            WIDGET_CONTROL, sInfo.wResetButton, SENSITIVE=1
            sInfo.step = 0
            d_imagprocDrawDltErd, sInfo
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end

        'FUSE' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wFuseButton, SENSITIVE=0
            WIDGET_CONTROL, sInfo.wMinsButton, SENSITIVE=1, $
                /INPUT_FOCUS
            sInfo.step = 1
            d_imagprocDrawDltErd, sInfo
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end

        'MINS' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wMinsButton, SENSITIVE=0
            WIDGET_CONTROL, sInfo.wResetButton, /INPUT_FOCUS
            sInfo.step = 2
            d_imagprocDrawDltErd, sInfo
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end

        'RESET' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wBreakButton, SENSITIVE=1, $
                /INPUT_FOCUS
            WIDGET_CONTROL, sInfo.wFuseButton,  SENSITIVE=0
            WIDGET_CONTROL, sInfo.wMinsButton,  SENSITIVE=0
            WIDGET_CONTROL, sInfo.wResetButton, SENSITIVE=0
            sInfo.step = 3
            d_imagprocDrawDltErd, sInfo
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end

        'CONVOLUTION' : begin

            WIDGET_CONTROL, sEvent.top, GET_UVALUE=sInfo, /NO_COPY
            WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=0
            d_imagprocDrawConvolution, sInfo.drawXSize, sInfo.drawYSize, $
                sInfo.highColor, sInfo.kernel, sInfo.scalingImage
            WIDGET_CONTROL, sInfo.wTopBase, SENSITIVE=1
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sInfo, /NO_COPY
        end    ;       of  CONVOLUTION


        'QUIT' : begin

            WIDGET_CONTROL, sEvent.top, /DESTROY
        end

        'ABOUT' : begin
            ONLINE_HELP, 'd_imageproc', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
        end           ;  of ABOUT

        else :   ;  do nothing

    endcase
end

;--------------------------------------------------------------------
;
pro d_imagprocCleanup, wTopBase

    ;  Get the color table saved in the window's user value
    ;
    WIDGET_CONTROL, wTopBase, GET_UVALUE=sInfo, /NO_COPY

    ;  Restore the previous color table.
    ;
    TVLCT, sInfo.colorTable

    ;  Restore the previous plot font.
    ;
    !P.FONT = sInfo.plotFont

    !P.CHARSIZE = sInfo.previousChar

    ;  Delete the pixmap windows.
    ;
    for i = 0, sInfo.nPixmap-1 do begin
        WDELETE, sInfo.pixmapArray[i]
    endfor

    ;  Destroy heap variables.
    ;
    ptr_free, [sInfo.pImage, sInfo.pMask]

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(sInfo.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sInfo.groupBase, /MAP

end   ; of d_imagprocCleanup

;--------------------------------------------------------------------
;
;   PURPOSE
;
pro d_imagproc, $
    GROUP=group, $     ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

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

    ;  Get the current color table. It will be restored when exiting.
    ;
    TVLCT, savedR, savedG, savedB, /GET
    colorTable = [[savedR],[savedG],[savedB]]

    ;  Also save the font
    ;
    plotFont = !P.FONT

    ;  Get the screen size.
    ;
    DEVICE, GET_SCREEN_SIZE = screenSize

    if (ngroup EQ 0) then begin
        drawbase = demo_startmes()
     endif else begin
        drawbase = demo_startmes(GROUP=group)
    endelse

    previousChar = !P.CHARSIZE

    !P.CHARSIZE = 8.0 / !D.X_CH_SIZE

    ;  Load a new color table
    ;
    LOADCT, 12, /SILENT
    highColor = !D.TABLE_SIZE-18
    TEK_COLOR, highColor+1, 16

    ;  Use hardware-drawn font.
    ;
    !P.FONT=0

    ;  Set up the drawing area size (predetermined for image processing)
    ;
    drawXSize = 512
    drawYSize = 400

    if (screenSize[0] LT 800) then begin
        widID = $
        DIALOG_MESSAGE('This application is optimized' + $
            ' for 800 x 640 resolution.', $
            /INforMATION)
    endif

    ;  Set the slider width on windows
    ;
    sliderWidth = 70

    ;  Add scroll bar if the monitor x size is less than 750 pixels.
    ;
    if (screenSize[0] LT 750) then myScroll=1 else myScroll=0

    ;  Create the widgets.
    ;
    if (myScroll EQ 1) then begin
        if (N_ELEMENTS(group) EQ 0) then begin
            wTopBase = WIDGET_BASE(TITLE="Image Processing", $
                /COLUMN, $
                /TLB_KILL_REQUEST_EVENTS, $
                SCROLL=myScroll, $
                X_SCROLL_SIZE=screenSize[0]-75, $
                Y_SCROLL_SIZE=screenSize[1]-75, $
                MAP=0, $
                UNAME='d_imagproc:tlb', $
                TLB_FRAME_ATTR=1, MBAR=barBase)
        endif else begin
            wTopBase = WIDGET_BASE(TITLE="Image Processing", $
                /COLUMN, $
                /TLB_KILL_REQUEST_EVENTS, $
                SCROLL=myScroll, $
                X_SCROLL_SIZE=screenSize[0]-75, $
                Y_SCROLL_SIZE=screenSize[1]-75, $
                MAP=0, $
                UNAME='d_imagproc:tlb', $
                GROUP_LEADER=group, $
                TLB_FRAME_ATTR=1, MBAR=barBase)
        endelse
    endif else begin
        if (N_ELEMENTS(group) EQ 0) then begin
            wTopBase = WIDGET_BASE(TITLE="Image Processing", $
                /COLUMN, $
                /TLB_KILL_REQUEST_EVENTS, $
                MAP=0, $
                UNAME='d_imagproc:tlb', $
                TLB_FRAME_ATTR=1, MBAR=barBase)
        endif else begin
            wTopBase = WIDGET_BASE(TITLE="Image Processing", $
                /COLUMN, $
                /TLB_KILL_REQUEST_EVENTS, $
                MAP=0, $
                UNAME='d_imagproc:tlb', $
                GROUP_LEADER=group, $
                TLB_FRAME_ATTR=1, MBAR=barBase)
        endelse
    endelse

        ;  Create the menu bar items
        ;
        wFileButton = WIDGET_BUTTON(barBase, VALUE='File')

            wQuitButton = WIDGET_BUTTON(wFileButton, VALUE='Quit', $
                UVALUE='QUIT', UNAME='d_imagproc:quit')

        wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', /HELP)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About Image Processing', $
                UVALUE='ABOUT')

        ;  Create the left and right bases
        ;
        wTopRowBase = WIDGET_BASE(wTopBase, COLUMN=2)

            wLeftBase = WIDGET_BASE(wTopRowBase, /COLUMN)

                modes = ['Zooming',    'Fourier Filter', $
                    'Pixel Scaling',    'Histogram', $
                    'Edges', 'Dilate and Erode', 'Convolution']
                wSelectButton = CW_BGROUP(wLeftBase, modes, $
                    UVALUE='SELECT', /NO_RELEASE, /EXCLUSIVE)
                WIDGET_CONTROL, wSelectButton, SET_UNAME='d_imagproc:radio'

                ;  Create a base for each options
                ;
                wSelectionBase = LONARR(n_elements(modes))
                wTempBase = WIDGET_BASE(wLeftbase)

                    ;  Put the selection bases into the temporary (temp)
                    ;  base. This way, the selection bases overlaps each
                    ;  another. When the user select from wSelectButton,
                    ;  only one selection base is mapped.
                    ;
                    for i=0, N_ELEMENTS(wSelectionbase)-1 do  begin
                        wSelectionbase[i] = WIDGET_BASE(wTempBase, $
                        UVALUE=0L, /COLUMN, MAP=0, YPAD=20)
                    endfor

                        ;  Create the content of each selection base
                        ;  Beginning with zooming
                        ;
                        wZoomingBase = WIDGET_BASE(wSelectionBase[0], $
                            /COLUMN, /BASE_ALIGN_CENTER)

                        ;  Fourier filtering.
                        ;
                        wFilterBase = WIDGET_BASE(wSelectionBase[1], $
                            /COLUMN, /FRAME)

                            if (!D.Name EQ 'WIN') then begin
                                wFilterSlider = WIDGET_SLIDER(wFilterBase, $
                                    MINIMUM=1, MAXIMUM=20, $
                                    XSIZE=sliderWidth, $
                                    VALUE=8, $
                                    TITLE='Filter Width', UVALUE='FILTERWIDTH', $
                                    UNAME='d_imagproc:fftwidth')
                            endif else begin
                                wFilterSlider = WIDGET_SLIDER(wFilterBase, $
                                    MINIMUM=1, MAXIMUM=20, $
                                    VALUE=8, $
                                    TITLE='Filter Width', UVALUE='FILTERWIDTH', $
                                    UNAME='d_imagproc:fftwidth')
                            endelse

                        ;  Pixel scaling.
                        ;
                        wScalingBase = WIDGET_BASE(wSelectionBase[2], $
                            /COLUMN, /FRAME)

                            if (!D.Name EQ 'WIN') then begin
                                wMinScalingSlider = $
                                    WIDGET_SLIDER(wScalingBase, $
                                    MINIMUM=89, MAXIMUM=253, $
                                    XSIZE=sliderWidth, $
                                    VALUE=115, $
                                    UNAME='d_imagproc:minscaling', $
                                    TITLE='Minimum', UVALUE='MINSCALING')

                                wMaxScalingSlider =WIDGET_SLIDER(wScalingBase, $
                                    MINIMUM=93, MAXIMUM=255, $
                                    XSIZE=sliderWidth, $
                                    VALUE=178, $
                                    UNAME='d_imagproc:maxscaling', $
                                    TITLE='Maximum', UVALUE='MAXSCALING')
                            endif else begin
                                wMinScalingSlider = $
                                    WIDGET_SLIDER(wScalingBase, $
                                    MINIMUM=89, MAXIMUM=253, $
                                    VALUE=115, $
                                    UNAME='d_imagproc:minscaling', $
                                    TITLE='Minimum', UVALUE='MINSCALING')

                                wMaxScalingSlider =WIDGET_SLIDER(wScalingBase, $
                                    MINIMUM=93, MAXIMUM=255, $
                                    VALUE=178, $
                                    UNAME='d_imagproc:maxscaling', $
                                    TITLE='Maximum', UVALUE='MAXSCALING')
                            endelse

                        ;  Histogram distribution
                        ;
                        wHistogramBase = WIDGET_BASE(wSelectionBase[3], $
                            /COLUMN, /FRAME)

                            if (!D.Name EQ 'WIN') then begin
                                wMinHistogramSlider = $
                                    WIDGET_SLIDER(wHistogramBase, $
                                    XSIZE=sliderWidth, $
                                    MINIMUM=0, MAXIMUM=220, $
                                    VALUE=0, $
                                    UNAME='d_imagproc:minhisto', $
                                    TITLE='Minimum', UVALUE='MINHISTOGRAM')

                                wMaxHistogramSlider = $
                                    WIDGET_SLIDER(wHistogramBase, $
                                    XSIZE=sliderWidth, $
                                    MINIMUM=2, MAXIMUM=224, $
                                    VALUE=222, $
                                    UNAME='d_imagproc:maxhisto', $
                                    TITLE='Maximum', UVALUE='MAXHISTOGRAM')
                            endif else begin
                                wMinHistogramSlider = $
                                    WIDGET_SLIDER(wHistogramBase, $
                                    MINIMUM=0, MAXIMUM=220, $
                                    VALUE=0, $
                                    UNAME='d_imagproc:minhisto', $
                                    TITLE='Minimum', UVALUE='MINHISTOGRAM')

                                wMaxHistogramSlider = $
                                    WIDGET_SLIDER(wHistogramBase, $
                                    MINIMUM=2, MAXIMUM=224, $
                                    VALUE=222, $
                                    UNAME='d_imagproc:maxhisto', $
                                    TITLE='Maximum', UVALUE='MAXHISTOGRAM')
                            endelse

                        ;  Edge enhancement
                        ;
                        wEdgeBase = WIDGET_BASE(wSelectionBase[4], $
                            /COLUMN, /FRAME)

                            if (!D.Name EQ 'WIN') then begin
                                wEdgeSlider = WIDGET_SLIDER(wEdgeBase, $
                                    MINIMUM=0, MAXIMUM=20, $
                                    XSIZE=sliderWidth, $
                                    VALUE=0, $
                                    UNAME='d_imagproc:edge_slider', $
                                    TITLE='Smooth width', UVALUE='EDGE')
                            endif else begin
                                wEdgeSlider = WIDGET_SLIDER(wEdgeBase, $
                                    MINIMUM=0, MAXIMUM=20, $
                                    VALUE=0, $
                                    UNAME='d_imagproc:edge_slider', $
                                    TITLE='Smooth Width', UVALUE='EDGE')
                            endelse

                        ;  Dilate and Erode
                        ;
                        wDltErdBase = WIDGET_BASE(wSelectionBase[5], $
                            /COLUMN, /FRAME)

                            wBreakButton = WIDGET_BUTTON(wDltErdBase, $
                                value='Break Mask', uval='BREAK', $
                                UNAME='d_imagproc:breakmask')
                            wFuseButton = WIDGET_BUTTON(wDltErdBase, $
                                VALUE='Fuse Mask', UVALUE='FUSE', $
                                UNAME='d_imagproc:fusemask')
                            wMinsButton = WIDGET_BUTTON(wDltErdBase, $
                                VALUE='Neighborhood Mins.', UVALUE='MINS', $
                                UNAME='d_imagproc:neighborhood_mins')
                            wResetButton = WIDGET_BUTTON(wDltErdBase, $
                                VALUE='Reset', UVALUE='RESET', $
                                UNAME='d_imagproc:reset')
                            WIDGET_CONTROL, wFuseButton, SENSITIVE=0
                            WIDGET_CONTROL, wMinsButton, SENSITIVE=0
                            WIDGET_CONTROL, wResetButton, SENSITIVE=0

                        ;  Convolution
                        ;
                        wConvolutionBase = WIDGET_BASE(wSelectionBase[6], $
                            /COLUMN, /FRAME)

                            wConvolutionButton = $
                                WIDGET_Button(wConvolutionBase, $
                                VALUE='Convolve', UVALUE='CONVOLUTION', $
                                UNAME='d_imagproc:convolve')

            wRightBase = WIDGET_BASE(wTopRowBase, /COLUMN)

                wAreaDraw = WIDGET_DRAW(wRightBase, XSIZE=drawXSize, $
                    YSIZE=drawYSize, RETAIN=2, UVALUE='DRAWING', $
                    /MOTION, /BUTTON, UNAME='d_imagproc:draw')

        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ;  Returns the top level base in the appTLB keyword.
    ;
    appTLB = wTopBase

    sText = demo_getTips(demo_filepath('imagproc.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)


    WIDGET_CONTROL, wSelectButton, SET_VALUE=0

    ; Determine the window value of plot window
    ;
    WIDGET_CONTROL, wAreaDraw, GET_VALUE=drawWindowID

    ;  Map the integration demo (index 0) as default
    ;
    WIDGET_CONTROL, wSelectionBase[0], MAP=1

    ;  Create the pixmaps
    ;
    nPixmap = 2
    pixmapArray = LONARR(nPixmap)
    for i = 0, nPixmap-1 do begin
        Window, /FREE, XSIZE=drawXSize, YSIZE=drawYSize, /PIXMAP
        pixmapArray[i] = !D.Window
    endfor

    ;  Make the zooming demo as default.
    ;
    WSET, drawWindowID
    ERASE
    d_imagprocMakeZooming, drawXSize, drawYSize, $
        pixmapArray[0], drawWindowID, highColor, $
        zoomStr
    WIDGET_CONTROL, wAreaDraw, /DRAW_BUTTON_EVENTS

    if n_elements(record_to_filename) eq 0 then $
        record_to_filename = ''

    ;  Create the info structure
    ;
    sInfo = { $
        ZoomStr: zoomStr, $                          ; Zoom structure
        FrequencyImage: COMPLEXARR(64,64,/NOZERO), $ ; Image frequencies
        ScalingImage: BYTARR(256,200,/NOZERO), $     ; Scaled image
        Kernel: BYTARR(10,10), $                     ; Kernel array
        ImagePositionX: 0, $                         ; Position of zoomed image
        ImagePositionY: 0, $
        HighColor: highColor, $                      ; Highest color index
        NPixmap: nPixmap, $                          ; Number of pixmaps
        PixmapArray: pixmapArray, $                  ; Pixmap IDs array
        DrawXSize: drawXSize, $                      ; Drawing area size
        DrawYSize: drawYSize, $
        CurrentBase : wSelectionBase[0], $           ; Current displayed base
        ColorTable:colorTable, $                     ; Color table to restore
        DrawWindowID: drawWindowID, $                ; Window ID
        WTopBase: wTopBase, $                        ; Top level base ID
        WSelectionBase: wSelectionBase, $            ; Selection base IDs
        WSelectButton: wSelectButton, $              ; Buttons and sliders IDs
        WConvolutionButton: wConvolutionButton, $
        WFilterSlider: wFilterSlider, $
        WMinScalingSlider: wMinScalingSlider, $
        WMaxScalingSlider: wMaxScalingSlider, $
        WMinHistogramSlider: wMinHistogramSlider, $
        WMaxHistogramSlider: wMaxHistogramSlider, $
        wBreakButton: wBreakButton, $                ; dilate & erode
        wFuseButton: WfuseButton, $
        wMinsButton: wMinsButton, $
        wResetButton: wResetButton, $
        WEdgeSlider: wEdgeSlider, $
        WAreaDraw: wAreaDraw, $                      ; Widget draw ID
        SText: sText, $                              ; Text structure for tips.
        previousChar : previousChar, $               ; Previous character size
        plotFont: plotFont, $                        ; Font to trestore
        pImage: ptr_new(), $
        pMask: ptr_new(), $
        step: 0, $
        button: 0, $                                 ; Mouse-button state
        record_to_filename: record_to_filename, $
        groupBase: groupBase $                       ; Base of Group Leader
    }

    ;  Register the info structure in the user value
    ;  of the top-level base.
    ;
    WIDGET_CONTROL, wTopBase, SET_UVALUE=sInfo, /NO_COPY

    ;  Destroy the starting up window.
    ;
    WIDGET_CONTROL, drawbase, /DESTROY

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, wTopBase, MAP=1

    ; Register with the BIG GUY, XMANAGER!
    ;
    XMANAGER, "d_imagproc", wTopBase, $
        EVENT_HANDLER="d_imagprocEvent", $
        CLEANUP="D_ImagprocCleanup", /NO_BLOCK

end   ; of D_Imagproc
