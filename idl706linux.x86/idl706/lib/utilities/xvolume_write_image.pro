;$Id: //depot/idl/IDL_70/idldir/lib/utilities/xvolume_write_image.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
pro xvolume_write_image, $
    filename, $ ; IN
    format, $   ; IN: scalar string (e.g. 'bmp', 'jpeg', etcetera).
    tlb=tlb_, $ ; IN: (opt) Top-level base widget ID of xvolume.
    dimensions=dimensions   ; IN: (opt) Output this pixel size. [x, y].

on_error, 2

if n_elements(tlb_) gt 0 then begin
    xobjview_write_image, filename, format, dimensions=dimensions, tlb=tlb_
    end $
else begin
    if xregistered('xVolume') eq 0 then $
        message, 'No valid XVOLUME available.'
    tlb = LookupManagedWidget('xVolume')

    widget_control, tlb, get_uvalue=pState
    (*pState).oObjViewWid->WriteImage, $
        filename, format, dimensions=dimensions
    end

end
