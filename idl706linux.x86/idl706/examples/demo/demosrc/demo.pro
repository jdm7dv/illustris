; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/demo.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       demo.pro
;
;  CALLING SEQUENCE: demo
;
;  PURPOSE:
;       Main demo shell.
;
;  MAJOR TOPICS: All topics in IDL.
;
;  CATEGORY:
;       IDL demo system.
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro demoTimer             -  Print times & update current time
;       pro demoDoAScreen         -  Write image to file
;       pro demoSaveScreens       -  Write images to save file
;       func demoPReadScreen      -  Return a pointer to an image
;       pro demoResetSysVars      -  Reset system variables
;       pro demoShowScreen        -  Display a screen
;       pro demoStartHelp         -  Start the Online Help system
;       pro demoStartApp          -  Start a demo application
;       func demoFuncsumCleanup   -  Cleanup
;       func demoFuncsumEvent     -  Event handler
;       func demoFuncsum          -  Display IDL functional summary text
;       pro demoEvent             -  Event handler
;       pro demo                  -  Main routine
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
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
;       3/97,    ACY   - Modified
;-
;----------------------------------------------------------------------------
pro demoTimer, text, t0             ;Print times & update current time
t1 = systime(1)
print, text, ' ', t1 - t0
t0 = t1
end
;----------------------------------------------------------------------------
Function demoPReadScreen, Index, Header, Colortable, NO_CACHE=no_cache, $
                         DEBUG = debug
; Return a pointer to an image for screen number Index.
; Return colortable in Colortable
;

Null = ptr_new()
Nkeep = 3                       ;# of images to keep in cache
Header.count = Header.count + 1 ;Keep track of time

if Header.cache[Index] ne Null then begin ;Already there?
    Result = Header.cache[Index]
    Colortable = *(Header.colortb[Index])
;    if keyword_set(debug) then print,'cached ', Index
endif else begin
    in = where(header.cache ne Null, count)
    if count ge Nkeep then begin ;Must get rid of an image
        junk = min(header.time[in], Toss);Find image that been in the longest
        toss = in[toss]
;        if keyword_set(debug) then print, 'Removed ', toss
        ptr_free, Header.cache[toss]
        Header.cache[toss] = Null
    endif
    result = ptr_new(READ_PNG(header.filename[Index], r, g, b))
    Colortable = transpose([transpose(r), transpose(g), transpose(b)])
    Header.colortb[Index] = PTR_NEW(Colortable)
    if keyword_set(no_cache) eq 0 then Header.cache[Index] = result
;    if keyword_set(debug) then print, 'Read ', index
endelse

Header.time[Index] = Header.count
Return, Result                  ;Return the pointer to the image
end

;----------------------------------------------------------------------------
;
;  Purpose:  Reset the system variables.
;
pro demoResetSysVars

    Set_Shading, LIGHT=[0.0, 0.0, 1.0], /REJECT, /GOURAUD, $
        VALUES=[0, (!D.Table_Size-1L)]

    T3d, /RESET
    !P.T3d = 0
    !P.Position = [0.0, 0.0, 0.0, 0.0]
    !P.Clip = [0L, 0L, (!D.X_Size-1L), (!D.Y_Size-1L), 0L, 0L]
    !P.Region = [0.0, 0.0, 0.0, 0.0]
    !P.Background = 0L
    !P.Charsize = 8.0 / Float(!D.X_Ch_Size)
    !P.Charthick = 0.0
    !P.Color = !D.N_Colors - 1L
    !P.Font = (-1L)
    !P.Linestyle = 0L
    !P.Multi = [0L, 0L, 0L, 0L, 0L]
    !P.Noclip = 0L
    !P.Noerase = 0L
    !P.Nsum = 0L
    !P.Psym = 0L
    !P.Subtitle = ''
    !P.Symsize = 0.0
    !P.Thick = 0.0
    !P.Title = ''
    !P.Ticklen = 0.02
    !P.Channel = 0

    !X.S = [0.0, 1.0]
    !X.Style = 0L
    !X.Range = 0
    !X.Type = 0L
    !X.Ticks = 0L
    !X.Ticklen = 0.0
    !X.Thick = 0.0
    !X.Crange = 0.0
    !X.Omargin = 0.0
    !X.Window = 0.0
    !X.Region = 0.0
    !X.Charsize = 0.0
    !X.Minor = 0L
    !X.Tickv = 0.0
    !X.Tickname = ''
    !X.Gridstyle = 0L
    !X.Tickformat = ''

    !Y = !X
    !Z = !X

    !X.Margin = [10.0, 3.0]     ;.Margin is different for x,y,z
    !Y.Margin = [4.0, 2.0]
    !Z.Margin = 0
