; $Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/demoObj__define.pro#2 $
;
; Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;       demoObj__define.pro
;
; PURPOSE:
;       Main demo harness.
;
; CATEGORY:
;       IDL demo system
;
; CALLING SEQUENCE:
;       demo = OBJ_NEW('demoObj')
;
; ARGUMENTS:
;       See Init method
;
; KEYWORDS:
;       See Init method
;
; OUTPUTS:
;       Object reference to the newly created demoObj object
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       Inherits from the IDLffXMLSAX class.
;
; PROCEDURES CALLED:
;       Any in this file and possibly those specified in the XML input
;       file
;
; FUNCTIONS CALLED:
;       Any in this file and possibly those specified in the XML input
;       file
;
; CREATED BY: AGEH, November 2002.
;
;---

;;----------------------------------------------------------------------------
;; demoObj::demoStartApp
;;
;; Purpose:
;;   launches the specified demo.  Taken mostly directly from the IDL
;;   5.x demo system.
;;
;; Parameters:
;;   NAME - the name of the procedure to call
;;
;;   STATE - an input structure holding information on the procedure
;;           to be called
;;
;;   TOP - widget ID of the TLB
;;
;; Keywords:
;;   EXTRA - extra keyword parameter stucture
;;
pro demoObj::demoStartApp, $
                           Name, $ ; Name of demo
                           appTLB, $ ; ID of demo TLB (optional)
                           top, $ ; IN: top level base
                           record_to_filename, $ ; IN: filename to record tour
                           EXTRA = extra ;Extra structure (optional)
  compile_opt idl2, hidden
;
;  Purpose:  This routine is used to start all demos.
;            Name must be the name of the procedure to call.
;            a button or the pulldown menu
;

  IF (WIDGET_INFO(apptlb, /VALID)) || $
    (xregistered("demo_slideshow")) THEN BEGIN
    result = DIALOG_MESSAGE('Only one demo may run at a time')
    return
  ENDIF

  WIDGET_CONTROL, /HOURGLASS

  ;; handle special cases, if needed
  CASE strupcase(Name) OF

    ELSE : BEGIN
      resolve_routine, Name     ;Be sure its compiled/loaded
    ENDELSE

  ENDCASE

  if !Version.Os_Family EQ 'MacOS' then WAIT, .1

  if n_elements(extra) gt 0 then $ ;Call it
    call_procedure, $
    Name, $
    GROUP=top, $
    APPTLB = appTLB, $
    RECORD_TO_FILENAME=record_to_filename, $
    _EXTRA=extra $
  else call_procedure, $
    Name, $
    GROUP=top, $
    APPTLB = appTLB, $
    RECORD_TO_FILENAME=record_to_filename

  ;; save TLB if one is returned from the demo
  if n_elements(appTLB) then appTlb = appTLB $
  else appTlb = 0L

end

;;----------------------------------------------------------------------------
;; demoObj::demoStartSlideshow
;;
;; Purpose:
;;   launches the specified slideshow.
;;
;; Parameters:
;;   FILENAME - the name of the slideshow input file to use
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::demoStartSlideshow, FileName
  compile_opt idl2, hidden

  IF (WIDGET_INFO(self.state.appTLB, /VALID)) || $
    (xregistered("demo_slideshow")) THEN BEGIN
    result = DIALOG_MESSAGE('Only one demo may run at a time')
    return
  ENDIF

  void = obj_new('slideshow',FILENAME=FileName)

END

;;----------------------------------------------------------------------------
;; demoObj_kill_demo
;;
;; Purpose:
;;   kill notify procedure for the tlb widget
;;
;; Parameters:
;;   WID - the ID of the tlb
;;
;; Keywords:
;;   None
;;
PRO demoObj_kill_demo,wID
  compile_opt idl2, hidden

  widget_control,wID,get_uvalue=state
  IF obj_valid(state.self) THEN obj_destroy,state.self

END

;;----------------------------------------------------------------------------
;; demoObj_demo_event
;;
;; Purpose:
;;   first event handler, called via xmanager.  Basically just passes
;;   the event on to demoObj_event
;;
;; Parameters:
;;   event - a widget event structure
;;
;; Keywords:
;;   None
;;
PRO demoObj_demo_event,event
  compile_opt idl2, hidden

  ;; get uname of the event
  uname = widget_info(event.id,/uname)

  ;; if the event is the quit from the menu then destroy ourself.
  IF uname EQ 'demo:quit' THEN BEGIN
    widget_control,event.top,/destroy
    return
  ENDIF

  ;; otherwise pass the event on to the object's event method
  widget_control,event.top,get_uvalue=state
  state.self->demoObj_event,event

END

;;----------------------------------------------------------------------------
;; demoObj::to_tree_bitmap
;;
;; Purpose:
;;   converts an image to a 24 bit bitmap suitable for use as a bitmap
;;   in the tree widget
;;
;; Parameters:
;;   IMAGE - an image structure with the following tags:
;;     image : 2D image array
;;     r : red image channel (optional)
;;     g : green image channel (optional)
;;     b : blue image channel (optional)
;;
;; Keywords:
;;   None
;;
FUNCTION demoObj::to_tree_bitmap,image
  compile_opt idl2, hidden

  ndim = size(image.image,/n_dimensions)
  sz = size(image.image,/dimensions)
  ;; if image is 16x16x3 then it is usable, return it as is
  IF ndim EQ 3 && sz[0] EQ 16 && sz[1] EQ 16 && sz[2] EQ 3 THEN begin
    result = image.image
  endif else IF ndim EQ 3 && sz[0] EQ 3 && sz[1] EQ 16 && sz[2] EQ 16 THEN begin
    ;; if the image is 3x16x16 then transpose the order and return
    result = transpose(image.image,[1,2,0])
  endif else IF sz[0] EQ 16 && sz[1] EQ 16 && $
    total([n_elements(image.r),n_elements(image.g),n_elements(image.b)]ne 0) $
    EQ 3 THEN BEGIN
    ;; if image is a 2D array then use r,g,b values to create a 16x16x3
    ;; image array
    result = bytarr(16,16,3)
    result[*,*,0] = image.r[image.image]
    result[*,*,1] = image.g[image.image]
    result[*,*,2] = image.b[image.image]
  endif else begin
      ;; return 0 if all above methods fail
      return,0
  endelse

  ;; Make the background match the tree background.
  colors = widget_info(widget_base(),/system_colors)
  for i=0,2 do begin
    channel = result[*,*,i]
    ;; Find all values that match the lower left pixel,
    ;; and set them to the background.
    match = WHERE(channel eq channel[0,0])
    if (match[0] eq -1) then $
      continue
    channel[match] = colors.window_bk[i]
    result[0,0,i] = channel
  endfor
  
  return, result

END

;;----------------------------------------------------------------------------
;; demoObj::get_image
;;
;; Purpose:
;;   reads in an image file and stores it in an image structure for
;;   use with the to_tree_bitmap function
;;
;; Parameters:
;;   IMAGEPATH - valid filename of the image, optionally as a comma
;;               delineated relative path if root is specified
;;
;; Keywords:
;;   ROOT - root directory to use in filepath
;;
FUNCTION demoObj::get_image,imagepath,root=root
  compile_opt idl2, hidden

  IF n_elements(root) NE 0 THEN BEGIN
    imagestr = strsplit(imagepath,',',/extract)
    IF n_elements(imagestr) GT 1 THEN $
      subdir=imagestr[0:n_elements(imagestr)-2]
    imagefile = filepath(imagestr[n_elements(imagestr)-1],root=root, $
                         subdirectory=subdir)
    IF self->validfile(imagefile,/fullpath) NE '' THEN $
      image = read_image(imagefile,r,g,b)
  ENDIF ELSE BEGIN
    IF self->validfile(imagepath,/fullpath) NE '' THEN $
      image = read_image(imagepath,r,g,b)
  ENDELSE

  IF size(image,/type) NE 0 THEN $
    return,{image:image,r:n_elements(r)EQ 0?0:r,b:n_elements(b)EQ 0?0:b, $
            g:n_elements(g)EQ 0?0:g} $
  ELSE return, {image:0,r:0,g:0,b:0}

END

