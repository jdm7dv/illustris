; $Id: //depot/idl/IDL_70/idldir/examples/doc/objects/obj_logaxis.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;

PRO obj_logaxis

    ; Create a window and a view.
    oWindow = OBJ_NEW('IDLgrWindow')
    oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-0.2,-0.2,1.4,1.4])

    ; Create a model for the graphics; add to the view.
    oModel = OBJ_NEW('IDLgrModel')
    oView->Add, oModel

    ; Create some simple data.
    yData = FINDGEN(50)*20.

    ; Compute data range in X and Y.
    yMin = MIN(yData, MAX=yMax)
    yRange = yMax - yMin
    xMin = 0
    xMax = N_ELEMENTS(yData)-1
    xRange = xMax - xMin

    ; Create an X-axis with a title.
    oXTitle = OBJ_NEW('IDLgrText', 'Linear X Axis')
    oXAxis = OBJ_NEW('IDLgrAxis', 0, RANGE=[xmin,xmax], $
	TICKLEN=(0.1*yRange), TITLE=oXTitle)
    oModel->Add, oXAxis

    ; Create a Y-axis with a title.
    oYTitle = OBJ_NEW('IDLgrText','Linear Y Axis')
    oYAxis = OBJ_NEW('IDLgrAxis', 1, RANGE=[yMin,yMax], $
	TICKLEN=(0.1*xRange), TITLE=oYTitle)
    oModel->Add, oYAxis

    ; Create a plot of the data.
    oPlot = OBJ_NEW('IDLgrPlot', yData, COLOR=[255,0,0])
    oModel->Add, oPlot

    ; Scale and translate the model so the plot will fit within the view.
    oModel->Scale, 1.0/xRange, 1.0/yRange, 1.0
    oModel->Translate, -(xMin/xRange), -(yMin/yRange), 0.0

    ; Ensure that axis text recomputes its dimensions as needed.
    oXAxis->GetProperty, TICKTEXT=oXTickText
    oXTitle->SetProperty, RECOMPUTE_DIMENSIONS=2
    oXTickText->SetProperty, RECOMPUTE_DIMENSIONS=2
    oYAxis->GetProperty, TICKTEXT=oYTickText
    oYTickText->SetProperty, RECOMPUTE_DIMENSIONS=2
    oYTitle->SetProperty, RECOMPUTE_DIMENSIONS=2

    ; Draw the plot.
    oWindow->Draw, oView

    ; Refresh the plot when ready.
    val=''
    READ, val, PROMPT='Press <Return> to refresh the window.'
    oWindow->Draw, oView

    ; Now that the original plot has been displayed, switch to a
    ; logarithmic version of the plot when ready.
    READ, val, PROMPT='Press <Return> to draw with a logarithmic Y axis.'

    ; Only positive values are valid when computing the logarithmic data.
    posElts = WHERE(yData GT 0, nPos)
    IF (nPos GT 0) THEN BEGIN
        ; Compute new Y range.
        yValidData = yData[posElts]
        yValidMin = MIN(yValidData, MAX=yValidMax)

        ; Compute logarithmic data.
        yLogData = ALOG10(yValidData)

        ; Update the plot data.  
        oPlot->Setproperty, DATAY=yLogData
    ENDIF ELSE BEGIN
        MESSAGE, 'Original plot data is entirely non-positive.',/INFORMATIONAL
        MESSAGE, '  Log plot will contain no data.',/NOPREFIX, /INFORMATIONAL

        ; Create a fake log axis range.
        yValidMin = 1.0
        yValidMax = 10.0

        ; Simply hide the plot, since no valid log data exists.
        oPlot->SetProperty, /HIDE
    ENDELSE

    ; Update the Y axis to be logarithmic, and modify the Y axis title. 
    oYAxis->SetProperty, /LOG, RANGE=[yValidMin, yValidMax]
    oYTitle->SetProperty, STRING='Logarithmic Y Axis'

    ; Get the new Y axis logarithmic range.
    oYAxis->GetProperty, CRANGE=crange
    yLogMin = crange[0]
    yLogMax = crange[1]
    yLogRange = yLogMax - yLogMin

    ; Update the X axis ticklen.
    oXAxis->SetProperty, TICKLEN=(0.1*yLogRange), $
                         LOCATION=[0,yLogMin,0]

    ; Update the model transform to match the new data ranges.
    oModel->Reset
    oModel->Scale, 1.0/xRange, 1.0/yLogRange, 1.0
    oModel->Translate, -(xMin/xRange), $
                       -(yLogMin/yLogRange), 0.0

    oWindow->Draw, oView

    READ, val, PROMPT='Press <Return> to quit.'
    
    OBJ_DESTROY, oView
    OBJ_DESTROY, oWindow
    OBJ_DESTROY, oXTitle
    OBJ_DESTROY, oYTitle
END
