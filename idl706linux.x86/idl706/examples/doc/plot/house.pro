;  $Id: //depot/idl/IDL_70/idldir/examples/doc/plot/house.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO HOUSE

house_x = [0, 16, 16, 8, 0, 0, 16, 16, 8, 0]
house_y = [0, 0, 10, 16, 10, 0, 0, 10, 16, 10]
house_z = [54, 54, 54, 54, 54, 30, 30, 30, 30, 30]
min_x = -4 & max_x = 20
!X.S = [-(-4), 1.]/(20 - (-4))
!Y.S = !X.S
!Z.S = [-10, 1.]/(70 - 10)
face = [INDGEN(5), 0]
PLOTS, house_x(face), house_y(face), house_z(face), /T3D, /DATA
PLOTS, house_x(face + 5), house_y(face + 5), house_z(face + 5), /T3D, /DATA
FOR I = 0, 4 DO PLOTS, [house_x(i), house_x(i + 5)], $
    [house_y(i), house_y(i + 5)], [house_z(i), house_z(i + 5)], /T3D, /DATA
XYOUTS, house_x(3), house_y(3), Z = house_z(3), 'Front', /T3D, /DATA, SIZE = 2
XYOUTS, house_x(8), house_y(8), Z = house_z(8), 'Back', /T3D, /DATA, SIZE = 2

END