;;----------------------------------------------------------------------------
;; demoObj::showImage
;;
;; Purpose:
;;   displays an image in a direct graphics window taking into account
;;   the bit-depth of the image and the decomposed value of the system
;;
;; Parameters:
;;   IMAGE - structure (returned from get_image) of the image
;;
;;   WID - widget ID of a direct graphics draw widget
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::showImage,image,wID
  compile_opt idl2, hidden

  IF n_elements(image.image) EQ 1 THEN return
  win = !d.window
  wset,wID
  device,get_decomposed=dec
  ;; save colour table on systems that do not use a shared color map
  IF ~self.norestorecolors THEN tvlct,rr,gg,bb,/get
  IF (n_elements(image.r) NE 1) THEN BEGIN
    ;; if r,g,b arrays exist, load them into the colour table
    device,decomposed=0
    tvlct,image.r,image.g,image.b
    tv,image.image
  ENDIF ELSE BEGIN
    device,get_visual_depth=visdep
    IF visdep EQ 8 THEN BEGIN
      ;; if on an 8-bit display, color_quan the image
      image = color_quan(image.image, 1, r, g, b, colors=!d.table_size)
      device,decomposed=0
      tvlct,r,g,b
      tv,image
    ENDIF ELSE BEGIN
      ;; 24 bit image on 24 or 32 bit display, just tv the image
      device,decomposed=1
      tv,image.image,true=(where(size(image.image,/dimensions) EQ 3))[0]+1
    ENDELSE
  ENDELSE
  wset,win
  device,decomposed=dec
  ;; restore the colour table
  IF ~self.norestorecolors THEN tvlct,rr,gg,bb

END

;;----------------------------------------------------------------------------
;; demoObj::validfile
;;
;; Purpose:
;;   returns a full valid file path if the file exists, assuming a
;;   root of the demo root
;;
;; Parameters:
;;   FILESTR - filename of the image
;;
;; Keywords:
;;   FULLPATH - set this keyword to indicate that the filename already
;;              contains a fully qualified path
;;
FUNCTION demoObj::validfile,filestr,FULLPATH=fullpath
  compile_opt idl2, hidden

  IF keyword_set(fullpath) THEN BEGIN
    file = filestr
  ENDIF ELSE BEGIN
    ;; separate by commas and remove whitespaces
    pathstr = strtrim(strsplit(filestr,',',/extract),2)
    IF n_elements(pathstr) GT 1 THEN BEGIN
      ;; create subdirectory list if it exists
      filename = pathstr[n_elements(pathstr)-1]
      sub = pathstr[0:n_elements(pathstr)-2]
    ENDIF ELSE BEGIN
      filename = pathstr[0]
      sub = ''
    ENDELSE
    ;; create full filepath name
    file = filepath(filename,root=self.demo_root,subdirectory=sub)
  ENDELSE

  ;; if file exists, return the name, else return a null string
  return,(file_info(file)).exists ? file : ''

END

;;----------------------------------------------------------------------------
;; demoObj::validname
;;
;; Purpose:
;;   returns a valid string name that avoids name conflict by
;;   appending a number on the end of the name if necessary
;;
;; Parameters:
;;   NAME - name of the object
;;
;; Keywords:
;;   NONE
;;
FUNCTION demoObj::validname,name
  compile_opt idl2, hidden

  IF ptr_valid(self.items) EQ 0 THEN return,name
  i = 1
  outname = name
  WHILE where(outname EQ (*self.items).uname) NE -1 DO $
    outname=name+strtrim(i++,2)
  return,outname

END

;;----------------------------------------------------------------------------
;; demoObj::Error
;;
;; Purpose:
;;   The IDLffXMLSAX::Error procedure method is called when the parser
;;   detects an error that is not expected to be fatal.
;;
;; Parameters:
;;   ID - not used
;;
;;   LINENUMBER - the line number of the file where the error occurred
;;
;;   COLUMNNUMBER - the column number where the error occurred
;;
;;   MESSAGE - the error message
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::Error,ID,LineNumber,ColumnNumber,Message
  compile_opt idl2, hidden

  st=['Error reading input file: '+self.demo_filename, $
      Message, $
      'Line '+strtrim(LineNumber,2)+', Column '+strtrim(ColumnNumber,2)]
  void = dialog_message(st,/error,title='Error in IDL Demo System')
  self->stopParsing
  self.invalidparse = 1

END

;;----------------------------------------------------------------------------
;; demoObj::FatalError
;;
;; Purpose:
;;   The IDLffXMLSAX::Error procedure method is called when the parser
;;   detects a fatal error.
;;
;; Parameters:
;;   ID - not used
;;
;;   LINENUMBER - the line number of the file where the error occurred
;;
;;   COLUMNNUMBER - the column number where the error occurred
;;
;;   MESSAGE - the error message
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::FatalError,ID,LineNumber,ColumnNumber,Message
  compile_opt idl2, hidden

  st=['Error reading input file: '+self.demo_filename, $
      Message, $
      'Line '+strtrim(LineNumber,2)+', Column '+strtrim(ColumnNumber,2)]
  void = dialog_message(st,/error,title='Error in IDL Demo System')
  self->stopParsing
  self.invalidparse = 1

END

;;----------------------------------------------------------------------------
;; demoObj::characters
;;
;; Purpose:
;;   The IDLffXMLSAX::Characters procedure method is called when the
;;   parser detects text in the parsed document.
;;
;; Parameters:
;;   CHARS - A string containing the text detected by the parser.
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::characters,chars
  compile_opt idl2, hidden

  ;; chars comes in as a single string with line returns embedded as
  ;; byte values of 10.  This removes trailing/leading returns and
  ;; then separates the rest of the string.
  byt = byte(chars)
  IF byt[0] EQ 10b THEN byt=byt[1:*]
  len = n_elements(byt)
  IF byt[len-1] EQ 10b THEN byt=byt[0:len-2]
  chars = string(byt)
  str = strsplit(chars,string(10b),/extract,/preserve_null)

  IF ptr_valid(self.items) THEN n = n_elements(*self.items)-1

  CASE self.processCharacters OF
    ;; store the incoming characters in the appropriate variable,
    ;; depending on which element tag we are currently inside.

    self.in.title_graphic : BEGIN
      IF ((file=self->validfile(str[0]))) NE '' THEN $
        self.demo_titleimage = file
    END

    self.in.default_graphic : BEGIN
      IF ((file=self->validfile(str[0]))) NE '' THEN BEGIN
        self.demo_defaultimage = ptr_new(self->get_image(file))
      ENDIF
    END

    self.in.default_text : BEGIN
      *self.demo_defaulttext = str
    END

    self.in.default_program_bitmap : BEGIN
      IF ((file=self->validfile(str[0]))) NE '' THEN BEGIN
        self.demo_programbitmap = file
        self.demo_programbitmap_image = $
          ptr_new(self->to_tree_bitmap(self->get_image(attrValue[wh[0]])))
      ENDIF
    END

    self.in.default_url_bitmap : BEGIN
      IF ((file=self->validfile(str[0]))) NE '' THEN BEGIN
        self.demo_urlbitmap = file
        self.demo_urlbitmap_image = $
          ptr_new(self->to_tree_bitmap(self->get_image(attrValue[wh[0]])))
      ENDIF
    END

    self.in.graphic : BEGIN
      (*self.items)[n_elements(*self.items)-1].graphic = $
        self->validfile(str[0])
    END

    self.in.program_file : BEGIN
      (*self.items)[n_elements(*self.items)-1].program = str[0]
      widget_control,self.button_entry,set_uvalue=str[0]
    END

    self.in.tag : BEGIN
      self.tag = str[0]
    END 

    self.in.value : BEGIN
      badData = 0
      ;; do proper string to value conversion
      ;; does not handle structures, pointers, or object references
      vals = strsplit(str[0],',',/extract)
      SWITCH self.idltype OF
        1 : BEGIN
          value = byte(fix(vals))
          BREAK
        END 
        6 : BEGIN
          IF n_elements(vals) GE 2 THEN $
            value = complex(float(vals[0]),float(vals[1])) $
          ELSE $
            badData = 1
          BREAK
        END
        9 : BEGIN
          IF n_elements(vals) GE 2 THEN $
            value = dcomplex(float(vals[0]),float(vals[1])) $
          ELSE $
            badData = 1
          BREAK
        END
        0:&8:&10:&11: BEGIN
          badData = 1
          BREAK
        END
        ELSE : value = fix(vals,type=self.idltype)
      ENDSWITCH 

      ;; if valid data create or append the extra structure
      IF ~badData THEN BEGIN
        ptr = (*self.items)[n_elements(*self.items)-1].extra
        IF ptr_valid(ptr) THEN BEGIN
          oldStruct = *ptr
          newStruct = create_struct(oldStruct,self.tag,value)
          *ptr = newStruct
        ENDIF ELSE BEGIN
          newStruct = create_struct(self.tag,value)
          (*self.items)[n_elements(*self.items)-1].extra = ptr_new(newStruct)
        ENDELSE 
      ENDIF 

      ;; reset default idltype to string
      self.idltype = 7
    END

    self.in.url_page : BEGIN
      (*self.items)[n_elements(*self.items)-1].url_page = $
        self->validfile(str[0])
    END

    self.in.slideshow_file : BEGIN
      (*self.items)[n_elements(*self.items)-1].slideshow_file = $
        self->validfile(str[0])
    END

    self.in.text : BEGIN
      *((*self.items)[n_elements(*self.items)-1].text) = str
    END

    ELSE :

  ENDCASE

