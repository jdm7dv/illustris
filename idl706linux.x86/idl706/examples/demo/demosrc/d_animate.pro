; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_animate.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_animate.pro
;
;  CALLING SEQUENCE: d_animate
;
;  PURPOSE:
;       Display several animations.
;
;  MAJOR TOPICS: Animation and widgets
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_cfd                 - Call the cfd animation.
;       pro d_gated               - Call the gated blood animation.
;       pro d_animateEvent        - Event handler
;       pro d_animateCleanup      - Cleanup
;       pro cfd                   - Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro CW_ANIMATE:         - Animation tool routine
;       pro CW_ANIMATE_INIT:    - Animation tool routine
;       pro CW_ANIMATE_LOAD:    - Animation tool routine
;       pro CW_ANIMATE_RUN:     - Animation tool routine
;       pro demo_gettips        - Read the tip file and create widgets
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
;
;-
;---------------------------------------------------------
;
;  PURPOSE  :  Call for the pressure field animation.
;
pro d_cfd, $
         RECORD_TO_FILENAME=record_to_filename, $
         GROUP = group, $       ; IN: (opt) group identifier
         APPTLB = wTopBase ; OUT: (opt) TLB of this application

d_animate, "cfd", '2-D CFD Animation', $
  NFRAMES=16, NCOLORS=160, $
  GROUP=group, APPTLB = wTopBase
end                             ;cfd


;---------------------------------------------------------
;
;  PURPOSE  :  Call for the gated blood pool animation.
;
pro d_gated, $
         RECORD_TO_FILENAME=record_to_filename, $
         GROUP = group, $       ; IN: (opt) group identifier
         APPTLB = wTopBase ; OUT: (opt) TLB of this application

; If gated data file is NOT compressed:
d_animate, "gated", "Gated Blood Pool", $
  UNCOMPRESSED = [128, 64], $
  COLOR_TABLE_INDEX = 3, $
  NFRAMES=15, NCOLORS=225, GROUP=group, APPTLB = wTopBase, /ZOOM

; If we use a png file:
; animate_demo, "gated", "Gated Blood Pool", $
;  NFRAMES=15, NCOLORS=225, GROUP=group, APPTLB = wTopBase, /ZOOM

end                             ;gated

;---------------------------------------------------------
;
;  PURPOSE  : event handler
;
pro d_animateEvent, $
       sEvent                   ; IN: event structure

if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
    'WIDGET_KILL_REQUEST') then begin
    WIDGET_CONTROL, sEvent.top, /DESTROY
    RETURN
endif

WIDGET_CONTROL, sEvent.id, GET_UVALUE= uValue

case uValue of
        ;  Quit this application (end animation button).
        ;
    0 : begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    end

        ;  Quit this application (menu bar).
        ;
    1 : begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    end

    2 : begin
        XLOADCT, GROUP=sEvent.top
        RETURN
    end

        ;  Display the information file.
        ;
    3 : begin
        Widget_Control, sEvent.top, GET_UVALUE = sInfo
        ONLINE_HELP, 'd_animate', $
                     book=demo_filepath("idldemo.adp", $
                                        SUBDIR=['examples','demo','demohelp']), $
                     /FULL_PATH
    end

endcase
end   ; of d_animateEvent

