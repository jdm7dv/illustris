;  $Id: //depot/idl/IDL_70/idldir/examples/doc/language/ptr_read.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; PTR_READ accepts one argument, a named variable in which 
; to return the pointer that points at the beginning of the list.

PRO ptr_read, first

; Initialize the input string variable.

newstring = ''

; Create an anonymous strucutre to contain list elements. Note that 
; the next field is initialized to be a null pointer.

llist = {name:'', next:PTR_NEW()}

; Print instructions for this program.

PRINT, 'Enter a list of names.'
PRINT, 'Enter a period (.) to stop list entry.'

; Continue accepting input until a period is entered.

WHILE newstring NE "." DO BEGIN

  ; Read a new string from the key board.

  READ, newstring, PROMPT='Enter string: '

  IF newstring NE '.' THEN BEGIN

    ; Check to see if a pointer called _first_ exists. If not, this
    ; is the first element. Create a pointer called _first_ and
    ; initialize it to be a list element. Create a second pointer
    ; to the heap variable pointed at by _first_.

    IF NOT(PTR_VALID(first)) THEN BEGIN
       first = PTR_NEW(llist)
       current = first
    ENDIF
      
    ; Create a pointer to the next list element.

    next = PTR_NEW({name:'', next:PTR_NEW()})

    ; Set the name field of _current_ to the input string.
      
    (*current).name = newstring

    ; Set the next field of _current_ to the pointer
    ; to the next list element.

    (*current).next = next

    ; Copy the pointer to _current_.

    last = current

    ; Make _next_ the current pointer.

    current = next
  
  ENDIF

ENDWHILE

IF PTR_VALID(next) THEN PTR_FREE, next

; Set the _next_ field of the last element to the null pointer.

IF PTR_VALID(last) THEN (*last).next = PTR_NEW()

END
