;  $Id: //depot/idl/IDL_70/idldir/examples/doc/file_io/xml_to_struct__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This object class definition is used as an example in
; the "Using the XML Parser Object Class" chapter of the
; _Building IDL Applications_ manual.

;---------------------------------------------------------------------------
; Init method
; Called when the xmlstruct object is created.

FUNCTION xml_to_struct::Init
   ; Initialize the value of the planetNum counter. This
   ; will be incremented as elements are added to the
   ; Planets array.
   self.planetNum = 0
   RETURN, self->IDLffxmlsax::Init()
END

;---------------------------------------------------------------------------
; Characters method
; Called when parsing character data within an element.
; Adds data to the charBuffer field.

PRO xml_to_struct::characters, data
   self.charBuffer = self.charBuffer + data
END

;---------------------------------------------------------------------------
; StartElement method
; Called when the parser encounters the start of an element.

PRO xml_to_struct::startElement, URI, local, strName, attrName, attrValue

   CASE strName OF
      "Solar_System":   ; Do nothing
      ; Initialize the PLANET structure held in currentPlanet,
      ; and set the Name field of the structure equal to the
      ; value of the first attribute of the <Planet> element.
      "Planet" : BEGIN
         self.currentPlanet = {PLANET, "", 0ull, 0.0, 0}
         self.currentPlanet.Name = attrValue[0]
      END
      ; Reinitialize the charBuffer.
      "Orbit" : self.charBuffer = ''
      "Period" : self.charBuffer = ''
      "Moons" : self.charBuffer = ''
   ENDCASE

END

;---------------------------------------------------------------------------
; EndElement method
; Called when the parser encounters the end of an element.

PRO xml_to_struct::EndElement, URI, Local, strName

   CASE strName of
      "Solar_System":   ; Do nothing
      "Planet": BEGIN
         ; Set element 'planetNum' of the Planets array equal
         ; to the PLANET structure held in currentPlanet.
         self.Planets[self.planetNum] = self.currentPlanet
         ; Increment planetNum counter
         self.planetNum = self.planetNum + 1
      END
      ; Set the value of the appropriate field in the current
      ; PLANET structure equal to the value of charBuffer.
      "Orbit" : self.currentPlanet.Orbit = self.charBuffer
      "Period" : self.currentPlanet.Period = self.charBuffer
      "Moons" : self.currentPlanet.Moons= self.charBuffer
   ENDCASE

END

;---------------------------------------------------------------------------
; GetArray method
; Returns the current array stored internally. If
; no data is available, returns -1.

FUNCTION xml_to_struct::GetArray
   IF (self.planetNum EQ 0) THEN $
      RETURN, -1 $
   ELSE RETURN, self.Planets[0:self.planetNum-1]
END

;---------------------------------------------------------------------------
; Object class definition method.

PRO xml_to_struct__define

   ; Define a useful structure
   void = {PLANET, NAME: "", Orbit: 0ull, period:0.0, Moons:0}

   ; Define the class data structure
   void = {xml_to_struct, $
            INHERITS IDLffXMLSAX, $
            charBuffer : "", $
            planetNum : 0, $
            currentPlanet: {PLANET}, $
            Planets : MAKE_ARRAY(9, VALUE={PLANET}) }

END
