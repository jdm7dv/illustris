;  $Id: //depot/idl/IDL_70/idldir/examples/doc/itools/itpropertyreport.pro#2 $

; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME:
;   itPropertyReport
;
; PURPOSE:
;   To display the names, data types, and current values of
;   itool object properties.
;
; CATEGORY:
;   iTools
;
; CALLING SEQUENCE:
;   itpropertyreport, oTool, ID [, /VALUE] [, /DESCRIPTION]
;
; INPUTS:
;  oTool: an object reference to an existing iTool
;
;  ID: a string containing the object identifier of the iTool
;      component object for which properties will be displayed.
;
; OPTIONAL INPUTS:
;  VALUE: Set this keyword to display the current value of
;         each property
;  DESCRIPTION: Set this keyword to display the description
;         of each property
;
; OUTPUTS:
;   A report is printed to the IDL Command Log
;
;   NOTE: the output is formatted in columns and will be aligned
;         correctly only if the IDL Command Log is displayed using
;         a fixed-width font.
;
; EXAMPLE:
;
;   IPLOT, RANDOMU(S, 10)              ; Create an iTool
;
;   idTool = ITGETCURRENT(TOOL=otool)  ; Get the object reference
;
;   ; Get object identifier for the plot line
;   plotID = otool->FindIdentifiers('*data space/plot*', /VISUALIZATIONS)
;
;   itPropertyReport, otool, plotID    ; Display the properties
;
; COMMON BLOCKS:
;   None.
;
; MODIFICATION HISTORY:
;   May 2004, DD
;
;-
;

PRO listProperties, obj, VALUE=value_kw, DESCRIPTION=desc_kw

val = KEYWORD_SET(value_kw) ? 1 : 0
desc = KEYWORD_SET(desc_kw) ? 1 : 0

   ; Make sure the identifer represents a valid object
   IF (~OBJ_VALID(obj)) THEN BEGIN
      PRINT, "Input ID does not exist"
      RETURN
   ENDIF

   ; Some reader-friendly type names
   TypeNames= ['USERDEF','BOOLEAN','INTEGER','FLOAT','STRING',$
               'COLOR','LINESTYLE','SYMBOL','THICKNESS','ENUMLIST']

   ; Get the properties of the specified object
   propIDs = obj->QueryProperty()

   ; Create some string arrays to hold the property info
   propNames = STRARR(N_ELEMENTS(propIDs))
   propTypes = STRARR(N_ELEMENTS(propIDs))
   propDesc  = STRARR(N_ELEMENTS(propIDs))
   propValues  = STRARR(N_ELEMENTS(propIDs))

   ; Loop through the properties of the object and get their
   ; name, type, and value
   FOR i = 0, N_ELEMENTS(propIDs)-1 DO BEGIN
      obj->GetPropertyAttribute, propIDs[i], NAME=name, TYPE=type, DESCRIPTION=descr
      propNames[i]=name
      propTypes[i]=type
      propDesc[i]=descr
      success = obj->GetPropertyByIdentifier(propIDs[i], value)
      IF success THEN BEGIN
         CASE propTypes[i] OF
            0: propValues[i] = 'unknown'
            1: propValues[i] = (LOGICAL_TRUE(value)) ? 'True' : 'False'
            5: propValues[i] = '['+STRJOIN(STRTRIM(FIX(value),1), ', ')+']'
            7: propValues[i] = STRTRIM(STRING(FIX(value)),1)
            9: BEGIN
               obj->GetPropertyAttribute, propIDs[i], ENUMLIST=elist
               propValues[i] = STRTRIM(STRING(FIX(value)),1)+$
                  ' ('+STRTRIM(elist[value], 1)+')'
               END
            ELSE: BEGIN
               IF (N_ELEMENTS(value) GT 1) THEN value = STRJOIN(value, ', ')
               propValues[i] = STRTRIM(STRING(value), 1)
               END
         ENDCASE
      ENDIF ELSE BEGIN
         propValues[i] = 'no value retrieved'
      ENDELSE
   ENDFOR

   ; Devise a format string based on which fields will be shown.
   IF ~(val || desc) THEN format='((A-25), (A-20), (A-10), (A-1), (A-1))'
   IF (val && desc) THEN BEGIN
      format='((A-25), (A-20), (A-10), (A-30), (A-40))'
   ENDIF ELSE BEGIN
      IF val THEN format='((A-25), (A-20), (A-10), (A-30), (A-1))'
      IF desc THEN format='((A-25), (A-20), (A-10), (A-1), (A-40))'
   ENDELSE

   ; Print out the report
   PRINT, ''
   PRINT, 'Properties of ', obj->GetFullIdentifier()
   PRINT, ''
   PRINT, 'Identifier', 'Name', 'Type', $
      (val ? 'Value' : ''), (desc ? 'Description' : ''), $
      FORMAT=format
   PRINT, '----------', '----', '----', $
      (val ? '-----' : ''), (desc ? '-----------' : ''), $
      FORMAT=format
   FOR i = 0, N_ELEMENTS(propNames)-1 DO BEGIN
      PRINT, propIDs[i], propNames[i], TypeNames[propTypes[i]], $
      (val ? propValues[i] : ''), $
      (desc ? propDesc[i] : ''), $
      FORMAT=format
   ENDFOR
   PRINT, ''

END

PRO itPropertyReport, otool, id, VALUE=value_kw, DESCRIPTION=desc_kw


   ; Check input arguments
   IF (N_ELEMENTS(id) EQ 0) THEN BEGIN
      PRINT, 'Input identifier is undefined'
      RETURN
   ENDIF

   IF (~OBJ_VALID(otool)) THEN BEGIN
      PRINT, 'Specified iTool object is not valid'
      RETURN
   ENDIF

   ; Get the object asscicated with the input
   ; identifier
   obj = otool->GetByIdentifier(STRING(id))

   listProperties, obj, VALUE=value_kw, DESCRIPTION=desc_kw

END
