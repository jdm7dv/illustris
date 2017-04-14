; $Id: //depot/idl/IDL_70/idldir/external/spawn/test_pipe.pro#2 $
;
; Copyright (c) 2000-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
pro test_pipe

  ; Check that test_pipe is available 
  IF !version.os_family EQ 'Windows' THEN app='test_pipe.exe' $
     ELSE app='test_pipe'

  IF FILE_TEST(app) EQ 0 THEN BEGIN 
    PRINT, 'The executable "' + app + '" was not found.'
    PRINT, 'The program must be compiled first.' 
    RETURN 
  ENDIF

  ; Start test_pipe. The use of the NOSHELL keyword is not necessary,
  ; but speeds up the start-up process.
  SPAWN, 'test_pipe', UNIT=UNIT, /NOSHELL

  ; Send the number of points followed by the actual data.
  WRITEU, UNIT, 10L, FINDGEN(10)

  ; Read the answer.
  READU, UNIT, ANSWER

  ; Announce the result.
  PRINT, 'Average = ', ANSWER

  ; Close the pipe, delete the child process, and deallocate the
  ; logical file unit.
  FREE_LUN, UNIT
end

