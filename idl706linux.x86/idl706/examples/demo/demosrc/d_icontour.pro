; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_icontour.pro#2 $
;
;  Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;---------------------------------------------------------------------

PRO d_icontour, _EXTRA=_extra

z = BYTARR(64,64, /NOZERO)
OPENR, lun, $
    demo_filepath( $
        'elevbin.dat', $
        SUBDIR=['examples','data'] $
        ), $
   /GET_LUN
READU, lun, z
FREE_LUN, lun
z = REVERSE(TEMPORARY(z), 2)

;
;Reduce high frequencies in z data, so as to better expose
;contour lines that will be lying on surface of z data.
;
z = SMOOTH(TEMPORARY(z), 3, /EDGE_TRUNCATE) + 1

;
; Scale x and y to proportional dimensions.
dataDims = SIZE(z,/DIMENSIONS)
xyScale = 14.0
x = FINDGEN(dataDims[0])*xyScale
y = FINDGEN(dataDims[1])*xyScale

;
;Create texture map.
;
READ_JPEG, filepath('elev_t.jpg', $
  SUBDIR=['examples','data']), $
  idata, TRUE=3


icontour, view_grid=[2,1], $
    /no_saveprompt

icontour, z, x, y, $
    view_number=2, $
    N_LEVELS=11, $
    COLOR=[255,0,0]

; do this last so it is selected
iSurface, $
    view_number=1, $
    z, x, y, $
    TEXTURE_IMAGE=idata
icontour, z, x, y, $
    COLOR=[255,255,0], $
    PLANAR=0, $
    TICKLEN=7, $
    N_LEVELS=11, $
    C_LABEL_SHOW=0, $
    /overplot

END
