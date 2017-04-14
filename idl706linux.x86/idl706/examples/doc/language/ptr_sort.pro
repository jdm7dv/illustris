;  $Id: //depot/idl/IDL_70/idldir/examples/doc/language/ptr_sort.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; PTR_SORT accepts one arugument, a pointer to the first element
; of a linked list returned by PTR_READ. Note that the PTR_SORT
; program does not need to know how many elements are in the list,
; nor does it need to explicitly know of any pointer other than the first.

pro ptr_sort, first

; Initialize swap flag

swap = 1

; Create an anonymous strucutre to contain list elements. Note that 
; the next field is initialized to be a pointer. Create a pointer to
; this structure, to be used as "swap space."

llist = {name:'', next:PTR_NEW()}
junk = ptr_new(llist)

; Continue the sorting until no swaps are made. If no adjacent 
; elements need to be swapped, the list is in alphabetical order.

WHILE swap NE 0 DO BEGIN

  ; Create a second pointer to the heap variable pointed at by _first_,
  ; and another pointer to the heap variable held in the next field
  ; of _current_.

  current = first
  next = (*current).next
  swap = 0

  ; Continue the sorting until next is no longer a valid pointer.
  ; Note that the null pointer is not a valid pointer.

  WHILE PTR_VALID(next) DO BEGIN

    ; Get values to compare.

    value1 = (*current).name
    value2 = (*next).name

    ; Compare values and exchange if first is greater than second.

    IF (value1 GT value2) THEN BEGIN

      ; Use the "swap space" pointer to exchange the name fields of
      ; _current_ and _next_.

      (*junk).name = (*current).name
      (*current).name = (*next).name
      (*next).name = (*junk).name

      ; Set _current_ to _next_ to advance through the list.

      current = next

      ; Reset swap flag.

      swap = 1

    ; If value1 is less than value2, set _current_ to _next_
    ; to advance through the list.

    ENDIF ELSE current = next

    ; Redefine _next_ pointer.

    next = (*current).next

  ENDWHILE

ENDWHILE

END