END

;;----------------------------------------------------------------------------
;; demoObj::endElement
;;
;; Purpose:
;;   The IDLffXMLSAX::EndElement procedure method is called when the
;;   parser detects the end of an element.
;;
;; Parameters:
;;   VOID1,VOID2 - not used
;;
;;   NAME - A string containing the element name found in the XML file.
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::endElement,void1,void2,name
  compile_opt idl2, hidden

  CASE name OF

    'TAB' : BEGIN
      ;; when finished loading a tab, set the initial graphic
      uname = widget_info(self.current_tab,/uname)
      wh = where((*self.items).uname EQ uname)
      IF wh[0] EQ -1 THEN return
      drawWin = widget_info(self.current_tab,find_by_uname='draw')
      widget_control,drawWin,get_value=wID
      ;; display graphic if one exists
      ;; if first use, get and cache graphic
      IF (*self.items)[wh].graphic NE '' THEN BEGIN
        (*self.items)[wh].graphic_image = $
          ptr_new(self->get_image((*self.items)[wh].graphic))
        (*self.items)[wh].graphic = ''
      ENDIF
      IF ptr_valid((*self.items)[wh].graphic_image) THEN BEGIN
        self->showimage,*((*self.items)[wh].graphic_image),wID
      ENDIF ELSE BEGIN
        self->showimage,*self.demo_defaultimage,wID
      ENDELSE
      self.nomenu = 0
      self.in.tab = 0
    END

    'TITLE_GRAPHIC' : BEGIN
      self.in.title_graphic = 0
    END

    'DEFAULT_GRAPHIC' : BEGIN
      self.in.default_graphic = 0
    END

    'DEFAULT_TEXT' : BEGIN
      self.in.default_text = 0
    END

    'DEFAULT_PROGRAM_BITMAP' : BEGIN
      self.in.default_program_bitmap = 0
    END

    'DEFAULT_URL_BITMAP' : BEGIN
      self.in.default_url_bitmap = 0
    END

    'DEFAULT_SLIDESHOW_BITMAP' : BEGIN
      self.in.default_slideshow_bitmap = 0
    END

    'TREE_FOLDER' : BEGIN
      ;; reset current_item[_menu] to the parent item[menu]
      self.current_item = widget_info(self.current_item,/parent)
      IF ~self.nomenu THEN $
        self.current_menu = widget_info(self.current_menu,/parent)
      self.in.tree_folder = 0
    END

    'TREE_NODE' : BEGIN
      ;; reset current_item[_menu] to the parent item[menu]
      self.current_item = widget_info(self.current_item,/parent)
      IF ~self.nomenu THEN BEGIN
        IF widget_info(self.current_menu,/child) EQ 0 THEN $
          entry=widget_button(self.current_menu,value='No Demos')
        self.current_menu = widget_info(self.current_menu,/parent)
      ENDIF
      self.in.tree_node = 0
    END

    'GRAPHIC' : BEGIN
      self.in.graphic = 0
    END

    'PROGRAM' : BEGIN
      ;; if text is keyed to a program add in a line stating the
      ;; location of the source code
      programName = (*self.items)[n_elements(*self.items)-1].program
      filename = file_which(programName+'.pro')
      IF filename NE '' THEN BEGIN
        IF (*((*self.items)[n_elements(*self.items)-1].text))[0] NE '' THEN $
          *((*self.items)[n_elements(*self.items)-1].text)= $
          [*((*self.items)[n_elements(*self.items)-1].text), $
           'Source code located at: '+fileNAME] $
        ELSE *((*self.items)[n_elements(*self.items)-1].text)= $
          ['Source code located at: '+fileNAME]
      ENDIF ELSE BEGIN
        ;; if no source code is found and no other text is available
        ;; then create an 'empty' text string
        IF (*((*self.items)[n_elements(*self.items)-1].text))[0] EQ '' THEN $
          *((*self.items)[n_elements(*self.items)-1].text)=' '
      ENDELSE

      ;; add the program to the uval list of the current item
      widget_control,self.current_item,get_uvalue=uval
      uname = (*self.items)[n_elements(*self.items)-1].uname
      IF n_elements(uval) EQ 0 THEN uval = [uname] $
      ELSE uval = [uval,uname]
      widget_control,self.current_item,set_uvalue=uval
      self.in.program = 0
    END

    'PROGRAM_FILE' : BEGIN
      self.in.program_file = 0
    END

    'EXTRA' : BEGIN
      self.in.extra = 0
    END

    'TAG' : BEGIN
      self.in.tag = 0
    END

    'VALUE' : BEGIN
      self.in.value = 0
    END

    'TEXT' : BEGIN
      self.in.text = 0
    END

    'URL' : BEGIN
      ;; add the url to the uval list of the current item
      widget_control,self.current_item,get_uvalue=uval
      uname = (*self.items)[n_elements(*self.items)-1].uname
      IF n_elements(uval) EQ 0 THEN uval = [uname] $
      ELSE uval = [uval,uname]
      widget_control,self.current_item,set_uvalue=uval
      self.in.url = 0
    END

    'PAGE' : BEGIN
      self.in.url_page = 0
    END

    'SLIDESHOW' : BEGIN
      IF self.processCharacters EQ -1 THEN BEGIN
        self.processCharacters = 1
        BREAK
      ENDIF
      ;; add the slideshow to the uval list of the current item
      widget_control,self.current_item,get_uvalue=uval
      uname = (*self.items)[n_elements(*self.items)-1].uname
      IF n_elements(uval) EQ 0 THEN uval = [uname] $
      ELSE uval = [uval,uname]
      widget_control,self.current_item,set_uvalue=uval
      self.in.slideshow = 0
    END

    'SLIDESHOW_FILE' : BEGIN
      self.in.slideshow_file = 0
    END

    'ABOUT_TAB' : BEGIN
      ;; when finished loading a tab, set the initial graphic
      uname = widget_info(self.current_tab,/uname)
      wh = where((*self.items).uname EQ uname)
      IF wh[0] EQ -1 THEN return
      drawWin = widget_info(self.current_tab,find_by_uname='draw')
      widget_control,drawWin,get_value=wID
      ;; display graphic if one exists
      ;; if first use, get and cache graphic
      IF (*self.items)[wh].graphic NE '' THEN BEGIN
        (*self.items)[wh].graphic_image = $
          ptr_new(self->get_image((*self.items)[wh].graphic))
        (*self.items)[wh].graphic = ''
      ENDIF
      IF ptr_valid((*self.items)[wh].graphic_image) THEN BEGIN
        self->showimage,*((*self.items)[wh].graphic_image),wID
      ENDIF ELSE BEGIN
        self->showimage,*self.demo_defaultimage,wID
      ENDELSE
      self.in.about_tab = 0
    END

    ELSE :

  ENDCASE

END

