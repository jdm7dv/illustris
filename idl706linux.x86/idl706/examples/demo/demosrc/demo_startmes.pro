; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/demo_startmes.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;  PURPOSE This function creates a start up message window.
;          Returns the draw base ID.
;
function demo_Startmes, $
                   Name, $      ;Demo name (optional)
                   GROUP = group, $ ;  IN:(opt) group leader
                   STATUS = status, $ ;If set, create a status line and
                                ;initialize it to this text
                   UPDATE = updatebase ;Set to the Widget ID of the startup
                                ;message window to update the status
                                ;line with the text in Name. 
; Example:
; Create startup window with status line.
; Wid = demo_Startmes('My Demo', STATUS='')  
; Update status message
; Dummy = demo_Startmes('Loading vertex data', UPDATE=Wid) 
;

if n_elements(updatebase) ne 0 then begin ;Update existing message window?
    WIDGET_CONTROL, updatebase, GET_UVALUE=txtwid
    if txtwid ne 0 then WIDGET_CONTROL, txtwid, SET_VALUE=name
    return, updatebase
endif

    ;  Otherwise set up the starting up message.
    ;  Get the screen size and set an offset.
    ;
    DEVICE, GET_SCREEN_SIZE = screenSize
    xstext = screenSize[0]/6
    ystext = 30
    xoff = (screenSize[0] - xstext)/2.0
    yoff = (screenSize[1] - ystext) /2.0

    if N_ELEMENTS(group) eq 0 then group = 0L
    if N_ELEMENTS(name) ne 0 then addl = name else addl = 'the Demo'

    if (group NE 0) then $
       drawbase = WIDGET_BASE(YOFFSET=yoff, XOFFSET=xoff, /COLUMN, $
                           TITLE='IDL Demo', $
                           TLB_FRAME_ATTR=27, /FRAME, GROUP_LEADER=group, $
                           /MODAL) $
    else $
       drawbase = WIDGET_BASE(YOFFSET=yoff, XOFFSET=xoff, /COLUMN, $
                           TITLE='IDL Demo', $
                           TLB_FRAME_ATTR=27, /FRAME, GROUP_LEADER=group)

    ;  Create the starting up window.
    ;
    Label = WIDGET_LABEL (drawbase, XSIZE=xstext, SCR_XSIZE=xstext, $
        SCR_YSIZE=ystext, YSIZE=ystext, /ALIGN_CENTER, $
        VALUE='Starting ' + addl, $
        FRAME=0)

    if N_ELEMENTS(status) ne 0 then $ ;New style, add a status window
      textwin = WIDGET_TEXT (drawbase, XSIZE=40, YSIZE=1, /ALIGN_CENTER,   $
                             Value = status, FRAME=0) $
    else textwin = 0L

    ;  Realize the starting up  message window.
    ;
    WIDGET_CONTROL, drawbase, /REALIZE, SET_UVALUE=textwin

    RETURN, drawbase
end
