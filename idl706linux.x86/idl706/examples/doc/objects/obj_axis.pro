; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/obj_axis.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;

PRO obj_axis

; Create some data.
data = FINDGEN(100)

; Create plot and axis objects.
myplot = OBJ_NEW('IDLgrPlot', data)
xaxis = OBJ_NEW('IDLgrAxis', 0)
yaxis = OBJ_NEW('IDLgrAxis', 1)

; Retrieve the data range from the plot object and set the X and Y
; axis objects' RANGE properly so that the axes will match the data
; when displayed:
myplot -> GetProperty, XRANGE=xr, YRANGE=yr
xaxis -> SetProperty, RANGE=xr
yaxis -> SetProperty, RANGE=yr

; By default, major tickmarks are 0.2 data units in length. Since
; the data range in this example is 0 to 99, we set the tick length
; to 2% of the data range instead:
xtl = 0.02 * (xr[1] - xr[0])
ytl = 0.02 * (yr[1] - yr[0])
xaxis -> SetProperty, TICKLEN=xtl
yaxis -> SetProperty, TICKLEN=ytl

; Create model and view objects to contain the object tree, and
; a window object to display it:
mymodel = OBJ_NEW('IDLgrModel')
myview = OBJ_NEW('IDLgrView')
mywindow = OBJ_NEW('IDLgrWindow')
mymodel -> Add, myplot
mymodel -> Add, xaxis
mymodel -> Add, yaxis
myview -> Add, mymodel

; Use the SET_VIEW procedure to add an appropriate viewplane rectangle
; to the view object.
SET_VIEW, myview, mywindow

; Now, display the plot:
mywindow -> Draw, myview

val=''
READ, val, PROMP='Press <Return> to Redraw.'
mywindow -> Draw, myview

READ, val, PROMP='Press <Return> to destroy objects.'
OBJ_DESTROY, mywindow
OBJ_DESTROY, myview

END
