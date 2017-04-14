; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_roi.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
PRO DemoROI$Read_Image, File, TrueColorImage, ColorTable
;
; Modify this routine to read specific image types other
; than JPEG.
;
READ_JPEG, File, TrueColorImage, /TRUE
END


PRO DemoROI$Read_File_And_Initialize, pDemo$State, File = File
;
; This routine reads the image file (expected to be a
; JPEG) and initializes the environment.
;
IF (N_ELEMENTS(File) EQ 0) THEN BEGIN
   File = DIALOG_PICKFILE(Filter = "*.jpg")
   IF (File EQ '') THEN BEGIN
      RETURN
   ENDIF
ENDIF
WIDGET_CONTROL, /HOURGLASS
DemoROI$Read_Image, File, TrueColorImage
;
; If the image red was not a three-level TrueColor
; image, then stack the image.  (This may need
; some more work.)
;
SizeOfTrueColor = SIZE(TrueColorImage)
IF (SizeOfTrueColor[0] NE 3) THEN BEGIN
   TC = BYTARR(3, SizeOfTrueColor[1], SizeOfTrueColor[2])
   FOR I = 0, 2 DO BEGIN
      TC[I, *, *] = TrueColorImage
   ENDFOR
   TrueColorImage = TC
ENDIF
Demo$State = *pDemo$State
;
; If specified, rebin the image to fit the
; maximum window size.
;
SizeOfImage = SIZE(TrueColorImage)
IF (Demo$State.ScaleImagesToFit) THEN BEGIN
   IF ((SizeOfImage[2] GT Demo$State.MaxWindowDimension) OR $
       (SizeOfImage[3] GT Demo$State.MaxWindowDimension)) THEN BEGIN
      Scale = MAX([SizeOfImage[2]/$
         FLOAT(Demo$State.MaxWindowDimension), SizeOfImage[3]/ $
         FLOAT(Demo$State.MaxWindowDimension)])
      TrueColorImage = CONGRID(TrueColorImage, 3, $
         SizeOfImage[2]/Scale, SizeOfImage[3]/Scale)
      Demo$State.SizeOfImage = SIZE(TrueColorImage)
   ENDIF ELSE BEGIN
      Demo$State.SizeOfImage = SizeOfImage
   ENDELSE
ENDIF ELSE BEGIN
   Demo$State.SizeOfImage = SizeOfImage
ENDELSE
XSize = Demo$State.SizeOfImage[2]
YSize = Demo$State.SizeOfImage[3]
;
; Destroy the draw window and create a new
; one to fit the image.
;
Widgets = TEMPORARY(*Demo$State.pWidgets)
WIDGET_CONTROL, Widgets.DrawWidget, /DESTROY
IF (Demo$State.ImageScrollbars) THEN BEGIN
   IF ((Demo$State.MaxWindowDimension LT XSize) OR $
       (Demo$State.MaxWindowDimension LT YSize)) THEN BEGIN
      Widgets.DrawWidget = $
         WIDGET_DRAW(Widgets.ImageBase, $
         XSIZE = XSize, YSIZE = YSize, $
         X_Scroll_Size = XSize < Demo$State.MaxWindowDimension, $
         Y_Scroll_Size = YSize < Demo$State.MaxWindowDimension, $
         RETAIN = 2)
   ENDIF ELSE BEGIN
      Widgets.DrawWidget = WIDGET_DRAW(Widgets.ImageBase, $
         XSIZE = XSize, YSIZE = YSize, RETAIN = 2)
   ENDELSE
ENDIF ELSE BEGIN
   Widgets.DrawWidget = WIDGET_DRAW(Widgets.ImageBase, $
      XSIZE = XSize, YSIZE = YSize, RETAIN = 2)
ENDELSE
WIDGET_CONTROL, Widgets.DrawWidget, GET_VALUE = NewWindowID
Demo$State.ImageWindow = NewWindowID
;
; Erase the draw window.
;
WSET, Demo$State.ImageWindow
ERASE, 0
IF (Demo$State.HistoWindow NE 0) THEN BEGIN
   WSET, Demo$State.HistoWindow
   ERASE, 0
ENDIF
;
; Create the new image and "ghost image" pixmaps.
;
IF (Demo$State.ImagePixmap NE 0) THEN BEGIN
   WDELETE, Demo$State.ImagePixmap
ENDIF
WINDOW, /PIXMAP, /FREE, XSIZE = XSize, YSIZE = YSize
Demo$State.ImagePixmap = !D.WINDOW
ERASE, 0
IF (Demo$State.GrayBackgroundImagePixmap NE 0) THEN BEGIN
   WDELETE, Demo$State.GrayBackgroundImagePixmap
ENDIF
WINDOW, /PIXMAP, /FREE, XSIZE = XSize, YSIZE = YSize
Demo$State.GrayBackgroundImagePixmap = !D.WINDOW
;
; Display the image into the pixmap.
;
WSET, Demo$State.ImagePixmap
DEVICE, GET_VISUAL_DEPTH=visual_depth
DEVICE, GET_DECOMPOSED=decomp
IF (visual_depth gt 8 and decomp) THEN BEGIn
   TV, TrueColorImage, TRUE = 1
   RGBImage = 0B
ENDIF ELSE BEGIN
   RGBImage = COLOR_QUAN(TrueColorImage, 1, R, G, B, $
      COLORS = !D.TABLE_SIZE - Demo$State.NReservedColors - 1) + $
      Demo$State.NReservedColors
   Demo$State.BackgroundColor = MIN(R + G + B)
   Gray = INDGEN(Demo$State.NReservedColors) * 20
   TVLCT, [Gray, R, 255], [Gray, G, 255], [Gray, B, 255]
   TV, RGBImage
ENDELSE
;
; Initialize the flags, buttons, and widgets.
;
Demo$State.Initialized = 0B
Demo$State.GhostBackground = 0
Demo$State.ManualCenter = [0., 0.]
Demo$State.PreviousCenter = [0., 0.]
WIDGET_CONTROL, Widgets.DrawWidget, $
   DRAW_BUTTON_EVENTS = Demo$State.ManualMode
WIDGET_CONTROL, Widgets.GhostOnButton2, SET_BUTTON = 0
WIDGET_CONTROL, Widgets.GhostOffButton2, /SET_BUTTON
WIDGET_CONTROL, Widgets.GhostOnButton, SET_BUTTON = 0
WIDGET_CONTROL, Widgets.GhostOffButton, /SET_BUTTON
WIDGET_CONTROL, Widgets.GhostBase, SENSITIVE = 0
WIDGET_CONTROL, Widgets.ApplyButton, SENSITIVE = 1
WIDGET_CONTROL, Widgets.DisplayOrigImgButton2, SENSITIVE = 1
WIDGET_CONTROL, Widgets.IdentifyROIsButton, SENSITIVE = 1
WIDGET_CONTROL, Widgets.DisplayOrigImgButton, SENSITIVE = 1
;
; Free up any existing object pointers.
;
IF (PTR_VALID(Demo$State.pObjects)) THEN BEGIN
   VPtr = PTR_VALID(*Demo$State.pObjects)
   OkayPtr = WHERE(VPtr NE 0, NOkayPtr)
   IF (NOkayPtr NE 0) THEN BEGIN
      PTR_FREE, (*Demo$State.pObjects)[OkayPtr]
   ENDIF
   PTR_FREE, Demo$State.pObjects
ENDIF
;
; Save the image information into the state
; structure.
;
*Demo$State.pTrueColorImage = TEMPORARY(TrueColorImage)
*Demo$State.pRGBImage = TEMPORARY(RGBImage)
*Demo$State.pWidgets = TEMPORARY(Widgets)
*pDemo$State = TEMPORARY(Demo$State)
;
; Continue processing.
;
DemoROI$Generate_Gray_Background, pDemo$State
DemoROI$Weight_Image_By_Layer, pDemo$State
DemoROI$Display_Original_Image, pDemo$State
END


FUNCTION DemoROI$Histogram, pDemo$State, SurfaceBrightness
;
; This routine calculates the distribution of surface
; brightness among the objects.  Surface brightness
; is defined as the sum of the pixels in the R, G,
; and B planes divided by the area of the object.
;
Status = 1
Demo$State = *pDemo$State
IF (Demo$State.DemoMode) THEN BEGIN
   Widgets = TEMPORARY(*Demo$State.pWidgets)
   WIDGET_CONTROL, Widgets.AstroStatusLabel, SET_VALUE = $
      'Calculating brightness distribution...'
   *Demo$State.pWidgets = TEMPORARY(Widgets)
ENDIF
;
; Just use IDL's HISTOGRAM function.
;
Histo = HISTOGRAM(SurfaceBrightness, REVERSE_INDICES = R, $
   MAX = 765, MIN = 0)
;
; Display the histogram, if specified.
;
IF (Demo$State.HistoWindow NE 0) THEN BEGIN
   WSET, Demo$State.HistoWindow
   PLOT, Histo, XSTYLE = 4, YSTYLE = 4, YMARGIN = [0, 0], $
      XMARGIN = [0, 0], COLOR = Demo$State.ColorWhite
   XYOUTS, .5, .9, 'Max Cts/Pixel = ' + STRTRIM(N_ELEMENTS(Histo), 2), $
      /NORMAL, ALIGNMENT = .5
ENDIF
;
; The selection criteria may be too tight.
;
NHisto = N_ELEMENTS(Histo)
IF (NHisto LT Demo$State.MinBrightness) THEN BEGIN
   v = DIALOG_MESSAGE('Minimum brightness value is set too low.' + $
      '  The minimum data value is ' + $
      STRTRIM(NHisto, 2) + ' counts per pixel.')
   Status = 0
ENDIF
;
; Save the histogram data.
;
*Demo$State.pHistogram = {Histogram : Histo, ReverseIndices : R}
*pDemo$State = TEMPORARY(Demo$State)
RETURN, Status
END


PRO DemoROI$Display_Chosen_Subset, pDemo$State, $
   Hide_First_Pass = Hide_First_Pass, No_Histogram = No_Histogram
;
; This routine displays the chosen objects from the image.
;
Demo$State = *pDemo$State
RGBImage = TEMPORARY(*Demo$State.pRGBImage)
TrueColorImage = TEMPORARY(*Demo$State.pTrueColorImage)
pObjects = TEMPORARY(*Demo$State.pObjects)
WSET, Demo$State.ImageWindow
DEVICE, GET_VISUAL_DEPTH=visual_depth
DEVICE, GET_DECOMPOSED=decomp
IF (NOT KEYWORD_SET(Hide_First_Pass)) THEN BEGIN
;
; The visual sort is just for effect.  No real processing
; is done here.  The objects are displayed according
; to their ranking in the surface brightness distribution
; with fainter objects displayed first.
;
   IF (Demo$State.DemoMode) THEN BEGIN
      Widgets = TEMPORARY(*Demo$State.pWidgets)
      WIDGET_CONTROL, Widgets.AstroStatusLabel, SET_VALUE = $
         'Sorting by surface brightness...'
      *Demo$State.pWidgets = TEMPORARY(Widgets)
   ENDIF
   Histogram = TEMPORARY(*Demo$State.pHistogram)
   IF (visual_depth GT 8 and decomp) THEN BEGIN
;
; TrueColor display.
;
      FOR I = Demo$State.MinBrightness, $
         MIN([N_ELEMENTS(Histogram.Histogram) - 1, $
         Demo$State.MaxBrightness]) DO BEGIN
         IF (Histogram.ReverseIndices[I] NE $
            Histogram.ReverseIndices[I + 1]) THEN BEGIN
            These = Histogram.ReverseIndices[ $
               Histogram.ReverseIndices[I] : $
               Histogram.ReverseIndices[I + 1] - 1]
            DEVICE, COPY = [0, 0, Demo$State.SizeOfImage[2], $
                  Demo$State.SizeOfImage[3], 0, 0, $
                  Demo$State.GrayBackgroundImagePixmap]
            WSET, Demo$State.ImageWindow
            FOR J = 0L, N_ELEMENTS(These) - 1 DO BEGIN
               Object = TEMPORARY(*pObjects[These[J]])
               TV, TrueColorImage[*, $
                  Object.Origin[0]:Object.Origin[0] + $
                  Object.Extents[0] - 1, $
                  Object.Origin[1]:Object.Origin[1] + $
                  Object.Extents[1] - 1],$
                  MIN(Object.Perimeter[*, 0]), $
                  MIN(Object.Perimeter[*, 1]), TRUE = 1
               *pObjects[These[J]] = TEMPORARY(Object)
            ENDFOR
         ENDIF
      ENDFOR
   ENDIF ELSE BEGIN
