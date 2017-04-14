; $Id: //depot/idl/IDL_70/idldir/lib/utilities/make_rt.pro#5 $
; Copyright (c) 1996-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.


FUNCTION write_unix_launcher, p_distinfo

  saveFileBasename = FILE_BASENAME((*p_distinfo).s_file)
  idlDirBasename = FILE_BASENAME((*p_distinfo).idldir)
  rtMode = (*p_distinfo).rtMode

  launcherTxt = [ $
    '#!/bin/sh', $
    '#', $
    '# This script starts an IDL Runtime or Virtual Machine application', $
    '# from an IDL installation located in a subdirectory of the directory', $
    '# containing the script.', $
    '#', $
    '', $
    '', $
    '# Find the location of this script', $
    'topdir=`dirname $0`', $
    'if (test $topdir = ".") ; then', $
    '   topdir=$PWD;', $
    'fi', $
    '', $
    '# Specify the path to the IDL SAVE file that launches', $
    '# the application, relative to $topdir.', $
    'idlapp=./' + saveFileBasename, $
    '', $
    '# Specify the path to the top directory of the IDL', $
    '# distribution, relative to $topdir.', $
    'idl_install_dir=' + idlDirBasename, $
    'IDL_DIR=$topdir/$idl_install_dir ; export IDL_DIR', $
    '', $
    '# Change the working directory', $
    'cd $topdir', $
    '', $
    '# Run the application', $
    'exec $IDL_DIR/bin/idl -' + rtMode + '=$idlapp' $
  ]
  
  ; write the text of the launch script
  launchScript = (*p_distinfo).outpath + PATH_SEP() + $
    (*p_distinfo).appname
  OPENW, startout, launchScript, /GET_LUN
  for i=0, n_elements(launcherTxt)-1 do begin
     PRINTF, startout, launcherTxt[i]
  endfor
  FREE_LUN, startout
  FILE_CHMOD, launchScript, '755'o

  RETURN, 'Wrote UNIX launcher'
END


