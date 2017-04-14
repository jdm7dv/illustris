;  $Id: //depot/idl/IDL_70/idldir/examples/doc/language/ptr_print.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; PTR_PRINT accepts one arugument, a pointer to the first element
; of a linked list returned by PTR_READ. Note that the PTR_PRINT
; program does not need to know how many elements are in the list,
; nor does it need to explicitly know of any pointer other than the first.

PRO ptr_print, first

; Create a second pointer to the heap variable pointed at by _first_.

current = first

; PTR_VALID returns 0 if its argument is not a valid pointer.
; Note that the null pointer is not a valid pointer.

WHILE PTR_VALID(current) DO BEGIN

  ; Print the list element information.

  PRINT, current, ', named ', (*current).name, $
      ', has a pointer to: ', (*current).next

  ; Set _current_ equal to the pointer in its own next field.

  current = (*current).next

ENDWHILE

END