;
; 256 color mode.
;
      FOR I = Demo$State.MinBrightness, $
         MIN([N_ELEMENTS(Histogram.Histogram) - 1, $
         Demo$State.MaxBrightness]) DO BEGIN
         IF (Histogram.ReverseIndices[I] NE $
            Histogram.ReverseIndices[I + 1]) THEN BEGIN
            These = Histogram.ReverseIndices[ $
               Histogram.ReverseIndices[I] : $
               Histogram.ReverseIndices[I + 1] - 1]
            DEVICE, COPY = [0, 0, Demo$State.SizeOfImage[2], $
                  Demo$State.SizeOfImage[3], 0, 0, $
                  Demo$State.GrayBackgroundImagePixmap]
            WSET, Demo$State.ImageWindow
            FOR J = 0L, N_ELEMENTS(These) - 1 DO BEGIN
               Object = TEMPORARY(*pObjects[These[J]])
               TV, RGBImage[Object.Origin[0]:Object.Origin[0] + $
                  Object.Extents[0] - 1, $
                  Object.Origin[1]:Object.Origin[1] + $
                  Object.Extents[1] - 1], $
                  MIN(Object.Perimeter[*, 0]), $
                  MIN(Object.Perimeter[*, 1])
               *pObjects[These[J]] = TEMPORARY(Object)
            ENDFOR
         ENDIF
      ENDFOR
   ENDELSE
   *Demo$State.pHistogram = TEMPORARY(Histogram)
ENDIF
;
; If ghosting, display the gray scale layer,
; otherwise erase to black.
;
IF (Demo$State.GhostBackground) THEN BEGIN
   DEVICE, COPY = [0, 0, Demo$State.SizeOfImage[2], $
      Demo$State.SizeOfImage[3], 0, 0, $
      Demo$State.GrayBackgroundImagePixmap]
ENDIF ELSE BEGIN
   ERASE, 0
ENDELSE
IF (Demo$State.DemoMode) THEN BEGIN
   Widgets = TEMPORARY(*Demo$State.pWidgets)
   WIDGET_CONTROL, Widgets.AstroStatusLabel, SET_VALUE = $
      'Displaying ROIs...'
   *Demo$State.pWidgets = TEMPORARY(Widgets)
ENDIF
IF (NOT KEYWORD_SET(No_Histogram)) THEN BEGIN
;
; Display objects in groups based on sorting
; order by surface brightness.
;
   Histogram = TEMPORARY(*Demo$State.pHistogram)
   IF (visual_depth GT 8 and decomp) THEN BEGIN
;
; TrueColor mode.
;
      FOR I = Demo$State.MinBrightness, $
         MIN([N_ELEMENTS(Histogram.Histogram) - 1, $
         Demo$State.MaxBrightness]) DO BEGIN
         IF (Histogram.ReverseIndices[I] NE $
            Histogram.ReverseIndices[I + 1]) THEN BEGIN
            These = Histogram.ReverseIndices[ $
               Histogram.ReverseIndices[I]: $
               Histogram.ReverseIndices[I + 1] - 1]
            FOR J = 0L, N_ELEMENTS(These) - 1 DO BEGIN
               Object = TEMPORARY(*pObjects[These[J]])
               GrayImage = TVRD(Object.Origin[0], Object.Origin[1], $
                  Object.Extents[0], Object.Extents[1], TRUE = 1)
               ColorSubImage = TrueColorImage[*, Object.Origin[0]: $
                  Object.Origin[0] + Object.Extents[0] - 1, $
                  Object.Origin[1]:Object.Origin[1] + $
                  Object.Extents[1] - 1]
               SubImagePixels = WHERE(Object.BiLevelMask NE 0)
               FOR K = 0, 2 DO BEGIN
                  G1 = REFORM(GrayImage[K, *, *])
                  C1 = REFORM(ColorSubImage[K, *, *])
                  G1[SubImagePixels] = C1[SubImagePixels]
                  GrayImage[K, *, *] = G1
               ENDFOR
               TV, GrayImage, Object.Origin[0], Object.Origin[1], TRUE = 1
               *pObjects[These[J]] = TEMPORARY(Object)
            ENDFOR
         ENDIF
      ENDFOR
   ENDIF ELSE BEGIN
;
; 256 color mode.
;
      FOR I = Demo$State.MinBrightness, $
         MIN([N_ELEMENTS(Histogram.Histogram) - 1, $
         Demo$State.MaxBrightness]) DO BEGIN
         IF (Histogram.ReverseIndices[I] NE $
            Histogram.ReverseIndices[I + 1]) THEN BEGIN
            These = Histogram.ReverseIndices[ $
               Histogram.ReverseIndices[I]: $
               Histogram.ReverseIndices[I + 1] - 1]
            FOR J = 0L, N_ELEMENTS(These) - 1 DO BEGIN
               Object = TEMPORARY(*pObjects[These[J]])
               GrayImage = TVRD(Object.Origin[0], Object.Origin[1], $
                  Object.Extents[0], Object.Extents[1])
               ColorSubImage = RGBImage[Object.Origin[0]: $
                  Object.Origin[0] + Object.Extents[0] - 1, $
                  Object.Origin[1]:Object.Origin[1] + $
                  Object.Extents[1] - 1]
               SubImagePixels = WHERE(Object.BiLevelMask NE 0)
               GrayImage[SubImagePixels] = ColorSubImage[SubImagePixels]
               TV, GrayImage, Object.Origin[0], Object.Origin[1]
               *pObjects[These[J]] = TEMPORARY(Object)
            ENDFOR
         ENDIF
      ENDFOR
   ENDELSE
   *Demo$State.pHistogram = TEMPORARY(Histogram)
ENDIF ELSE BEGIN
;
; In this mode we dispense with the sorting the objects
; by brightness and just display them
;
   IF (visual_depth GT 8 and decomp) THEN BEGIN
;
; TrueColor display.
;
      FOR I = 0L, N_ELEMENTS(pObjects) - 1 DO BEGIN
         Object = TEMPORARY(*pObjects[I])
         IF ((!D.X_SIZE LT Object.Extents[0]) OR $
             (!D.Y_SIZE LT Object.Extents[1])) THEN BEGIN
            v = DIALOG_MESSAGE('problem with sizes', /info)
         ENDIF
;
; Read the background that's currently displayed.
;
         GrayImage = TVRD(Object.Origin[0], Object.Origin[1], $
            Object.Extents[0], Object.Extents[1], TRUE = 1)
;
; Get the subimage of the TrueColor image that surrounds the
; object.
;
         ColorSubImage = TrueColorImage[*, $
            Object.Origin[0]:Object.Origin[0] + Object.Extents[0] - 1, $
            Object.Origin[1]:Object.Origin[1] + Object.Extents[1] - 1]
;
; Determine which pixels in the subimage actually belong to the
; object.
;
         SubImagePixels = WHERE(Object.BiLevelMask NE 0)
         IF (N_ELEMENTS(SubImagePixels) NE Object.Extents[0]*Object.Extents[1]) THEN BEGIN
;
; Replace the pixels in the background subimage with the pixels
; belonging to the object.
;
            Xs = SubImagePixels MOD Object.Extents[0]
            Ys = SubImagePixels/Object.Extents[0]
            FOR J = 0, 2 DO BEGIN
               GrayImage[J, Xs, Ys] = ColorSubImage[J, Xs, Ys]
            ENDFOR
         ENDIF ELSE BEGIN
            GrayImage = ColorSubImage
         ENDELSE
;
; Put the modified subimage back into the window.
;
         TV, GrayImage, Object.Origin[0], Object.Origin[1], TRUE = 1
         *pObjects[I] = TEMPORARY(Object)
      ENDFOR
   ENDIF ELSE BEGIN
;
; 256 color mode.
;
      FOR I = 0L, N_ELEMENTS(pObjects) - 1 DO BEGIN
         Object = TEMPORARY(*pObjects[I])
         IF ((!D.X_SIZE LT Object.Extents[0]) OR $
             (!D.Y_SIZE LT Object.Extents[1])) THEN BEGIN
            v = DIALOG_MESSAGE('problem with sizes', /info)
         ENDIF
         GrayImage = TVRD(Object.Origin[0], Object.Origin[1], $
            Object.Extents[0], Object.Extents[1])
         ColorSubImage = RGBImage[Object.Origin[0]:Object.Origin[0] + $
            Object.Extents[0] - 1, $
            Object.Origin[1]:Object.Origin[1] + Object.Extents[1] - 1]
         SubImagePixels = WHERE(Object.BiLevelMask NE 0)
         GrayImage[SubImagePixels] = ColorSubImage[SubImagePixels]
         TV, GrayImage, Object.Origin[0], Object.Origin[1]
         *pObjects[I] = TEMPORARY(Object)
      ENDFOR
   ENDELSE
ENDELSE
IF (Demo$State.DemoMode) THEN BEGIN
   Widgets = TEMPORARY(*Demo$State.pWidgets)
   WIDGET_CONTROL, Widgets.AstroStatusLabel, SET_VALUE = ''
   *Demo$State.pWidgets = TEMPORARY(Widgets)
ENDIF
;
; Store the objects and images back into the state structure.
;
*Demo$State.pObjects = TEMPORARY(pObjects)
*Demo$State.pRGBImage = TEMPORARY(RGBImage)
*Demo$State.pTrueColorImage = TEMPORARY(TrueColorImage)
*pDemo$State = TEMPORARY(Demo$State)
END


PRO DemoROI$Generate_Gray_Background, pDemo$State
;
; Thie routine creates the "ghost" background image.
; We've reserved a few indices at the bottom of the
; color table (in 256-color mode).
;
Demo$State = *pDemo$State
BWImage = BYTSCL(TOTAL(*Demo$State.pTrueColorImage, 1))
Background = BYTSCL(BWImage, TOP = Demo$State.NReservedColors - 1)
WSET, Demo$State.GrayBackgroundImagePixmap
DEVICE, GET_VISUAL_DEPTH=visual_depth
DEVICE, GET_DECOMPOSED=decomp
Background[WHERE(Background EQ 0)] = Demo$State.BackgroundColor
IF (visual_depth GT 8 and decomp) THEN BEGIN
;
; TrueColor mode.
;
   TV, Background*20, CHANNEL = 0
ENDIF ELSE BEGIN
;
; 256 color mode.
;
   TV, Background
ENDELSE
*pDemo$State = TEMPORARY(Demo$State)
END


PRO DemoROI$Generate_Edge_Enhanced_Image, pDemo$State
;
; This routine generates the edge-enhanced image based
; on the black-and-white weighted image.  Here, we
; simply use SOBEL but you can use whatever technique
; is most appropriate.
;
Demo$State = *pDemo$State
IF (Demo$State.DemoMode) THEN BEGIN
   Widgets = TEMPORARY(*Demo$State.pWidgets)
   WIDGET_CONTROL, Widgets.AstroStatusLabel, SET_VALUE = $
      'Generating edge-enhanced mask...'
   *Demo$State.pWidgets = TEMPORARY(Widgets)
ENDIF
*Demo$State.pEdgeEnhancedImage = $
    BYTSCL(SOBEL(*Demo$State.pBWWeightedImage))
*pDemo$State = TEMPORARY(Demo$State)
END


PRO DemoROI$Weight_Image_By_Layer, pDemo$State
;
; This routine creates a black-and-white version
; of the original image, with specified weights
; applied to each layer.  The result is then scaled.
;
Demo$State = *pDemo$State
WeightedImage = *Demo$State.pTrueColorImage
FOR I = 0, 2 DO BEGIN
   WeightedImage[I, *, *] = WeightedImage[I, *, *] * $
      Demo$State.Weights[I]
ENDFOR
BWWeightedImage = BYTSCL(TOTAL(WeightedImage, 1))
IF (Demo$State.UseNegativeImage) THEN BEGIN
   BWWeightedImage = 255 - TEMPORARY(BWWeightedImage)
ENDIF
*Demo$State.pBWWeightedImage = TEMPORARY(BWWeightedImage)
*pDemo$State = TEMPORARY(Demo$State)
;
; Feed the result into the edge enhancement.
;
DemoROI$Generate_Edge_Enhanced_Image, pDemo$State
END


PRO DemoROI$Display_Original_Image, pDemo$State
;
; This routine copies the original image pixmap to
; the display window.
;
Demo$State = *pDemo$State
WSET, Demo$State.ImageWindow
DEVICE, COPY = [0, 0, Demo$State.SizeOfImage[2], $
   Demo$State.SizeOfImage[3], 0, 0, Demo$State.ImagePixmap]