FUNCTION write_mac_launcher, p_distinfo
  saveFileBasename = FILE_BASENAME((*p_distinfo).s_file)
  idlDirBasename = FILE_BASENAME((*p_distinfo).idldir)
  rtMode = (*p_distinfo).rtMode

  launcherTxt = [ $
    '(*', $
    'This script creates a "double-clickable" icon for a runtime IDL', $
    'application defined by the idlApp variable. This script should be placed', $
    'at the top level of a runtime application hierarchy. The ', $
    'Utils_applescripts.scpt file must be in the same directory.', $
    '*)', $
    '', $
    '(*', $
    'Specify the path to the IDL SAVE file that launches the application, ', $
    'relative to the location of the script', $
    '*)', $
    '', $
    'set idlApp to "' + saveFileBasename + '" as string', $
    '', $
    '(*', $
    'Specify the path to the top directory of the IDL distribution, ', $
    'relative to the location of the script.', $
    '*)', $
    'set idlDir to "' + idlDirBasename + '" as string', $
    '', $
    'tell application "Finder"', $
    '  set myContainer to (container of (path to me)) as string', $
    '  set IDLDirFolder to POSIX path of myContainer & idlDir & "/"', $
    '  set IDLRunFolder to quoted form of (IDLDirFolder & "bin")', $
    '  set ApplescriptUtilsFile to myContainer & "Utils_applescripts.scpt" as string', $
    'end tell', $
    '', $
    'set myAppPath to POSIX path of myContainer & "/" & idlApp as string', $
    '', $
    'set idlCmd to IDLDirFolder & "bin/idl -' + rtMode + '=" & myAppPath', $
    '', $
    'set ApplescriptUtils to load script file ApplescriptUtilsFile', $
    'tell ApplescriptUtils', $
    '  set XResult to LaunchX11()', $
    '  EnvironmentSetup(IDLDirFolder)', $
    'end tell', $
    '', $
    'if XResult is equal to 0 then', $
    '  set theCommand to shellCmd & "''" & fullSetupCmd & "; " & DisplayCmd & "; cd  " & IDLRunFolder & "; /usr/X11R6/bin/xterm -e " & idlCmd & "'' > /dev/null  2>&1 & "', $
    '  --display dialog theCommand', $
    '  set results to do shell script theCommand', $
    'end if' $
  ]


  ; write the text for the launch script
  ; this will need to be converted to applescript
  launchTextFilename = (*p_distinfo).outpath + PATH_SEP() + $
    (*p_distinfo).appname + '_mac_script_source.txt'
  OPENW, startout, launchTextFilename, /GET_LUN
  for i=0, n_elements(launcherTxt)-1 do begin
     PRINTF, startout, launcherTxt[i]
  endfor
  FREE_LUN, startout

  ; convert the text version of the script to AppleScript
  launchAplScriptname = (*p_distinfo).outpath + PATH_SEP() + $
    (*p_distinfo).appname + '.app'
  compileCommand = 'osacompile -o ' + launchAplScriptname + ' ' + $
    launchTextFilename
  spawn, compileCommand, result



  ; Just copy the utilities script
  IF FILE_TEST((*p_distinfo).mk_rt_dir + 'Utils_applescripts.scpt', /READ) THEN BEGIN
    FILE_COPY, (*p_distinfo).mk_rt_dir + 'Utils_applescripts.scpt', $
      (*p_distinfo).outpath, /OVERWRITE
  ENDIF ELSE BEGIN
    md_log, 'Utils_applescripts.scpt not found or not readable', (*p_distinfo).logfile
  ENDELSE
  
  IF FILE_TEST((*p_distinfo).mk_rt_dir + '._Utils_applescripts.scpt', /READ) THEN BEGIN
    FILE_COPY, (*p_distinfo).mk_rt_dir + '._Utils_applescripts.scpt', $
      (*p_distinfo).outpath, /OVERWRITE
  ENDIF ELSE BEGIN
    md_log, '._Utils_applescripts.scpt not found or not readable', (*p_distinfo).logfile
  ENDELSE

  
  RETURN, 'Wrote Macintosh launcher'
  

END


FUNCTION write_win_autorun, p_distinfo

  appname = (*p_distinfo).appname

  launcherTxt = [ $
    '[autorun]', $
    'open = ' + appname + '.exe', $
    'icon= idl.ico' $
  ]

  ; write the text for the autorun.inf file
  OPENW, startout, (*p_distinfo).outpath + path_sep() + 'autorun.inf', /GET_LUN
  for i=0, n_elements(launcherTxt)-1 do begin
     PRINTF, startout, launcherTxt[i]
  endfor
  FREE_LUN, startout

  RETURN, 'Wrote Windows_autorun'
END


