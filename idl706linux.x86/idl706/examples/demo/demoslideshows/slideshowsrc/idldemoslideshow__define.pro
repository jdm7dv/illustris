; $Id: //depot/idl/IDL_70/idldir/examples/demo/demoslideshows/slideshowsrc/idldemoslideshow__define.pro#2 $
;
; Copyright (c) 2003-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;       IDLDemoSlideshow__define.pro
;
; PURPOSE:
;       Displays a slideshow with each slide consisting of a text
;       panel and a graphics panel.  Graphics can be specified
;       directly, can be the output of a given .pro file, or can be
;       the output of IDL code in the input file that will be executed
;       directly.
;
; CATEGORY:
;       IDL demo system
;
; CALLING SEQUENCE:
;       slideshow = OBJ_NEW('IDLDemoSlideshow',filename='slides.sld')
;
; ARGUMENTS:
;       See Init method
;
; KEYWORDS:
;       See Init method
;
; OUTPUTS:
;       Object reference to the newly created slideshow object
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
; CREATED BY: AGEH, September 2003.
;
;---

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::wrapline
;;
;; Purpose:
;;   reads in an image file and stores it in an image structure for
;;   use with the to_tree_bitmap function
;;
;; Parameters:
;;   STR (required) - scalar string: string to be displayed
;;
;;   MAXWIDTH (required) - scalar float: maximum width, in normal
;;                         coordinates, that is allowed before
;;                         wrapping the text 
;;
;;   LINESPACING (required) - scalar float: vertical distance, in
;;                            normal coordinates, from the bottom of
;;                            one line to the bottom of the next 
;;
;;   X,Y (required) - scalar floats: normal coordinates of the
;;                    starting position of the text 
;;
;; Keywords:
;;   CHARSIZE (optional) - scalar float: character size displayed
;;
;;   COLOR (optional) - int array: array, or scalar, of indicies into
;;                      the current colour table
;;
;;   POSITIONS (optional) - int array: positions in the str where the
;;                          colour changes and where line breaks are
;;                          allowed 
;;
;;   FONT (optional) - int representing which font system to use,
;;                     -1,0,1
;;
;;   OUTPOS (optional, output) - if set to a named variable, outpos
;;                               will contain the y value of next line
;;
pro IDLDemoSlideshow::wrapline,str,maxwidth,linespacing,x,y,charsize=charsize, $
                        color=color,positions=positions,font=font, $
                        outpos=outpos
  compile_opt idl2, hidden
  
  ;; check and set some of the input variables
  IF n_elements(charsize) EQ 0 THEN chars = 1 ELSE chars = charsize
  IF n_elements(color) EQ 0 THEN col = !p.color ELSE col = color
  IF n_elements(font) EQ 0 THEN font = !p.font ELSE font = font
  
  ;; if the input is a blank line just update the the output position
  IF str EQ '' THEN BEGIN
    outpos = y-linespacing
    return
  ENDIF

  ;; if no positions were passed in then use spaces as positions.
  ;; positions are possible places for breaking the line
  IF n_elements(positions) EQ 0 THEN BEGIN
    n = strlen(str) 
    pos = [0,where(strmid(str,indgen(n-1),replicate(1,n-1)) EQ ' ')+1,n]
  ENDIF ELSE pos = positions

  ;; if colour is a scalar then replicate the current colour
  IF n_elements(col) NE n_elements(pos) THEN $
    col = replicate(col[0],n_elements(pos)) 

  place = 0
  FOR i=0,n_elements(pos)-2  DO BEGIN
    ;; get a substring
    strtemp = strmid(str,pos[place],pos[i+1]-pos[place])
    ;; get the width of the substring
    xyouts,0,-1,charsize=-1,width=w,strtemp,/normal,font=font
    ;; if width is too wide then output the next smaller substring
    IF w GT maxwidth THEN BEGIN
      i--
      ;; if line is longer than the window without any listed break
      ;; points then just output the line and let it go past the end
      ;; of the window
      IF i LT place THEN i++
      strarray = strmid(str,pos[place:i],pos[place+1:i+1]-pos[place:i])
      colarray = col[place:i]
      ;; set position for xyouts
      xyouts,x,y,charsize=-1,/normal,' '
      ;; output string using the specified colours
      xyouts,charsize=chars,strarray,/normal,color=colarray,font=font
      place = i+1
      y = y-linespacing
    ENDIF 
    ;; substring includes the end of the line
    IF i EQ n_elements(pos)-2 THEN BEGIN
      strarray = strmid(str,pos[place:i],pos[place+1:i+1]-pos[place:i])
      colarray = col[place:i]
      xyouts,x,y,charsize=-1,/normal,' '
      xyouts,charsize=chars,strarray,/normal,color=colarray,font=font
      y = y-linespacing
    ENDIF
  ENDFOR

  ;; update output position
  IF arg_present(outpos) THEN outpos=y

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::execute_text
;;
;; Purpose:
;;   Executes a string array of IDL commands
;;
;; Parameters:
;;   TEXT (required) - string array of IDL commands to be executed.
;;                     The commands do not have to be written in batch
;;                     format, i.e., the '&' is not required at the
;;                     end of the lines.
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::execute_text, text
  compile_opt idl2, hidden

  newText = ''
  FOR i=0,n_elements(text)-1 DO BEGIN
    ;; remove comments and excess whitespaces
    str = strtrim(strcompress((strsplit(' '+text[i],';',/extract))[0]),2)
    IF str NE '' THEN BEGIN
      ;; add a '&' character at the end of each completed line
      IF ((pos=strpos(str,'$',/reverse_search))) EQ -1 THEN BEGIN
        str += ' & '
      ENDIF ELSE BEGIN
        str = strmid(str,0,pos)
      ENDELSE
      ;; add to newText array
      newText = [newText,str]
    ENDIF
  ENDFOR
  n = n_elements(newText)
  ;; remove '&' from the last line
  newText[n-1] = strmid(newText[n-1],0,strlen(newText[n-1])-3)
  
  oWindow = self.OGwin
  ;; execute the text

  ;; save current colour table
  tvlct,slideshow_red,slideshow_green,slideshow_blue,/get
  ;; load default gray scale colour table
  loadct,0,/silent

  ;; execute the text
  void = execute(strjoin(newText))

  ;; restore colour table
  tvlct,slideshow_red,slideshow_green,slideshow_blue

  resolve_all

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::chromacode
;;
;; Purpose:
;;   Defines positions and colour indices for proper chromacoding of
;;   an array of IDL code lines.
;;
;; Parameters:
;;   TEXT (required) - Array of IDL code lines
;;
;;   POSITIONS (output) - Array of pointers to int arrays, one for
;;                        each line in TEXT, denoting the positions in
;;                        the strings where a change in colour occurs
;;
;;   TYPES (output) - Array of pointers to int arrays, one for each
;;                    line in TEXT, denoting the type index (1-9) that
;;                    begins at the corresponding position.  To match
;;                    the IDLDE, the following colours are suggested:
;;
;;                    type code - name (colour)
;;                    0 - reserved for background colour
;;                    1 - system procedures (navy: [0,0,128])
;;                    2 - system functions (royal blue: [0,0,255])
;;                    3 - user procedures (teal: [0,128,128])
;;                    4 - user functions (cyan: [0,255,255])
;;                    5 - strings (red: [255,0,0])
;;                    6 - numbers (olive drab: [128,128,0])
;;                    7 - reserved words (maroon: [128,0,0])
;;                    8 - comments (medium green: [0,128,0])
;;                    9 - other (black: [0,0,0])
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::chromacode, text, positions, types
  compile_opt idl2, hidden

  ;; create arrays of routine names to be chromacoded
  usrProcedures = routine_info()
  usrFunctions = routine_info(/functions)

  ;; characters that can be used to delineate words and numbers
  specialChars = [' ',string(9b),',','/',"'",'\[','\]','\\','`','-','=', $
                  '<','>','\?','\*','\+',':','"','{','}','\|','~','!', $
                  '@','#','$','%','\^','&','\(','\)','_']

  FOR i=0,n_elements(text)-1 DO BEGIN

    ;; if current string is a null string, add empty pointers to the
    ;; output variables
    IF strlen(text[i]) EQ 0 THEN BEGIN
      positionsTemp = n_elements(positionsTemp) EQ 0 ? ptr_new(-1) $
        : [positionsTemp,ptr_new(-1)]
      typesTemp = n_elements(typesTemp) EQ 0 ? ptr_new(-1) $
        : [typesTemp,ptr_new(-1)]
      positions = positionsTemp
      types = typesTemp
      CONTINUE
    ENDIF 

    ;; set mask bitstring and do initial parsing of the string
    mask = bytarr(strlen(text[i]))+1b
    pos = strsplit(text[i],strjoin(specialChars,'|'),/regex)
    str = strupcase(strsplit(text[i],strjoin(specialChars,'|'), $
                             /regex,/extract))

    ;; find comments
    commentPos = strpos(text[i],';')
    IF commentPos NE -1 THEN BEGIN
      mask[commentPos:*] = 0b
    ENDIF 

    ;; find quotes (')
    quote = 0
    currentPos = 0
    quotePos = intarr(2,100)-1
    quoteSearch = 1
    WHILE quoteSearch && currentPos LT strlen(text[i]) DO BEGIN
      txt = strmid(text[i],currentPos)
      quotePos[0,quote] = stregex(txt,"'[^']*(('')*[^']*)*'",length=len)
      IF quotePos[0,quote] NE -1 THEN BEGIN
        quotePos[0,quote] += currentPos
        quotePos[1,quote] = quotePos[0,quote]+len
        currentPos = quotePos[1,quote++]+1
      ENDIF ELSE quoteSearch = 0
    ENDWHILE 

    ;; find quotes (")
    quote = (where(quotePos[1,*] LE 0))[0]
    currentPos = 0
    quoteSearch = 1
    WHILE quoteSearch && currentPos LT strlen(text[i]) DO BEGIN
      txt = strmid(text[i],currentPos)
      quotePos[0,quote] = stregex(txt,'"[^"]*(("")*[^"]*)*"',length=len)
      IF quotePos[0,quote] NE -1 THEN BEGIN
        quotePos[0,quote] += currentPos
        quotePos[1,quote] = quotePos[0,quote]+len
        currentPos = quotePos[1,quote++]+1
      ENDIF ELSE quoteSearch = 0
    ENDWHILE 

    ;; find numbers
    numberPos = intarr(2,100)-1
    number = 0
    currentPos = 0
    numberSearch = 1
    WHILE numberSearch && currentPos LT strlen(text[i]) DO BEGIN
      txt = strmid(text[i],currentPos)
      numberPos[0,number] = stregex(txt,'([0-9]+\.?[0-9]*|\.[0-9]+)' + $
                                    '([de][+-][0-9]+)?' + $
                                    '(b|s|d|e|ull|ul|ll|l|us|u)?',length=len)
      IF numberPos[0,number] NE -1 THEN BEGIN
        numberPos[0,number] += currentPos
        numberPos[1,number] = numberPos[0,number]+len
        currentPos = numberPos[1,number++]+1
      ENDIF ELSE numberSearch = 0
    ENDWHILE 

    ;; determine type of text
    posLine = [-1]
    typeLine = [-1]
    FOR j=0,n_elements(pos)-1 DO BEGIN
      IF mask[pos[j]] THEN BEGIN
        type = 9
        IF (where(str[j] EQ *self.sysProcedures))[0] NE -1 THEN type=1
        IF (where(str[j] EQ *self.sysFunctions))[0] NE -1 THEN type=2
        IF (where(str[j] EQ usrProcedures))[0] NE -1 THEN type=3
        IF (where(str[j] EQ usrFunctions))[0] NE -1 THEN type=4
        IF (where(str[j] EQ *self.reserved))[0] NE -1 THEN type=7
        IF stregex(str[j],'[0-9]') NE -1 THEN type=6
        IF type NE 9 THEN BEGIN
          endpos = stregex(strmid(text[i],pos[j]+1),strjoin(specialChars,'|'))
          posLine = [posLine,pos[j],endpos+pos[j]+1]
          typeLine = [typeLine,type,9]
        ENDIF ELSE BEGIN
          posLine = [posLine,pos[j]]
          typeLine = [typeLine,type]
        ENDELSE 
      ENDIF
    ENDFOR

    ;; adjust positions and types for numbers
    k = -1
    WHILE numberPos[0,++k] GE 0 DO BEGIN
      posLine = [posLine,numberPos[*,k]]
      typeLine = [typeLine,6,9]
      wh = where(posLine GT numberPos[0,k] AND posLine LT numberPos[1,k])
      IF wh[0] NE -1 THEN BEGIN
        ;; remove positions that occur inside a number
        posLine = [posLine[0:min(wh)-1], $
                   posLine[max(wh)+1 < n_elements(posLine)-1 :*]]
        typeLine = [typeLine[0:min(wh)-1], $
                    typeLine[max(wh)+1 < n_elements(typeLine)-1 :*]]
      ENDIF
    ENDWHILE

    ;; adjust positions and types for strings
    k = -1
    WHILE quotePos[0,++k] GE 0 DO BEGIN
      posLine = [posLine,quotePos[*,k]]
      typeLine = [typeLine,5,9]
      wh = where(posLine GT quotePos[0,k] AND posLine LT quotePos[1,k])
      IF wh[0] NE -1 THEN BEGIN
        ;; remove positions that occur between quote pairs
        posLine = [posLine[0:min(wh)-1],posLine[max(wh)+1:*]]
        typeLine = [typeLine[0:min(wh)-1],typeLine[max(wh)+1:*]]
      ENDIF
    ENDWHILE

    ;; adjust positions and types for comments
    IF commentPos NE -1 THEN BEGIN
      wh = where(posLine GT commentPos)
      IF wh[0] NE -1 THEN BEGIN
        ;; remove positions that occur after the comment
        posLine = posLine[0:wh[0]-1]
        typeLine = typeLine[0:wh[0]-1]
      ENDIF
      posLine = [posLine,commentPos]
      typeLine = [typeLine,8]
    ENDIF 

    ;; sort positions
    typeLine = typeLine[sort(posLine)]
    posLine = posLine[sort(posLine)]

    ;; collapse lines to remove consecutive positions with identical
    ;; types
    indices = where(typeline ne [0,typeline])
    typeLine = typeLine[indices[1:*]]
    posLine = posLine[indices[1:*]]
    IF posLine[0] NE 0 THEN BEGIN
      IF typeLine[0] EQ 9 THEN BEGIN
        posLine[0] = 0
      ENDIF ELSE BEGIN
        posLine = [0,posLine]
        typeLine = [9,typeLine]
      ENDELSE 
    ENDIF

    ;; ensure posLine starts and ends with the correct positions
    n = n_elements(posLine)-1
    s = strlen(text[i])
    IF posLine[n] NE s THEN BEGIN
      IF posLine[n] LT s THEN BEGIN
        posLine = [posLine,s]
        typeLine = [typeLine,9]
      ENDIF ELSE BEGIN
        posLine[n] = s
      ENDELSE 
    ENDIF 

    ;; add position and type arrays to output pointers
    positionsTemp = n_elements(positionsTemp) EQ 0 ? ptr_new(posLine) $
      : [positionsTemp,ptr_new(posLine)]
    typesTemp = n_elements(typesTemp) EQ 0 ? ptr_new(typeLine) $
      : [typesTemp,ptr_new(typeLine)]
    positions = positionsTemp
    types = typesTemp
    
  ENDFOR

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::expandTextWindow
;;
;; Purpose:
;;   Adds space to the text window, adding scroll bars if necessary,
;;   if the text were to run off the bottom of the current window
;;
;; Parameters:
;;   YPOS (required) - float: current text position
;;
;;   IN_LINE_SPACING - distance between lines, in normal coordinates
;;
;; Keywords:
;;   NONE
;;
PRO IDLDemoSlideshow::expandTextWindow,ypos,in_line_spacing
  compile_opt idl2, hidden

  ;; get current window geometry
  info = widget_info(self.wText,/geometry)
  ;; convert current output location into pixels
  yPix = ypos*info.draw_ysize
  ;; add 33% to old window size
  newYsize = info.draw_ysize*1.33
  widget_control,self.wText,draw_xsize=self.textxsize-self.scrollbarwidth, $
                 draw_ysize=newYsize
  ;; set window
  win = !d.window
  widget_control,self.wText,get_value=wID
  wset,wID
  ;; make colour of newly added portion the same as the background of
  ;; the rest of the window
  tv,bytarr(self.textxsize,newYsize-info.draw_ysize)+11b
  wset,win
  ;; calculate new output location and line spacing values
  ypos = (yPix+(newYsize-info.draw_ysize))/newYsize
  in_line_spacing = 1.5*!d.y_ch_size/newYsize

END 

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::slide_display_text
;;
;; Purpose:
;;   Displays the text of the given slide.  Text can be in one of
;;   three formats, simple text, IDL code (chromacoded but not
;;   executed), or IDL code (chromacoded and executed).
;;
;; Parameters:
;;   WTEXT (required) - long int: window ID to be used via wset
;;
;;   STRLINE_PTR (required) - array of pointers to strings: text to be
;;                            displayed
;;
;;   TYPE_PTR (required) - array of pointers to ints: type code of
;;                         each line of text in STRLINE_PTR denoted
;;                         by the following values:
;;
;;                         0 - descriptive text
;;                         1 - IDL code, not to be executed
;;                         2 - IDL code that needs to be executed
;;
;; Keywords:
;;   SHOW_GRAPHIC (output) - boolean int: output denoting whether or
;;                           not a graphic still needs to be displayed
;;                           on the right hand side of the slide
;;                           viewer.  A '0' indicates that there was
;;                           input text that was executed that should
;;                           have produced a graphical output
;;
PRO IDLDemoSlideshow::slide_display_text,wTextID,strline_ptr,type_ptr,show_graphic=sg
  compile_opt idl2, hidden

  strline = *strline_ptr
  type = *type_ptr
  typePos = [0,uniq(type)+1]
  IF max(typePos) NE n_elements(type) THEN $
    typePos = [typePos,n_elements(type)]

  ;; save current window and colour states
  win = !d.window
  wset,wTextID
  device,get_current_font=fnt

  ;; load colours for chromacoding
  device,decomposed=0
  tvlct,[  0,  0,  0,  0,255,128,128,  0,  0,128,255], $
        [  0,  0,128,255,  0,128,  0,128,  0,  0,255], $
        [128,255,128,255,  0,  0,  0,  0,  0,128,255],1

  ;; reset text window
  widget_control,self.wText,update=0
  widget_control,self.wText,draw_xsize=10,draw_ysize=10
  widget_control,self.wText,draw_xsize=self.textxsize,draw_ysize=self.ysize
  widget_control,self.wText,update=1
  erase,11

  ;; set values for text output
  xpos = 0.00
  maxwidth = 1.-2*xpos-0.08
  bottom = 0.05
  font = 0
  textFont = (!version.os_family EQ 'Windows' ? 'Times New Roman*16' : 'fixed')
  codeFont = (!version.os_family EQ 'Windows' ? 'Courier New*16' : 'fixed')

  sg = 1
  
  ;; if using device fonts, replace all '!' with '!!'
  IF font EQ 0 THEN $
    FOR i=0,n_elements(strline)-1 DO  $
    strline[i] = strjoin(strsplit(strline[i],'!',/extract),'!!')

  FOR i=0,n_elements(typePos)-2 DO BEGIN
    strtemp = strline[typePos[i]:(typePos[i+1]-1 > 0)]
    typetemp = type[typePos[i]]
    CASE typetemp OF
      ;; descriptive text
      0 : BEGIN
        device,set_font=textFont
        ;; set values for starting position and line spacing
        IF i EQ 0 THEN ypos = (self.ysize-2.5*!d.y_ch_size)/self.ysize
        in_line_spacing = 1.5*!d.y_ch_size/self.ysize
        FOR j=0,n_elements(strtemp)-1 DO BEGIN
          self->wrapline,strtemp[j],maxwidth,in_line_spacing,xpos,ypos, $
            font=font,color=10,outpos=outpos
          ypos = outpos
          IF ypos LT bottom THEN self->expandTextWindow,ypos,in_line_spacing
        ENDFOR
      END
      ;; code text (not executed)
      1 : BEGIN
        device,set_font=codeFont
        ;; set values for starting position and line spacing
        IF i EQ 0 THEN ypos = (self.ysize-2.5*!d.y_ch_size)/self.ysize
        in_line_spacing = 1.5*!d.y_ch_size/self.ysize
        self->chromacode,strtemp,pos,types
        FOR j=0,n_elements(strtemp)-1 DO BEGIN
          self->wrapline,strtemp[j],maxwidth,in_line_spacing,xpos,ypos, $
            font=font,color=*types[j],positions=*pos[j],outpos=outpos
          ypos = outpos
          IF ypos LT bottom THEN self->expandTextWindow,ypos,in_line_spacing
        ENDFOR
        ptr_free,pos,types
      END
      ;; code text that need to be executed
      2 : BEGIN 
        sg = 0
        device,set_font=codeFont
        ;; set values for starting position and line spacing
        IF i EQ 0 THEN ypos = (self.ysize-2.5*!d.y_ch_size)/self.ysize
        in_line_spacing = 1.5*!d.y_ch_size/self.ysize
        wset,self.DGwin
        self->execute_text,strtemp
        wset,wTextID
        self->chromacode,strtemp,pos,types
        FOR j=0,n_elements(strtemp)-1 DO BEGIN
          self->wrapline,strtemp[j],maxwidth,in_line_spacing,xpos,ypos, $
            font=font,color=*types[j],positions=*pos[j],outpos=outpos
          ypos = outpos
          IF ypos LT bottom THEN self->expandTextWindow,ypos,in_line_spacing
        ENDFOR
        ptr_free,pos,types
      END 
    ENDCASE 
  ENDFOR 

  ;; restore current window states
  device,set_font=fnt
  wset,win

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::slide_display
;;
;; Purpose:
;;   For the current slide, map appropriate graphics window and calls
;;   user procedures, graphics displays, and text display routines, as
;;   needed 
;;
;; Parameters:
;;   None
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::slide_display
  compile_opt idl2, hidden

  slide = self.slides[self.n]

  ;; reset object graphics window
  self.OGwin->getProperty,graphics_tree=oView
  obj_destroy,oView
  ;; reset slideshow object graphics widget
  widget_control,self.oOGwin,event_PRO='IDLDemoSlideshow_graphic_event', $
                 event_func='', $
                 draw_motion_events=0,draw_button_events=0, $
                 draw_expose_events=0,draw_viewport_events=0, $
                 tracking_events=0
  ;; reset slideshow direct graphics widget
  widget_control,self.oDGwin,event_PRO='IDLDemoSlideshow_graphic_event', $
                 event_func='', $
                 draw_motion_events=0,draw_button_events=0, $
                 draw_expose_events=0,draw_viewport_events=0, $
                 tracking_events=0
  ;; reset direct graphics window and save state
  window = !d.window
  tvlct,r,g,b,/get  
  device,get_decomposed=dec
  wset,self.DGwin
  erase

  ;; display proper graphics window
  widget_control,self.oDGwin,map=slide.graphics_level NE 2
  widget_control,self.oOGwin,map=slide.graphics_level EQ 2

  ;; display slide text
  self->slide_display_text,self.wTextID,slide.strline,slide.type, $
    show_graphic=sg

  IF sg THEN BEGIN
    ;; if graphic window still needs to be updated, e.g., if the text
    ;; was not executed text...
    flag = 0
    
    IF slide.program THEN BEGIN
      ;; if a program was specified, call it
      IF ((programPath=self->validfile(slide.program))) THEN BEGIN
        ;; separate path from the program name
        program = file_basename(programPath,'.pro',/fold_case)
        programDir = file_dirname(programPath)
        ;; change into the needed directory
        cd,programDir,current=currentDir
        ;; compile the needed routine
        resolve_routine,program,/no_recompile
        ;; change back to old directory
        cd,currentDir
        ;; call idl procedure for graphics display
        IF slide.graphics_level EQ 0 THEN $
          call_procedure,program,self.oDGwin $
        ELSE $
          call_procedure,program,self.oOGwin,self.OGwin
        flag = 1
      ENDIF
    ENDIF
    
    IF ((file=self->validfile(slide.graphic))) && ~flag THEN BEGIN
      ;; if we still need a graphic, display the image specified
      self->showImage,self->get_image(file),self.DGwin
      flag = 1
    ENDIF
    
    IF ~flag THEN BEGIN
      ;; if all else fails, try to display the default image
      self->showImage,*self.default_graphic,self.DGwin
    ENDIF
  ENDIF

  ;; reset current window
  device,decomposed=dec
  tvlct,r,g,b
  wset,window

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::update_buttons
;;
;; Purpose:
;;   De/sensitizes the buttons, as needed
;;
;; Parameters:
;;   None
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::update_buttons
  compile_opt idl2, hidden
  
  ;; if on first slide you cannot go back,
  ;; if on last slide you cannot go forward or start autoplay
  widget_control,self.wStart,sensitive=self.n NE 0
  widget_control,self.wPrev,sensitive=self.n NE 0
  widget_control,self.wNext,sensitive=self.n NE self.n_slides-1
  widget_control,self.wEnd,sensitive=self.n NE self.n_slides-1
  widget_control,self.wPlay,sensitive=self.n NE self.n_slides-1

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::get_image
;;
;; Purpose:
;;   reads in an image file and stores it in an image structure for
;;   use with the to_tree_bitmap function
;;
;; Parameters:
;;   IMAGEPATH (required) - valid filename of the image, optionally as
;;                          a comma delineated relative path if root
;;                          is specified 
;;
;; Keywords:
;;   ROOT - root directory to use in filepath
;;
FUNCTION IDLDemoSlideshow::get_image,imagepath,root=root
  compile_opt idl2, hidden

  IF n_elements(root) NE 0 THEN BEGIN
    ;; build path using root
    imagestr = strsplit(imagepath,',',/extract)
    IF n_elements(imagestr) GT 1 THEN $
      subdir=imagestr[0:n_elements(imagestr)-2]
    imagefile = filepath(imagestr[n_elements(imagestr)-1],root=root, $
                         subdirectory=subdir)
    IF self->validfile(imagefile,/fullpath) NE '' THEN $
      image = read_image(imagefile,r,g,b)
  ENDIF ELSE BEGIN
    ;; assume path is a fully qualified path
    IF self->validfile(imagepath,/fullpath) NE '' THEN $
      image = read_image(imagepath,r,g,b)
  ENDELSE

  ;; return image, and colour tables, if one was found
  IF size(image,/type) NE 0 THEN $
    return,{image:image,r:n_elements(r)EQ 0?0:r,b:n_elements(b)EQ 0?0:b, $
            g:n_elements(g)EQ 0?0:g} $
  ELSE return, {image:0,r:0,g:0,b:0}

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::showImage
;;
;; Purpose:
;;   displays an image in a direct graphics window taking into account
;;   the bit-depth of the image and the decomposed value of the system
;;
;; Parameters:
;;   IMAGE (required) - structure (returned from get_image) of the image
;;
;;   WID (required) - widget ID of a direct graphics draw widget
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::showImage,image,wID
  compile_opt idl2, hidden

  IF n_elements(image.image) EQ 1 THEN return
  wset,wID
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

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::validfile
;;
;; Purpose:
;;   returns a full valid file path if the file exists, assuming a
;;   root of the demo root
;;
;; Parameters:
;;   FILESTR (required) - filename of the image
;;
;; Keywords:
;;   FULLPATH - set this keyword to indicate that the filename already
;;              contains a fully qualified path
;;
FUNCTION IDLDemoSlideshow::validfile,filestr,FULLPATH=fullpath
  compile_opt idl2, hidden

  IF keyword_set(fullpath) || filestr EQ '' THEN BEGIN
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
      file = file_which(filename,/include_current_dir)
      IF (file_info(file)).exists THEN return,file
      sub = ''
    ENDELSE
    ;; create full filepath name
    file = filepath(filename,root=self.slideshow_root,subdirectory=sub)
    IF (file_info(file)).exists EQ 0 THEN BEGIN
      subdir = ['examples','demo','demoslideshow']
      IF sub NE '' THEN subdir=[subdir,sub]
      file = filepath(filename,subdirectory=subdir)
    ENDIF 
  ENDELSE

  ;; if file exists, return the name, else return a null string
  return,(file_info(file)).exists ? file : ''

END

;;----------------------------------------------------------------------------
;; demo_slideshow_kill
;;
;; Purpose:
;;   routine called when user kills window
;;
;; Parameters:
;;   wID (required) - widget ID of the top level base
;;
;; Keywords:
;;   None
;;
PRO demo_slideshow_kill,wID
  compile_opt idl2, hidden

  widget_control,wID,get_uvalue=self
  IF obj_valid(self) THEN obj_destroy,self

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow_graphic_event
;;
;; Purpose:
;;   Event handler.  
;;
;; Parameters:
;;   EVENT (required) - an IDL event structure
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow_graphic_event,event
  compile_opt idl2, hidden

  ;; pass event to object's event handler
  widget_control,event.top,get_uvalue=self
  self->graphic_event,event

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::graphic_event
;;
;; Purpose:
;;   Event handler for the slideshow graphics windows.  Saves window
;;   state, passes event to specified event handler (if specified),
;;   and resets window states
;;
;; Parameters:
;;   EVENT (required) - an IDL event structure
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::graphic_event,event
  compile_opt idl2, hidden

  IF self.slides[self.n].event_pro NE '' THEN BEGIN
    window = !d.window
    wset, self.slides[self.n].graphics_level EQ 2 ? self.OGwin : self.DGwin
    tvlct,r,g,b,/get
    device,get_decomposed=dec

    call_procedure,self.slides[self.n].event_pro,event

    device,decomposed=dec
    tvlct,r,g,b
    wset,window
  ENDIF 

END

;;----------------------------------------------------------------------------
;; demo_slideshow_event
;;
;; Purpose:
;;   Event handler.  Destroys TLB if needed, otherwise passes event
;;   onto the objects event handler
;;
;; Parameters:
;;   EVENT (required) - an IDL event structure
;;
;; Keywords:
;;   None
;;
PRO demo_slideshow_event,event
  compile_opt idl2, hidden

  IF widget_info(event.id,/uname) EQ 'stop' THEN BEGIN
    widget_control,event.top,/destroy
    return
  ENDIF
  ;; pass event to object's event handler
  widget_control,event.top,get_uvalue=self
  self->event,event

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::slide_exit
;;
;; Purpose:
;;   Calls the graphics event handler when leaving the slide
;;
;; Parameters:
;;   None
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::slide_exit
  compile_opt idl2, hidden

  IF self.slides[self.n].event_pro NE '' THEN BEGIN
    ID = self.slides[self.n].graphics_level EQ 2 ? self.oOGwin : self.oDGwin
    exitEvent = {SLIDE_EXIT, ID:ID, TOP:self.tlb, HANDLER: ID}
    call_procedure,self.slides[self.n].event_PRO,exitEvent
  ENDIF 

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::event
;;
;; Purpose:
;;   Event handler for the slideshow object
;;
;; Parameters:
;;   EVENT (required) - an IDL event structure
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::event,event
  compile_opt idl2, hidden

  IF TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_TIMER' THEN BEGIN
    IF ~self.autoplay THEN return
    IF self.n LT self.n_slides-1 THEN BEGIN
      ;; notify slide that a different slide is about to be displayed
      self->slide_exit
      ;; go to next slide
      self.n++
      ;; update displays
      widget_control,self.labelNum,set_value=string(self.n+1,format='(I3)')
      self->slide_display
      self->update_buttons
    ENDIF
    IF self.n EQ self.n_slides-1 THEN BEGIN
      ;; if on last slide, turn off autoplay
      self.autoplay = 0
      widget_control,self.wPlay,set_value='AutoPlay'
      return
    ENDIF 
    ;; set timer for next slide update
    widget_control,event.id,timer=self.delay
    return
  ENDIF 

  CASE widget_info(event.id,/uname) OF
    'start' : BEGIN
      ;; notify slide that a different slide is about to be displayed
      IF self.n NE 0 THEN self->slide_exit
      ;; go to first slide
      self.n = 0
    END
    'end' : BEGIN
      ;; notify slide that a different slide is about to be displayed
      IF self.n NE self.n_slides-1 THEN self->slide_exit
      ;; go to last slide
      self.n = self.n_slides-1
    END
    'prev' : BEGIN
      ;; notify slide that a different slide is about to be displayed
      IF self.n NE 0 THEN self->slide_exit
      ;; go to previous slide
      ((self.n>=1))--
    END 
    'next' : BEGIN
      ;; notify slide that a different slide is about to be displayed
      IF self.n NE self.n_slides-1 THEN self->slide_exit
      ;; go to next slide
      ((self.n<=self.n_slides-2))++
    END 
    'delay' : BEGIN
      ;; set delay factor
      widget_control,self.wDelay,get_value=delay
      self.delay = delay
      return
    END 
    'play' : BEGIN
      ;; start/stop autoplay
      IF self.n NE self.n_slides-1 THEN BEGIN
        self.autoplay = ~self.autoplay
        widget_control,self.wPlay,set_value= $
                       (self.autoplay ? 'Pause' : 'AutoPlay')
        ;; set timer for next slide update
        IF self.autoplay THEN widget_control,event.id,timer=self.delay
      ENDIF 
      return
    END
  ENDCASE

  ;; update displays
  widget_control,self.labelNum,set_value=string(self.n+1,format='(I3)')
  self->slide_display
  self->update_buttons
    
END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::Error
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
PRO IDLDemoSlideshow::Error,ID,LineNumber,ColumnNumber,Message
  compile_opt idl2, hidden

  self->stopParsing
  self.invalidparse = 1
  st=['Error reading input file: '+self.slideshow_filename, $
      Message, $
      'Line '+strtrim(LineNumber,2)+', Column '+strtrim(ColumnNumber,2)]
  void = dialog_message(st,/error,title='Error in IDL Demo System')

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::FatalError
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
PRO IDLDemoSlideshow::FatalError,ID,LineNumber,ColumnNumber,Message
  compile_opt idl2, hidden

  self->stopParsing
  self.invalidparse = 1
  st=['Error reading input file: '+self.slideshow_filename, $
      Message, $
      'Line '+strtrim(LineNumber,2)+', Column '+strtrim(ColumnNumber,2)]
  void = dialog_message(st,/error,title='Error in IDL Demo System')

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::characters
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
PRO IDLDemoSlideshow::characters,chars
  compile_opt idl2, hidden

  ;; convert to byte to remove leading and trailing returns, then
  ;; split the string into lines
  byt = byte(chars)
  IF byt[0] EQ 10b THEN byt=byt[1:*]
  len = n_elements(byt)
  IF byt[len-1] EQ 10b THEN byt=byt[0:len-2]
  chars = string(byt)
  str = strsplit(chars,string(10b),/extract,/preserve_null)

  SWITCH 1b OF
    self.in_default_graphic : BEGIN
      ;; set default slide graphic
      self.default_graphic = ptr_new(self->get_image(self->validfile(str)))
    END
    self.in_title : BEGIN
      ;; set slideshow title
      self.title = str[0]
      BREAK
    END
    self.in_program : BEGIN
      ;; set program name
      self.slides[self.current_slide].program = str[0]
      BREAK
    END
    self.in_graphic : BEGIN
      ;; set graphic image
      self.slides[self.current_slide].graphic = str[0]
      BREAK
    END
    self.in_text : 
    self.in_code : 
    self.in_idlcode : BEGIN
      ;; if in either text or code, add the lines of text, with the
      ;; appropriate type code, to the given slide's text and type
      ;; arrays
      IF strtrim(chars,2) NE '' THEN BEGIN
        IF ptr_valid(self.slides[self.current_slide].type) EQ 0 THEN BEGIN
          self.slides[self.current_slide].type = $
            ptr_new(replicate(self.type,n_elements(str)))
          self.slides[self.current_slide].strline = ptr_new([str])
        ENDIF ELSE BEGIN
          (*self.slides[self.current_slide].type) = $
            [(*self.slides[self.current_slide].type), $
             replicate(self.type,n_elements(str))]
          (*self.slides[self.current_slide].strline) = $
            [(*self.slides[self.current_slide].strline),str]
        ENDELSE
      ENDIF
      BREAK
    END 
    ELSE :
  ENDSWITCH

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::endElement
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
PRO IDLDemoSlideshow::endElement,void1,void2,name
  compile_opt idl2, hidden

  CASE name OF
    'DIMENSIONS' : BEGIN
      self.in_dimensions = 0b
    END  
    'AUTOPLAY' : BEGIN
      self.in_autoplay = 0b
    END  
    'TITLE' : BEGIN
      self.in_title = 0b
    END 
    'DEFAULT_GRAPHIC' : BEGIN
      self.in_default_graphic = 0b
    END 
    'SLIDE' : BEGIN
      self.in_slide = 0b
      ;; increment current slide number
      self.current_slide++
    END
    'TEXT' : BEGIN
      self.in_text = 0b
    END
    'CODE' : BEGIN
      self.in_code = 0b
    END
    'IDLCODE' : BEGIN
      self.in_idlcode = 0b
    END
    'PROGRAM' : BEGIN
      self.in_program = 0b
    END
    'GRAPHIC' : BEGIN
      self.in_graphic = 0b
    END
    ELSE :
  ENDCASE

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::startElement
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
PRO IDLDemoSlideshow::startElement,void1,void2,name,attrName,attrValue
  compile_opt idl2, hidden

  CASE name OF
    'DIMENSIONS' : BEGIN
      self.in_dimensions = 1b
      wh = where(attrName EQ 'TEXT_XSIZE')
      IF wh[0] NE -1 THEN self.textxsize = long(attrValue[wh])
      wh = where(attrName EQ 'GRAPHIC_XSIZE')
      IF wh[0] NE -1 THEN self.graphicsxsize = long(attrValue[wh])
      wh = where(attrName EQ 'YSIZE')
      IF wh[0] NE -1 THEN self.ysize = long(attrValue[wh])
    END 
    'AUTOPLAY' : BEGIN
      self.in_autoplay = 1b
      self.delay = fix(attrValue[(where(attrName EQ 'DELAY'))[0]])
    END 
    'TITLE' : BEGIN
      self.in_title = 1b
    END 
    'DEFAULT_GRAPHIC' : BEGIN
      self.in_default_graphic = 1b
    END 
    'SLIDE' : BEGIN
      self.in_slide = 1b
    END
    'TEXT' : BEGIN
      self.in_text = 1b
      self.type = 0
    END
    'CODE' : BEGIN
      self.in_code = 1b
      self.type = 1
    END
    'IDLCODE' : BEGIN
      self.in_idlcode = 1b
      self.type = 2
      ;; set graphics level for current slide
      self.slides[self.current_slide].graphics_level = $
        attrValue[(where(attrName EQ 'GRAPHICS_LEVEL'))[0]]
    END
    'PROGRAM' : BEGIN
      self.in_program = 1b
      ;; set graphics level for current slide
      self.slides[self.current_slide].graphics_level = $
        attrValue[(where(attrName EQ 'GRAPHICS_LEVEL'))[0]]
      wh = where(attrName EQ 'EVENT_PRO')
      IF wh[0] NE -1 THEN $
        self.slides[self.current_slide].event_pro = attrValue[wh]
    END
    'GRAPHIC' : BEGIN
      self.in_graphic = 1b
    END
    ELSE :
  ENDCASE

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::cleanup
;;
;; Purpose:
;;   cleanup routine
;;
;; Parameters:
;;   None
;;
;; Keywords:
;;   None
;;
PRO IDLDemoSlideshow::CleanUp
  compile_opt idl2, hidden

  ;; free pointers
  FOR i=0,n_elements(self.slides)-1 DO begin
    IF ptr_valid(self.slides[i].type) THEN ptr_free,self.slides[i].type
    IF ptr_valid(self.slides[i].strline) THEN ptr_free,self.slides[i].strline
  ENDFOR 
  IF ptr_valid(self.sysProcedures) THEN ptr_free,self.sysProcedures
  IF ptr_valid(self.sysFunctions) THEN ptr_free,self.sysFunctions
  IF ptr_valid(self.reserved) THEN ptr_free,self.reserved
  IF ptr_valid(self.default_graphic) THEN ptr_free,self.default_graphic

  ;; destroy grView, if accessible
  IF obj_valid(self.OGwin) THEN BEGIN
    self.OGwin->getProperty,graphics_tree=oView
    IF obj_valid(oView) THEN obj_destroy,oView
  ENDIF
  ;; calling heap_gc is normally considered poor programming but since
  ;; there is no guarantee that the IDL_CODE in the input file will
  ;; always set the graphics_tree of oWindow and might just call
  ;; oWindow->draw,oView   
  ;; the view could become inaccessible and would not be able to
  ;; be cleaned up any other way. 
  heap_gc

  ;; reset colour table and decomposed value
  device,decomposed=self.decomposed
  tvlct,self.colourTable.r,self.colourTable.g,self.colourTable.b

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow::Init
;;
;; Purpose:
;;   initialization routine for the slideshow object
;;
;; Parameters:
;;   None
;;
;; Keywords:
;;   FILENAME (required) - name of input XML file, either as a file
;;                         found in the IDL path or as a fully
;;                         qualified file.
;;
;;   AUTOPLAY - If set to a positive integer, will start the slideshow
;;              in autoplay mode with the delay set to the number of
;;              seconds specified by AUTOPLAY
;;
;;   ROOT - name of root directory to use when looking for
;;          slideshow[programs,graphics,etc].  If not set, root is set
;;          to the directory in which is found FILENAME. 
;;
FUNCTION IDLDemoSlideshow::Init,filename=filename,autoplay=autoplay,root=root
  compile_opt idl2, hidden

  ;; set input file
  IF ~keyword_set(filename) THEN BEGIN
    message,'Slideshow input file not specified'
    return,-1
  ENDIF 
  IF file_dirname(filename) NE '.' THEN BEGIN
    self.slideshow_filename = filename
  ENDIF ELSE BEGIN
    self.slideshow_filename = file_which(filename,/include_current_dir)
    IF self.slideshow_filename EQ '' THEN $
      self.slideshow_filename = $
      filepath(filename,SUBDIR=['examples','demo','demoslideshows'])
  ENDELSE

  ;; if input file does not exist throw an error and return
  info = file_info(self.slideshow_filename)
  IF info.exists EQ 0 THEN BEGIN
    message,'Slideshow input file not found'
    return,-1
  ENDIF

  ;; set slideshow root directory
  IF keyword_set(root) THEN BEGIN
    self.slideshow_root = root
  ENDIF ELSE BEGIN
    self.slideshow_root = file_dirname(self.slideshow_filename)
  ENDELSE

  ;; set default slide graphic
  self.default_graphic = $
    ptr_new(self->get_image(self->validfile('slideshowgraphics,' + $
                                            'defaultslide.bmp')))

  ;; initialize xml object
  IF self->IDLffXMLSAX::Init() NE 1 THEN return,0

  ;; parse input file
  self->parsefile,self.slideshow_filename
  IF self.invalidparse EQ 1 THEN return,1

  ;; save decomposed and colour tables
  device,get_decomposed=dec
  self.decomposed = dec
  tvlct,r,g,b,/get
  self.colourTable.r = r
  self.colourTable.g = g
  self.colourTable.b = b

  ;; save number of slides
  self.n_slides = self.current_slide

  ;; if autoplay is passed in, set the delay value
  IF self.delay EQ 0 THEN BEGIN
    autoplay = -1
    self.delay = 3
  ENDIF ELSE BEGIN
    autoplay = 1
    self.delay = 1 > self.delay < 10
  ENDELSE 

  ;; set sizes of panels
  ;; defaults are:  text panel - 450x300 ; graphics panels - 300x300
  IF self.textxsize NE 0 THEN $
    textxsize=(self.textxsize > 220) ELSE textxsize=450
  self.textxsize = textxsize
  IF self.graphicxsize NE 0 THEN $
    graphicxsize=(self.graphicxsize > 200) ELSE graphicxsize=300
  self.graphicxsize = graphicxsize
  IF self.ysize NE 0 THEN $
    ysize=(self.ysize > 200) ELSE ysize=300
  self.ysize = ysize

  ;; determine width of vertical scroll bars with temporary widget
  tlb = widget_base(map=0)
  draw = widget_draw(tlb,scr_xsize=200,ysize=300,/scroll, $
                     y_scroll_size=200,x_scroll_size=200)
  widget_control,tlb,/realize
  info = widget_info(draw,/geometry)
  self.scrollbarwidth = info.scr_xsize - info.xsize
  widget_control,tlb,/destroy

  ;; create slideshow widget
  tlb = widget_base(title=self.title NE '' ? self.title : 'IDL Slideshow', $
                    /column,/tlb_size_events,uname='top',tlb_frame_attr=1, $
                    kill_notify='demo_slideshow_kill')
  self.tlb = tlb
  drawbase = widget_base(tlb,/row)
  ;; text window (draw window used with xyouts)
  wText = widget_draw(drawbase,graphics_level=0,xsize=textxsize, $
                      x_scroll_size=textxsize+2,scr_xsize=textxsize+2, $
                      ysize=ysize,y_scroll_size=ysize+2,scr_ysize=ysize+2, $
                      /frame,/scroll)
  self.wText = wText
  ;; create base to hold both graphics windows
  outbase = widget_base(drawbase,/frame)
  DGbase = widget_base(outbase)
  ;; direct graphics window
  oDGwin = widget_draw(DGbase,graphics_level=0,xsize=graphicxsize, $
                       ysize=ysize,event_pro='IDLDemoSlideshow_graphic_event')
  self.oDGwin = oDGwin
  OGbase = widget_base(outbase)
  ;; object graphics window
  oOGwin = widget_draw(OGbase,graphics_level=2,xsize=graphicxsize, $
                       ysize=ysize,event_pro='IDLDemoSlideshow_graphic_event')
  self.oOGwin = oOGwin

  buttonbase = widget_base(tlb,column=3,/grid,scr_xsize=textxsize+graphicxsize)

  leftbase = widget_base(buttonbase,/row,/align_left)
  ;; autoplay delay slider
  self.wDelay = widget_slider(leftbase,minimum=1,maximum=10,uname='delay', $
                              value=self.delay,xsize=125, $
                              title='AutoPlay Delay (sec)')
  sizebase = widget_base(leftbase,/row,ysize=32)
  ;; autoplay button
  self.wPlay = widget_button(sizebase,value='AutoPlay', $
                             tooltip='Autoplay slideshow',uname='play')

  centerbase = widget_base(buttonbase,/row,/align_center,ysize=32)
  ;; text labels
  label1 = widget_label(centerbase,value='Slide ')
  self.labelNum = widget_label(centerbase,value='  1')
  label2 = widget_label(centerbase,value=' of ')
  label3 = widget_label(centerbase,value=string(self.n_slides,format='(I3)'))

  rightbase = widget_base(buttonbase,/row,/align_right,ysize=32)
  ;; first slide
  self.wStart = widget_button(rightbase,value= $
                              self->validfile('slideshowgraphics,start.bmp'), $
                              /bitmap,tooltip='Return to first slide', $
                              uname='start')
  ;; previous slide
  self.wPrev = widget_button(rightbase,value= $
                             self->validfile('slideshowgraphics,prev.bmp'), $
                             /bitmap,tooltip='Previous slide',uname='prev')
  ;; next slide
  self.wNext = widget_button(rightbase,value= $
                             self->validfile('slideshowgraphics,next.bmp'), $
                             /bitmap,tooltip='Next slide',uname='next')
  ;; last slide
  self.wEnd = widget_button(rightbase,value= $
                            self->validfile('slideshowgraphics,end.bmp'), $
                            /bitmap,tooltip='Jump to last slide',uname='end')
  ;; exit slideshow
  wStop = widget_button(rightbase,value= $
                        self->validfile('slideshowgraphics,stop.bmp'), $
                        /bitmap,tooltip='Stop and quit slideshow',uname='stop')

  ;; register graphics windows so that wset,-1 will work properly
  dwindow = !d.window
  xmanager,'demo_slideshow',wText,/just_reg
  xmanager,'demo_slideshow',oDGwin,/just_reg
  xmanager,'demo_slideshow',oOGwin,/just_reg
  widget_control,tlb,/realize
  wset,dwindow

  ;; store ids of the windows
  widget_control,wText,get_value=wTextID
  self.wTextID = wTextID
  widget_control,oDGwin,get_value=DGwin
  self.DGwin = DGwin
  widget_control,oOGwin,get_value=OGwin
  self.OGwin = OGwin

  ;; store procedure and function names and reserved words
  self.sysProcedures = ptr_new(routine_info(/system))
  self.sysFunctions = ptr_new(routine_info(/system,/functions))
  self.reserved = ptr_new(['AND','BEGIN','BREAK','CASE','COMMON', $
                           'COMPILE_OPT','CONTINUE','DO','ELSE','END', $
                           'ENDCASE','ENDELSE','ENDFOR','ENDIF','ENDREP', $
                           'ENDSWITCH','ENDWHILE','EQ','FOR', $
                           'FORWARD_FUNCTION','FUNCTION','GE','GOTO','GT', $
                           'IF','INHERITS','LE','LT','MOD','NE','NOT','OF', $
                           'ON_IOERROR','OR','PRO','REPEAT','SWITCH','THEN', $
                           'UNTIL','WHILE','XOR'])

  ;; set uvalue
  widget_control,tlb,set_uvalue=self

  ;; kick off xmanager
  xmanager,'demo_slideshow',tlb,/no_block

  ;; create event to start slide show
  demo_slideshow_event,{top:tlb,id:self.wStart}

  ;; if needed, create event to start autoplay
  IF autoplay GT 0 THEN demo_slideshow_event,{top:tlb,id:self.wPlay}

  return,1

END

;;----------------------------------------------------------------------------
;; IDLDemoSlideshow__define
;;
;; Purpose:
;;   definition routine for the slideshow object
;;
;; Parameters:
;;   NONE
;;
;; Keywords:
;;   NONE
;;
PRO IDLDemoSlideshow__define
  compile_opt idl2, hidden

  max_slides = 500
  slide = {slide,type:ptr_new(),strline:ptr_new(),program:'', $
           graphic:'',graphics_level:0,event_pro:''}
  void = {IDLDemoSlideshow,inherits IDLffXMLSAX, $
          tlb: 0l, $
          current_slide: 0, $
          n: 0, $
          title: '', $
          slides: replicate(slide,max_slides), $
          n_slides: 0l, $
          wText: 0l, $
          wTextID: 0l, $
          oDGwin: 0l, $
          oOGwin: 0l, $
          DGwin: 0l, $
          OGwin: obj_new(), $
          wDelay: 0l, $
          wPlay: 0l, $
          wStart: 0l, $
          wPrev: 0l, $
          wNext: 0l, $
          wEnd: 0l, $
          labelNum: 0l, $
          autoplay: 0b, $
          delay: 0, $
          in_dimensions: 0b, $
          in_autoplay: 0b, $
          in_title: 0b, $
          in_default_graphic: 0b, $
          in_slide: 0b, $
          in_text: 0b, $
          in_code: 0b, $
          in_program: 0b, $
          in_graphic: 0b, $
          in_idlcode: 0b, $
          type: 0, $
          invalidparse: 0b, $
          slideshow_filename: '', $
          slideshow_root: '', $
          default_graphic: ptr_new(), $
          textxsize: 0l, $
          graphicxsize: 0l, $
          ysize: 0l, $
          scrollbarwidth: 0l, $
          decomposed: 0l, $
          colourTable: {colours,r:bytarr(256),g:bytarr(256),b:bytarr(256)}, $
          sysProcedures: ptr_new(), $
          sysFunctions: ptr_new(), $
          reserved: ptr_new() $
         }

END