*pDemo$State = TEMPORARY(Demo$State)
END


PRO DemoROI$Find_Edge_Enhanced_Contours, pDemo$State, $
   PathInfo, Path_XY
;
; This routine takes as input the black and white image,
; filters out minimum and maximum thresholds from the
; edge enhancement, and contours the result to find
; individual "objects".
;
Demo$State = *pDemo$State
IF (Demo$State.DemoMode) THEN BEGIN
   Widgets = TEMPORARY(*Demo$State.pWidgets)
   WIDGET_CONTROL, Widgets.AstroStatusLabel, SET_VALUE = $
      'Searching for ROIs...'
   *Demo$State.pWidgets = TEMPORARY(Widgets)
ENDIF
EdgeEnhancedImage = TEMPORARY(*Demo$State.pEdgeEnhancedImage)
BWWeightedImage = TEMPORARY(*Demo$State.pBWWeightedImage)
CONTOUR, BWWeightedImage * (1 - $
   ((EdgeEnhancedImage LT Demo$State.MinSobel) OR $
   (EdgeEnhancedImage GT Demo$State.MaxSobel))), $
   LEVEL =1, /FOLLOW, XMARGIN = [0, 0], YMARGIN = [0, 0], /NOERASE, $
   PATH_INFO = PathInfo, PATH_XY = Path_XY, XSTYLE = 5, YSTYLE = 5
;
; PATH_XY and PATH_INFO define the outlines of the objects.
;
IF (MAX(Path_XY[0, *]) GT 1.1) THEN BEGIN
   Path_XY[0, *] = Path_XY[0, *]/!d.x_size
   Path_XY[1, *] = Path_XY[1, *]/!d.y_size
ENDIF
*Demo$State.pBWWeightedImage = TEMPORARY(BWWeightedImage)
*Demo$State.pEdgeEnhancedImage = TEMPORARY(EdgeEnhancedImage)
*pDemo$State = TEMPORARY(Demo$State)
END


PRO DemoROI$Find_Objects, pDemo$State
;
; This routine finds the individual "objects" in
; an image and creates structures to define each
; one.
;
DemoROI$Find_Edge_Enhanced_Contours, pDemo$State, PInfo, PXY
Demo$State = *pDemo$State
;
; First, make sure we found some object perimeters that
; weren't filtered out by length criteria.
;
IF (N_ELEMENTS(PInfo) NE 0) THEN BEGIN
   IF (Demo$State.HighLowContours NE 2) THEN BEGIN
      Low = WHERE((PInfo.High_Low EQ Demo$State.HighLowContours) $
         AND (PInfo.N GE Demo$State.MinCircumference) AND $
         (PInfo.N LE Demo$State.MaxCircumference), NLow)
      ENDIF ELSE BEGIN
         Low = WHERE((PInfo.N GE Demo$State.MinCircumference) AND $
            (PInfo.N LE Demo$State.MaxCircumference), NLow)
   ENDELSE
ENDIF ELSE BEGIN
   NLow = 0
ENDELSE
IF (NLow EQ 0) THEN BEGIN
   StatsMessage = 'None found'
   v = DIALOG_MESSAGE(StatsMessage, /Information)
   *pDemo$State = TEMPORARY(Demo$State)
   RETURN
ENDIF
;
; Now we know we have some valid outlines.
; The subimage pixmap is used for temporary
; image manipulation.
;
IF (Demo$State.SubImagePixmap NE 0) THEN BEGIN
   WDELETE, Demo$State.SubImagePixmap
   Demo$State.SubImagePixmap = 0
ENDIF
Widgets = TEMPORARY(*Demo$State.pWidgets)
RGBImage = TEMPORARY(*Demo$State.pRGBImage)
TrueColorImage = TEMPORARY(*Demo$State.pTrueColorImage)
;
; Since we've got objects, we allow the user to
; select "ghost" image display in the future.
;
WIDGET_CONTROL, Widgets.GhostBase, SENSITIVE = 1
;
; Find the longest contour.
;
Longest = MIN(WHERE(PInfo[Low].N EQ MAX(PInfo[Low].N)))
SurfaceBrightness = FLTARR(N_ELEMENTS(Low))
WSET, Demo$State.ImageWindow
;
; Allocate enough pointers to handle the individual
; objects, then loop over the contours.
;
Pointers = PTRARR(N_ELEMENTS(Low), /ALLOCATE_HEAP)
FOR I = 0L, N_ELEMENTS(Low) - 1 DO BEGIN
;
; Get the individual outlines in device coordinates.
; Make sure they're clipped to it into the physical
; size of the image.
;
   S = [LINDGEN(PInfo[Low[I]].N), 0]
   ThisXY = REFORM(PXY[*, PInfo[Low[I]].Offset + S])
   ThisXY[0, *] = ThisXY[0, *] * Demo$State.SizeOfImage[2] < $
      (Demo$State.SizeOfImage[2] - 1)
   ThisXY[1, *] = ThisXY[1, *] * Demo$State.SizeOfImage[3] < $
      (Demo$State.SizeOfImage[3] - 1)
;
; Get the maximum extents of the objects.
;
   X = LONG(REFORM(ThisXY[0, *]))
   Y = LONG(REFORM(ThisXY[1, *]))
   DeltaX = (MAX(X) - MIN(X) + 1)
   DeltaY = (MAX(Y) - MIN(Y) + 1)
;
; Plot the contour of the object on the image.
;
   WSET, Demo$State.ImageWindow
   PLOTS, ThisXY, /DEVICE, COLOR = Demo$State.ColorWhite
;
; Create a temporary pixmap large enough to hold the
; object.  If we need a larger pixmap, than already
; exists, we create it.  If we use small pixmaps,
; we can speed processing.
;
   IF (Demo$State.SubImagePixmap EQ 0) THEN BEGIN
      WINDOW, /PIXMAP, /FREE, XSIZE = DeltaX, YSIZE = DeltaY, $
         COLOR = 2
      Demo$State.SubImagePixmap = !D.WINDOW
   ENDIF ELSE BEGIN
      WSET, Demo$State.SubImagePixmap
      IF ((!D.X_SIZE LT DeltaX) OR (!D.Y_SIZE LT DeltaY)) $
      THEN BEGIN
         WDELETE, Demo$State.SubImagePixmap
         WINDOW, /FREE, /PIXMAP, XSIZE = DeltaX, YSIZE = DeltaY, $
            COLOR = 2
         Demo$State.SubImagePixmap = !D.WINDOW
      ENDIF
   ENDELSE
;
; Erase the pixmap to 0.
;
   ERASE, 0
   DEVICE, GET_VISUAL_DEPTH=visual_depth
   DEVICE, GET_DECOMPOSED=decomp
   IF (visual_depth GT 8 and decomp) THEN BEGIN
      SubImage = Total(TrueColorImage[*, MIN(X):MAX(X), $
         MIN(Y):MAX(Y)], 1)
   ENDIF ELSE BEGIN
      SubImage = RGBImage[MIN(X):MAX(X), MIN(Y):MAX(Y)]
   ENDELSE
;
; Fill the interior of the contour with 255s.  This creates
; a bilevel image mask.  We would use 1s, but in 65535 color
; mode, the 1 is rounded down to 0.
;
   POLYFILL, X - MIN(X), Y - MIN(Y), Color = 255, /DEVICE
;
; Here's where we convert to 0s and 1s only.
;
   BiLevel =  TVRD() < 1
;
; Apply the bilevel mask to the original image data to
; zero out regions outside the contour.
;
   SubImage = TEMPORARY(SubImage) * BiLevel[0:DeltaX - 1, $
      0:DeltaY - 1]
;
; Calculate the brightness of each layer of the
; masked subimage.
;
   FOR J = 0, 2 DO BEGIN
      SurfaceBrightness[I] = SurfaceBrightness[I] + $
         TOTAL(REFORM(TrueColorImage[J, MIN(X):MAX(X), $
         MIN(Y):MAX(Y)])*BiLevel[0:DeltaX - 1, 0:DeltaY - 1])
   ENDFOR
;
; Determine the surface brightness by dividing by the
; area of the object.
;
   Area = POLY_AREA(X, Y)
   SurfaceBrightness[I] = SurfaceBrightness[I]/Area
;
; Save the information about this object into a
; structure.
;
   *Pointers[I] = { $
      Origin : [MIN(X), MIN(Y)], $
      Extents : [DeltaX, DeltaY], $
      Perimeter : [[X], [Y]], $
      Area : Area, $
      BiLevelMask : BiLevel[0:DeltaX - 1, 0:DeltaY - 1], $
      SurfaceBrightness : SurfaceBrightness[I] $
      }
ENDFOR
;
; Demo$State.pObjects is a pointer to the array of pointers
; to objects.
;
IF (NOT PTR_VALID(Demo$State.pObjects)) THEN BEGIN
   Demo$State.pObjects = PTR_NEW(/ALLOCATE_HEAP)
ENDIF ELSE BEGIN
;
; Free up any existing pointers to objects.
;
   Ptrs = PTR_VALID(*Demo$State.pObjects)
   UsedPtrs = Where(Ptrs NE 0, NUsedPtrs)
   IF (NUsedPtrs NE 0) THEN BEGIN
      PTR_FREE, (*Demo$State.pObjects)[UsedPtrs]
   ENDIF
ENDELSE
;
; Free up the temporary pixmap.
;
IF (Demo$State.SubImagePixmap NE 0) THEN BEGIN
   WDELETE, Demo$State.SubImagePixmap
   Demo$State.SubImagePixmap = 0
ENDIF
;
; Save the images and objects to the state structure.
;
*Demo$State.pTrueColorImage = TEMPORARY(TrueColorImage)
*Demo$State.pRGBImage = TEMPORARY(RGBImage)
*Demo$State.pWidgets = TEMPORARY(Widgets)
*Demo$State.pObjects = TEMPORARY(Pointers)
*pDemo$State = TEMPORARY(Demo$State)
;
; If there are objects not filtered out by the
; surface brightness limits imposed by the user,
; display them.
;
IF (DemoROI$Histogram(pDemo$State, SurfaceBrightness)) $
THEN BEGIN
   DemoROI$Display_Chosen_Subset, pDemo$State
ENDIF
END


PRO DemoROI$Ghost_Image_Event, Event
;
; This routine takes ghost button on/off
; events and redisplays any objects.
;
WIDGET_CONTROL, /HOURGLASS
WIDGET_CONTROL, Event.Top, GET_UVALUE = pDemo$State
WIDGET_CONTROL, Event.ID, GET_VALUE = ButtonValue
(*pDemo$State).GhostBackground = ButtonValue EQ 'On'
IsManual = (*pDemo$State).ManualMode
IF (PTR_VALID((*pDemo$State).pObjects)) THEN BEGIN
   DemoROI$Display_Chosen_Subset, pDemo$State, /Hide_First_Pass, $
      No_Histogram = IsManual
ENDIF
WIDGET_CONTROL, Event.Top, /CLEAR_EVENTS
END


PRO DemoROI$Apply_Selection, pDemo$State, Show = Show
;
; This routine determines the current settings of the
; control widgets and creates or displays objects based
; on changes from the previous state.
;
Demo$State = *pDemo$State
Widgets = TEMPORARY(*Demo$State.pWidgets)
IF (Demo$State.DemoMode) THEN BEGIN
   WIDGET_CONTROL, Widgets.AstroStatusLabel, SET_VALUE = $
      'Applying new selection criteria...'
ENDIF
;
; Get the values of the various control widgets.
;
WIDGET_CONTROL, Widgets.SobelSlider, GET_VALUE = MinSobel
WIDGET_CONTROL, Widgets.MinCircumferenceSlider, $
   GET_VALUE = MinCircumference
WIDGET_CONTROL, Widgets.MaxCircumferenceSlider, $
   GET_VALUE = MaxCircumference
WIDGET_CONTROL, Widgets.RedSlider, GET_VALUE = RedWeight
WIDGET_CONTROL, Widgets.GreenSlider, GET_VALUE = GreenWeight
WIDGET_CONTROL, Widgets.BlueSlider, GET_VALUE = BlueWeight
WIDGET_CONTROL, Widgets.MinBrightnessSlider, $
   GET_VALUE = MinBrightness
WIDGET_CONTROL, Widgets.MaxBrightnessSlider, $
   GET_VALUE = MaxBrightness
