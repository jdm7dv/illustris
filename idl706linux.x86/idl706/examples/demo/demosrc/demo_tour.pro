; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/demo_tour.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
; NAME:
;       DEMO_TOUR
;
; PURPOSE:
;       Provide GUI controls and functionality to play a series
;       of events that step through and display the IDL
;       demonstration system.
;
;       Typically, (possibly hand-edited) output from
;       DEMO_RECORD is played by DEMO_TOUR.
;
; CATEGORY:
;       Demos
;
; CALLING SEQUENCE:
;       demo_tour
;
; KEYWORD PARAMETERS:
;       Show_Filenums: (Input).  If this keyword is set, numbers
;               from filenames such as 'recording55.txt' will
;               be shown in DEMO_TOUR's GUI control panel.
;               For example 'recording55.txt' would create an
;               item on DEMO_TOUR's GUI checklist with a name
;               ending in '(55)'.
;       Debug: (Input).  If set, do not catch and continue after an
;               error.
;
; OUTPUTS: none
;
; SIDE EFFECTS:
;       The IDL demo system is left running.
;
; RESTRICTIONS:
;       The IDL Demo system must be installed.
;
; PROCEDURE:
;       Read ASCII lines from certain IDL batch files.
;       Execute each line via IDL's CALL_PROCEDURE or
;       EXECUTE commands.
;
;       Batch files to be executed by DEMO_TOUR are assumed
;       to have the naming convention "recording??.pro", where
;       "??" can be any two digits.
;-
function demo_tour_poll, wid, wPauseButton, wStopButton, n_waits=n_waits, $
    frozen=frozen
forward_function demo_tour_poll
;
;Poll WIDget to see if the user clicked stop button.
;If N_WAITS is set, poll N_WAIT additional times, waiting
;between each.  Return the id of the
;clicked stop button, else return 0L.  If FROZEN
;then this function can return id of stop, pause, or 0L.
;
if not keyword_set(n_waits) then begin
    num_waits = 0
    end $
else begin
    num_waits = n_waits
    end

for i=0,num_waits do begin
    event = widget_event(wid, /nowait)
    if i gt 0 then $
        wait, .05
    if not keyword_set(frozen) then begin
        if event.id eq wPauseButton then begin
            widget_control, wPauseButton, set_value='Unfreeze Tour'
            repeat clicked = demo_tour_poll( $
                wid, wPauseButton, wStopButton, /frozen $
                ) $
            until clicked eq wPauseButton or clicked eq wStopButton
            if clicked eq wStopButton then $
                return, clicked
            widget_control, wPauseButton, set_value='Freeze Tour'
            end
        end
    if event.id ne 0 then begin
        if tag_names(event, /structure_name) eq 'WIDGET_KILL_REQUEST' then $
            return, wStopButton
        if event.id eq wStopButton then $
            return, wStopButton
        if event.id eq wPauseButton then $
            return, wPauseButton
        end
    end

return, event.id
end
;-------------------------------------------------------------------------
;Purpose: play accumulated events.
;
pro demo_tour_flush, $
    accum_strucs, $ ; IN/OUT. Gets undefined on output.
    done, $         ; IN/OUT
    accum_proc, $   ; IN
    damp_fac, $     ; IN
    tlb, $          ; IN
    wPauseButton, $ ; IN
    wStopButton, $  ; IN
    wDamper         ; IN

if n_elements(accum_strucs) gt 0 then begin
    num_damp_events = n_elements(accum_strucs) * damp_fac
    damp_strucs = replicate(accum_strucs[0], num_damp_events)
    if num_damp_events gt 1 then begin
        damp_strucs.x = congrid( $
            [accum_strucs.x], num_damp_events, /interp, /minus_one $
            )
        damp_strucs.y = congrid( $
            [accum_strucs.y], num_damp_events, /interp, /minus_one $
            )
        end
    for indx=0,num_damp_events-1 do begin
        if not done then begin
            call_procedure, accum_proc, damp_strucs[indx]
            case demo_tour_poll(tlb, $
                wPauseButton, $
                wStopButton $
                ) $
            of
                wStopButton: done = 1b
                wDamper: $
                    if num_damp_events-indx gt 10 $
;
;                   On Unix, several of these dialog_messages can
;                   be issued in a sequence if the user drags
;                   the wDamper slider.  This is undesirable because
;                   the user must issue numerous clicks to dissmiss
;                   all of the dialog messages.  Thus, don't issue this
;                   message on Unix.
;
                    and !version.os_family ne 'unix' then $
;
                        void = dialog_message( $
                            ['Your new motion dampening factor will', $
                             'take effect after the current motion', $
                             'is completed.'], $
                            /information $
                            )
                else:
                endcase
            end
        end
    void = temporary(accum_strucs)
    end
