; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/ex_reverse_plot.pro#2 $
;
; Copyright (c) 2000-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   EX_REVERSE_PLOT
;
; PURPOSE:
;   This procedure displays a plot with the X and/or Y axis optionally
;   reversed.
;
; CATEGORY:
;   Object Graphics.
;
; CALLING SEQUENCE:
;
;   EX_REVERSE_PLOT, [[X,] Y]
;
; INPUTS:
;   If neither X nor Y are supplied, ex_reverse_plot will
;   display an example vector of Y values.
;
; OPTIONAL INPUTS:
;   Y:  A vector of values representing the ordinate data to be
;       plotted.
;   X:  A vector of values representing the X values for the plot.
;       If X is present, Y is plotted as a function of X.  If X
;       is not present, Y is plotted as a function of the Y value
;       index (starting at zero).
;
; KEYWORD PARAMETERS:
;   PLOT_PROPERTIES:    Set this keyword to an anonymous structure
;       containing property values for the IDLgrPlot object that is
;       used for the display.  For each field within this structure
;       whose name matches a property for an IDLgrPlot object, its
;       value will be used to set that property for the plot.
;
;   XAXIS_PROPERTIES:   Set this keyword to an anonymous structure
;       containing property values for the IDLgrAxis object that is
;       used for the X axis of the display.  For each field within
;       this structure whose name matches a property for an IDLgrAxis
;       object, its value will be used to set that property for the
;       X axis.
;
;   XRANGE: Set this keyword to a two-element vector representing the
;       desired range for the X axis.  If the first element is
;       greater than the second element, the X axis will be drawn
;       with tick values in reverse order and the display of the
;       plotted data will be adjusted accordingly.  The default
;       xrange runs from the minimum x value to the maximum x
;       value without reversal.
;
;   YAXIS_PROPERTIES:   Set this keyword to an anonymous structure
;       containing property values for the IDLgrAxis object that is
;       used for the Y axis of the display.  For each field within
;       this structure whose name matches a property for an IDLgrAxis
;       object, its value will be used to set that property for the
;       Y axis.
;
;   YRANGE: Set this keyword to a two-element vector representing the
;       desired range for the Y axis.  If the first element is
;       greater than the second element, the Y axis will be drawn
;       with tick values in reverse order and the display of the
;       plotted data will be adjusted accordingly.  The default
;       yrange runs from the minimum y value to the maximum y
;       value without reversal.
;
;   MODAL: Set this keyword to block processing of events from other
;       widgets until the user quits ex_reverse_plot.  A group
;       leader must be specified (via the GROUP keyword to
;       ex_reverse_plot).
;
;   GROUP: The ID of a widget that will act as "group leader" to
;       ex_reverse_plot.  A death of this group leader results in
;       a death of this instance of ex_reverse_plot.
;
; PROCEDURE:
;   The axes for a reverse axis plot are generated primarily by
;   modifying the baseline and updir of the tick labels and rotating
;   the entire plot.  To ensure the rotated plot looks correct, the
;   location of the axes, the direction of tickmarks, and positioning of
;   labels relative to the axis are also adjusted.  The results are
;   displayed using the XOBJVIEW tool.
;
; EXAMPLE:
;
;   Create a plot of values running from 0 to 99 with the Y axis
;       reversed:
;
;       EX_REVERSE_PLOT, FINDGEN(100), YRANGE=[100,0]
;
;   Create the same plot, with the reversed Y axis, but with a
;       red dashed plotline:
;       EX_REVERSE_PLOT, FINDGEN(100), YRANGE=[100,0], $
;                    PLOT_PROPERTIES={COLOR:[255b,0,0], LINESTYLE:2l}
;
; MODIFICATION HISTORY:
;   Written by: DLD, May 2000.
;-

