; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_ivolume.pro#2 $
;
;  Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;---------------------------------------------------------------------

PRO d_ivolume, _EXTRA=_extra

  fname = filepath('cduskcD1400.sav', subdir=['examples', 'data'])
  restore, fname
  ; get some nice colors
  loadct, 15, /silent
  tvlct, r, g, b, /get

  ivolume, density, $
    rgb_table0=[[r],[g],[b]], $
    /auto_render, $
    /no_saveprompt

END