FUNCTION write_win_ini, p_distinfo

  saveFileBasename = FILE_BASENAME((*p_distinfo).s_file)
  idlDirBasename = FILE_BASENAME((*p_distinfo).idldir)
  rtMode = (*p_distinfo).rtMode
  appname = (*p_distinfo).appname

  IF ((*p_distinfo).win64 && ~(*p_distinfo).win32) THEN BEGIN
    binDir = 'bin.x86_64'
  ENDIF ELSE BEGIN
    binDir = 'bin.x86'
  ENDELSE
  
  launcherTxt = [ $
    '# This file defines the appearance and operation of the', $
    '# start_app_win.exe application, which can be used to launch', $
    '# runtime IDL applications.', $
    '# For a complete description of this file and the process', $
    '# of creating a runtime distribution, see the "Creating a', $
    '# Runtime Distribution" chapter of the "Application Programming"', $
    '# manual.', $
    '#', $
    '', $
    '[DIALOG]', $
    'Show=True', $
    'BackColor=&H6B1F29', $
    'Caption=IDL Virtual Machine Application', $
    'Picture=.\splash.bmp', $
    'DefaultAction=.\' + idlDirBasename + '\bin\' + binDir + $
       '\idlrt.exe -' + rtMode + '=' + saveFileBasename, $
    '', $
    '[BUTTON1]', $
    'Show=True', $
    'Caption=' + appname, $
    'Action=.\' + idlDirBasename + '\bin\' + binDir + $
       '\idlrt.exe -' + rtMode + '=' + saveFileBasename, $
    '', $
    '[BUTTON2]', $
    'Show=True', $
    'Caption=Exit', $
    'Action=Exit', $
    '', $
    '[BUTTON3]', $
    'Show=False', $
    'Caption=', $
    'Action=', $
    '', $
    '[BUTTON4]', $
    'Show=False', $
    'Caption=', $
    'Action=' $
  ]

  ; write the text for the app.ini file
  OPENW, startout, (*p_distinfo).outpath + path_sep() + $
    appname + '.ini', /GET_LUN
  for i=0, n_elements(launcherTxt)-1 do begin
     PRINTF, startout, launcherTxt[i]
  endfor
  FREE_LUN, startout

  RETURN, 'Wrote Windows_ini'
END


FUNCTION write_win_launcher, p_distinfo

  ; Strings that will be replaced in the generic .ini file
  
  ; Copy static files
  IF FILE_TEST((*p_distinfo).mk_rt_dir + 'idl.ico', /READ) THEN BEGIN
    FILE_COPY, (*p_distinfo).mk_rt_dir + 'idl.ico', (*p_distinfo).outpath, $
      /OVERWRITE
  ENDIF ELSE BEGIN
    md_log, (*p_distinfo).mk_rt_dir + 'idl.ico not found or not readable', $
      (*p_distinfo).logfile
  ENDELSE
  
  IF FILE_TEST((*p_distinfo).mk_rt_dir + 'splash.bmp', /READ) THEN BEGIN
    FILE_COPY, (*p_distinfo).mk_rt_dir + 'splash.bmp', (*p_distinfo).outpath, $
      /OVERWRITE
  ENDIF ELSE BEGIN
    md_log, (*p_distinfo).mk_rt_dir + 'splash.bmp not found or not readable', $
      (*p_distinfo).logfile
  ENDELSE
  
  IF FILE_TEST((*p_distinfo).mk_rt_dir + 'start_app_win.exe', /READ) THEN BEGIN
    FILE_COPY, (*p_distinfo).mk_rt_dir + 'start_app_win.exe', $
      (*p_distinfo).outpath + PATH_SEP() + (*p_distinfo).appname + '.exe', $
      /OVERWRITE
  ENDIF ELSE BEGIN
    md_log, (*p_distinfo).mk_rt_dir + $
      'start_app_win.exe not found or not readable', (*p_distinfo).logfile
  ENDELSE
  
  ; Write autorun.inf
  md_log, write_win_autorun(p_distinfo), (*p_distinfo).logfile
  
  ; Write start_app_win.ini
  md_log, write_win_ini(p_distinfo), (*p_distinfo).logfile
  
  RETURN, 'Wrote windows launcher'
END


FUNCTION copy_launcher, p_distinfo

  IF (*p_distinfo).win32 || (*p_distinfo).win64 THEN $
    md_log, write_win_launcher(p_distinfo), (*p_distinfo).logfile
  IF (*p_distinfo).mac THEN $
    md_log, write_mac_launcher(p_distinfo), (*p_distinfo).logfile
  IF (*p_distinfo).unix THEN $
    md_log, write_unix_launcher(p_distinfo), (*p_distinfo).logfile
    
  RETURN, 'Finished writing launchers'
END

FUNCTION copy_savefile, p_distinfo

  FILE_COPY, (*p_distinfo).s_file, (*p_distinfo).outpath, /OVERWRITE
  
  RETURN, 'Copied savefile'
  