;;----------------------------------------------------------------------------
;; demoObj::startElement
;;
;; Purpose:
;;   The IDLffXMLSAX::StartElement procedure method is called when the
;;   parser detects the beginning of an element.
;;
;; Parameters:
;;   VOID1,VOID2 - not used
;;
;;   NAME - A string containing the element name found in the XML
;;          file.
;;
;;   ATTRNAME - A string array representing the names of the
;;              attributes associated with the element, if any.
;;
;;   ATTRVALUE - A string array representing the values of each
;;               attribute associated with the element, if any. The
;;               returned array will have the same number of elements
;;               as the array returned in the attrName keyword
;;               variable.
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::startElement,void1,void2,name,attrName,attrValue
  compile_opt idl2, hidden

  CASE name OF

    'TAB' : BEGIN
      self.in.tab = 1
      ;; bad_tab is required for proper geometry issues.  Once created
      ;; it is no longer needed and can be destroyed.
      IF ((badtab=widget_info(self.tabbase,find_by_uname='bad_tab'))) NE 0 $
        THEN widget_control,badtab,/destroy

      tabName = attrValue[(where(attrName EQ 'NAME'))[0]]
      IF (where(attrName EQ 'NO_MENU'))[0] NE -1 THEN self.nomenu=1

      ;; create item for this tab
      item = {item}
      item.graphic = ''
      item.text = ptr_new('')
      item.name = attrValue[(where(attrName EQ 'NAME'))[0]]
      item.uname = self->validname(item.name)
      IF ptr_valid(self.items) EQ 0 THEN self.items = ptr_new([item]) $
      ELSE *self.items = [*self.items,item]

      ;; create current tab
      self.current_tab = widget_base(self.tabbase,title=tabName, $
                                     xpad=self.padding,ypad=self.padding, $
                                     space=self.padding,/column, $
                                     uname=item.uname)
      IF ptr_valid(self.tablist) THEN $
        *self.tablist = [*self.tablist,self.current_tab] $
      ELSE $
        self.tablist = ptr_new([self.current_tab])

      ;; create label above category tree widget
      label = widget_label(self.current_tab,xsize=tab_x,value='Categories', $
                           /align_left)
      b1 = widget_base(self.current_tab,/row)
      ;; create tree widget to hold base categories
      tree1 = widget_tree(b1,xsize=self.tab_x-self.draw_x-8*self.padding, $
                          uname='tree')
      self.current_item = tree1
      b2 = widget_base(b1,/column,xpad=self.padding,space=self.padding)
      ;; create draw widget for the graphics
      draw2 = widget_draw(b2,xsize=self.draw_x,ysize=self.draw_y, $
                          uname='draw',/frame,colors=256, $
                          retain=2)
      xmanager,'demo',draw2,/just_reg
      ;; create label above demo tree widget
      label2 = widget_label(b2,xsize=self.draw_x,value='Demos and Links', $
                            /align_left)
      ;; create tree widget to hold list of demos and other "programs"
      tree2 = widget_tree(b2,ysize=self.tab_y-self.draw_y-15*self.padding, $
                          uname='list')
      IF ~self.nomenu THEN $
        self.current_menu = widget_button(self.menubar,value=tabName,/menu)
    END

    'TITLE_GRAPHIC' : BEGIN
      self.in.title_graphic = 1
    END

    'DEFAULT_GRAPHIC' : BEGIN
      self.in.default_graphic = 1
    END

    'DEFAULT_TEXT' : BEGIN
      self.in.default_text = 1
    END

    'DEFAULT_PROGRAM_BITMAP' : BEGIN
      self.in.default_program_bitmap = 1
    END

    'DEFAULT_URL_BITMAP' : BEGIN
      self.in.default_url_bitmap = 1
    END

    'DEFAULT_SLIDESHOW_BITMAP' : BEGIN
      self.in.default_slideshow_bitmap = 1
    END

    'TREE_FOLDER' : BEGIN
      self.in.tree_folder = 1
      ;; create item for this folder
      item = {item}
      item.graphic = ''
      item.text = ptr_new('')
      item.name = attrValue[(where(attrName EQ 'NAME'))[0]]
      item.uname = self->validname(item.name)

      self.current_item = widget_tree(self.current_item,/folder,/expanded, $
                                      value=item.name,uname=item.uname, $
                                      uvalue='folder')
      ;; set bitmap if one is specified
      IF ((wh=where(attrName EQ 'BITMAP'))) NE -1 THEN BEGIN
        IF self->validfile(attrValue[wh[0]]) NE '' THEN BEGIN
          item.bitmap_image = $
            ptr_new(self->to_tree_bitmap(self->get_image(attrValue[wh[0]], $
                                                         root=self.demo_root)))
          widget_control,self.current_item, $
            set_tree_bitmap= *item.bitmap_image
        ENDIF
      ENDIF

      IF ptr_valid(self.items) EQ 0 THEN self.items = ptr_new([item]) $
      ELSE *self.items = [*self.items,item]

      IF ~self.nomenu THEN $
        self.current_menu = widget_button(self.current_menu, $
                                          value=item.name,/menu)
    END

    'TREE_NODE' : BEGIN
      self.in.tree_node = 1
      ;; create item for this node
      item = {item}
      item.graphic = ''
      item.text = ptr_new('')
      item.name = attrValue[(where(attrName EQ 'NAME'))[0]]
      item.uname = self->validname(item.name)

      self.current_item = widget_tree(self.current_item,value=item.name, $
                                      uname=item.uname)
      ;; set bitmap if one is specified
      IF ((wh=where(attrName EQ 'BITMAP'))) NE -1 THEN BEGIN
        IF self->validfile(attrValue[wh[0]]) NE '' THEN BEGIN
          item.bitmap_image = $
            ptr_new(self->to_tree_bitmap(self->get_image(attrValue[wh[0]], $
                                                         root=self.demo_root)))
          widget_control,self.current_item, $
            set_tree_bitmap=*item.bitmap_image
        ENDIF
      ENDIF

      IF ptr_valid(self.items) EQ 0 THEN self.items = ptr_new([item]) $
      ELSE *self.items = [*self.items,item]

      IF ~self.nomenu THEN $
        self.current_menu = widget_button(self.current_menu, $
                                          value=item.name,/menu)
    END

    'GRAPHIC' : BEGIN
      self.in.graphic = 1
    END

    'PROGRAM' : BEGIN
      self.in.program = 1
      ;; create item for this node
      item = {item}
      item.type = 'PROGRAM'
      item.graphic = ''
      item.text = ptr_new('')
      item.name = attrValue[(where(attrName EQ 'NAME'))[0]]
      item.uname = self->validname('demo:'+item.name)

      IF ((wh=where(attrName EQ 'BITMAP'))) NE -1 THEN BEGIN
        item.bitmap = self->validfile(attrValue[wh[0]])
        item.bitmap_image = $
          ptr_new(self->to_tree_bitmap(self->get_image(item.bitmap)))
      ENDIF ELSE BEGIN
        item.bitmap = self.demo_programbitmap
        item.bitmap_image = self.demo_programbitmap_image
      ENDELSE

      *self.items = [*self.items,item]
      IF ~self.nomenu THEN $
        self.button_entry=widget_button(self.current_menu,value=item.name, $
                                        uname=item.uname)
    END

    'PROGRAM_FILE' : BEGIN
      self.in.program_file = 1
    END

    'EXTRA' : BEGIN
      self.in.extra = 1
    END 

    'TAG' : BEGIN
      self.in.tag = 1
    END

    'VALUE' : BEGIN
      self.in.value = 1
      IF n_elements(attrName) NE 0 THEN $
        IF ((wh=where(attrName EQ 'IDLTYPE')))[0] NE -1 THEN $
        self.idltype = fix(attrValue[wh[0]])
    END

    'TEXT' : BEGIN
      self.in.text = 1
    END

    'URL' : BEGIN
      self.in.url = 1
      item = {item}
      item.type = 'URL'
      item.graphic = ''
      item.text = ptr_new('')
      item.name = attrValue[(where(attrName EQ 'NAME'))[0]]
      item.uname = self->validname(item.name)

      IF ((wh=where(attrName EQ 'BITMAP'))) NE -1 THEN BEGIN
        item.bitmap = self->validfile(attrValue[wh[0]])
        item.bitmap_image = $
          ptr_new(self->to_tree_bitmap(self->get_image(item.bitmap)))
      ENDIF ELSE BEGIN
        item.bitmap = self.demo_urlbitmap
        item.bitmap_image = self.demo_urlbitmap_image
      ENDELSE

      *self.items = [*self.items,item]
      IF ~self.nomenu THEN $
        entry=widget_button(self.current_menu,value=item.name,uname=item.uname)
    END

    'PAGE' : BEGIN
      self.in.url_page = 1
    END

    'SLIDESHOW' : BEGIN
      IF self.virtualMachine THEN BEGIN
        self.processCharacters = -1
        BREAK
      ENDIF 
      self.in.slideshow = 1
      item = {item}
      item.type = 'SLIDESHOW'
      item.graphic = ''
      item.text = ptr_new('')
      item.name = attrValue[(where(attrName EQ 'NAME'))[0]]
      item.uname = self->validname(item.name)

      IF ((wh=where(attrName EQ 'BITMAP'))) NE -1 THEN BEGIN
        item.bitmap = self->validfile(attrValue[wh[0]])
        item.bitmap_image = $
          ptr_new(self->to_tree_bitmap(self->get_image(item.bitmap)))
      ENDIF ELSE BEGIN
        item.bitmap = self.demo_slideshowbitmap
        item.bitmap_image = self.demo_slideshowbitmap_image
      ENDELSE

      *self.items = [*self.items,item]
      IF ~self.nomenu THEN $
        entry=widget_button(self.current_menu,value=item.name,uname=item.uname)
    END

    'SLIDESHOW_FILE' : BEGIN
      self.in.slideshow_file = 1
    END

    'ABOUT_TAB' : BEGIN
      self.in.about_tab = 1

      ;; create item for this tab
      item = {item}
      item.graphic = ''
      item.text = ptr_new('')
      item.name = attrValue[(where(attrName EQ 'NAME'))[0]]
      item.uname = self->validname(item.name)
      IF ptr_valid(self.items) EQ 0 THEN self.items = ptr_new([item]) $
      ELSE *self.items = [*self.items,item]

      ;; create tab and draw widget for about tab graphic
      self.current_tab = widget_base(self.tabbase,title=attrValue[0], $
                                     xpad=self.padding,ypad=self.padding, $
                                     space=self.padding,/column, $
                                     uname=item.uname)

      IF ptr_valid(self.tablist) THEN $
        *self.tablist = [*self.tablist,self.current_tab] $
      ELSE $
        self.tablist = ptr_new([self.current_tab])

      tabinfo = widget_info(self.current_tab,/geometry)
      draw = widget_draw(self.current_tab,xsize=self.about_x, $
                         ysize=self.about_y, $
                         uname='draw',/frame,colors=256, $
                         retain=2)
      xmanager,'demo',draw,/just_reg

    END

    ELSE :

  ENDCASE