end
;-------------------------------------------------------------------------
pro demo_tour, show_filenums=show_filenums, debug=debug

catch, status
if status ne 0 then begin
    catch, /cancel
    void = dialog_message(!error_state.msg, /error)
    void = dialog_message('Turning off Demo Tour due to error.', /information)
    if n_elements(lun) gt 0 then begin
        if not keyword_set(show_filenums) then $
            print, 'Error occured while in: ' , (fstat(lun)).(1)
        close, lun
        free_lun, lun
        end
    if size(tlb, /tname) eq 'LONG' then begin
        if widget_info(tlb, /valid_id) then begin
            widget_control, /destroy, tlb
            end
        end
    if size(hidden_tlb, /tname) eq 'LONG' then begin
        if widget_info(hidden_tlb, /valid_id) then begin
            widget_control, /destroy, hidden_tlb
            end
        end
    return
    end
if keyword_set(debug) then $
    catch, /cancel

if xregistered('demo') gt 0 then begin
    void = dialog_message(['A copy of the IDL Demo System is currently', $
        'running.  Please exit the Demo System before', $
        'invoking the Demo Tour.'])
    return
    end

demo
art_screen = 'Main' ; Main Demo Screen with buttons on it.
;
;Open recorded files and count their lines.
;
master_filenames = FILE_SEARCH( $
    demo_filepath( $
        (['recording??.txt', 'recording%%.txt']) $
            [!version.os_family eq 'vms'], $
        subdir=["examples", "demo", "demodata"] $
        ) $
    )
if master_filenames[0] eq '' then $
    message, 'No recording .txt files were found.'

master_filenames = master_filenames[sort(strupcase(master_filenames))]
master_filenames = reverse(master_filenames, 1)
numlines = lonarr(n_elements(master_filenames))
checklist_names = strarr(n_elements(master_filenames))
line = ''
get_lun, lun
for i=0,n_elements(master_filenames)-1 do begin
    openr, lun, master_filenames[i]
    while not eof(lun) do begin
        readf, lun, line
;
;       Bold assumption: an appropriate name for the
;       Application Checklist can be extracted from the third line.
;
        if numlines[i] eq 2 then begin
            pos = strpos(line, 'demo:') + 5
            if pos gt 4 then begin
                checklist_names[i] = strmid( $
                    line, $
                    pos, $
                    strpos(line, '"', pos) - pos $
                    )
                end $
            else begin
                pos1 = strpos(line, '"') + 1
                pos2 = strpos(line, ':', pos1)
                checklist_names[i] = strmid(line, pos1, pos2-pos1)
                end
            end
        numlines[i] = numlines[i] + 1
        end
    close, lun
    end
if keyword_set(show_filenums) then begin
    for i=0,n_elements(checklist_names)-1 do begin
        checklist_names[i] = checklist_names[i] $
            + ' (' $
            + strmid( $
                master_filenames[i], $
                strlen(master_filenames[i]) - 6, $
                2 $
                ) $
            + ')'
        end
    end
;
;The demo tour player has two top-level bases. The
;first will be mapped, but, because we are going
;to handle its events ourselves, we do not
;register it with XMANAGER.
;
tlb = widget_base(title='Demo Tour', /tlb_kill_request_events)
;
;To avoid color flashing that can occur when the user clicks
;anywhere in this top-level base on 256 color Windows displays,
;hide an IDLgrWindow in this top-level base.
;
wHiddenDraw = widget_draw(widget_base(tlb, map=0), graphics_level=2)
;
wControlsBase = widget_base(tlb, /column)
wStopButton = widget_button( $
    wControlsBase, $
    value='Turn Off Tour' $
    )
wPauseButton = widget_button( $
    wControlsBase, $
    value='Freeze Tour' $
    )
wDamper = widget_slider( $
    wControlsBase, $
    title='Motion Dampening Factor', $
    minimum=1, $
    maximum=10 $
    )
wAdvancementSpeed = widget_slider( $
    wControlsBase, $
    title='Advancement Delay Factor', $
    minimum=1, $ ; 0 can make it difficult to interrupt Wavelets demo.
    maximum=25, $
    value=5 $
    )
wAppChecklist = cw_bgroup( $
    wControlsBase, $
    checklist_names, $
    set_value=bytarr(n_elements(checklist_names))+1b, $
    /nonexclusive $
    )
widget_control, tlb, map=0
widget_control, tlb, /realize
;
;Check to see if we got IDL's software rendering system for the
;hidden IDLgrWindow.  If yes, the hidden IDLgrWindow can cause
;color flashing with Direct Graphics on 256-color Windows displays.
;Such color flashing is worse than the flashing that the hidden
;IDLgrWindow was introduced to cure. So destroy the IDLgrWindow
;in this case.
;
widget_control, wHiddenDraw, get_value=oHiddenDraw
oHiddenDraw->GetProperty, renderer=renderer
if renderer eq 1 then $
    widget_control, /destroy, wHiddenDraw