end


;----------------------------------------------------------------------------
;
;  Purpose:  read the required image index newScreen, and display it.
;
pro demoShowScreen, newScreen, state

t0 = systime(1)

WSET, state.mainDrawID

Header = state.png_header
Image = demoPReadScreen(newScreen, header, colortb, DEBUG=state.debug)
state.png_header = Header          ;Restore status
WIDGET_CONTROL, state.imageBase, MAP=0, SENS=0   ;If we rearrange order of
                                ; operations, this seems unnecessary.
TVLCT, colortb
TV, *image                      ;show it

for i=0, N_ELEMENTS(state.buttons)-1 do $ ;Map buttons for this screen
  WIDGET_CONTROL, state.buttons[i].btnBase, $
    MAP= state.buttons[i].screenNum eq newScreen

if max(state.curScreenNum eq [0, 4, 5, 6, 8, 9, 1, 2, 7, 3]) gt 0 then begin
    state.prevScreenNum = state.curScreenNum
endif
state.curScreenNum  = newScreen
WIDGET_CONTROL, state.imageBase, /MAP
WIDGET_CONTROL, state.imageBase, /SENS

if state.debug then demoTimer, 'demoShowScreen ', t0
end

;----------------------------------------------------------------------------
;
;  Purpose:  This routine is used to start the online
;            help system. The user value (uval) can come
;            from either a button or the pulldown menu
;
pro demoStartHelp, $
    uval,      $ ; IN: user value
    top          ; IN: top level base

    result = DIALOG_MESSAGE(/QUESTION, $
        DIALOG_PARENT=top, $
        ['This choice will start the Online Help system.', $
         '', $
         'Do you want to continue ?'])
    if (strupcase(result) EQ 'NO') then RETURN

    case uval of


        ;  Start the online help system with the default screen
        ;
        'NOARG': online_help

    endcase

end


;----------------------------------------------------------------------------
;
;  Purpose:  This routine is used to start all demos.
;            Name must be the name of the procedure to call.
;            a button or the pulldown menu
;
pro demoStartApp, $
              Name, $           ;Name of demo
              state, $          ; IN: state structure
              top, $            ; IN: top level base
              EXTRA = extra     ;Extra keyword parameter structure (optional)

    if (WIDGET_INFO(state.apptlb, /VALID)) then begin
        result = DIALOG_MESSAGE('Only one demo may run at a time')
        RETURN
    endif

    if state.slow and (total(name eq state.slow_demos) gt 0) then begin
        result = $
          DIALOG_MESSAGE(['This demo utilizes computationally intensive', $
                          'graphics.  Response on this machine may be', $
                          'unacceptably slow.', $
                          'Continue anyway?'], $
                         DIALOG_PARENT=top, $
                         /QUESTION)
                                ;Only display once
        state.slow_demos[where(state.slow_demos eq name)] = 'XXXX'
        if result eq 'No' then return
    endif

    WIDGET_CONTROL, /HOURGLASS
    demoResetSysVars
    resolve_routine, Name       ;Be sure its compiled/loaded
    state.demo_name = Name      ;Save name of demo