END

;;----------------------------------------------------------------------------
;; demoObj::demoObj_event
;;
;; Purpose:
;;   the primary event handler
;;
;; Parameters:
;;   EVENT - a widget event structure
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::demoObj_event,event
  compile_opt idl2, hidden

  ;; catch errors if pdf does not exist or errors occur with Acrobat
  ErrorStatus = 0
  CATCH, ErrorStatus
  IF (ErrorStatus NE 0) THEN BEGIN
    IF (!error_state.name EQ 'IDL_M_CNTOPNFIL') || $
      (!error_state.name EQ 'IDL_M_FILE_EOF') || $
      (strmid(!error_state.name,0,9) EQ 'IDL_M_OLH') THEN $
      void = $
      dialog_message('An Error has occured with the Online Help System',/ERROR)
    CATCH, /CANCEL
    return
  ENDIF

  uname = widget_info(event.id,/uname)
  IF (uname EQ 'demo:idlhelp') THEN BEGIN
    online_help
    return
  ENDIF
  IF (uname EQ 'demo:demohelp') THEN BEGIN
    online_help, 'd_demo', $
                 book=demo_filepath("idldemo.adp", $
                                    SUBDIR=['examples','demo','demohelp']), $
                 /FULL_PATH
    return
  ENDIF
  IF (uname EQ 'demo:demoabout') THEN BEGIN
    self->displayAbout
    return
  ENDIF
  wh = where((*self.items).uname EQ uname)

  ;; if a tab is clicked, set the current tab
  IF tag_names(event,/structure_name) EQ 'WIDGET_TAB' THEN BEGIN
    ;; set the current tab
    tab = widget_info(self.tabbase,/tab_current)
    self.current_tab = (*self.tablist)[tab]
    IF self.notabreset THEN BEGIN
      ;; get deepest selected item with text

      ;; if an item in the list is selected, use its text
      list = widget_info(self.current_tab,find_by_uname='list')
      IF (list NE 0) && $
        (((treesel=widget_info(list,/tree_select))) NE -1) THEN BEGIN
        treeuname = widget_info(treesel,/uname)
        wh4 = where((*self.items).uname EQ treeuname)
        IF *((*self.items)[wh4].text) NE '' THEN BEGIN
          widget_control,self.text_window,set_value=*((*self.items)[wh4].text)
          return
        ENDIF
      ENDIF

      ;; if an item in the tree is selected, use its text
      tree = widget_info(self.current_tab,find_by_uname='tree')
      IF (tree NE 0) && $
        (((treesel=widget_info(tree,/tree_select))) NE -1) THEN BEGIN
        treeuname = widget_info(treesel,/uname)
        wh3 = where((*self.items).uname EQ treeuname)
        IF *((*self.items)[wh3].text) NE '' THEN BEGIN
          widget_control,self.text_window,set_value=*((*self.items)[wh3].text)
          return
        ENDIF
      ENDIF

      ;; if no item selected, use text from tab
      IF widget_info(self.current_tab,/valid_id) THEN BEGIN
        wh5 = where((*self.items).uname EQ $
                    widget_info(self.current_tab,/uname))
        text = *((*self.items)[wh5].text)
        IF text[0] NE '' THEN $
          widget_control,self.text_window,set_value=text $
        ELSE $
          widget_control,self.text_window,set_value=*self.demo_defaulttext
      ENDIF ELSE $
        widget_control,self.text_window,set_value=*self.demo_defaulttext

    ENDIF ELSE BEGIN
      ;; reset the tab to initial state

      ;; use text from tab
      IF widget_info(self.current_tab,/valid_id) THEN BEGIN
        wh6 = where((*self.items).uname EQ $
                    widget_info(self.current_tab,/uname))
        text = *((*self.items)[wh6].text)
        IF text[0] NE '' THEN $
          widget_control,self.text_window,set_value=text $
        ELSE $
          widget_control,self.text_window,set_value=*self.demo_defaulttext
      ENDIF ELSE $
        widget_control,self.text_window,set_value=*self.demo_defaulttext

      ;; clear selection in tree
      tree = widget_info(self.current_tab,find_by_uname='tree')
      IF tree NE 0 THEN widget_control,tree,set_tree_select=0

      ;; clear list window
      list = widget_info(self.current_tab,find_by_uname='list')
      IF list NE 0 THEN BEGIN
        widget_control,list,sensitive=1
        WHILE ((child=widget_info(list,/child))) NE 0 DO $
          widget_control,child,/destroy
      ENDIF

      ;; reset graphic
      draw = widget_info(self.current_tab,find_by_uname='draw')
      widget_control,draw,get_value=wID
      ;; when finished loading a tab, set the initial graphic
      uname = widget_info(self.current_tab,/uname)
      wh = where((*self.items).uname EQ uname)
      IF wh[0] EQ -1 THEN return
      ;; display graphic if one exists
      ;; if first use, get and cache graphic
      IF (*self.items)[wh].graphic NE '' THEN BEGIN
        (*self.items)[wh].graphic_image = $
          ptr_new(self->get_image((*self.items)[wh].graphic))
        (*self.items)[wh].graphic = ''
      ENDIF
      IF ptr_valid((*self.items)[wh].graphic_image) THEN BEGIN
        self->showimage,*((*self.items)[wh].graphic_image),wID
      ENDIF ELSE BEGIN
        self->showimage,*self.demo_defaultimage,wID
      ENDELSE

    ENDELSE

  ENDIF

  ;; if a tree element is clicked, update the graphics window and text
  ;; label, if needed
  IF tag_names(event,/structure_name) EQ 'WIDGET_TREE_SEL' THEN BEGIN
    uname = widget_info(event.id,/uname)
    wh = where((*self.items).uname EQ uname)
    IF wh[0] EQ -1 THEN return
    drawWin = widget_info(self.current_tab,find_by_uname='draw')
    widget_control,drawWin,get_value=wID
    ;; display graphic if one exists
    ;; if first use, get and cache graphic
    IF (*self.items)[wh].graphic NE '' THEN BEGIN
      (*self.items)[wh].graphic_image = $
        ptr_new(self->get_image((*self.items)[wh].graphic))
      (*self.items)[wh].graphic = ''
    ENDIF
    IF ptr_valid((*self.items)[wh].graphic_image) THEN BEGIN
      self->showimage,*((*self.items)[wh].graphic_image),wID
    ENDIF ELSE BEGIN
      ;; if no graphic found, check to see if there is a graphic
      ;; specified for the node that created the list
      tree = widget_info(self.current_tab,find_by_uname='tree')
      treesel = widget_info(tree,/tree_select)
      treeuname = widget_info(treesel,/uname)
      wh2 = where((*self.items).uname EQ treeuname)
      ;; if first use, get and cache graphic
      IF (*self.items)[wh2].graphic NE '' THEN BEGIN
        (*self.items)[wh2].graphic_image = $
          ptr_new(self->get_image((*self.items)[wh2].graphic))
        (*self.items)[wh2].graphic = ''
      ENDIF
      IF ptr_valid((*self.items)[wh].graphic_image) THEN BEGIN
        self->showimage,*((*self.items)[wh].graphic_image),wID
      ENDIF
    ENDELSE

    ;; set text window
    IF (*((*self.items)[wh].text))[0] NE '' THEN $
      widget_control,self.text_window,set_value=*((*self.items)[wh].text) $
    ELSE $
      widget_control,self.text_window,set_value=' '

    treename = widget_info(widget_info(event.id,/tree_root),/uname)
    CASE treename OF

      'tree' : BEGIN
        ;; populate list widget with items found in the tree node
        list = widget_info(self.current_tab,find_by_uname='list')
        widget_control,list,sensitive=1
        WHILE ((child=widget_info(list,/child))) NE 0 DO $
          widget_control,child,/destroy
        widget_control,event.id,get_uvalue=uval
        IF ((n=n_elements(uval))) NE 0 THEN BEGIN
          ;; if item is a folder, display default text in list tree
          IF uval[0] EQ 'folder' THEN BEGIN
            node = widget_tree(list,value=*self.demo_defaulttext, $
                               bitmap=self.invisible_bitmap)
            return
          ENDIF
          FOR i=0,n-1 DO BEGIN
            ;; add items to the list tree
            wh = where((*self.items).uname EQ uval[i])
            node = widget_tree(list,value=(*self.items)[wh].name, $
                               uname=(*self.items)[wh].uname)
            IF ptr_valid((*self.items)[wh].bitmap_image) THEN BEGIN
              widget_control,node, $
                             set_tree_bitmap=*((*self.items)[wh].bitmap_image)
            ENDIF
          ENDFOR
        ENDIF ELSE BEGIN
          ;; if no items to display, gray out the list
          node = widget_tree(list,value='No Demos', $
                               bitmap=self.invisible_bitmap_dark)
          widget_control,list,sensitive=0
        ENDELSE
      END

      'list' : BEGIN
        ;; run the application specifed by the item that was double clicked
        IF event.clicks EQ 2 THEN BEGIN
          self->runApp,wh
        ENDIF
      END

    ELSE :

    ENDCASE

  ENDIF

  IF tag_names(event,/structure_name) EQ 'WIDGET_BUTTON' THEN BEGIN
    ;; if a menu option was chosen, run the selected application
    IF wh[0] NE -1 THEN $
      self->runApp,wh
  ENDIF