;
;Position and map our top-level base.
;
tlb_geometry = widget_info(tlb, /geometry)
device, get_screen_size=scrsz
widget_control, tlb, $
   tlb_set_xoffset=(0 > (scrsz[0] - tlb_geometry.scr_xsize))
widget_control, tlb, map=1
;
;The second top level base is never mapped,
;but, so that apps (e.g. d_objworld2) can test
;the existence of the demo tour via XREGISTERED,
;this base is registerd with XMANAGER.
;
hidden_tlb = widget_base(map=0)
xmanager, 'demo_tour', hidden_tlb, /just_reg, /no_block
;
;Give the user a few moments to interact with the tour
;controls before cycling through the applications.
;
case demo_tour_poll( $
    tlb, $
    wPauseButton, $
    wStopButton, $
    n_waits=60 $
    ) $
of
    wStopButton: done = 1b
    else: done = 0b
    endcase
line = ''
current_file = n_elements(master_filenames) - 1
current_line_num = numlines[current_file]
mystruc = {id:0l, top:0l, handler:0l}
previous_was_widget_control = 0b
previous_was_slider = 0b
;
;Assume that recorded WIDGET_DRAW events were scaled to a
;2048 x 2048 pixel space.
;
rec_xsize = 2048 ; Pixels. Recorder's draw widget size in x.
rec_ysize = 2048 ; Pixels. Recorder's draw widget size in y.
;
while (not done) or previous_was_widget_control do begin
    widget_control, tlb, /show
    if current_line_num eq numlines[current_file] then begin
        widget_control, wAppChecklist, get_value=value
        if max(value) eq 0 then begin
            void = dialog_message(['You do not have any Demos selected.', $
                'The demo tour will now select one for you.'], /inform)
            value[0] = 1b
            widget_control, wAppChecklist, set_value=value, /show
            wait, 1 ; Allow user to notice what got checked.
            end
        repeat begin
            current_file = (current_file + 1) mod n_elements(master_filenames)
            end $
        until value[current_file]
        close, lun
        openr, lun, master_filenames[current_file]
        current_line_num = 0
        point_lun, lun, 0
        if keyword_set(show_filenums) then $
            print, 'Now Playing: ' + master_filenames[current_file]
        end
    readf, lun, line
    current_line_num = current_line_num + 1
;
;   Toggle Motion Damper sensitivity.
;
    case 1 of
        strpos(line, 'demo:Flythrough') ne -1: begin
            widget_control, wDamper, get_value=old_damp_fac
            widget_control, wDamper, sensitive=0
            widget_control, wDamper, set_value=1
            end
        strpos( $
            line, $
            'WIDGET_KILL_REQUEST, ID: demo_find_wid("d_flythru:tlb")' $
            ) ne -1: begin
            widget_control, wDamper, sensitive=1
            widget_control, wDamper, set_value=old_damp_fac
            end
        else:
        endcase
;
    widget_control, wAdvancementSpeed, get_value=wait_factor
    if strpos(line, 'WIDGET_DRAW') ne -1 $
    or strpos(line, 'WIDGET_SLIDER') ne -1 $
    or strpos(line, 'WIDGET_DROPLIST') ne -1 $
    or strpos(line, 'WIDGET_LIST') ne -1 then begin
        line_part = strtok(line, '{', /extract)
        if not execute('mystruc = {' + line_part[1]) then begin
            print, 'line ' + strtrim(current_line_num, 2) + ': ' + line
            message, !error_state.msg
            end
        end
;
;   For nicety, some events are padded with wait commands
;   before they are executed.  Determine how
;   many waits will be used to pad various events.
;
    case 1 of
        previous_was_widget_control: begin
            n_waits = 0
            end
        strpos(line, 'WIDGET_SLIDER') ne -1 and previous_was_slider: $
            n_waits = 2
        previous_was_slider: begin
            n_waits = 4
            end
        strpos(line, 'WIDGET_TEXT') ne -1: begin
            n_waits = 2
            end
        strpos(line, 'WIDGET_DRAW') ne -1: begin
            if mystruc.type eq 0 then begin ; Mouse-Button down event.
                n_waits = 2
;               if strpos(line, 'd_objworld2:') ne -1 then begin
;                   n_waits = n_waits / 2 ; Add some extra zippiness.
;                   end
                end $
            else $
                n_waits = 0
            end
        strpos(line, 'WIDGET_TIMER') ne -1: $
            n_waits = 0
        strpos(line, 'demo:') ne -1: $
            n_waits = 10
        else: begin
            n_waits = 6
            if strpos(line, 'd_objworld2:') ne -1 then begin
                n_waits = n_waits / 2 ; Add some extra zippiness.
                end
            end
        endcase
