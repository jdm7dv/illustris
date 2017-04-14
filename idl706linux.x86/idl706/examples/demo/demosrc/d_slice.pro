; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_slice.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
PRO d_slice, $
    GROUP=group, $          ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    APPTLB = appTLB         ; OUT: (opt) TLB of this application

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

    ;  Get the current color vectors to restore 
    ;  when this application is exited.
    ;
    TVLCT, savedR, savedG, savedB, /GET
 
   head = Bytarr(80, 100, 57, /Nozero)
   Openr, lun, demo_filepath('head.dat', $
       SUBDIR=['examples','data']), $
       /GET_LUN
   Readu, lun, head
   free_lun, lun

   h_data = PTR_NEW(head, /no_copy)
   Slicer3, h_data, /modal
   PTR_FREE, h_data

    ;  Restore the saved color vectors
    ;
    TVLCT, savedR, savedG, savedB
 
    if widget_info(groupBase, /valid) then $
        widget_control, groupBase, /map

    ;  d_slice is a special case and does not return a valid appTLB
    ;  but it needs to return the argument in any case, as all demos
    ;  are called with the same calling convention
    appTLB = 0L
END