END

;;----------------------------------------------------------------------------
;; demoObj::SpecifyBrowser
;;
;; Purpose:
;;   Test for the presence of a specified browser. If found, set the 
;;   environment variable so that online_help_html uses this browser
;;   instead of the default (currently Netscape.) This just helps to
;;   modernize the usage of the script and allows it to work on Linux.
;;
;; Parameters:
;;   browser [in]:      Browser to test for.
;
;; Keywords:
;;   None
;;
;; Returns:
;;   True if the specified browser was found
;;
;; Usage:
;;    browserFound = oBrowseURL->SpecifyBrowser, browser
;;
function demoObj::SpecifyBrowser, browser

  compile_opt idl2, hidden
    
  spawn, 'which '+browser, outText, errText
  ; outText may have full path or error message
  if file_test(outText[0]) then begin
    setenv, 'IDL_ONLINE_HELP_HTML_BROWSER='+browser
    return, 1
  endif
    
  return, 0

end


;;----------------------------------------------------------------------------
;; demoObj::runApp
;;
;; Purpose:
;;   executes the specified program
;;
;; Parameters:
;;   INDEX - an integer denoting the program in the items list to be
;;           called
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::runApp,index
  compile_opt idl2, hidden

  CASE (*self.items)[index].type OF

    'PROGRAM' : BEGIN
      self.state.mainWinBase = self.tlb
      progname = index NE -1 ? (*self.items)[index].program : ''
      IF progname NE '' THEN BEGIN
        ;; if the extra tag contains anything, pass it to the program
        ;; to be executed
        self.state.demo_name = progname
        appTLB = self.state.appTLB

        ;; use extra structure, if one exists
        IF ptr_valid((*self.items)[index].extra) THEN BEGIN
          ex = *((*self.items)[index].extra)
          self->demoStartApp,progname,appTLB,self.tlb, $
            self.state.record_to_filename,extra=ex
        ENDIF ELSE self->demoStartApp,progname,appTLB,self.tlb, $
          self.state.record_to_filename
        IF obj_valid(self) THEN self.state.appTLB = appTLB
      ENDIF
    END

    'URL' : BEGIN
      IF (*self.items)[index].url_page NE '' THEN BEGIN
        ; Test for the presence of mozilla and firefox browsers
        ; If one of these is present, set the environment variable
        ; so that online_help_html uses that browser instead of the
        ; default of Netscape. Most linux machines and some new
        ; Sun machines do not have Netscape.
        IF strupcase(!version.os_family) EQ 'UNIX' THEN BEGIN
          IF ~self->SpecifyBrowser('mozilla') THEN BEGIN
            void = self->SpecifyBrowser('firefox')
          ENDIF
        ENDIF
        online_help,book=(*self.items)[index].url_page
      ENDIF
    END

    'SLIDESHOW' : BEGIN
      IF (*self.items)[index].slideshow_file NE '' THEN $
        self->demoStartSlideshow,(*self.items)[index].slideshow_file
    END

    ELSE :

  ENDCASE

END

;;----------------------------------------------------------------------------
;; demoObj::displayAbout
;;
;; Purpose:
;;   displays the demo About widget
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::displayAbout
  compile_opt idl2, hidden

  str1 = ['IDL Demos', $
          '', $
          'IDL version: '+!version.release, $
          'Copyright '+stregex(!version.build_date,'2[0-9]{3}',/extract)]

  str2 = ['This program serves as a demonstration of the capabilities' + $
          'and features of IDL,', $
          'the Interactive Data Language. IDL is data analysis, ' + $
          'visualization, and application', $
          'development software developed by ITT Visual Information Solutions. ' + $
          'This demonstration', $
          'was developed using IDL to illustrate the unparalleled ' + $
          'flexibility offered for reading,', $
          'analyzing, and displaying any type of data.', $
          '']

  wTLB = widget_base(/modal,group_leader=self.tlb, $
                     tlb_frame_attr=1, $
                     /base_align_left, $
                     /column,xpad=5,ypad=5,space=10, $
                     title='About the IDL Demo System')

  wRow = widget_base(wTLB,/row,space=20,xpad=5)

  ;; get idl logo bitmap
  imagefile = filepath('idllogo.bmp', $
                       subdirectory=['examples','demo','demographics'])
  hasImage = file_test(imagefile)

  ;; if we have it, create a draw widget for it
  IF hasImage THEN BEGIN
    img = read_bmp(imagefile,/RGB,r,g,b)
    szImage = size(img, /DIMENSIONS)
    wDraw = widget_draw(wRow,xsize=szImage[0],ysize=szImage[1], $
                        retain=2,/align_center)
  ENDIF

  ;; column base next to graphic
  wCol = widget_base(wRow,/column)
  ;; put first set of text next to graphic
  FOR i=0,n_elements(str1)-1 DO $
    void = widget_label(wCol,/align_left,value=str1[i])

  ;; column base for bottom text
  wCol = widget_base(wTLB,/column)
  ;; put second set of text below graphic and first set
  FOR i=0,n_elements(str2)-1 DO $
    void = widget_label(wCol,/align_left,value=str2[i])

  ;; Add a Close button.
  wBBase = Widget_base(wTLB,/align_center,/row,space=3)
  wOK = Widget_Button(wBBase,value=' OK ',uname="demo:quit")
  widget_control, wTLB, cancel_button=wOK

  widget_control, wTLB, /realize

  IF (hasImage) THEN BEGIN
    window = !d.window
    tvlct, rr,gg,bb, /GET
    device, get_decomposed=dec
    widget_control,wDraw,get_value=wID
    wset,wID
    device,decomposed=0
    tvlct, r,g,b
    tv,img
    device, decomposed=dec
    tvlct, rr,gg,bb
    wset, window
  ENDIF

  ;; Call xmanager, which will block until the dialog is closed
  xmanager,'demo',wTLB,event_handler='demoObj_demo_event'

END

;;----------------------------------------------------------------------------
;; demoObj::getTLB
;;
;; Purpose:
;;   returns the TLB ID
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
FUNCTION demoObj::getTLB
  compile_opt idl2, hidden

  return,self.tlb

END