END

FUNCTION copy_manifest, p_distinfo

  ; Read the manifest file
  md_log, 'Looking in manifest file '+(*p_distinfo).m_file, (*p_distinfo).logfile
  nlines = FILE_LINES((*p_distinfo).m_file)
  array = STRARR(nlines)
  OPENR, unit, (*p_distinfo).m_file, /GET_LUN
  READF, unit, array
  FREE_LUN, unit
  
  
  ; Ignore lines for OSes that are not selected
  ; Ignore lines for X11 if no Unix platform is selected
  FOR i=0, N_ELEMENTS(array)-1 DO BEGIN
    IF (~(*p_distinfo).win32 && STREGEX(array[i], 'bin\.x86[^_]') NE -1) || $
      (~(*p_distinfo).win64 && STREGEX(array[i], 'bin\.x86_64') NE -1) || $
      (~(*p_distinfo).macppc32 && STREGEX(array[i], 'bin\.darwin\.ppc') NE -1) || $
      (~(*p_distinfo).macint32 && STREGEX(array[i], 'bin\.darwin\.i386') NE -1) || $
      (~(*p_distinfo).macint64 && STREGEX(array[i], 'bin\.darwin\.x86_64') NE -1) || $
      (~(*p_distinfo).lin32 && STREGEX(array[i], 'bin\.linux\.x86[^_]') NE -1) || $
      (~(*p_distinfo).lin64 && STREGEX(array[i], 'bin\.linux\.x86_64') NE -1) || $
      (~(*p_distinfo).sun32 && STREGEX(array[i], 'bin\.solaris2\.sparc[^6]') NE -1) || $
      (~(*p_distinfo).sun64 && STREGEX(array[i], 'bin\.solaris2\.sparc64') NE -1) || $
      
      (~(*p_distinfo).unix && ~(*p_distinfo).mac && STREGEX(array[i], 'X11') NE -1) || $
      
      (~(*p_distinfo).dataminer && STREGEX(array[i], 'idl_dataminer') NE -1) || $
      (~(*p_distinfo).dataminer && STREGEX(array[i], '/dm/') NE -1) || $
      
      (~(*p_distinfo).dicomex && STREGEX(array[i], 'dicomex', /FOLD_CASE) NE -1) || $
      (~(*p_distinfo).dicomex && STREGEX(array[i], 'libpic', /FOLD_CASE) NE -1) || $
      (~(*p_distinfo).dicomex && STREGEX(array[i], 'picu', /FOLD_CASE) NE -1) || $
      (~(*p_distinfo).dicomex && STREGEX(array[i], 'picn', /FOLD_CASE) NE -1) || $
      (~(*p_distinfo).dicomex && STREGEX(array[i], 'MC3ADV\.DLL', /FOLD_CASE) NE -1) || $
      
      (~(*p_distinfo).idl_assistant && STREGEX(array[i], 'idl_assistant') NE -1) || $
      
      (~(*p_distinfo).idl_help && STREGEX(array[i], 'this is a stub') NE -1) || $
      
      (~(*p_distinfo).maps && STREGEX(array[i], 'maps/high') NE -1) THEN $
      array[i]=';'+array[i]
  ENDFOR
  
  ; Copy the files
  FOR i=0, N_ELEMENTS(array)-1 DO BEGIN
  
    ; If a line begins with a ';', ignore the entire line
    ; Otherwise chop of the rest of the line.
    IF STRPOS(array[i], ';') EQ 0 THEN CONTINUE
    IF STRPOS(array[i], ';') NE -1 THEN $
    array[i] = STRTRIM(STRMID(array[i], 0, STRPOS(array[i], ';')), 2)
    
    ; If a line is blank, ignore it
    IF array[i] EQ '' THEN CONTINUE
    
    ; Strip off './' at the beginning of manifest file entries
    IF STRPOS(array[i], './') NE -1 THEN array[i] = STRMID(array[i],2)
    
    ; Strip off leading or trailing space characters
    array[i] = STRTRIM(array[i], 2)
    
    ; Build source and output file paths
    source_file = (*p_distinfo).idldir + PATH_SEP() + array[i]
    output_file = (*p_distinfo).outpath + PATH_SEP() + $
      FILE_BASENAME((*p_distinfo).idldir) + PATH_SEP() + array[i]
      
    ; If source file exists, copy it. Otherwise skip and report.
    IF FILE_TEST(source_file, /READ) THEN BEGIN
      IF ~FILE_TEST(FILE_DIRNAME(output_file), /DIRECTORY) THEN $
        FILE_MKDIR, FILE_DIRNAME(output_file)
      ; Test for symlink and remove if necessary (49828)
      IF !version.os_family eq 'unix' && FILE_TEST(output_file, /SYMLINK) THEN $
        FILE_DELETE, output_file
      FILE_COPY, source_file, output_file, /OVERWRITE, /RECURSIVE, /COPY_SYMLINK
      md_log, 'Copying: '+source_file, (*p_distinfo).logfile
    ENDIF ELSE BEGIN
      md_log, 'Source file not found: '+source_file, (*p_distinfo).logfile
    ENDELSE
  ENDFOR
  
  RETURN, 'finished processing manifest'
  
