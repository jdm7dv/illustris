; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/obj_plot.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;

FUNCTION NORM_COORD, range

; This function takes a range vector [min, max] as contained
; in the [XYZ]RANGE property of an object and converts it to
; a scaling vector (suitable for the [XYZ]COORD_CONV property)
; that scales the object to fit in the range [0,1].

scale = [-range[0]/(range[1]-range[0]), 1/(range[1]-range[0])]

RETURN, scale

END

;-------------------------------------------------------------

PRO obj_plot, data, VIEW=myview, MODEL=mymodel, WINDOW=mywindow, $
              CONTAINER=mycontainer, XAXIS=myxaxis, YAXIS=myyaxis, $
	      PLOT=myplot, _extra=e

; If no data provided, create some default data.
IF (N_ELEMENTS(data) EQ 0) THEN data = randomu(seed,100)

; Create Container, Window, View, and Model objects.

mycontainer = OBJ_NEW('IDL_Container')
mywindow = OBJ_NEW('IDLgrWindow')
myview = OBJ_NEW('IDLgrView')
mymodel = OBJ_NEW('IDLgrModel')

; Create a font object.

myfont = OBJ_NEW('IDLgrFont', 'times')

; Create a plot object using data specified at the command line.

myplot = OBJ_NEW('IDLgrPlot', data, COLOR=[200,100,200])

; Pass any extra keywords to obj_plot to the SetProperty method of the
; plot object.

myplot ->SetProperty, _extra=e

; Retrieve the data ranges from the plot object, and convert to
; normalized coordinates using the norm_coord function we created.

myplot -> GetProperty, XRANGE=xr, YRANGE=yr
myplot->SetProperty, XCOORD_CONV=norm_coord(xr), YCOORD_CONV=norm_coord(yr)

; Create X and Y axis objects with appropriate ranges, and convert
; to normalized coordinates. Set the tick lengths to 5% of the data
; range (which is now nomralized to 0.0-1.0).

myxaxis = OBJ_NEW('IDLgrAxis', 0, RANGE=[xr[0], xr[1]])
myxaxis -> SetProperty, XCOORD_CONV=norm_coord(xr)
myyaxis = OBJ_NEW('IDLgrAxis', 1, RANGE=[yr[0], yr[1]])
myyaxis -> SetProperty, YCOORD_CONV=norm_coord(yr)
myxaxis -> SetProperty, TICKLEN=0.05
myyaxis -> SetProperty, TICKLEN=0.05

; Add the model object to the view object, and the plot and axis objects
; to the model object.

myview -> Add, mymodel
mymodel -> Add, myplot
mymodel -> Add, myxaxis
mymodel -> Add, myyaxis

; Set an appropriate viewplane rectangle and zclip region for the view.

SET_VIEW, myview, mywindow

; Add a Title to the X axis.

xtext = OBJ_NEW('IDLgrText', 'X Title', FONT=myfont)
myxaxis -> SetProperty, TITLE=xtext

; Add all objects to the container object. Destroying the container
; will destroy all of its contents.

mycontainer -> Add, mywindow
mycontainer -> Add, myview
mycontainer -> Add, myfont
mycontainer -> Add, xtext

; Draw the object tree.

mywindow -> Draw, myview

val=''
READ, val, PROMP='Press <Return> to Redraw.'
mywindow -> Draw, myview

READ, val, PROMP='Destroy objects? (y/n) [y]: '
IF (STRPOS(STRUPCASE(val),'N') EQ -1) THEN $
    OBJ_DESTROY, mycontainer

END