;
    if strmid(line, 0, 1) ne ';' then begin
        case demo_tour_poll( $
            tlb, $
            wPauseButton, $
            wStopButton, $
            n_waits=n_waits*wait_factor $
            ) $
        of
            wStopButton: done = 1b
            else:
            endcase
;
;       Some widgets are easy to update automatically, so we
;       control them here.  Similar WIDGET_CONTROL commands
;       for other widgets (e.g. unusual compund widgets) can be
;       put into the recorded .txt file by hand as needed.
;
        if strpos(line, 'WIDGET_SLIDER') ne -1 then begin
            widget_control, mystruc.id, set_value=mystruc.value
            previous_was_slider = 1b
            end $
        else begin
            previous_was_slider = 0b
            case 1 of
                strpos(line, 'WIDGET_DROPLIST') ne -1: $
                    widget_control, mystruc.id, set_droplist_select=mystruc.index
                strpos(line, 'WIDGET_LIST') ne -1: $
                    widget_control, mystruc.id, set_list_select=mystruc.index
                else: ; Hope that any needed widget_control is in recording file.
                endcase
            end
;
        if strpos(line, 'WIDGET_DRAW') ne -1 then begin
;
;           Objworld uses some negative x, y locations as special signals,
;           so we skip those.
;
            if mystruc.x ge 0 and mystruc.y ge 0 then begin
;
;               Scale the recorded x & y event location to the geometry
;               size of the current draw widget.  (Note: Due to this
;               scaling, applications which use Trackball objects typically
;               work best when they are coded so as to preserve the aspect
;               ratio of their draw widget if the draw widget can be different
;               sizes.)
;
                geometry = widget_info(mystruc.id, /geometry)
                mystruc.x = round( $
                    mystruc.x / (rec_xsize - 1.) * (geometry.draw_xsize - 1) $
                    )
                mystruc.y = round( $
                    mystruc.y / (rec_ysize - 1.) * (geometry.draw_ysize - 1) $
                    )
                end
;
            myproc = byte(line_part[0])
            myproc = string(myproc[0:n_elements(myproc)-3]) ; Trim comma.

            case mystruc.type of
                4: begin    ; Expose event.
                    cueing = 0b
                    n_waits = 2
                    end
                2: begin    ; Mouse-button motion
                    widget_control, wDamper, get_value=damp_fac
                    if damp_fac gt 0 then begin
                        cueing = 1b
                        if n_elements(accum_strucs) eq 0 then begin
                            accum_strucs = mystruc
                            accum_proc = myproc
                            end $
                        else begin
                            if accum_proc ne myproc then $
                                cueing = 0b $
                            else $
                                accum_strucs = [accum_strucs, mystruc]
                            end
                        end $
                    else $
                        cueing = 0b
                    end
                1: begin    ; Mouse-button up event.
                    cueing = 0b
                    n_waits = 4
                    end
                0: begin
                    pressed = mystruc.press
                    cueing = 0b
                    end
                else: cueing = 0b
                endcase
            if not cueing then begin
                demo_tour_flush, accum_strucs, done, accum_proc, $
                    damp_fac, tlb, wPauseButton, wStopButton, wDamper
                call_procedure, myproc, mystruc
                end
            end $
        else begin
            demo_tour_flush, accum_strucs, done, accum_proc, $
                damp_fac, tlb, wPauseButton, wStopButton, wDamper
            if not execute(line) then begin
                print, 'Error executing line ' + strtrim(current_line_num, 2) + ': '
                print, line
                message, !error_state.msg
                end
            end

        previous_was_widget_control = $
            ([0b, 1b])[strpos(strupcase(line), 'WIDGET_CONTROL') eq 0]
        end
    end
;
;If the user stopped the tour while a recording has a mouse-button
;down, execute a mouse-button up command.  This code is written
;with the assumption that only one mouse button is pressed at a time.
;
if strpos(line, 'WIDGET_DRAW') ne -1 then begin ; Draw widget event?
    if mystruc.type eq 0 or mystruc.type eq 2 then begin
        mystruc.release = pressed
        mystruc.press = 0
        mystruc.type = 1 ; Mouse-button release.
        call_procedure, myproc, mystruc
        end
    end

close, lun
free_lun, lun
widget_control, /destroy, tlb
widget_control, /destroy, hidden_tlb
void = dialog_message( $
    ['The Demo Tour is turned off.  You can', $
     'now operate the IDL Demo System manually.'], $
    /inform $
    )
;
;Attempt to clear any user generated Demo App events that
;may have been piling up.
;
if widget_info(mystruc.top, /valid_id) then begin
    widget_control, mystruc.id, /clear_events
    end
end