;    WIDGET_CONTROL, state.mainWinBase, map=0 ;Unmap menu
    if !Version.Os_Family EQ 'MacOS' then WAIT, .1
    if state.debug then begin   ;Clean up our memory first, we should
                                ;have nothing allocated except the
                                ;pointers for the screen cache.
        ptr_free, state.png_header.cache ;Free our screens
        state.png_header.cache = ptr_new() ;by clearing the cache...
        state.memory = memory() ;Save memory state
    endif

    if n_elements(extra) gt 0 then $ ;Call it
      call_procedure, $
        Name, $
        GROUP=top, $
        APPTLB = appTLB, $
        RECORD_TO_FILENAME=state.record_to_filename, $
        _EXTRA=extra $
    else call_procedure, $
        Name, $
        GROUP=top, $
        APPTLB = appTLB, $
        RECORD_TO_FILENAME=state.record_to_filename

    if state.debug then begin
    endif
    if n_elements(appTLB) then state.appTlb = appTLB $
    else state.appTlb = 0L

end


;----------------------------------------------------------------------------
;
;  Purpose:  Display IDL functional summary in text widgets

pro demoFuncsumCleanup, wTopBase
end

pro demoFuncsumEvent, sEvent
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ  $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sStateFuncsum, /NO_COPY

    WIDGET_CONTROL, sEvent.id, GET_UVALUE= uvalue
    case uvalue of
       'LIST': begin
                online_help, $
                             book=demo_filepath("d_demo.pdf", $
                                SUBDIR=['examples','demo','demohelp']), $
                             /FULL_PATH
           end
        'QUIT' : BEGIN
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sStateFuncsum, /NO_COPY
            WIDGET_CONTROL, sEvent.top, /DESTROY
            RETURN
        end   ; of QUIT
        ELSE: help, /str, sEvent
    endcase
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sStateFuncsum, /NO_COPY

end


PRO demoFuncsum, $
    GROUP=group, $               ; IN: (opt) group identifier
    APPTLB = appTLB              ; OUT: (opt) TLB of this application

    ; Check the validity of the group identifier.
    ;
    ngroup = N_ELEMENTS(group)
    if (ngroup NE 0) then begin
        check = WIDGET_INFO(group, /VALID_ID)
        if (check NE 1) then begin
            print,'Error, the group identifier is not valid'
            print, 'Return to the main application'
            RETURN
        endif
        groupBase = group
    endif else groupBase = 0L

    ;  Read the topics for the list
    OPENR, lun, /get_lun, demo_filepath("funcsum_topics.txt", $
                             SUBDIR=['examples','demo','demotext'])
    line=''
    readf, lun, line
    topicList = [line]
    while not eof(lun) do begin
       readf, lun, line
       topicList = [topicList, line]
    endwhile
    free_lun, lun

    ;  Create widgets.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase = WIDGET_BASE(/COLUMN, $
            TITLE="IDL Functional Summary", $
            XPAD=0, YPAD=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR=1, MBAR=barBase)
    endif else begin
        wTopBase = WIDGET_BASE(/COLUMN, $
            TITLE="IDL Functional Summary", $
            XPAD=0, YPAD=0, $
            /TLB_KILL_REQUEST_EVENTS, $
            GROUP_LEADER=group, $
            /FLOATING, $
            TLB_FRAME_ATTR=1, MBAR=barBase)
    endelse

        ;  Create the menu bar. It contains the file/quit,
        ;  edit/ shade-style, help/about.
        ;
        wFileButton = WIDGET_BUTTON(barBase, VALUE='File', /MENU)

            wQuitButton = WIDGET_BUTTON(wFileButton, $
                VALUE='Quit', UVALUE='QUIT', $
                UNAME='demo:quit')

         ;  Create a sub base of the top base (wTopBase)
         ;
         subBase = WIDGET_BASE(wTopBase, /COLUMN)

         wLabel = WIDGET_LABEL(subBase, value= $
            'For detailed information select a topic.')

         wList = WIDGET_LIST(subBase, value=topicList, $
                             uvalue="LIST", $
                             ysize=n_elements(topicList))

    ;  Realize the base widget.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ;  Returns the top level base in the appTLB keyword
    ;
    appTLB = wTopBase


    ;  Create the state structure.
    ;
    sStateFuncsum = { $
        topicList: topicList, $
        wTopBase : wTopbase, $               ; Top level base
        groupBase: groupBase $               ; Base of Group Leader
     }

    WIDGET_CONTROL, wTopBase, SET_UVALUE=sStateFuncsum, /NO_COPY

    XMANAGER, 'demoFuncsum', wTopBase, $
        EVENT_HANDLER='demoFuncsumEvent', $
        /NO_BLOCK, $
        CLEANUP='demoFuncsumCleanup'