*Demo$State.pWidgets = TEMPORARY(Widgets)
;
; See if any of the values have changed.
;
IF ((((Demo$State.MinSobel EQ MinSobel) AND $
     (Demo$State.MinCircumference EQ MinCircumference) AND $
     (Demo$State.MaxCircumference EQ MaxCircumference) AND $
     (TOTAL(Abs(Demo$State.Weights - $
      [RedWeight, GreenWeight, BlueWeight])) EQ 0) AND $
     (Demo$State.Initialized))) AND $
     (NOT Demo$State.ModifiedHighLow)) THEN BEGIN
;
; No changes were made to parameters that require searching
; for a new set of objects.  Brightness filtering is performed
; after objects are found.
;
   Demo$State.MinBrightness = MinBrightness
   Demo$State.MaxBrightness = MaxBrightness
   *pDemo$State = TEMPORARY(Demo$State)
   DemoROI$Display_Chosen_Subset, pDemo$State, /Hide_First_Pass
ENDIF ELSE BEGIN
;
; At least one parameter changed that will require us to generate
; a new object list.
;
   Demo$State.MinSobel = MinSobel
   Demo$State.MinCircumference = MinCircumference
   Demo$State.MaxCircumference = MaxCircumference
   Demo$State.Weights = [RedWeight, GreenWeight, BlueWeight]
   Demo$State.MinBrightness = MinBrightness
   Demo$State.MaxBrightness = MaxBrightness
   Demo$State.Initialized = 1B
   Demo$State.ModifiedHighLow = 0
   *pDemo$State = TEMPORARY(Demo$State)
   DemoROI$Display_Original_Image, pDemo$State
   DemoROI$Weight_Image_By_Layer, pDemo$State
   DemoROI$Find_Objects, pDemo$State
ENDELSE
END


PRO DemoROI$Main_Image_Event, Event, No_Event = No_Event
;
; This routine handles events from the "manual mode"
; of the demo.  Either the user has clicked the mouse
; on an object in order to have IDL find its outline,
; or a constructed event was sent (when the search pattern
; is tightened or loosened.)
;
IF ((KEYWORD_SET(No_Event)) OR (Event.Press EQ 1)) THEN BEGIN
   WIDGET_CONTROL, /HOURGLASS
   WIDGET_CONTROL, Event.Top, GET_UVALUE = pDemo$State
   Demo$State = *pDemo$State
   BWWeightedImage = TEMPORARY(*Demo$State.pBWWeightedImage)
;
; Determine the "tightness" of the search about the value
; of the selected pixel.  The tightness is a threshold
; used by SEARCH2D.
;
   WIDGET_CONTROL, (*Demo$State.pWidgets).TightnessSlider, $
      GET_VALUE = Tightness
   Tightness = 255 - TEMPORARY(Tightness)
;
; The mouse button event determines the origin about which
; SERACH2D should search for pixels "similar" to that one.
; Note that the black and white weighted image is used
; so the search takes place in grayscale space rather than
; color space.
;
   Demo$State.ManualCenter = [Event.X, Event.Y]
   SubImage = SEARCH2D(BWWeightedImage, Event.X, Event.Y, $
      BWWeightedImage[Event.X, Event.Y] - Tightness, $
      BWWeightedImage[Event.X, Event.Y] + Tightness)
   *Demo$State.pBWWeightedImage = TEMPORARY(BWWeightedImage)
;
; Make sure we found some pixels.
;
   IF (N_ELEMENTS(SubImage) le 1) THEN BEGIN
      *pDemo$State = TEMPORARY(Demo$State)
      v = DIALOG_MESSAGE('Too few points.  ' + $
         'Try a looser search pattern.')
      RETURN
   ENDIF
;
; Determine the outline and extents of the found
; object.
;
   IndexY = SubImage/Demo$State.SizeOfImage[2]
   IndexX = SubImage - (IndexY * Demo$State.SizeOfImage[2])
   MinIndexX = MIN(IndexX)
   MinIndexY = MIN(IndexY)
   DeltaX = MAX(IndexX) - MinIndexX + 1
   DeltaY = MAX(IndexY) - MinIndexY + 1
;
; Make sure the object extents are reasonable.
;
   IF ((DeltaX LT 2) OR (DeltaY LT 2)) THEN BEGIN
      *pDemo$State = TEMPORARY(Demo$State)
      v = DIALOG_MESSAGE('Too few points.  ' + $
         'Try a looser search pattern.')
      RETURN
   ENDIF
   NewIndexX = IndexX - MIN(IndexX)
   NewIndexY = IndexY - MIN(IndexY)
;
; Get the color subimage enclosed within the extents
; of the object.
;
   DEVICE, GET_VISUAL_DEPTH=visual_depth
   DEVICE, GET_DECOMPOSED=decomp
   IF (visual_depth LE 8) THEN BEGIN
      RGBImage = TEMPORARY(*Demo$State.pRGBImage)
      OriginalSubImage = RGBImage[MinIndexX:MinIndexX + $
         DeltaX - 1, MinIndexY:MinIndexY + DeltaY - 1]
   ENDIF ELSE BEGIN
      TrueColorImage = TEMPORARY(*Demo$State.pTrueColorImage)
      OriginalSubImage = REFORM( $
        TrueColorImage[ $
            0, $
            MinIndexX:MinIndexX+DeltaX-1, $
            MinIndexY:MinIndexY+DeltaY-1 $
            ] $
        )
   ENDELSE
;
; Create a rectangular bilevel mask of 0s and 1s. 1s indicate
; pixels that are within the object.
;
   BiLevel = OriginalSubImage*0
   BiLevel2 = BiLevel
   BiLevel[NewIndexX, NewIndexY] = 1
;
; A temporary pixmap is used to create the subimage
; to be displayed.
;
   IF (Demo$State.SubImagePixmap NE 0) THEN BEGIN
      WDELETE, Demo$State.SubImagePixmap
   ENDIF
   WINDOW, /FREE, /PIXMAP, XSIZE = DeltaX, YSIZE = DeltaY
   Demo$State.SubImagePixmap = !D.WINDOW
;
; Contour the bilevel image to get the outline of the
; object.
;
   CONTOUR, BiLevel, LEVEL =1, $
      XMARGIN = [0, 0], YMARGIN = [0, 0], /NOERASE, /FOLLOW, $
      PATH_INFO = PInfo, PATH_XY = PXY, XSTYLE = 5, YSTYLE = 5, $
      /DEVICE, XRANGE = [0, DeltaX - 1], YRANGE = [0, DeltaY - 1]
   IF (MAX(PXY) GT 1.01) THEN BEGIN
      PXY[0, *] = PXY[0, *]/!d.x_vsize
      PXY[1, *] = PXY[1, *]/!d.y_vsize
   ENDIF
   WSET, Demo$State.ImageWindow
   GaveUp = 0B
   IF (N_ELEMENTS(PInfo) GT 1) THEN BEGIN
      LongestPath = -1L
      LongPath = -1L
      I = -1L
;
; Sort the contours by length.  We want the longest
; possible contour that contains the object.
;
      LengthSort = REVERSE(SORT(PInfo.N))
      WHILE ((NOT GaveUp) AND (LongestPath EQ -1) AND $
         (I LT N_ELEMENTS(PInfo) - 1)) DO BEGIN
         I = I + 1L
         LongPath = LengthSort[I]
         BiLevel2[*] = 0B
         S = [LINDGEN(PInfo[LongPath].N), 0]
         ThisXY = REFORM(PXY[*, PInfo[LongPath].Offset + S])
         ThisXY[0, *] = ThisXY[0, *] * DeltaX
         ThisXY[1, *] = ThisXY[1, *] * DeltaY
         X = LONG(REFORM(ThisXY[0, *]))
         Y = LONG(REFORM(ThisXY[1, *]))
         DEVICE, COPY = [0, 0, Demo$State.SizeOfImage[2], $
            Demo$State.SizeOfImage[3], 0, 0, $
            Demo$State.GrayBackgroundImagePixmap]
;
; Make sure the mouse click (or constructed event) was inside
; this contour.
;
         MinX = MIN(X)
         MaxX = MAX(X)
         MinY = MIN(Y)
         MaxY = MAX(Y)
         IF ((MaxX ge Event.X - MinIndexX) AND $
             (MaxY ge Event.Y - MinIndexY) AND $
             (MinX le Event.X - MinIndexX) AND $
             (MinY le Event.Y - MinIndexY)) THEN BEGIN
;
; We determine if a point is inside a polygon by filling
; the polygon then setting the pixel to 1.  If the total
; of the image is larger than it was without that pixel
; set, then the pixel is outside the polygon.
;
            Inside = POLYFILLV(X, Y, DeltaX, DeltaY)
            IF (Inside[0] NE -1) THEN BEGIN
               BiLevel2[Inside] = 1B
               ImageTotal = TOTAL(BiLevel2)
               BiLevel2[Event.X - MinIndexX, Event.Y - MinIndexY] = $
                  1B
               IF (ImageTotal EQ TOTAL(BiLevel2)) THEN BEGIN
                  IF (PInfo[LongPath].N GT LongestPath) THEN BEGIN
                     LongestPath = LongPath
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
;
; Check in no more than 50 contours.  This will speed things up
; if the search criteria are just too darned lax.
;
         GaveUp = ((I GT 50) AND (LongestPath EQ -1))
      ENDWHILE
   ENDIF ELSE BEGIN
      LongestPath = 0
   ENDELSE
   IF (GaveUp) THEN BEGIN
;
; We didn't find an appropriate contour for this object.
;
      IF (N_ELEMENTS(RGBImage) NE 0) THEN BEGIN
         *Demo$State.pRGBImage = TEMPORARY(RGBImage)
      ENDIF
      IF (N_ELEMENTS(TrueColorImage) NE 0) THEN BEGIN
         *Demo$State.pTrueColorImage = TEMPORARY(TrueColorImage)
      ENDIF
      *pDemo$State = TEMPORARY(Demo$State)
      v = DIALOG_MESSAGE('Too many contours.  ' + $
         'Try tightening the search pattern.')
      RETURN
   ENDIF
;
; The next thing we do is plot the contour around the object.
;
   LongestPath = LongestPath > 0
   IF (N_ELEMENTS(RGBImage) NE 0) THEN BEGIN
      *Demo$State.pRGBImage = TEMPORARY(RGBImage)
   ENDIF
   S = [LINDGEN(PInfo[LongestPath].N), 0]
   ThisXY = REFORM(PXY[*, PInfo[LongestPath].Offset + S])
   ThisXY[0, *] = ThisXY[0, *] * DeltaX
   ThisXY[1, *] = ThisXY[1, *] * DeltaY
   X = LONG(REFORM(ThisXY[0, *])) + MIN(IndexX)
   Y = LONG(REFORM(ThisXY[1, *])) + MIN(IndexY)
   WSET, Demo$State.ImageWindow
   PLOTS, X, Y, /DEVICE, COLOR = Demo$State.ColorWhite
;
; Make sure the pointer array for the objects is
; large enough to include this object.
;
   NObjects = 0L
   Pointers = PTRARR(1)
   IF (PTR_VALID(Demo$State.pObjects)) THEN BEGIN
      NObjects = N_ELEMENTS(*Demo$State.pObjects)
      IF (NObjects NE 0) THEN BEGIN
         IF (TOTAL(ABS(Demo$State.PreviousCenter - $
            Demo$State.ManualCenter)) NE 0) THEN BEGIN
            Pointers = PTRARR(NObjects + 1)
            Pointers[0:NObjects - 1] = Temporary(*Demo$State.pObjects)
         ENDIF ELSE BEGIN
            Pointers = Temporary(*Demo$State.pObjects)
            NObjects = TEMPORARY(NObjects) - 1
            IF (PTR_VALID(Pointers[NObjects])) THEN BEGIN
               PTR_FREE, Pointers[NObjects]
            ENDIF
         ENDELSE
      ENDIF
   ENDIF
;
; Calculate the surface brightness of the object.
;
   SurfaceBrightness = 0.
   IF (N_ELEMENTS(TrueColorImage) EQ 0) THEN BEGIN
      TrueColorImage = TEMPORARY(*Demo$State.pTrueColorImage)
   ENDIF
   FOR J = 0, 2 DO BEGIN
      SurfaceBrightness = TEMPORARY(SurfaceBrightness) + $
         TOTAL(REFORM(TrueColorImage[J, $
         MIN(IndexX):MAX(IndexX), $
         MIN(IndexY):MAX(IndexY)])* $
         BiLevel[0:DeltaX - 1, 0:DeltaY - 1])
   ENDFOR
   IF (N_ELEMENTS(TrueColorImage) NE 0) THEN BEGIN
      *Demo$State.pTrueColorImage = TEMPORARY(TrueColorImage)
   ENDIF
   Area = POLY_AREA(IndexX, IndexY)
   SurfaceBrightness = SurfaceBrightness/Area
