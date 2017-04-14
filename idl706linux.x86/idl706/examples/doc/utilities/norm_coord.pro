; $Id: //depot/idl/IDL_70/idldir/examples/doc/utilities/norm_coord.pro#2 $
;
; Copyright (c) 1997-2008, ITT Visual Information Solutions. All
;       rights reserved.
;
FUNCTION NORM_COORD, inRange

; This function takes a range vector [min, max] as contained
; in the [XYZ]RANGE property of an object and converts it to
; a scaling vector (suitable for the [XYZ]COORD_CONV property)
; that scales the object to fit in the range [0,1].

; If the input range is double precision, keep it that way.
; Otherwise, convert to single precision floats.
rtype = SIZE(inRange, /TYPE)
if (rtype eq 5) then range = inRange else range = FLOAT(inRange) 

scale = [-range[0]/(range[1]-range[0]), 1/(range[1]-range[0])]

RETURN, scale

END
