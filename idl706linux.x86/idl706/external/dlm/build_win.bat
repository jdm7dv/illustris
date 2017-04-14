@ECHO OFF
REM  Copyright (c) 1995-2008, ITT Visual Information Solutions. All
REM  rights reserved. Reproduction by any means whatsoever is prohibited
REM  without express written permission.
REM
REM  MS Windows batch file to build the TESTMODULE DLM.
REM
REM  You may pass the location of the IDL directory to this file on the
REM  command line: e.g., build_win d:\myidl\idl
REM
REM  You may also edit the default location below.

SETLOCAL

IF "%1" == "" GOTO SET_IDLDIR
SET IDL_DIR=%1
GOTO CONTINUE

:SET_IDLDIR
SET IDL_DIR="c:\Program Files\ITT\IDL70"

:CONTINUE

SET IDL_LIBDIR=%IDL_DIR%\bin\bin.x86

IF NOT EXIST %IDL_LIBDIR%\idl.lib GOTO NO_IDL_LIB
IF NOT EXIST %IDL_DIR%\external\include/idl_export.h GOTO NO_EXPORT_H

ECHO ON

cl -I%IDL_DIR%\external\include -nologo -DWIN32_LEAN_AND_MEAN -DWIN32 -c testmodule.c
link /DLL /OUT:testmodule.dll /DEF:testmodule.def /IMPLIB:testmodule.lib testmodule.obj %IDL_LIBDIR%\idl.lib
@ECHO OFF

GOTO END

:NO_IDL_LIB
ECHO.
ECHO Unable to locate %IDL_LIBDIR%\idl.lib.
ECHO.
GOTO END

:NO_EXPORT_H
ECHO.
ECHO Unable to locate %IDL_DIR%\external\include\idl_export.h.
ECHO.

:END

ENDLOCAL