;---------------------------------------------------------
;
;  PURPOSE  : Cleanup procedure
;
pro d_animateCleanup, wTopBase

    ;  Get the info structure saved in the window's user value.
    ;
    WIDGET_CONTROL, wTopBase, GET_UVALUE=sInfo, /NO_COPY

    ;  Restore the previous color table.
    ;
    TVLCT, sInfo.colorTable

    ;  Map the group leader bvase if it exists.
    ;
    if (WIDGET_INFO(sInfo.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sInfo.groupBase, /MAP

end

;---------------------------------------------------------
;
PRO d_animate, Demoname, Title, $
           RECORD_TO_FILENAME=record_to_filename, $
           NFrames = Nframes, $
           NCOLORS=ncolors, $   ;# of colors required for animation.  If omitted, 1st image is scanned.
           UNCOMPRESSED = uncompressed, $ ;If data file isn't in PNG format,
                                ;this contains the dimensions of the images.
           ZOOM=zoom, $         ;TRUE to zoom up if screen is large
           COLOR_TABLE_INDEX = colortb_index, $ ; If set, load this color tbl
           GROUP = group, $     ; IN: (opt) group identifier
           APPTLB = wTopBase    ; OUT: (opt) TLB of this application

on_error, 2 ; Return to caller on error.

; tstart = systime(1)
if (n_elements(group) NE 0) then groupBase = group $
else groupBase = 0L

if N_ELEMENTS(demoname) eq 0 then begin
    demoname = "cfd"
    title = '2-D CFD Animation'
end

if n_elements(nframes) eq 0 then begin
    case 1 of
        strupcase(demoname) eq "CFD": nframes = 16
        strupcase(demoname) eq "GATED": nframes = 15
        else: message, 'Number of animation frames is undefined.  ' + $
            '(Use NFRAMES keyword).'
    endcase
endif

    ;  Initialize the device.
    ;
if (((!D.Name EQ 'X') OR (!D.NAME EQ 'MAC')) AND $
    (!D.N_Colors GE 256L)) then DEVICE, PSEUDO_COLOR=8
DEVICE, Decomposed=0, Bypass_Translation=0
DEVICE, GET_SCREEN_SIZE = scrsize

drawbase = demo_startmes(GROUP=groupbase) ;  Create the starting up message.

; Determine the input file name:
if keyword_set(uncompressed) then filename = DemoName + '.dat' $
else filename = DemoName + '.png'
Filename = demo_filepath(filename, SUBDIR=['examples', 'demo', 'demodata'])

openr, lun, /GET_LUN, Filename, ERROR=i ;See if file is readable
if i lt 0 then begin
    result = DIALOG_MESSAGE(["Can't read Data file:", filename], /ERROR)
    if groupBase ne 0 then WIDGET_CONTROL, groupBase, /MAP
    WIDGET_CONTROL, drawbase, /DESTROY ;  Destroy the starting up window.
    RETURN
endif

;  Get the current color table. It will be restored when exiting.
TVLCT, savedR, savedG, savedB, /GET
colorTable = [[savedR],[savedG],[savedB]]

if keyword_set(uncompressed) then begin
    Image = Bytarr(uncompressed[0], uncompressed[1], /NOZERO)
    readu, Lun, Image
    if n_elements(colortb_index) ne 0 then loadct, colortb_index, /SILENT
    tvlct, Red, Green, Blue, /GET
endif else begin
    mosaic = read_png(Filename, Red, Green, Blue)
    free_lun, lun
    mosaic = reform(mosaic, 400, 200, 16)
    image = mosaic[*,*,0]
endelse

if n_elements(ncolors) eq 0 then ncolors = max(Image) ;Default = max 1st frame

s = size(Image)                 ;Get dimensions of frame
ImXSize = s[1]                  ;Window and file image size
ImYSize = s[2]


if keyword_set(ZOOM) then begin ;Rebin?
    DEVICE, GET_SCREEN=screenSize ;How large is the screen

;  Try for approx 1/2 the vertical height of the screen
    zoomFactor = 0.666 * Float(screenSize) / s[1:2] ;Screensize / image size
    zoomFactor = FLOOR(min(zoomFactor)) > 1 ;Vertical zoom
endif else zoomFactor = 1

winxsize = zoomFactor * ImXSize
winysize = zoomFactor * ImYSize

if !d.table_size lt ncolors then $ ;Compress color tables?
  TVLCT, BYTSCL(red, MAX=ncolors-1), $
  BYTSCL(green, MAX=ncolors-1), $
  BYTSCL(Blue, MAX=ncolors-1) $
else TVLCT, Red, Green, Blue         ;The Demo's color table

wTopBase = WIDGET_BASE(TITLE = Title, /COLUMN, $
                       MBAR=barBase, $
                       /TLB_KILL_REQUEST_EVENTS, $
                       GROUP_LEADER=groupbase, $
                       TLB_FRAME_ATTR=1, MAP=0)

wFileButton = WIDGET_BUTTON(barBase, VALUE='File', $
                            UVALUE='File', /MENU)

wQuitButton = WIDGET_BUTTON(wFileButton, VALUE='Quit', $
                            UVALUE=1)

wViewButton = WIDGET_BUTTON(barBase, VALUE='View', $
                            UVALUE='VIEW', /MENU)

wColorButton = WIDGET_BUTTON(wViewButton, $
                             VALUE='Colors...', $
                             UVALUE=2)

cmap_applicable = COLORMAP_APPLICABLE(redraw_required)
if (cmap_applicable le 0) or $
   (cmap_applicable gt 0 and redraw_required gt 0) then begin
    WIDGET_CONTROL, wColorButton, SENSITIVE=0
endif

wHelpButton = WIDGET_BUTTON(barBase, VALUE='About', $
                            UVALUE='HELP', /MENU, /HELP)

wAboutButton = WIDGET_BUTTON(wHelpButton, $
                             VALUE='About this animation', $
                             UVALUE=3)

animate = CW_ANIMATE(wTopBase, winxsize, $
                     winysize, Nframes,$
                     INFO_FILE=demo_filepath(DemoName + '.txt', $
                                        SUBDIR=['examples','demo','demotext']))

wStatusBase = WIDGET_BASE(animate, MAP=0, /ROW) ;  text widget for tips.

WIDGET_CONTROL, wTopBase, /REALIZE ;  Realize the widget hierarchy.

sText = demo_getTips(demo_filepath(DemoName+'.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)


sInfo = { $                     ;  Create the info structure.
          DemoName : DemoName, $ ;our name
          Title : Title, $
          colorTable: colorTable, $ ; saved color table to restore
          groupBase: groupbase $ ; Base of Group Leader
        }

WIDGET_CONTROL, wTopBase, SET_UVALUE=sInfo, /NO_COPY
WIDGET_CONTROL, drawbase, /DESTROY ;  Destroy the starting up window.
WIDGET_CONTROL, wTopBase, map = 1 ;  Map the top level base.

for i = 0, Nframes-1 do begin  ;  Load the images.
    if i ne 0 then begin            ;Read 2nd and following images
        if keyword_set(uncompressed) then readu, lun, Image $
        else Image = mosaic[*,*,i]
    endif

    if !d.table_size lt ncolors then $ ;Compress color tables?
      image = BYTSCL(image, TOP=!D.TABLE_SIZE-1, MAX=ncolors, MIN=0)

    if zoomFactor ne 1 then $   ;Zoom up?
      CW_ANIMATE_LOAD, animate, FRAME=i, $
        IMAGE= REBIN(Image, winxsize, winysize) $
    else CW_ANIMATE_LOAD, animate, FRAME=i, image= image
endfor

if keyword_set(uncompressed) then FREE_LUN, lun

Image = 0                       ;Free the space
mosaic = 0

CW_ANIMATE_RUN, animate, 20     ; Run the animation...

; print, systime(1) - tstart, ' seconds'

XMANAGER, DemoName, wTopBase, Event_Handler='d_animateEvent', $
  Cleanup='d_animateCleanup', /NO_BLOCK
end                             ; animate_demo
