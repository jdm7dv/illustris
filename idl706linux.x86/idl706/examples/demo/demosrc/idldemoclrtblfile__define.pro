; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/idldemoclrtblfile__define.pro#2 $
;
;  Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
; NAME:
;   IDLdemoClrTblFile
;
; PURPOSE:
;   Color Table File class.
;   Provide methods for easy access to info in color
;   files such as colors1.tbl (the default).
;
; CATEGORY:
;   IDL demonstration code.
;
; CALLING SEQUENCE:
;   oClrTblFile = obj_new('IDLdemoClrTblFile')
;
; METHODS:
;   GetNames    (function)
;       Reurns string array of color table names.
;
;   Get         (function)
;       Given an index, returns a 256x3 byte array of rgb values.
;
;   Count       (function)
;       Returns the number of colortables in file.
;
; RESTRICTIONS:
;   +--------------------------------------------------------------+
;   |Please note:  This file is demonstration code.  There is no   |
;   |guarantee that programs written using this code will continue |
;   |to work in future releases of IDL. We reserve the right to    |
;   |change this code or remove it from future versions of IDL.    |
;   +--------------------------------------------------------------+
;
; MODIFICATION HISTORY:
;   Written by: TB, 1998
;
;-
function IDLdemoClrTblFile::getNames
    ; get the names of the color tables

    ; open the file
    get_lun,lun
    openr,lun,self.filename,/block

    ; get the number of tables
    ntables=0b
    readu, lun, ntables

    ; read the names
    names=bytarr(32,ntables)
    point_lun,lun,ntables*768l+1
    readu,lun,names
    names=strtrim(names, 2)

    ; close the file
    free_lun,lun

    return,names
end

function IDLdemoClrTblFile::get,index
    ; open the file
    get_lun,lun
    openr,lun,self.filename, /block

    ; get the number of tables
    ntables=0b
    readu, lun, ntables

    ; check to see if the index is in range
    if (index lt 0) or (index ge ntables) then return,bytarr(256,3)

    ; read the color table
    aa=assoc(lun, bytarr(256),1)    ;Read 256 long ints
    ct=bytarr(256,3,/nozero)
    ct[*,0]=aa[index*3]
    ct[*,1]=aa[index*3+1]
    ct[*,2]=aa[index*3+2]

    ; close the file
    free_lun,lun

    return,ct
end

function IDLdemoClrTblFile::count
    ; open the file
    get_lun,lun
    openr,lun,self.filename, /block

    ; get the number of tables
    ntables=0b
    readu, lun, ntables

    ; close the file
    free_lun,lun

    return,ntables
end

function IDLdemoClrTblFile::init,filename=filename
    ; initialize the object
    self.filename=(n_elements(filename) eq 0) ? filepath('colors1.tbl',subdir=['resource', 'colors']) : filename
    return,1
end

pro IDLdemoClrTblFile__define
    struct={IDLdemoClrTblFile,filename:''}
end