end   ;

;----------------------------------------------------------------------------
;
;  Purpose:  Main event handler.
;
; The uvalue (or in the case of pulldown menus, the uvalue is saved in
; state.MenuActions) is encoded as follows:
; quit = quit
; INSIGHT-START = start insight.
; >FileName|Title  = display the file FileName in the demotext
;   directory, with the given title.
; <topicNum|Book = display the topic topicNum from the specified book
; .n = display screen n (n is a series of digits.)
; .- = display previous screen
; ?KEY = call DEMOSTARTHELP with KEY
; NAME = call demoStartApp with NAME


pro demoEvent, $
    event      ; IN: event structure.

;  Quit the application using the close box.
;
WIDGET_CONTROL, event.top, GET_UVALUE=state, /NO_COPY

if state.record_to_filename ne '' then $
    demo_record, event, 'demoEvent', filename=state.record_to_filename

if (TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST') then begin
   WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY
   WIDGET_CONTROL, event.top, /DESTROY
   RETURN
endif

WIDGET_CONTROL,event.id,GET_UVALUE=uval

if state.debug and state.memory[0] ne 0L then begin ;Check demo's memory use?
    mem_end = fix(memory()/1000L) ;In K...
    mem_start = fix(state.memory/1000L)
    print, 'Finished demo ', state.demo_name
    print, 'Memory before start: ', mem_start[0], 'K, after: ', $
      mem_end[0], ', delta: ', mem_end[0] - mem_start[0]
;   print, 'High-water mark: ', mem_start[4]
    help, /heap
    heap_gc, /VERBOSE
    device, WINDOW_STATE=w      ;Check for open windows
    if total(w) gt 1 then begin ;Got too many windows open
        print, 'ERROR: Only one window should be open:', where(w)
    endif
    state.memory = 0L
endif


    ;  This CATCH branch handles unexpected errors that might
    ;  arise in the event loop.  Since the state is retrieved
    ;  with NO_COPY, it is important to put it back into the
    ;  user value of event.top so that execution can continue
    ;  if there is an error caught by CATCH.
    ;
ErrorStatus = 0
CATCH, ErrorStatus
IF (ErrorStatus NE 0) THEN BEGIN
    CATCH, /CANCEL
    v = DIALOG_MESSAGE(['Unexpected error in DEMO:', $
                        '!ERROR_STATE.MSG = ' + !ERROR_STATE.MSG, $
                        '!ERROR_STATE.SYS_CODE = ' + $
                           STRTRIM(LONG(!ERROR_STATE.SYS_CODE), 2), $
                        '!ERROR_STATE.SYS_MSG = ', !ERROR_STATE.SYS_MSG, $
                        ' ', 'Cleaning up...'], $
                       DIALOG_PARENT=event.top, $
                       /ERROR)
    WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY
    WIDGET_CONTROL, event.top, /MAP
    RETURN
ENDIF

IF state.debug THEN $
    CATCH, /CANCEL

; if state.debug then begin       ;Debugging
;    if total(tag_names(event) eq 'VALUE') ne 0 then v = event.value $
;    else v = '<>'
;    print, uval, ' ', v
; endif

if uval eq 'MAIN_PULLDOWN' then $ ;Translate menu pulldowns using action array
  uval = state.MenuActions[event.value]

char = strmid(uval, 0, 1)       ;What kind of action
rest = strmid(uval, 1, strlen(uval)-1)

if char eq '.' then begin       ;Display a screen
    if uval eq '.-' then demoShowScreen, state.prevScreenNum, state $
    else demoShowScreen, fix(rest), state
endif else if char eq '>' then begin ;Display a file
    parts = strtok(rest, '|', /extract) ;Get file name & title
    xdisplayfile, demo_filepath(parts[0] + '.txt', $
                           SUBDIR=['examples','demo','demotext']), $
             group=group, HEIGHT=35, WIDTH=75, $
             font=state.xdisplayfile_text_font, $
             title= parts[1]
endif else if char eq '<' then begin ;Display a topic from online help
    parts = strtok(rest, '|', /extract) ;Get file name & book
    book = parts[1]
    if (book EQ 'd_demo.pdf') then begin
       book=demo_filepath("d_demo.pdf", $
         SUBDIR=['examples','demo','demohelp'])
       online_help, $
                 book=book, $
                 /FULL_PATH
    endif else begin
       online_help, $
                 book=book
    endelse
endif else if char eq '?' then begin
    demoStartHelp, rest, event.top
endif else begin                ;Must be a demoStartApp
    if uval eq 'quit' then begin ;Quit is a special case
        WIDGET_CONTROL, event.top, SET_UVALUE=state ;Restore our state
        WIDGET_CONTROL, event.top, /destroy
        return
    endif else begin            ;Just call the app
        if keyword_set(state.record_to_filename) then begin
            if max( $
                strupcase(uval) $
                eq ['D_CONTOUR', 'D_FLYTHRU',  'D_IMAGPROC', $
                    'D_MAP',     'D_MATHSTAT', 'D_OBJWORLD2', $
                    'D_PLOT2D',  'D_SURFVIEW', 'D_T_SERIES', $
                    'D_USCENSUS','D_VECTRACK', 'D_VOLRENDR', $
                    'D_WAVELET'] $
                ) $
            eq 0 then begin
                void = dialog_message( $
                    ['The ' + uval + ' application requires code ', $
                     'modifications to be recordable.  The file to', $
                     'which you are currently recording, ', $
                      state.record_to_filename +', will not contain events',$
                     'for ' + uval + ', and may cause errors if', $
                     'it is run via the IDL Demo Tour without', $
                     'modification.'], $
                    DIALOG_PARENT=event.top $
                    )
            end
        end

        case uval of            ;Check for special cases
            'FUNCSUM': demoFuncsum, group=event.top
            'ROI-SPACE' : demoStartApp, 'D_ROI', state, event.top, $
              EXTRA={ASTRO:1}
            'FILTER-SIGNAL' : demoStartApp, 'D_FILTER', state, event.top, $
              EXTRA={FILENAME: 'damp_sn.dat'}
            'FILTER-ENGR': demoStartApp, 'D_FILTER', state, event.top, $
              EXTRA={FILENAME: 'damp_sn.dat'}
            'FILTER-SPACE': demoStartApp, 'D_FILTER', state, event.top, $
              EXTRA={FILENAME:'galaxy.dat'}
            'XROI': demoStartApp, 'XROI', state, event.top, $
              EXTRA={TEST:1}
            else : demoStartApp, uval, state, event.top ;Normal demo
        endcase
    endelse
endelse

WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY ;Restore our state
END   ; demoEvent




;----------------------------------------------------------------------------
;
;  Purpose:  Main procedure for IDL demo.
;
pro demo

  on_error, 2                   ; Return to caller on error.

  ;; for now, just create a new demo object and return
  IF (xregistered( "demo" ) NE 0) THEN return

  demo = obj_new('demoObj',/no_xmanager,/no_decomposed)
  xmanager,'demo',demo->getTLB(),/no_block,event_handler='demoObj_demo_event'
  return

END 

;---
PRO MAIN
  demo
END