END

PRO check_current_platform, p_distinfo

  ; If no OS keywords were set, select the current OS
  IF ((*p_distinfo).win32 + (*p_distinfo).win64 + (*p_distinfo).macppc32 + $
    (*p_distinfo).macppc64 + (*p_distinfo).macint32 + (*p_distinfo).macint64 + $
    (*p_distinfo).lin32 + (*p_distinfo).lin64 + (*p_distinfo).sun32 + $
    (*p_distinfo).sun64) EQ 0 THEN BEGIN
    CASE !version.os OF
      'Win32': BEGIN
        IF !version.memory_bits EQ 32 THEN (*p_distinfo).win32 = 1
        IF !version.memory_bits EQ 64 THEN (*p_distinfo).win64 = 1
      END
      'darwin': BEGIN
        IF !version.ARCH EQ 'ppc' THEN BEGIN
          IF !version.memory_bits EQ 32 THEN (*p_distinfo).macppc32 = 1
          IF !version.memory_bits EQ 64 THEN (*p_distinfo).macppc64 = 1
        ENDIF
        IF !version.ARCH EQ 'i386' THEN BEGIN
          IF !version.memory_bits EQ 32 THEN (*p_distinfo).macint32 = 1
          IF !version.memory_bits EQ 64 THEN (*p_distinfo).macint64 = 1
        ENDIF
        IF !version.ARCH EQ 'x86_64' THEN BEGIN
          IF !version.memory_bits EQ 32 THEN (*p_distinfo).macint32 = 1
          IF !version.memory_bits EQ 64 THEN (*p_distinfo).macint64 = 1
        ENDIF
      END
      'linux': BEGIN
        IF !version.memory_bits EQ 32 THEN (*p_distinfo).lin32 = 1
        IF !version.memory_bits EQ 64 THEN (*p_distinfo).lin64 = 1
      END
      'sunos': BEGIN
        IF !version.memory_bits EQ 32 THEN (*p_distinfo).sun32 = 1
        IF !version.memory_bits EQ 64 THEN (*p_distinfo).sun64 = 1
      END
    ENDCASE
  ENDIF
  
  ; Check to see if *any* non-Macintosh Unix platform is selected
  (*p_distinfo).unix = ((*p_distinfo).lin32 + (*p_distinfo).lin64 + $
    (*p_distinfo).sun32 + (*p_distinfo).sun64 GT 0) ? 1 : 0
    
  ; Check to see if *any* Macintosh platform is selected
  (*p_distinfo).mac = ((*p_distinfo).macppc32 + (*p_distinfo).macint32 + $
    (*p_distinfo).macppc64 + (*p_distinfo).macint64  GT 0) ? 1 : 0
    