;
; Create a structure for the characteristics of this object
; and store it in an heap variable.
;
   Pointers[NObjects] = PTR_NEW({ $
      Origin : [MIN(IndexX), MIN(IndexY)], $
      Extents : [DeltaX, DeltaY], $
      Perimeter : [[X], [Y]], $
      Area : Area, $
      BiLevelMask : BiLevel[0:DeltaX - 1, 0:DeltaY - 1], $
      SurfaceBrightness : SurfaceBrightness $
      })
;
; Save the pointers to the objects.
;
   IF (NOT PTR_VALID(Demo$State.pObjects)) THEN BEGIN
      Demo$State.pObjects = PTR_NEW(Pointers, /NO_COPY)
   ENDIF ELSE BEGIN
      *Demo$State.pObjects = Temporary(Pointers)
   ENDELSE
;
; Put things back where they belong.
;
   Demo$State.Initialized = 0
   Demo$State.PreviousCenter = Demo$State.ManualCenter
   IF (Demo$State.SubImagePixmap NE 0) THEN BEGIN
      WDELETE, Demo$State.SubImagePixmap
      Demo$State.SubImagePixmap = 0
   ENDIF
   IF (N_ELEMENTS(TrueColorImage) NE 0) THEN BEGIN
      *Demo$State.pTrueColorImage = TEMPORARY(TrueColorImage)
   ENDIF
   *pDemo$State = TEMPORARY(Demo$State)
;
; Display the objects in the list.
;
   DemoROI$Display_Chosen_Subset, pDemo$State, /No_Histogram, $
      /Hide_First_Pass
ENDIF
WIDGET_CONTROL, Event.Top, /CLEAR_EVENTS
END