;;----------------------------------------------------------------------------
;; demoObj::create_widget
;;
;; Purpose:
;;   creates the demo widget
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
FUNCTION demoObj::create_widget
  compile_opt idl2, hidden

  ;; create TLB
  self.tlb = widget_base(title=self.demo_title,mbar=menubar, $
                         xpad=self.padding,ypad=self.padding, $
                         space=self.padding,kill_notify='demoObj_kill_demo', $
                         tlb_frame_attr=1,/column,uname='demo:mainWinBase')
  ;; add menu bar
  self.menubar = menubar
  ;; hide widget during creation
  widget_control,self.tlb,map=0
  widget_control,self.tlb,/realize

  ;; add title graphic
  IF self.notitlegraphic EQ 0 THEN BEGIN
    titleimage_window = widget_draw(self.tlb,xsize=self.title_x, $
                                    ysize=self.title_y,/frame,colors=256, $
                                    retain=2)
    xmanager,'demo',titleimage_window,/just_reg
    widget_control,titleimage_window,get_value=wID
    self.titleimage_window = wID
  ENDIF

  self.tabbase = widget_tab(self.tlb,scr_xsize=self.tab_x,ysize=self.tab_y)
  self.current_item = self.tabbase
  ;; create dummy tab right now to counter certain geometry issues
  void = widget_base(self.tabbase,title='void',uname='bad_tab')
  self.text_window = widget_text(self.tlb,ysize=self.text_y-1,/wrap,/scroll)

  ;; add the only menu items found in all iterations of this widget
  file_menu = WIDGET_BUTTON(self.menubar,VALUE='File',/MENU)
  file_bttn = WIDGET_BUTTON(file_menu, VALUE='Quit',UNAME='demo:quit')

  ;; Create the main state structure.  This is only needed for the
  ;; current state of the demo tour and may be replace just with
  ;; 'self' in the future.
  mainState = { $
                self:self, $
;                 mainWinBase:mainWinBase, $
;                 imageBase : imageBase, $
;                 buttons: buttons, $
;                 mainDrawID: mainDrawID, $
                apptlb : 0L, $
;                 curScreenNum: 0L, $
;                 prevScreenNum: 0L, $
;                 MenuActions : MenuDescription[1,*], $
;                 colorTable: colorTable, $ ; Color table to restore
;                 quiet: quietsave, $
;                 png_header: temporary(header), $
                slow : 0, $
                demo_name: '<Startup>', $
                memory : memory(), $
                debug : 0,  $
                slow_demos : [''], $
;                 order: saveOrder, $
;                 xdisplayfile_text_font: xdisplayfile_text_font, $
;                 savedDecomposed: savedDecomposed, $
                record_to_filename: '' $
              }

  widget_control,self.tlb,set_uvalue=mainState
  ;; for runtime versions of the demo, the xmanager call must occur
  ;; outside of any demoObj method
  IF ~self.noxmanager THEN $
    xmanager,'demo',self.tlb,/no_block,event_handler='demoObj_demo_event'

END

;;----------------------------------------------------------------------------
;; demoObj::display_setup
;;
;; Purpose:
;;   sets up some initial widget values
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::display_setup
  compile_opt idl2, hidden

  ;; display title graphic
  IF self.notitlegraphic EQ 0 AND self.demo_titleimage NE '' THEN BEGIN
    self->showimage,self->get_image(self.demo_titleimage), $
      self.titleimage_window
  ENDIF

  ;; add help item to the menu
  IF (self.nohelp EQ 0) THEN BEGIN
    file_menu = WIDGET_BUTTON(self.menubar,VALUE='Help',/MENU)
    file_bttn = WIDGET_BUTTON(file_menu, VALUE='Help on the IDL Demos', $
                              UNAME='demo:demohelp')
    file_bttn = WIDGET_BUTTON(file_menu, VALUE='IDL Online Help Navigator', $
                              UNAME='demo:idlhelp')
  ENDIF

  ;; add about item to the menu
  IF (self.noabout EQ 0) THEN BEGIN
    IF (self.nohelp NE 0) THEN $
      file_menu = WIDGET_BUTTON(self.menubar,VALUE='About',/MENU)
    file_bttn = WIDGET_BUTTON(file_menu, VALUE='About the IDL Demo System', $
                              UNAME='demo:demoabout')
  ENDIF

  ;; fill in the text widget with the appropriate text
  widget_control,self.text_window,set_value=*self.demo_defaulttext
  widget_control,set_tab_current=0
  self.current_tab = widget_info(self.tabbase, $
                                 find_by_uname=(*self.items)[0].uname)
  IF widget_info(self.current_tab,/valid_id) THEN BEGIN
    text = *((*self.items)[0].text)
    IF text[0] NE '' THEN $
      widget_control,self.text_window,set_value=text $
    ELSE $
      widget_control,self.text_window,set_value=*self.demo_defaulttext

  ENDIF

  ;; create 'invisible' bitmaps
  colors = widget_info(self.tlb,/system_colors)
  bitmap = bytarr(16,16,3)
  FOR i=0,2 DO bitmap[*,*,i]=colors.window_bk[i]
  self.invisible_bitmap = bitmap
  bitmap = bytarr(16,16,3)
  FOR i=0,2 DO bitmap[*,*,i]=colors.face_3d[i]
  self.invisible_bitmap_dark = bitmap

END

;;----------------------------------------------------------------------------
;; demoObj::cleanup
;;
;; Purpose:
;;   cleanup routine
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO demoObj::cleanup
  compile_opt idl2, hidden

  ;; call superclass method
  self->IDLffXMLSAX::Cleanup

  ;; free all pointers
  IF ptr_valid(self.items) THEN $
    FOR i=0,n_elements(*self.items)-1 DO BEGIN
    ptr_free,(*self.items)[i].text
    ptr_free,(*self.items)[i].graphic_image
    ptr_free,(*self.items)[i].bitmap_image
    ptr_free,(*self.items)[i].extra
  ENDFOR
  ptr_free,self.items
  ptr_free,self.demo_defaulttext
  ptr_free,self.demo_defaultimage
  ptr_free,self.demo_programbitmap_image
  ptr_free,self.demo_slideshowbitmap_image
  ptr_free,self.tablist

  ;; reset decomposed value
  IF self.decomposed NE -1 THEN device,decomposed=self.decomposed
  ;; reset colour table
  tvlct,self.colourTable.r,self.colourTable.g,self.colourTable.b

END

