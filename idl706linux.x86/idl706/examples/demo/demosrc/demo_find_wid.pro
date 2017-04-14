;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/demo_find_wid.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
function demo_find_wid, uname
forward_function LookupManagedWidget
;
;Given the uname of a widget, where the uname
;is like '<xregistered name>:uname', return the id of
;the widget.
;
xreg_name = strmid(uname, 0, strpos(uname, ':'))
return, widget_info( $
    LookupManagedWidget(xreg_name), $
    find_by_uname=uname $
    )
end