PRO DemoROI_Event, Event
;
; This routine is the main event handler for the demo.
;
If (TAG_NAMES(Event, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST') $
   THEN BEGIN
   WIDGET_CONTROL, event.top, /DESTROY
;   v = DIALOG_MESSAGE('Use the File/Exit menu item to ' + $
;      'close this application.')
   RETURN
ENDIF
WIDGET_CONTROL, /HOURGLASS
WIDGET_CONTROL, Event.Top, GET_UVALUE = pDemo$State
;
; This CATCH branch handles unexpected errors that might
; arise in the event loop.  The cleanup of pointers,
; pixmaps, etc. will occur upon the return to the
; main procedure, after the base is destroyed.
;
IF (NOT (*pDemo$State).NoCatch) THEN BEGIN
   ErrorStatus = 0
   CATCH, ErrorStatus
   IF (ErrorStatus NE 0) THEN BEGIN
      CATCH, /CANCEL
      IF (!error_state.name EQ 'IDL_M_CNTOPNFIL') || $
        (!error_state.name EQ 'IDL_M_FILE_EOF') || $
        (strmid(!error_state.name,0,9) EQ 'IDL_M_OLH') || $
        (strmid(!error_state.msg,0,11) EQ 'ONLINE_HELP') THEN BEGIN
        void = dialog_message('An Error has occured with the ' + $
                              'Online Help System',/ERROR)
        return
      ENDIF
      v = DIALOG_MESSAGE(['Unexpected error in ROI:', $
         '!ERROR_STATE.MSG = ' + !ERROR_STATE.MSG, $
         '!ERROR_STATE.SYS_CODE = ' + $
             STRTRIM(LONG(!ERROR_STATE.SYS_CODE), 2), $
         '!ERROR_STATE.SYS_MSG = ', !ERROR_STATE.SYS_MSG, $
         ' ', 'Cleaning up...'], /ERROR)
      WIDGET_CONTROL, Event.Top, /DESTROY
      RETURN
   ENDIF
ENDIF
;
; Get the value of the button that was selected and
; act on it accordingly.
;
WIDGET_CONTROL, Event.ID, GET_VALUE = ButtonValue
ButtonValue = STRTRIM(ButtonValue[0], 2)
CASE ButtonValue OF
   'Display Original Image' : DemoROI$Display_Original_Image, $
      pDemo$State
   'Quit' : WIDGET_CONTROL, Event.Top, /DESTROY
   'Open...' : BEGIN
;
; Open an image file.  This is not available in demo mode.
;
      DemoROI$Read_File_And_Initialize, pDemo$State
      END
   'Astronomical Data' : BEGIN
;
; Demo modes require turning off or on various options.
;
      DemoROI$Read_File_And_Initialize, pDemo$State, $
         FILE = DEMO_FILEPATH('abell115.jpg', $
         SUBDIR = ['examples', 'demo', 'demodata'])

      Demo$State = *pDemo$State
      Widgets = TEMPORARY(*Demo$State.pWidgets)
;
; The astronomy demo is an "automatic mode" demo.
;
      Demo$State.ManualMode = 0
      WIDGET_CONTROL, Widgets.ManualButton, SENSITIVE = 0
      WIDGET_CONTROL, Widgets.AutomaticButton, /SENSITIVE
      WIDGET_CONTROL, Widgets.DrawWidget, DRAW_BUTTON_EVENTS = 0
      WIDGET_CONTROL, Widgets.ControlsBase[0], MAP = 1
      FOR I = 1, N_ELEMENTS(Widgets.ControlsBase) - 1 DO BEGIN
         WIDGET_CONTROL, Widgets.ControlsBase[I], MAP = 0
      ENDFOR
      *Demo$State.pWidgets = TEMPORARY(Widgets)
      *pDemo$State = TEMPORARY(Demo$State)
      END
   'Medical Imaging Data' : BEGIN
;
; The medical imaging data is a "manual mode" demo.
;
      DemoROI$Read_File_And_Initialize, pDemo$State, $
         FILE = DEMO_FILEPATH('pollens.jpg', $
         SUBDIR = ['examples', 'demo', 'demodata'])
      Demo$State = *pDemo$State
      Widgets = TEMPORARY(*Demo$State.pWidgets)
      Demo$State.ManualMode = 1
      WIDGET_CONTROL, Widgets.ManualButton, /SENSITIVE
      WIDGET_CONTROL, Widgets.AutomaticButton, SENSITIVE = 0
      WIDGET_CONTROL, Widgets.DrawWidget, /DRAW_BUTTON_EVENTS
      WIDGET_CONTROL, Widgets.ControlsBase[1], MAP = 1
      WIDGET_CONTROL, Widgets.ControlsBase[0], MAP = 0
      FOR I = 2, N_ELEMENTS(Widgets.ControlsBase) - 1 DO BEGIN
         WIDGET_CONTROL, Widgets.ControlsBase[I], MAP = 0
      ENDFOR
      *Demo$State.pWidgets = TEMPORARY(Widgets)
      *pDemo$State = TEMPORARY(Demo$State)
      END
   'Start A New List Of Objects' : BEGIN
;
; In manual mode, this deletes the existing array of objects
; and frees up their heap variables.
;
      Demo$State = *pDemo$State
      IF (PTR_VALID(Demo$State.pObjects)) THEN BEGIN
         Ptrs = PTR_VALID(*Demo$State.pObjects)
         OkayPtrs = WHERE(Ptrs NE 0, NOkayPtrs)
         IF (NOkayPtrs NE 0) THEN BEGIN
            PTR_FREE, (*Demo$State.pObjects)[OkayPtrs]
         ENDIF
         PTR_FREE, Demo$State.pObjects
      ENDIF
      Demo$State.PreviousCenter = [0, 0]
      *pDemo$State = TEMPORARY(Demo$State)
      DemoROI$Display_Original_Image, pDemo$State
      END
   'High' : BEGIN
;
; Select "high" contours from the CONTOUR command
; in automatic mode.  Not available in demo mode.
;
      (*pDemo$State).HighLowContours = 1
      (*pDemo$State).ModifiedHighLow = 1
      END
   'Low' : BEGIN
;
; Select "low" contours from the CONTOUR command
; in automatic mode.  Not available in demo mode.
;
      (*pDemo$State).HighLowContours = 0
      (*pDemo$State).ModifiedHighLow = 1
      END
   'All' : BEGIN
;
; Select both "high" and "low" contours from the
; CONTOUR command in automatic mode.  Not available
; in demo mode.
;
      (*pDemo$State).HighLowContours = 2
      (*pDemo$State).ModifiedHighLow = 1
      END
   'Identify ROIs' : BEGIN
;
; Apply the selection criteria to the image to find
; the objects in automatic mode.
;
      DemoROI$Apply_Selection, pDemo$State
      END
   'Apply Search Pattern' : BEGIN
;
; When manual mode is in effect, loosening or tightening
; the search pattern and hitting "apply" will send
; an event here.  We build a fake widget event and pass
; it to the appropriate event handler as if the user
; clicked on the image in the same place they clicked
; before.
;
      Center = (*pDemo$State).ManualCenter
      DemoROI$Main_Image_Event, {Press : 1, X : Center[0], $
         Y : Center[1], Top : Event.Top}, /No_Event
      END
   'Automatic' : BEGIN
;
; Change the object search mode to automatic.  This entails
; hiding and revealing bases, among other things.
;
      Demo$State = *pDemo$State
      Widgets = TEMPORARY(*Demo$State.pWidgets)
      Demo$State.ManualMode = 0
      WIDGET_CONTROL, Widgets.DrawWidget, DRAW_BUTTON_EVENTS = 0
      WIDGET_CONTROL, Widgets.ControlsBase[0], MAP = 1
      FOR I = 1, N_ELEMENTS(Widgets.ControlsBase) - 1 DO BEGIN
         WIDGET_CONTROL, Widgets.ControlsBase[I], MAP = 0
      ENDFOR
      *Demo$State.pWidgets = TEMPORARY(Widgets)
      *pDemo$State = TEMPORARY(Demo$State)
      END
   'Manual' : BEGIN
;
; Change the object search mode to manual.
;
      Demo$State = *pDemo$State
      Widgets = TEMPORARY(*Demo$State.pWidgets)
      Demo$State.ManualMode = 1
      WIDGET_CONTROL, Widgets.DrawWidget, /DRAW_BUTTON_EVENTS
      WIDGET_CONTROL, Widgets.ControlsBase[1], MAP = 1
      WIDGET_CONTROL, Widgets.ControlsBase[0], MAP = 0
      FOR I = 2, N_ELEMENTS(Widgets.ControlsBase) - 1 DO BEGIN
         WIDGET_CONTROL, Widgets.ControlsBase[I], MAP = 0
      ENDFOR
      *Demo$State.pWidgets = TEMPORARY(Widgets)
      *pDemo$State = TEMPORARY(Demo$State)
      END
   'About the demo...' : BEGIN
         Demo$State = *pDemo$State
         IF (Demo$State.DemoMode) THEN BEGIN
            ONLINE_HELP, 'd_roi', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH
         ENDIF ELSE BEGIN
;
; Create a non-modal text widget with information about
; the code used in the demo.
;
            IF (NOT XREGISTERED('DemoHelp')) THEN BEGIN
               Demo$State = *pDemo$State
               TextTLB = WIDGET_BASE(GROUP_LEADER = Event.Top, /COLUMN, $
                  UVALUE = pDemo$State)
               IF (Demo$State.ManualMode) THEN BEGIN
               ENDIF ELSE BEGIN
                  WIDGET_CONTROL, TextTLB, TLB_SET_TITLE = $
                     'About ROI Segmentation Demo'
                  T = WIDGET_TEXT(TextTLB, XSIZE = 60, YSIZE = 15, $
                     VALUE = Demo$State.AstroDemoText, /SCROLL)
                  OkayButton = WIDGET_BUTTON(TextTLB, VALUE = 'OK')
                  WIDGET_CONTROL, TextTLB, /REALIZE
               ENDELSE
               XMANAGER, 'DemoHelp', TextTLB, EVENT_HANDLER = $
                  'DemoROI_Event', /NO_BLOCK
               *pDemo$State = TEMPORARY(Demo$State)
            ENDIF
         ENDELSE
      END
   'OK' : BEGIN
;
; This event is generated by the "OK" button on the "About..."
; text widgets.
;
      WIDGET_CONTROL, Event.Top, /DESTROY
      END
   Else :
ENDCASE
;
; Clear events.
;
IF (ButtonValue NE 'Quit' and ButtonValue NE 'OK') THEN BEGIN
   WIDGET_CONTROL, Event.Top, /CLEAR_EVENTS
ENDIF
END


FUNCTION DemoROI$Free_Pointers, pDemo$State, $
   Keep_Objects = Keep_Objects
;
; This routine frees up all the heap variables associated with this
; application that it can find.  If we're keeping objects (to be
; returned to calling procedure), we don't free them.  The
; return value is the array of object pointers, or a null pointer.
;
IF (PTR_VALID(pDemo$State)) THEN BEGIN
   Demo$State = *pDemo$State
   IF (PTR_VALID(Demo$State.pObjects)) THEN BEGIN
      Ptrs = PTR_VALID(*Demo$State.pObjects)
      OkayPtrs = WHERE(Ptrs NE 0, NOkayPtrs)
      IF (NOkayPtrs NE 0) THEN BEGIN
         IF (NOT KEYWORD_SET(Keep_Objects)) THEN BEGIN
            PTR_FREE, (*Demo$State.pObjects)[OkayPtrs]
            ReturnPointers = PTR_NEW()
         ENDIF ELSE BEGIN
            ReturnPointers = (*Demo$State.pObjects)[OkayPtrs]
         ENDELSE
      ENDIF ELSE BEGIN
         ReturnPointers = PTR_NEW()
      ENDELSE
      ValidPtrs = PTR_VALID(*Demo$State.pObjects)
      Okay = WHERE(ValidPtrs NE 0, NOkay)
      IF ((NOkay NE 0) AND NOT KEYWORD_SET(Keep_Objects)) THEN BEGIN
         PTR_FREE, *Demo$State.pObjects
      ENDIF
   ENDIF ELSE BEGIN
      ReturnPointers = PTR_NEW()
   ENDELSE
   PTR_FREE, Demo$State.pWidgets
   PTR_FREE, Demo$State.pTrueColorImage
   PTR_FREE, Demo$State.pRGBImage
   PTR_FREE, Demo$State.pBWWeightedImage
   PTR_FREE, Demo$State.pEdgeEnhancedImage
   PTR_FREE, Demo$State.pHistogram
   PTR_FREE, Demo$State.pObjects
   PTR_FREE, pDemo$State
ENDIF ELSE BEGIN
   ReturnPointers = PTR_NEW()
ENDELSE
RETURN, ReturnPointers
END

PRO DemoROI_Cleanup, AppTLB

WIDGET_CONTROL, AppTLB, GET_UVALUE = pDemo$State

IF ((*pDemo$State).ImagePixmap NE 0) THEN BEGIN
   WDELETE, (*pDemo$State).ImagePixmap
ENDIF
IF ((*pDemo$State).GrayBackgroundImagePixmap NE 0) THEN BEGIN
   WDELETE, (*pDemo$State).GrayBackgroundImagePixmap
ENDIF
IF ((*pDemo$State).SubImagePixmap NE 0) THEN BEGIN
   WDELETE, (*pDemo$State).SubImagePixmap
ENDIF

;
; Restore the color table and system variables to their
; values before the application was started.
;
TVLCT, (*pDemo$State).OriginalR, $
       (*pDemo$State).OriginalG, $
       (*pDemo$State).OriginalB
!X = (*pDemo$State).XSave
!Y = (*pDemo$State).YSave
!Z = (*pDemo$State).ZSave
!P = (*pDemo$State).PSave

; Free all the pointers associated with the application,
; but keep any pointers to the objects.
; Get some local variables out of the state structure first
;
DemoMode = (*pDemo$State).DemoMode
No_Pointers = (*pDemo$State).No_Pointers
Group_Leader = (*pDemo$State).Group_Leader
pObjects = DemoROI$Free_Pointers(pDemo$State, /Keep_Objects)
;
; Free up the object pointers if we're running in a mode
; where we don't want them to be returned.
;
IF (DemoMode or No_Pointers) THEN BEGIN
   PTR_FREE, pObjects
ENDIF

;
;
if WIDGET_INFO(Group_Leader, /VALID_ID) then $
        WIDGET_CONTROL, Group_Leader, /MAP

END


Function DemoROI, Group_Leader = Group_Leader, $
    AppTLB = AppTLB, $
    No_Catch = No_Catch, No_Pointers = No_Pointers, $
    Astronomy_Demo = Astronomy_Demo, $
    Medical_Demo = Medical_Demo
;+
;  FILE:
;       ROI.pro
;
;  CALLING SEQUENCE: p = DemoROI([, GROUP_LEADER = GROUP_LEADER $]
;                             [, APPTLB = APPTLB $]
;                             [, NO_CATCH = NO_CATCH $]
;                             [, NO_POINTERS = NO_POINTERS $]
;                             [, /ASTRONOMY_DEMO $]
;                             [, /MEDICAL_DEMO])
;
;  PURPOSE:
;       This application highlights the ability of IDL to find
;       "objects" in an image.  It also shows implementation details
;       of a fairly sophisticated widget application's management of
;       heap variables, and displaying images in TrueColor vs. 256
;       color modes in Direct Graphics.
;
;       This routine operates as a BLOCKING widget application due to
;       its use of Direct Graphics IDL system variables and color
;       tables.
;
;       The source code to the demonstration routine can be modified
;       to return information about individual objects.  These data
;       can in turn be fed into further processing and refinement steps.
;
;  KEYWORD PARAMETERS:
;       GROUP_LEADER can be set to the ID of a parent widget when
;       this routine is called as a compound widget.
;
;       APPTLB returns the application top level base, mainly for
;       use in the IDL Demo.
;
;       /NO_CATCH can be set for debugging purposes.  It will turn
;       off automatic error trapping while the routine is running.
;       It will also be necessary to turn off XMANAGER's error
;       trapping before running the routine, via XMANAGER, CATCH = 0.
;
;       /NO_POINTERS can be set to prevent the application from
;       returning the array of pointers to objects found in the
;       image.  In demo mode, the default is to return a NULL pointer.
;
;       /ASTRONOMY_DEMO can be set to execute the procedure in
;       "automatic" demo mode, with restricted access to tools.
;
;       /MEDICAL_DEMO can be set to execute the procedure in "manual"
;       demo mode.
;
;  RETURN VALUE:
;       In demo mode, the return value is a NULL pointer.  In
;       application mode unless the /NO_POINTERS keyword is set, the
;       return value is a an array of pointers which refer to heap
;       variables that are anonymous structures containing
;       characteristics of each object.  The anonymous structure is
;       in the form:
;
;          {Origin : [X, Y],        The origin of the object's bounding
;                                   rectangle with respect to the image
;                                   origin, in pixels
;           Extents : [DX, DY],     The X and Y lengths of the
;                                   bounding rectangle, in pixels
;           Perimeter : [[X], [Y]], The X and Y coordinates of the
;                                   perimeter of the object within the
;                                   bounding rectangle, in pixels with
;                                   respect to Origin
;           Area : Area,            The area in pixels of the object
;                                   within the bounding perimeter
;           BiLevelMask : Mask,     A byte array dimensioned [DX, DY]
;                                   containing 1s for pixels within
;                                   the bounding perimeter, and 0s for
;                                   pixels outside it
;           SurfaceBrightness : B}  The sum of the R, G, and B planes
;                                   of the object, divided by the Area.
;
;  A typical call to display surface brightness distribution might
;  look like:
;
;       ObjPtrs = DemoROI()
;       SurfB = FltArr(N_elements(ObjPtrs))
;       For I = 0, N_elements(ObjPtrs) - 1 Do $
;          SurfB[I] = (*ObjPtrs[I]).SurfaceBrightness
;       Plot, SurfB
;       ; Don't forget to execute a "PTR_FREE, ObjPtrs" when you're
;       ; finished!
;
;  MAJOR TOPICS: Visualization, Analysis, Demo, Language
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro demoroi$read_image     - Read JPEG image data
;       pro demoroi$read_file_and_initialize
;                                  - Read image and initialize the
;                                    environment
;       fun demoroi$histogram      - Define surface brightness
;                                    distribution of objects
;       pro demoroi$display_chosen_subset
;                                  - Display objects selected from
;                                    image
;       pro demoroi$generate_gray_background
;                                  - Create the "ghost" background
;                                    grayscale image
;       pro demoroi$generate_edge_enhanced_image
;                                  - Create the edge-enhanced image
;       pro demoroi$display_original_image
;                                  - Display the image
;       pro demoroi$find_edge_enhanced_contours
;                                  - Contour the edge-enhanced image
;       pro demoroi$find_objects   - Find objects based on edge
;                                    enhancement, selection criteria
;       pro demoroi$ghost_image_event
;                                  - Turn on or off ghost image
;       pro demoroi$apply_selection
;                                  - Adjust selection criteria from
;                                    widget settings
;       pro demoroi$main_image_event
;                                  - Take draw widget button events
;                                    in manual mode
;       pro demoroi_event          - Application main event handler
;       fun demoroi$free_pointers  - Free heap variables that are
;                                    no longer needed
;       pro demoroi                - Application main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       abell115.jpg               - Image for astronomy demo
;       ???                        - Image for medical imaging demo
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       3/97,   JLP   - Completed version for IDL 5.0.
;-
;--------------------------------------------------------------------
;
; If we already have an instance of this demo running,
; then return.
;
    IF (XREGISTERED('DemoROI', /NOSHOW)) THEN BEGIN
        V = DIALOG_MESSAGE('An instance of ROI is already running.')
        RETURN, PTR_NEW()
    ENDIF

    IF (N_ELEMENTS(Group_Leader) EQ 0) THEN Group_Leader = 0L


    IF (KEYWORD_SET(Astronomy_Demo) AND KEYWORD_SET(Medical_Demo)) $
        THEN BEGIN
        v = DIALOG_MESSAGE('/Astronomy_Demo and /Medical_Demo are ' + $
        'mutually exclusive.', /ERROR)
        RETURN, 0
    ENDIF

    ;  Get the screen size.
    ;
    Device, GET_SCREEN_SIZE=scrSize

;
;
; Set up some text for the "About..." help.
;
AstroDataText = [ $
   '', $
   '  This image is a composite of three optical CCD images', $
   '  taken with the 0.9 meter telescope at Kitt Peak National', $
   '  Observatory on Sept. 1, 1995.  The image shows Abell 115',  $
   '  a cluster of galaxies that is known for the very large, ', $
   '  bright elliptical cD galaxy near its center and its', $
   '  asymmetric X-ray emission.', $
   ' ', $
   '  Three images were taken of the central region of the ', $
   '  cluster,each through a different colored filter. Several ', $
   '  hundred galaxies have been detected and, by measuring their', $
   '  relative brightness in the three images, the data can help', $
   '  us determine how the galaxies in this cluster evolved.', $
   ' ', $
   '  These data are courtesy of Kathy Romer, Anne Metevier and', $
   '  Melville Ulmer (Northwestern University), with additional', $
   "  thanks to the Illinois Space Grant Consortium's ", $
   '  Northwestern University High School and Undergraduate ', $
   '  Research Program', $
   ' ']
AstroDemoText = [ $
   '', $
   "  This procedure illustrates IDL's ability to find", $
   '  "objects" in an image.  The user creates the definition', $
   '  of an object based on certain criteria, including the ', $
   '  "fuzziness" of the edge-enhanced image, and the size of', $
   '  the related contour.', $
   ' ', $
   '  In this example, the default values have been defined to', $
   '  allow us to search for small galaxies in the field of view.', $
   '  A galaxy will generally have a less well-defined border ', $
   '  than a star, so we look for objects with "fuzzy" edges.', $
   '  Specifying contour lengths also allows us to discriminate', $
   '  a range of perimeters of potential objects.', $
   ' ', $
   '  Object identification proceeds through three', $
   '  general steps:', $
   '        1) Edge enhancement,', $
   '        2) Contouring, and ', $
   '        3) Segmentation.', $
   ' ', $
   '  The source code to the demonstration routine can be modified', $
   '  to return information about individual objects.  These data', $
   '  can in turn be fed into further processing and refinement steps.']

    ; Save the system environment so we can restore it when the
    ; application completes.
    ;
    XSave = !X
    YSave = !Y
    ZSave = !Z
    PSave = !P
    TVLCT, OriginalR, OriginalG, OriginalB, /GET


    ; Set up the error trap.  Note that this only applies
    ; *before* XMANAGER is called since XMANAGER's CATCH will
    ; supercede this.
    ;
    IF (NOT KEYWORD_SET(No_Catch)) THEN BEGIN
        ErrorStatus = 0
        CATCH, ErrorStatus
        IF (ErrorStatus NE 0) THEN BEGIN
;
; We've caught an error.  Restore the system variables
; and color table.
;
            CATCH, /CANCEL
            !X = XSave
            !Y = YSave
            !Z = ZSave
            !P = PSave
            TVLCT, OriginalR, OriginalG, OriginalB
;
; Display as much information as we can about the error.
;
      v = DIALOG_MESSAGE(['Unexpected error in ROI:', $
         '!ERROR_STATE.MSG = ' + !ERROR_STATE.MSG, $
         '!ERROR_STATE.SYS_CODE = ' + $
             STRTRIM(LONG(!ERROR_STATE.SYS_CODE), 2), $
         '!ERROR_STATE.SYS_MSG = ', !ERROR_STATE.SYS_MSG, $
         ' ', 'Cleaning up...'], /ERROR)
;
; If the top level base is still around, destroy the
; widgets.
;
      IF (N_ELEMENTS(TLB) NE 0) THEN BEGIN
         IF (WIDGET_INFO(TLB, /VALID_ID)) THEN BEGIN
            WIDGET_CONTROL, TLB, /DESTROY
         ENDIF
      ENDIF
;
; Free any stray pointers which may exist.
;
      Dummy = DemoROI$Free_Pointers(pDemo$State)
      PTR_FREE, Dummy
      HEAP_GC
      RETURN, -1
   ENDIF
ENDIF


;
; Set some flags and initial conditions.
;
DemoMode = KEYWORD_SET(Astronomy_Demo) OR $
   KEYWORD_SET(Medical_Demo)
MapBases = DemoMode EQ 0
IF (KEYWORD_SET(Astronomy_Demo)) THEN BEGIN
   MaxCircumference = 300
ENDIF ELSE BEGIN
   MaxCircumference = 10000
ENDELSE

DEVICE, GET_VISUAL_DEPTH=visual_depth
DEVICE, GET_DECOMPOSED=decomp
;
; Set up the application state structure.  Note that in
; this demo version, not all structure elements correspond
; to existing utilities!
;
case 1 of
    visual_depth le 8: $
        colorwhite = !D.TABLE_SIZE
    decomp eq 0: $
        colorwhite = 255b
    else: $
        colorwhite = 'ffffff'x
endcase

Demo$State = { $
   XSave                     : XSave, $
   YSave                     : YSave, $
   ZSave                     : ZSave, $
   PSave                     : PSave, $
   OriginalR                 : OriginalR, $
   OriginalG                 : OriginalG, $
   OriginalB                 : OriginalB, $
   Group_Leader              : Group_Leader, $
   pWidgets                  : PTR_NEW(/ALLOCATE_HEAP), $
   pTrueColorImage           : PTR_NEW(/ALLOCATE_HEAP), $
   pRGBImage                 : PTR_NEW(/ALLOCATE_HEAP), $
   pBWWeightedImage          : PTR_NEW(/ALLOCATE_HEAP), $
   pEdgeEnhancedImage        : PTR_NEW(/ALLOCATE_HEAP), $
   pHistogram                : PTR_NEW(/ALLOCATE_HEAP), $
   pObjects                  : PTR_NEW(/ALLOCATE_HEAP), $
   NoCatch                   : KEYWORD_SET(NO_CATCH), $
   No_Pointers               : KEYWORD_SET(NO_POINTERS), $
   Initialized               : 0B, $
   MinSobel                  : 20B, $
   MaxSobel                  : 255B, $
   MinCircumference          : 10, $
   MaxCircumference          : MaxCircumference/5., $
   Weights                   : [1, 1, 1], $
   HighLowContours           : 1B, $
   MinBrightness             : 1L, $
   MaxBrightness             : 765L, $
   ModifiedHighLow           : 0B, $
   MaxWindowDimension        : 512, $
   ImageWindow               : 0L, $
   ImagePixmap               : 0L, $
   HistoWindow               : 0L, $
   GrayBackgroundImagePixmap : 0L, $
   SubImagePixmap            : 0L, $
   SizeOfImage               : LONARR(6), $
   ScaleImagesToFit          : 0B, $
   ImageScrollBars           : 1B, $
   NReservedColors           : 5B, $
   BackgroundColor           : 0B, $
   GhostBackground           : 0B, $
   UseNegativeImage          : 1B, $
   ManualMode                : 0B, $
   DemoMode                  : DemoMode, $
   ManualCenter              : LONARR(2), $
   PreviousCenter            : LONARR(2), $
   ColorWhite                : colorWhite, $
   AstroDataText             : AstroDataText, $
   AstroDemoText             : AstroDemoText $
   }



;
; Save the state structure to a heap variable.
;
pDemo$State = PTR_NEW(Demo$State)

    ;
    ;  Set up the top level base widget.
    ;
    IF (KEYWORD_SET(Group_Leader)) THEN BEGIN
       TLB = WIDGET_BASE(/ROW, GROUP = Group_Leader, MBAR = MenuBar, $
          XPAD=0, YPAD=0, $
          TLB_FRAME_ATTR = 1, TITLE = 'ROI Segmentation', FRAME = 2)
    ENDIF ELSE BEGIN
       TLB = WIDGET_BASE(/ROW, MBAR = MenuBar, TLB_FRAME_ATTR = 1, $
          XPAD=0, YPAD=0, $
          TITLE = 'ROI Segmentation', FRAME = 2)
    ENDELSE



APPTLB = TLB

;
; There are different controls for "manual" and "automatic"
; modes, so we use hidden bases to account for them.
;
ControlBase = WIDGET_BASE(TLB)
ControlsBase = LONARR(3)


;
; The third control base is a dummy.  It's used to hide
; some of the controls when we're running in demo mode.
;
ControlsBase[2] = WIDGET_BASE(ControlBase, /COLUMN)


;
; The first control base holds the widgets for the
; automatic mode.
;
ControlsBase[0] = WIDGET_BASE(ControlBase, /COLUMN, /ALIGN_CENTER, $
   FRAME = 2)


;
; Define the slider for the fuzziness of edges for object
; detection.  Rather than define exactly what the values
; correspond to I simply use "Fuzzy" and "Distinct" as
; labels for the slider.  These actually represent contour
; levels of a Sobel image.
;
SobelBase = WIDGET_BASE(ControlsBase[0], /COLUMN, /ALIGN_CENTER, $
   FRAME = 2)
    SobelLabel = WIDGET_LABEL(SobelBase, VALUE = '  Object Edges  ')
    SobelBase2 = WIDGET_BASE(SobelBase, /ROW)
    SobelLabel2 = WIDGET_LABEL(SobelBase2, VALUE = '  Fuzzy ')
    SobelSlider = WIDGET_SLIDER(SobelBase2, $
       VALUE = (*pDemo$State).MinSobel, MINIMUM = 1, MAXIMUM = 75, $
       /SUPPRESS)
    SobelLabel3 = WIDGET_LABEL(SobelBase2, VALUE = '  Distinct  ')


;
; Define sliders for the minimum and maximum perimeter (contour)
; lengths that will be used to discriminate "objects".
;
CircumferenceBase = WIDGET_BASE(ControlsBase[0], /COLUMN, $
   /ALIGN_CENTER, FRAME = 2)
    CircumferenceLabel = WIDGET_LABEL(CircumferenceBase, $
       VALUE = "  Objects' Circumference (pixels)  ")
    CircumferenceBase2 = WIDGET_BASE(CircumferenceBase, /ROW, $
       /ALIGN_CENTER)
    CircumferenceLabel2 = WIDGET_LABEL(CircumferenceBase2, $
       VALUE = 'Minimum  ')
    MinCircumferenceSlider = WIDGET_SLIDER(CircumferenceBase2, $
       VALUE = (*pDemo$State).MinCircumference, MINIMUM = 3, $
       MAXIMUM = MaxCircumference)
    CircumferenceBase3 = WIDGET_BASE(CircumferenceBase, /ROW, $
       /ALIGN_CENTER)
    CircumferenceLabel3 = WIDGET_LABEL(CircumferenceBase3, $
       VALUE = 'Maximum  ')
    MaxCircumferenceSlider = WIDGET_SLIDER(CircumferenceBase3, $
       VALUE = (*pDemo$State).MaxCircumference, MINIMUM = 3, $
       MAXIMUM = MaxCircumference)

;
; Define the R, G, and B sliders.  These are used to weight
; the individual layers of the TrueColor image.  The default
; is to weight each layer equally.
;
IF (DemoMode) THEN BEGIN
   RGBSliderBase = WIDGET_BASE(ControlsBase[2])
ENDIF ELSE BEGIN
   RGBSliderBase = WIDGET_BASE(ControlsBase[0], /ALIGN_CENTER, $
      /COLUMN, FRAME = 2)
ENDELSE

RGBSliderLabel = WIDGET_LABEL(RGBSliderBase, $
   VALUE = '  Layer Weighting  ')
RGBSliderBase2 = WIDGET_BASE(RGBSliderBase, /ROW, /ALIGN_CENTER)
RGBSliderLabel2 = WIDGET_LABEL(RGBSliderBase2, VALUE = '  Red  ')
RSlider = WIDGET_SLIDER(RGBSliderBase2, $
   VALUE = (*pDemo$State).Weights[0], MINIMUM = 0, MAXIMUM = 10)
RGBSliderBase3 = WIDGET_BASE(RGBSliderBase, /ROW, /ALIGN_CENTER)
RGBSliderLabel3 = WIDGET_LABEL(RGBSliderBase3, VALUE = '  Green  ')
GSlider = WIDGET_SLIDER(RGBSliderBase3, $
   VALUE = (*pDemo$State).Weights[1], MINIMUM = 0, MAXIMUM = 10)
RGBSliderBase4 = WIDGET_BASE(RGBSliderBase, /ROW, /ALIGN_CENTER)
RGBSliderLabel4 = WIDGET_LABEL(RGBSliderBase4, VALUE = '  Blue  ')
BSlider = WIDGET_SLIDER(RGBSliderBase4, $
   VALUE = (*pDemo$State).Weights[2], MINIMUM = 0, MAXIMUM = 10)
;
; The IDL CONTOUR command returns both "high" and "low" contour
; information.  In non-demo mode we allow the user to select
; low, high, or both sets of contours when searching for objects.
;
IF (DemoMode) THEN BEGIN
   ContoursBase = WIDGET_BASE(ControlsBase[2], /COLUMN)
ENDIF ELSE BEGIN
   ContoursBase = WIDGET_BASE(ControlsBase[0], /COLUMN, $
      /ALIGN_CENTER, FRAME = 2)
ENDELSE
ContoursLabel = WIDGET_LABEL(ContoursBase, $
   VALUE = '  Select Contours  ')
HighLowBase = WIDGET_BASE(ContoursBase, /ROW, /EXCLUSIVE)
AllButton = WIDGET_BUTTON(HighLowBase, VALUE = 'All', /NO_RELEASE)
HighButton = WIDGET_BUTTON(HighLowBase, VALUE = 'High', $
   /NO_RELEASE)
LowButton = WIDGET_BUTTON(HighLowBase, VALUE = 'Low', /NO_RELEASE)
WIDGET_CONTROL, HighButton, /SET_BUTTON
;
; In non-demo mode, we allow the user to further refine
; object definition by surface brightness.
;
IF (DemoMode) THEN BEGIN
   BrightnessBase = WIDGET_BASE(ControlsBase[2], /COLUMN)
ENDIF ELSE BEGIN
   BrightnessBase = WIDGET_BASE(ControlsBase[0], /COLUMN, $
      /ALIGN_CENTER, FRAME = 2)
ENDELSE
BrightnessLabel = WIDGET_LABEL(BrightnessBase, $
   VALUE = '  Brightness Limits  ')
BrightnessBase2 = WIDGET_BASE(BrightnessBase, /ROW)
BrightnessLabel2 = WIDGET_LABEL(BrightnessBase2, $
   VALUE = '  Minimum  ')
MinBrightnessSlider = WIDGET_SLIDER(BrightnessBase2, $
   VALUE = (*pDemo$State).MinBrightness, MINIMUM = 1, MAXIMUM = 255*3)
BrightnessBase3 = WIDGET_BASE(BrightnessBase, /ROW)
BrightnessLabel3 = WIDGET_LABEL(BrightnessBase3, $
   VALUE = '  Maximum  ')
MaxBrightnessSlider = WIDGET_SLIDER(BrightnessBase3, $
   VALUE = (*pDemo$State).MaxBrightness, MINIMUM = 1, MAXIMUM = 255*3)

  wApplyBase = WIDGET_BASE(ControlsBase[0], /ALIGN_CENTER,  /COLUMN )
IdentifyROIsButton = WIDGET_BUTTON(wApplyBAse, $
   VALUE = 'Identify ROIs', SENSITIVE=0)
DisplayOrigImgButton = WIDGET_BUTTON(wApplyBase, $
   VALUE = 'Display Original Image', SENSITIVE=0)


WIDGET_CONTROL, BrightnessBase, MAP = (NOT DemoMode)
;
; The "ghost" image is a darkened grayscale version of the
; original image that can be used to underlay the objects.
;
GhostBase = WIDGET_BASE(ControlsBase[0], /ROW, /ALIGN_CENTER, $
   EVENT_PRO = 'DemoROI$Ghost_Image_Event', FRAME = 2)
GhostLabel = WIDGET_LABEL(GhostBase, VALUE = ' Ghost Image ')
GhostButtonBase = WIDGET_BASE(GhostBase, /ROW, /ALIGN_CENTER, $
   /EXCLUSIVE)
GhostOnButton = WIDGET_BUTTON(GhostButtonBase, VALUE = 'On', $
   /NO_RELEASE)
GhostOffButton = WIDGET_BUTTON(GhostButtonBase, VALUE = 'Off', $
   /NO_RELEASE)
WIDGET_CONTROL, GhostOffButton, /SET_BUTTON
WIDGET_CONTROL, GhostBase, SENSITIVE = 0
IF (DemoMode) THEN BEGIN
   AstroStatusLabel = WIDGET_TEXT(ControlsBase[0], Value = '')
ENDIF ELSE BEGIN
   AstroStatusLabel = 0B
ENDELSE
;
; In non-demo mode, we also create a draw widget which will display
; the distribution of objects by surface brightness as a histogram.
;
IF (NOT DemoMode) THEN BEGIN
   Geom = WIDGET_INFO(ControlsBase[0], /GEOMETRY)
   HistoWindow = WIDGET_DRAW(ControlsBase[0], XSIZE = Geom.Scr_XSize, $
      YSIZE = Geom.Scr_XSize, RETAIN = 2, FRAME = 2)
ENDIF
;
; The second control base is used for "manual" mode.
;
ControlsBase[1] = WIDGET_BASE(ControlBase, /COLUMN, /ALIGN_CENTER, $
   FRAME = 2)
InstructionsBase = WIDGET_BASE(ControlsBase[1], /COLUMN, $
   /ALIGN_CENTER, FRAME = 2)
v = WIDGET_LABEL(InstructionsBase, $
   VALUE = '  Select a point near the center  ', /ALIGN_LEFT)
v = WIDGET_LABEL(InstructionsBase, $
   VALUE = '  of an "object".  ', /ALIGN_LEFT)
;
; The "tightness" of a manual search is used internally as the threshold
; level of SEARCH2D().
;
TightnessBase = WIDGET_BASE(ControlsBase[1], /COLUMN, $
   /ALIGN_CENTER, FRAME = 2)
TightnessLabel = WIDGET_LABEL(TightnessBase, $
   VALUE = 'Search Pattern')
TightnessBase2 = WIDGET_BASE(TightnessBase, /ROW)
TightnessLabel2 = WIDGET_LABEL(TightnessBase2, VALUE = '  Loose  ')
TightnessSlider = WIDGET_SLIDER(TightnessBase2, VALUE = 235, $
   MINIMUM = 1, MAXIMUM = 255, /SUPPRESS)
TightnessLabel2 = WIDGET_LABEL(TightnessBase2, VALUE = '  Tight  ')
ApplyButton = WIDGET_BUTTON(TightnessBase, $
   VALUE = 'Apply Search Pattern', SENSITIVE=0)
DisplayOrigImgButton2 = WIDGET_BUTTON(ControlsBase[1], $
   VALUE = 'Display Original Image', SENSITIVE=0)
GhostBase2 = WIDGET_BASE(ControlsBase[1], /ROW, /ALIGN_CENTER, $
   EVENT_PRO = 'DemoROI$Ghost_Image_Event', FRAME = 2)
GhostLabel = WIDGET_LABEL(GhostBase2, VALUE = ' Ghost Image ')
GhostButtonBase = WIDGET_BASE(GhostBase2, /ROW, /ALIGN_CENTER, $
   /EXCLUSIVE)
GhostOnButton2 = WIDGET_BUTTON(GhostButtonBase, VALUE = 'On', $
   /NO_RELEASE)
GhostOffButton2 = WIDGET_BUTTON(GhostButtonBase, VALUE = 'Off', $
   /NO_RELEASE)
WIDGET_CONTROL, GhostOffButton2, /SET_BUTTON
NewListButton = WIDGET_BUTTON(ControlsBase[1], $
   VALUE = 'Start A New List Of Objects')
;
; Define the "System" menus which reside across the top
; of the base widget.
;
FileMenu = WIDGET_BUTTON(MenuBar, VALUE = 'File', /MENU)
;
; In non-demo mode, we allow the user to open files.  In
; demo mode, they're restricted.
;
IF (DemoMode) THEN BEGIN
   ;IF (KEYWORD_SET(Astronomy_Demo)) THEN BEGIN
   ;   AstronomyButton = WIDGET_BUTTON(FileMenu, $
   ;      VALUE = 'Astronomical Data')
   ;   WIDGET_CONTROL, AstronomyButton, SENSITIVE = 0
   ;ENDIF ELSE BEGIN
   ;   MedicalButton = WIDGET_BUTTON(FileMenu, $
   ;      VALUE = 'Medical Imaging Data')
   ;   WIDGET_CONTROL, MedicalButton, SENSITIVE = 0
   ;ENDELSE
   ExitButton = WIDGET_BUTTON(FileMenu, VALUE = 'Quit')
ENDIF ELSE BEGIN
   OpenButton = WIDGET_BUTTON(FileMenu, VALUE = 'Open...')
   ExitButton = WIDGET_BUTTON(FileMenu, VALUE = 'Quit', /SEPARATOR)
ENDELSE
;
; The "Search" menu allows the user to switch between automatic
; and manual modes (though this might not always make sense.)
;
IF (NOT DemoMode) THEN BEGIN
   SearchMenu = WIDGET_BUTTON(MenuBar, $
      VALUE = 'Object Search Method', /MENU)
   AutomaticButton = WIDGET_BUTTON(SearchMenu, VALUE = 'Automatic')
   ManualButton = WIDGET_BUTTON(SearchMenu, VALUE = 'Manual')
;
; In demo mode, only allow the mode appropriate for the
; specific demo.
;
   IF (KEYWORD_SET(ASTRONOMY_DEMO)) THEN BEGIN
      WIDGET_CONTROL, ManualButton, SENSITIVE = 0
   ENDIF
   IF (KEYWORD_SET(MEDICAL_DEMO)) THEN BEGIN
      WIDGET_CONTROL, AutomaticButton, SENSITIVE = 0
   ENDIF
ENDIF ELSE BEGIN
   AutomaticButton = 0L
   ManualButton = 0L
ENDELSE
;
; In demo mode, add some "about..." help buttons.
;
IF (DemoMode) THEN BEGIN
   HelpMenu = WIDGET_BUTTON(MenuBar, /HELP,  VALUE = 'About', /MENU)
   AboutDemoButton = WIDGET_BUTTON(HelpMenu, VALUE = $
      'About the demo...')
ENDIF
;
; Create a base next to the controls.  This will contain
; the draw widget for the image.
;
ImageBase = WIDGET_BASE(TLB, /COLUMN, FRAME = 2, $
   EVENT_PRO = 'DemoROI$Main_Image_Event')
DrawWidget = WIDGET_DRAW(ImageBase, RETAIN = 2)
;
; Create a structure that contains the IDs of the widgets
; we will want to map, unmap, poll, set, etc.
;
WidgetIDs = { $
   ControlsBase           : ControlsBase, $
   SobelSlider            : SobelSlider, $
   MinCircumferenceSlider : MinCircumferenceSlider, $
   MaxCircumferenceSlider : MaxCircumferenceSlider, $
   RedSlider              : RSlider, $
   GreenSlider            : GSlider, $
   BlueSlider             : BSlider, $
   MinBrightnessSlider    : MinBrightnessSlider, $
   MaxBrightnessSlider    : MaxBrightnessSlider, $
   IdentifyROIsButton     : IdentifyROIsButton, $
   DisplayOrigImgButton   : DisplayOrigImgButton, $
   ApplyButton            : ApplyButton, $
   DisplayOrigImgButton2  : DisplayOrigImgButton2, $
   GhostBase              : GhostBase, $
   GhostOnButton          : GhostOnButton, $
   GhostOffButton         : GhostOffButton, $
   GhostOnButton2         : GhostOnButton2, $
   GhostOffButton2        : GhostOffButton2, $
   TightnessSlider        : TightnessSlider, $
   ImageBase              : ImageBase, $
   AutomaticButton        : AutomaticButton, $
   ManualButton           : ManualButton, $
   AstroStatusLabel       : AstroStatusLabel, $
   DrawWidget             : DrawWidget $
   }
;
; Store the widget structure into the application state
; structure.
;
*(*pDemo$State).pWidgets = WidgetIDs
;
; Map and unmap (hide) the control bases appropriate
; to the mode in which the application is being run.
;
IF (NOT KEYWORD_SET(Medical_Demo)) THEN BEGIN
   WIDGET_CONTROL, ControlsBase[0], MAP = 1
   FOR I = 1, N_ELEMENTS(ControlsBase) - 1 DO BEGIN
      WIDGET_CONTROL, ControlsBase[I], MAP = 0
   ENDFOR
ENDIF ELSE BEGIN
   WIDGET_CONTROL, ControlsBase[0], MAP = 0
   WIDGET_CONTROL, ControlsBase[1], MAP = 1
   FOR I = 2, N_ELEMENTS(ControlsBase) - 1 DO BEGIN
      WIDGET_CONTROL, ControlsBase[I], MAP = 0
   ENDFOR
   (*pDemo$State).ManualMode = 1
ENDELSE
;
; Realize the widget.
;
WIDGET_CONTROL, TLB, /REALIZE
;
; Get the ID of the histogram window, if we're not
; in demo mode.
;
IF (NOT DemoMode) THEN BEGIN
   WIDGET_CONTROL, HistoWindow, GET_VALUE = WindowID
   (*pDemo$State).HistoWindow = WindowID
ENDIF
;
; Set the UVALUE of the top level base to the
; pointer to the state structure heap variable.
;
WIDGET_CONTROL, TLB, SET_UVALUE = pDemo$State
;
; In demo mode, we have specific files to be read.
;
IF (DemoMode) THEN BEGIN
   IF (KEYWORD_SET(Astronomy_Demo)) THEN BEGIN
      WIDGET_CONTROL, AstroStatusLabel, SET_VALUE = $
         'Loading image...'
      DemoROI$Read_File_And_Initialize, pDemo$State, $
         FILE = DEMO_FILEPATH('abell115.jpg', $
         SUBDIR = ['examples', 'demo', 'demodata'])
      WIDGET_CONTROL, AstroStatusLabel, SET_VALUE = ''
   ENDIF ELSE BEGIN
      DemoROI$Read_File_And_Initialize, pDemo$State, $
         FILE = DEMO_FILEPATH('pollens.jpg', $
         SUBDIR = ['examples', 'demo', 'demodata'])
   ENDELSE
ENDIF

;
; Intercept kill requests to force the user to exit
; gracefully via File/Exit.
;
WIDGET_CONTROL, TLB, /TLB_KILL_REQUEST_EVENTS

CATCH, /CANCEL
;
; Start up the event handler.
; This Xmanager call may not block if being called from
; another application which does not block
;
IF (DemoMode) THEN BEGIN
   DemoROI$Apply_Selection, pDemo$State
   XMANAGER, 'DemoROI', TLB, EVENT_HANDLER = 'DemoROI_Event', $
          CLEANUP='demoROI_Cleanup'
ENDIF ELSE BEGIN
   XMANAGER, 'DemoROI', TLB, EVENT_HANDLER = 'DemoROI_Event'
ENDELSE
;
; We're back from the event loop if we were in blocking mode,
; or the application has just been launched if in non-blocking mode

IF (NOT DemoMode) THEN BEGIN

   ; Free all the pointers associated with the application,
   ; but keep any pointers to the objects.
   ;
   pObjects = DemoROI$Free_Pointers(pDemo$State, /Keep_Objects)

ENDIF ELSE pObjects = PTR_NEW()

;
; pObjects will be a NULL pointer if we're not returning
; object information.
;
RETURN, pObjects
END


Pro d_ROI, AppTLB = AppTLB, $
           RECORD_TO_FILENAME=record_to_filename, $
           _Extra = Extra

;
; This is the IDL Demo's entry point for accessing
; the DemoROI function.
;
Dummy = DemoROI(_Extra = Extra, APPTLB = AppTLB)
End