END

PRO md_log, msg, logfile

  OPENW, log, logfile, /GET_LUN, /APPEND
  PRINTF, log, msg
  FREE_LUN, log
  
END

PRO md_error, msg

  PRINT, '-----------------------------------------------'
  MESSAGE, 'Error making distribution:', LEVEL=-1, /CONTINUE
  PRINT, ''
  FOR i = 0L, N_ELEMENTS(msg)-1 DO BEGIN
    PRINT, msg[i]
  ENDFOR
  PRINT, ''
  PRINT, 'make_rt exiting...'
  PRINT, '-----------------------------------------------'
END

PRO make_rt, appname, outdir, $
    SAVEFILE=s_file, $
    MANIFEST=m_file, $
    IDLDIR=idldir, $
    LOGFILE=logfile, $
    VM=vm, $
    EMBEDDED=embedded, $
    WIN32=win32, $
    WIN64=win64, $
    MACPPC32=macppc32, $
    ;MACPPC64=macppc64, $    ; 64-bit MacOS not supported on PPC
    MACINT32=macint32, $
    MACINT64=macint64, $
    LIN32=lin32, $
    LIN64=lin64, $
    SUN32=sun32, $
    SUN64=sun64, $
    DATAMINER=dataminer, $
    DICOMEX=dicomex, $
    HIRES_MAPS=hires_maps, $
    ;IDL_HELP=idl_help, $     ; IDL_HELP not supported in IDL 7.0
    IDL_ASSISTANT=idl_assistant
    
  ; Must have an application name
  IF (N_ELEMENTS(appname) EQ 0) THEN BEGIN
    md_error, 'You must specify an application name.'
    RETURN
  ENDIF
  
  ; Save file must be readable if specified
  IF KEYWORD_SET(s_file) && (FILE_TEST(s_file, /READ) NE 1) THEN BEGIN
    md_error, ['The Save file you specified', ' ', $
      '   '+s_file, ' ', 'is not readable or does not exist']
    RETURN
  ENDIF
  
  ; If no Save file specified, use null string
  IF KEYWORD_SET(s_file) EQ 0 THEN s_file=''
  
  ; Output dir must be specified
  IF (N_ELEMENTS(outdir) EQ 0) THEN BEGIN
    md_error, 'You must specify an output directory.'
    RETURN
  ENDIF
  
  ; Output dir must be writable
  IF (FILE_TEST(outdir, /DIRECTORY, /WRITE) NE 1) THEN BEGIN
    md_error, ['The output directory you specified', ' ', $
      '   '+outdir, ' ', 'is not writable or does not exist']
    RETURN
  ENDIF
  
  ; If no manifest file specified, use the one in bin/make_rt
  IF N_ELEMENTS(m_file) EQ 0 THEN $
    m_file = FILEPATH('manifest_rt.txt', $
    SUBDIR=['bin', 'make_rt'])
    
  ; Make sure the manifest keyword is set to a string
  IF (SIZE(m_file, /TNAME) NE 'STRING') THEN BEGIN
    md_error, 'You must specify a filename for the MANIFEST keyword'
    RETURN
  ENDIF
  
  ; Manifest file must be readable
  IF (FILE_TEST(m_file, /READ) EQ 0) THEN BEGIN
    md_error, ['The manifest file you specified', ' ', $
      '   '+STRING(m_file), ' ', 'is not readable or does not exit']
    RETURN
  ENDIF
  
  ; If IDLDIR is not set, use !DIR. Note that we don't check
  ; whether the specified IDLDIR is readable or even exists;
  ; if there is a problem, the errors go to the log file when
  ; the copies are attempted.
  IF KEYWORD_SET(idldir) EQ 0 THEN idldir=!DIR
  
  ; Assume we'll use the -rt flag, but allow user to specify
  ; the app *must* run in the Virtual Machine or with an embedded
  ; license.
  IF KEYWORD_SET(vm) THEN rtMode = 'vm' ELSE rtMode = 'rt'
  IF KEYWORD_SET(embedded) THEN rtMode = 'em'
  
  ; Dataminer files are not copied unless DATAMINER=1
  dataminer = (KEYWORD_SET(dataminer) NE 0 && dataminer EQ 1) ? 1 : 0
  
  ; DICOMEX files are not copied unless DICOMEX=1
  dicomex = (KEYWORD_SET(dicomex) NE 0 && dicomex EQ 1) ? 1 : 0
  
  ; IDL_Assistant executables are not copied unless IDL_ASSISTANT=1
  idl_assistant = (KEYWORD_SET(idl_assistant) NE 0 && idl_assistant EQ 1) ? 1 : 0
  
  ; IDL Help system files are not copied unless IDL_HELP=1
  ; IDL_HELP not supported in IDL 7.0, but leave the infrastructure
  idl_help = (KEYWORD_SET(idl_help) NE 0 && idl_help EQ 1) ? 1 : 0
  
  ; High-res maps are not copied unless HIRES_MAPS=1
  maps = (KEYWORD_SET(hires_maps) NE 0 && hires_maps EQ 1) ? 1 : 0
  
  ; Create the output directory
  outpath = outdir + PATH_SEP() + appname
  IF (FILE_TEST(outpath, /DIRECTORY, /WRITE) NE 1) THEN $
    FILE_MKDIR, outpath
    
  ; If no logfile path is specified, put it in the output directory
  IF KEYWORD_SET(logfile) EQ 0 THEN logfile=outpath+PATH_SEP()+'log.txt'
  
  ; We'll pass a pointer to this structure around to the
  ; various functions
  distinfo = { s_file:s_file, $
    appname:appname, $
    outdir:outdir, $
    outpath:outpath, $
    mk_rt_dir:!DIR + '/bin/make_rt/', $
    m_file:m_file, $
    idldir:idldir, $
    logfile:logfile, $
    rtMode:rtMode, $
    win32:KEYWORD_SET(win32), $
    win64:KEYWORD_SET(win64), $
    macppc32:KEYWORD_SET(macppc32), $
    macppc64:0, $
    macint32:KEYWORD_SET(macint32), $
    macint64:KEYWORD_SET(macint64), $
    lin32:KEYWORD_SET(lin32), $
    lin64:KEYWORD_SET(lin64), $
    sun32:KEYWORD_SET(sun32), $
    sun64:KEYWORD_SET(sun64), $
    unix:0, $
    mac:0, $
    dicomex:dicomex, $
    dataminer:dataminer, $
    idl_assistant:idl_assistant, $
    idl_help:0, $
    maps:maps $
    }
    
  p_distinfo = PTR_NEW(distinfo)
  
  check_current_platform, p_distinfo
  
  md_log, 'Starting: '+SYSTIME(/utc), distinfo.logfile
  md_log, 'Using Save file: '+distinfo.s_file, distinfo.logfile
  md_log, 'Using manifest file: '+distinfo.m_file, distinfo.logfile
  md_log, 'Using IDL directory: '+distinfo.idldir, distinfo.logfile
  
  md_log, copy_manifest(p_distinfo), distinfo.logfile
  IF (distinfo.s_file NE '') THEN BEGIN
    md_log, copy_savefile(p_distinfo), distinfo.logfile
    md_log, copy_launcher(p_distinfo), distinfo.logfile
  ENDIF
  
  md_log, 'Finished: '+SYSTIME(/utc), distinfo.logfile
  md_log, ['--------------------------------------', ' '], distinfo.logfile
  
  PRINT, 'make_dist routine finished. See log file: ', distinfo.logfile
END