;;----------------------------------------------------------------------------
;; demoObj::init
;;
;; Purpose:
;;   initialization routine for the demoObj object
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NO_HELP - if set do not add the help item to the menubar
;;
;;   NO_ABOUT - if set do not add the about item to the menubar
;;
;;   NO_TITLE_GRAPHIC - if set do not include space for a title
;;                      graphic
;;
;;   NO_TAB_RESET - if set, do not reset the trees in a tab upon
;;                  display
;;
;;   FILENAME - name of optional input XML file, either as a file
;;              found in the IDL path or as a fully qualified file.
;;              If not set, "demo.men" is used.
;;
;;   DEMO_ROOT - name of root directory to use when looking for
;;               demo[bitmaps,graphics,etc].  If not set, demo_root is
;;               set to the directory in which is found FILENAME.
;;
;;   TITLE - title for the TLB widget
;;
;;   NO_XMANAGER - if set xmanager will not be started leaving the
;;                 responsibility up to the user.  Example:
;;                 demo = obj_new('demoObj',/no_xmanager)
;;                 xmanager, 'demo', demo->getTLB(), /no_block, $
;;                   event_handler='demoObj_demo_event'
;;
;;   NO_DECOMPOSED - if set the decomposed state of the system will be
;;                   set to 0 during the life of the demo and restored
;;                   to the current state in the cleanup routine.
;;
FUNCTION demoObj::init,no_help=nohelp,no_about=noabout, $
                       no_title_graphic=notitlegraphic, $
                       no_tab_reset=notabreset, $
                       filename=filename, demo_root=demoroot, $
                       title=title,no_xmanager=noxmanager, $
                       no_decomposed=nodecomposed
  compile_opt idl2, hidden
  IF self->IDLffXMLSAX::Init() EQ 0 THEN return,0

  self.nohelp = keyword_set(nohelp)
  self.noabout = keyword_set(noabout)
  self.notitlegraphic = keyword_set(notitlegraphic)
  self.notabreset = keyword_set(notabreset)
  IF ~keyword_set(title) THEN $
    self.demo_title='IDL Demo Library' $
  ELSE $
    self.demo_title=title
  self.noxmanager = keyword_set(noxmanager)
  IF keyword_set(nodecomposed) THEN BEGIN
    device,get_decomposed = dec
    self.decomposed = dec
    device,decomposed=0
  ENDIF ELSE self.decomposed = -1

  ;; if platform is using 8 bit colour and a shared colourmap, 
  ;; hide the title graphic
  ;; This is done for situations where loading a colour map changes
  ;; all the other direct graphics windows on the screen.  Because
  ;; there is no guarantee that the colour table of the title graphic
  ;; will match the table of the last loaded image window the colours
  ;; in the title graphic could become mismatched.
  device,get_visual_name=visName
  IF (visName EQ 'DirectColor') OR (visName EQ 'PseudoColor') THEN BEGIN
    self.notitlegraphic=1
    self.norestorecolors=1
  ENDIF

  ;; check license.  Some things cannot run in the virtual machine
  self.virtualMachine = LMGR(/VM)

  ;; set processCharacters value.  1 : normal processing of input file,
  ;;                              -1 : skip processing
  self.processCharacters = 1

  ;; save colour tables
  tvlct,r,g,b,/get
  self.colourTable.r = r
  self.colourTable.g = g
  self.colourTable.b = b

  ;; set input file
  IF ~keyword_set(filename) THEN BEGIN
    self.demo_filename = file_which('demo.men',/include_current_dir)
    IF self.demo_filename EQ '' THEN $
      self.demo_filename = filepath('demo.men',SUBDIR=['examples','demo'])
  ENDIF ELSE BEGIN
    IF file_dirname(filename) EQ '.' THEN BEGIN
      self.demo_filename = file_which(filename,/include_current_dir)
    ENDIF ELSE BEGIN
      self.demo_filename = filename
    ENDELSE
  ENDELSE

  info = file_info(self.demo_filename)
  IF info.exists EQ 0 THEN BEGIN
    message,'Demo input file not found'
    return,-1
  ENDIF

  ;; set demo root
  IF keyword_set(demoroot) THEN BEGIN
    self.demo_root = demoroot
  ENDIF ELSE BEGIN
    self.demo_root = file_dirname(self.demo_filename)
  ENDELSE

  ;;define image, bitmap, and text defaults
  ;; header image
  self.demo_titleimage = self->validfile('demographics,demotop.bmp')
  ;; graphic window
  self.demo_defaultimage = $
    ptr_new(self->get_image(self->validfile('demographics,idldemo.bmp')))
  ;; text
  self.demo_defaulttext = $
    ptr_new('Select a category for a list of demos and/or links')

  ;; get system colours
  colors = widget_info(widget_base(),/system_colors)
  ;; icon for programs
  self.demo_programbitmap = self->validfile('demobitmaps,program.bmp')
  IF self.demo_programbitmap NE '' THEN BEGIN
    self.demo_programbitmap_image = $
      ptr_new(self->to_tree_bitmap(self->get_image(self.demo_programbitmap)))
    IF ~array_equal(colors.window_bk,[255,255,255]) THEN BEGIN
      ;; set background colour to colour of window for transparency
      wh = where(((*self.demo_programbitmap_image)[*,*,0] EQ 255) AND $
                 ((*self.demo_programbitmap_image)[*,*,1] EQ 255) AND $
                 ((*self.demo_programbitmap_image)[*,*,2] EQ 255))
      IF wh[0] NE -1 THEN $
        FOR i=0,2 DO (*self.demo_programbitmap_image)[wh+256*i] = $
        colors.window_bk[i]
    ENDIF
  ENDIF
  ;; icon for urls
  self.demo_urlbitmap = self->validfile('demobitmaps,url.bmp')
  IF self.demo_urlbitmap NE '' THEN BEGIN
    self.demo_urlbitmap_image = $
      ptr_new(self->to_tree_bitmap(self->get_image(self.demo_urlbitmap)))
    IF ~array_equal(colors.window_bk,[255,255,255]) THEN BEGIN
      ;; set background colour to colour of window for transparency
      wh = where(((*self.demo_urlbitmap_image)[*,*,0] EQ 255) AND $
                 ((*self.demo_urlbitmap_image)[*,*,1] EQ 255) AND $
                 ((*self.demo_urlbitmap_image)[*,*,2] EQ 255))
      IF wh[0] NE -1 THEN $
        FOR i=0,2 DO (*self.demo_urlbitmap_image)[wh+256*i] = $
        colors.window_bk[i]
    ENDIF
  ENDIF
  ;; icon for slideshows
  self.demo_slideshowbitmap = self->validfile('demobitmaps,slideshow.bmp')
  IF self.demo_slideshowbitmap NE '' THEN BEGIN
    self.demo_slideshowbitmap_image = $
      ptr_new(self->to_tree_bitmap(self->get_image(self.demo_slideshowbitmap)))
    IF ~array_equal(colors.window_bk,[255,255,255]) THEN BEGIN
      ;; set background colour to colour of window for transparency
      wh = where(((*self.demo_slideshowbitmap_image)[*,*,0] EQ 255) AND $
                 ((*self.demo_slideshowbitmap_image)[*,*,1] EQ 255) AND $
                 ((*self.demo_slideshowbitmap_image)[*,*,2] EQ 255))
      IF wh[0] NE -1 THEN $
        FOR i=0,2 DO (*self.demo_slideshowbitmap_image)[wh+256*i] = $
        colors.window_bk[i]
    ENDIF
  ENDIF

  ;;  define sizes for various aspects of the demo GUI
  ;;size of top bar graphic
  self.title_x = 700
  self.title_y = 50

  ;;size of graphic window for screen shots, ...
  self.draw_x = 400
  self.draw_y = 200

  ;;size of 'about tab' graphic
  self.about_x = 675
  self.about_y = 360

  ;;size of a tab pane
  self.tab_x = self.title_x
  self.tab_y = 380

  ;;number of text lines in text box
  self.text_y = 3

  self.padding = 5

  ;; default type for items in an extra structure
  self.idltype = 7

  ;; create the widget
  IF self->create_widget() EQ -1 THEN return,0

  ;; parse the input XML file
  self->parsefile,self.demo_filename

  IF self.invalidparse THEN BEGIN
    ;; if there was an error reading XML file then destroy widget and exit
    WHILE ((child=widget_info(self.tlb,/child))) DO $
      widget_control,child,/destroy
    return,1
  ENDIF

  ;; finish setting up the display
  self->display_setup
  wset,-1

  widget_control,self.tlb,map=1

  ;; re-display title graphic to ensure it is visible
  IF self.notitlegraphic EQ 0 AND self.demo_titleimage NE '' THEN BEGIN
    self->showimage,self->get_image(self.demo_titleimage), $
      self.titleimage_window
  ENDIF

  ;; set the initial tab graphic
  self->demoObj_event, $
    {WIDGET_TAB,ID:self.current_tab,TOP:self.tlb, $
     HANDLER:self.current_tab,TAB:0l}

  return,1

END

;;----------------------------------------------------------------------------
;; demoObj__define
;;
;; Purpose:
;;   definition routine for the demoObj object
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO demoObj__define
  compile_opt idl2, hidden

  in = {in,title_graphic:0,default_graphic:0,default_text:0, $
        tab:0,about_tab:0,tree_folder:0,tree_node:0, $
        text:0,graphic:0, $
        program:0,program_file:0,extra:0,tag:0,value:0, $
        default_program_bitmap:0, $
        url:0,url_page:0,default_url_bitmap:0, $
        slideshow:0,slideshow_file:0,default_slideshow_bitmap:0}

  state = {state,appTLB:0l,mainWinBase:0l,demo_name:'',record_to_filename:''}

  item = {item,graphic:'',graphic_image:ptr_new(),program:'',url_page:'', $
          slideshow_file:'',bitmap:'',bitmap_image:ptr_new(), $
          text:ptr_new(),name:'',uname:'',type:'',extra:ptr_new()}

  void = {demoObj,inherits IDLffXMLSAX, $
          nohelp:0, $
          noabout:0, $
          notitlegraphic:0, $
          nomenu:0, $
          notabreset:0, $
          noxmanager:0, $
          norestorecolors:0, $
          invalidparse:0, $
          demo_root:'', $
          demo_title:'', $
          demo_filename:'', $
          demo_titleimage:'', $
          demo_defaultimage:ptr_new(), $
          demo_programbitmap:'', $
          demo_programbitmap_image:ptr_new(), $
          demo_urlbitmap:'', $
          demo_urlbitmap_image:ptr_new(), $
          demo_slideshowbitmap:'', $
          demo_slideshowbitmap_image:ptr_new(), $
          demo_defaulttext:ptr_new(), $
          in:in, $
          invisible_bitmap:bytarr(16,16,3), $
          invisible_bitmap_dark:bytarr(16,16,3), $
          items:ptr_new(), $
          current_item:0l, $
          current_tab:0l, $
          tablist:ptr_new(), $
          current_menu:0l, $
          button_entry:0l, $
          tlb:0l, $
          menubar:0l, $
          tabbase:0l, $
          text_window:0l, $
          titleimage_window:0l, $
          title_x:0,title_y:0,tab_x:0,tab_y:0,draw_x:0,draw_y:0, $
          about_x:0,about_y:0,text_y:0,padding:0, $
          virtualMachine: 0, $
          processCharacters: 0, $
          decomposed:0l, $
          colourTable: {colours,r:bytarr(256),g:bytarr(256),b:bytarr(256)}, $
          idltype:0l, $
          tag:'', $
          value:'', $
          state:state}

END