PRO ex_Reverse_Plot, x, y, $
                     PLOT_PROPERTIES=plot_properties, $
                     XAXIS_PROPERTIES=xaxis_properties, $
                     XRANGE=inXRange, $
                     YAXIS_PROPERTIES=yaxis_properties, $
                     YRANGE=inYRange, $
                     MODAL=modal, $
                     GROUP=group

    ON_ERROR, 2 ; Return to caller on error.

    if N_ELEMENTS(group) gt 0 then begin
        if SIZE(group, /TNAME) ne 'LONG' then $
            MESSAGE, 'GROUP must be of type long.'
        if not WIDGET_INFO(group, /VALID) then $
            MESSAGE, 'GROUP leader is not a valid widget.'
    end

    if KEYWORD_SET(modal) then begin
        if not KEYWORD_SET(group) then $
            MESSAGE, 'MODAL requires a GROUP leader widget.'
    end

    ; Determine number of arguments provided.  If only one argument
    ; provided, use it as the y data to be plotted, and generate
    ; indices for x.  If two arguments provided, accept as is.
    if (N_ELEMENTS(x) eq 0) then begin
        x = FINDGEN(101)
        x = SIN(x/5) / EXP(x/50)
        x = x + 1
        x = x * 50
        color = [0, 0, 255]
        default_data = 1b ; we are using default data.
    endif else $
        default_data = 0b ; we are not using default data.

    if (N_ELEMENTS(y) eq 0) then begin
        y = x
        x = FINDGEN(N_ELEMENTS(y))
    endif

    ; Compute the range of the data to be plotted.
    xmin = MIN(x, MAX=xmax)
    ymin = MIN(y, MAX=ymax)

    ; Reverse the ranges as needed and set reverse flags.
    if (N_ELEMENTS(inXRange) ne 2) then begin
        xrange = [xmin,xmax]
        xReverse = 0b
    endif else begin
        if (inXRange[0] gt inXRange[1]) then begin
            xrange = REVERSE(inXRange)
            xReverse = 1b
        endif else begin
            xrange = inXRange
            xReverse = 0b
        endelse
    endelse
    if (N_ELEMENTS(inYRange) ne 2) then begin
        yrange = [ymin,ymax]
        yReverse = default_data ? 1b : 0b
    endif else begin
        if (inYRange[0] gt inYRange[1]) then begin
            yrange = REVERSE(inYRange)
            yReverse = 1b
        endif else begin
            yrange = inYRange
            yReverse = 0b
        endelse
    endelse

    ; Determine the axis configuration to use based on the reverse flags.
    iconfig = 0l
    if (xReverse ne 0) then iconfig = iconfig + 1
    if (yReverse ne 0) then iconfig = iconfig + 2

    ; Set up the textbaseline, textupdir, axis locations, tick directions,
    ; and axis text positions for each of the four configurations:
    CASE iconfig OF
	    0: BEGIN ;   0 = standard x-axis, standard y-axis
		    textbaseline=[ 1, 0, 0]
		    textupdir=   [ 0, 1, 0]
		    xlocs = 0
		    ylocs = 0
		    xtickdirs = 0
		    ytickdirs = 0
		    xtextpos =  0
		    ytextpos =  0
                    y_xalign = (ytextpos eq 0) ? 1.0 : 0.0
		   END
	    1: BEGIN ;   1 = reversed x-axis, standard y-axis
		    textbaseline=[-1, 0, 0]   ; flip all tick labels left-to-right
		    textupdir=   [ 0, 1, 0]
		    xlocs = 0
		    ylocs = 1   ; move y-axis to left
		    xtickdirs = 0
		    ytickdirs = 1  ; draw tick marks toward decreasing X
		    xtextpos =  0
		    ytextpos =  1  ; draw Y tick labels on side of increasing X
                    y_xalign = (ytextpos eq 0) ? 0.0 : 1.0
	       END
	    2: BEGIN ;   2 = standard x-axis, reversed y-axis
		    textbaseline=[ 1, 0, 0]
		    textupdir=   [ 0,-1, 0]   ; flip Y tick labels upside down
		    xlocs = 1   ; move x-axis to bottom
		    ylocs = 0
		    xtickdirs = 1  ; draw tick marks toward decreasing Y
		    ytickdirs = 0
		    xtextpos =  1  ; draw X tick labels on side of increasing Y
		    ytextpos =  0
                    y_xalign = (ytextpos eq 0) ? 1.0 : 0.0
	       END
	    3: BEGIN ;   3 = reversed x-axis, reversed y-axis
		    textbaseline=[-1, 0, 0]   ; flip X tick labels left-to-right
		    textupdir=   [ 0,-1, 0]   ; flip Y tick labels upside down
		    xlocs = 1   ; move x-axis to bottom
		    ylocs = 1   ; move y-axis to left
		    xtickdirs = 1  ; draw tick marks toward decreasing Y
		    ytickdirs = 1  ; draw tick marks toward decreasing X
		    xtextpos =  1  ; draw X tick labels on side of increasing Y
		    ytextpos =  1  ; draw Y tick labels on side of increasing X
                    y_xalign = (ytextpos eq 0) ? 0.0 : 1.0
	       END
    ENDCASE

    ; Create the X axis.
    xticklen = 0.02 * (ymax-ymin)
    oXAxis = OBJ_NEW('IDLgrAxis', 0, RANGE=xrange, $
                      TICKDIR=xtickdirs, TICKLEN=xticklen, $
                      TEXTPOS=xtextpos, $
                      TEXTALIGNMENTS=[0.5,1.0], $
                      TEXTBASELINE=textbaseline, $
                      TEXTUPDIR=textupdir, $
                      _EXTRA=xaxis_properties)
    oXAxis->GetProperty, CRANGE=xcrange

    ; Create the Y axis.
    yticklen = 0.02 * (xmax - xmin)
    oYAxis = OBJ_NEW('IDLgrAxis', 1, RANGE=yrange, $
                      TICKDIR=ytickdirs, TICKLEN=yticklen, $
                      TEXTPOS=ytextpos, $
                      TEXTALIGNMENTS=[y_xalign,0.5], $
                      TEXTBASELINE=textbaseline, $
                      TEXTUPDIR=textupdir, $
                      _EXTRA=yaxis_properties)
    oYAxis->GetProperty, CRANGE=ycrange

    ; Position the X and Y axis at the appropriate end of the other axis.
    loc = [xcrange[ylocs],ycrange[xlocs]]
    oXAxis->SetProperty, LOCATION=loc
    oYAxis->SetProperty, LOCATION=loc

    ; Create the plot object.
    oPlot = OBJ_NEW('IDLgrPlot', x, y, _EXTRA=plot_properties, COLOR=color)

    ; Place the axes and the plot in a model.
    oModel = OBJ_NEW('IDLgrModel')
    oModel->Add, oXAxis
    oModel->Add, oYAxis
    oModel->Add, oPlot
    oModel->Scale, (ycrange[1]-ycrange[0]) / (xcrange[1]-xcrange[0]), 1, 1

    ; Apply the appropriate rotation(s) for the axis configuration.
    if (xReverse ne 0b) then $
        oModel->Rotate, [0,1,0], 180

    if (yReverse ne 0b) then $
        oModel->Rotate, [1,0,0], 180

    ; Display the results.
    XOBJVIEW, oModel, /BLOCK, MODAL=modal, GROUP=group

    OBJ_DESTROY, oModel
END