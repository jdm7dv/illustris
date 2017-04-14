;
; Copyright (c) 2002-2008, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
; Purpose: Demonstrate pulling an Image object from Java and displaying it in IDL
;
; Usage:
;    IDL> showgreyimage
;
; Uses:
;    jbexamples.jar (GreyBandsImage.java)
;

pro SHOWGREYIMAGE

  ; Construct the GreyBandImage in Java.  This is a sub-class of BufferedImage.
  ; It is actually a 4 band image that happens to display bands in
  ; greyscale.  It is 100x100 pixels.
  oGrey = obj_new("idljavaobject$greybandsImage", "GreyBandsImage")

  ; Get the 4 byte pixel values
  data = oGrey->getRawData()

  ; get the height and width
  h = oGrey->getH()
  w = oGrey->getW()

  ; Display the graphic in an IDL window
  WINDOW, 0, XSIZE=100, YSIZE=100
  tv, REBIN(data,h,w)

  ; cleanup
  OBJ_DESTROY, oGrey

end
