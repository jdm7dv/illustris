; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_gatedbp.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_gatedbp.pro
;
;  CALLING SEQUENCE: d_gatedbp
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
;       pro d_gatedbp               - Call the gated blood animation.
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       pro d_animate           - Main animation demo
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
PRO d_gatedbp, $
             RECORD_TO_FILENAME=record_to_filename, $
             GROUP = group, $   ; IN: (opt) group identifier
             APPTLB = wTopBase  ; OUT: (opt) TLB of this application

  ;; compile main routine (found in the demosrc directory)
  resolve_routine,'d_animate'

  d_animate, "gated", "Gated Blood Pool", $
             UNCOMPRESSED = [128, 64], $
             COLOR_TABLE_INDEX = 3, $
             NFRAMES=15, NCOLORS=225, GROUP=group, APPTLB = wTopBase, /ZOOM
  
END
