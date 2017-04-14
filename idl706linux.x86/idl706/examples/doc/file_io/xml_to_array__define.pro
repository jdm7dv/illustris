;  $Id: //depot/idl/IDL_70/idldir/examples/doc/file_io/xml_to_array__define.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This object class definition is used as an example in
; the "Using the XML Parser Object Class" chapter of the
; _Building IDL Applications_ manual.

;---------------------------------------------------------------------------
; Init method.
; Called when the xml_to_array object is created.

FUNCTION xml_to_array::Init
    self.pArray = PTR_NEW(/ALLOCATE_HEAP)
    RETURN, self->IDLffXMLSAX::Init()
END

;---------------------------------------------------------------------------
; Cleanup method.
; Called when the xml_to_array object is destroyed.

PRO xml_to_array::Cleanup
   ; Release pointer
   IF (PTR_VALID(self.pArray)) THEN PTR_FREE, self.pArray
   ; Call superclass cleanup method
   self->IDLffXMLSAX::Cleanup
END

;---------------------------------------------------------------------------
; StartDocument method
; Called when parsing of the document data begins.
; If the array pointed at by pArray contains data, reinitialize it.

PRO xml_to_array::StartDocument
   IF (N_ELEMENTS(*self.pArray) GT 0) THEN $
      void = TEMPORARY(*self.pArray)
END

;---------------------------------------------------------------------------
; Characters method
; Called when parsing character data within an element.
; Adds data to the charBuffer field.

PRO xml_to_array::characters, data
   self.charBuffer = self.charBuffer + data
END

;---------------------------------------------------------------------------
; StartElement
; Called when the parser encounters the start of an element.

PRO xml_to_array::startElement, URI, local, strName, attr, value

   CASE strName OF
      ; If the array pointed at by pArray contains data, 
      ; reinitialize it.
      "array": BEGIN
         IF (N_ELEMENTS(*self.pArray) GT 0) THEN $
         void = TEMPORARY(*self.pArray); clear out memory
      END
      ; Reinitialize the charBuffer field.
      "number" : BEGIN
         self.charBuffer = ''
      END
   ENDCASE

END

;---------------------------------------------------------------------------
; EndElement method
; Called when the parser encounters the end of an element.

PRO xml_to_array::EndElement, URI, Local, strName

   CASE strName OF
      "array":  ; Do nothing.
      "number": BEGIN
         ; Convert string data to an integer.
         idata = FIX(self.charBuffer);
         ; If the array pointed at by pArray has no elements,
         ; set it equal to the current data.
         IF (N_ELEMENTS(*self.pArray) EQ 0) THEN $
            *self.pArray = iData $
         ; If the array pointed at by pArray contains data
         ; already, extend the array.
         ELSE $
            *self.pArray = [*self.pArray,iData]
      END
   ENDCASE 

END

;---------------------------------------------------------------------------
; GetArray method
; Returns the current array stored internally. If
; no data is available, returns -1.

FUNCTION xml_to_array::GetArray

   IF (N_ELEMENTS(*self.pArray) GT 0) THEN $
     RETURN, *self.pArray $
   ELSE RETURN , -1

END

;---------------------------------------------------------------------------
; Object class definition method.

PRO xml_to_array__define

   void = {xml_to_array, $
           INHERITS IDLffXMLSAX, $
           charBuffer : '', $
           pArray     : PTR_NEW() } 
    
END
