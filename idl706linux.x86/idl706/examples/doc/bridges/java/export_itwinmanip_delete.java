/*
'  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
'       rights reserved. Unauthorized reproduction is prohibited.
'
'+
'  FILE:
'       export_itwinmanip_delete.java
'
'  CALLING SEQUENCE: None.
'
'  PURPOSE:
'       Demonstrates how to subclass to pass keyboard events to IDL
'       For instructions on using this Java file, search the Online
'       Help index for the name of this file.
'
'  MAJOR TOPICS: Bridges
'
'  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
'       export_itwinmanip_doc__define.pro
'       Export Bridge Assistant needs to be used to generate:
'       export_itwinamnip_doc directory which contains
'          export_itwinmanip_doc.java
'          export_itwinmanip_doc.class
'       export_itwinmanip_doc_example.java is the main Java application file.
'
'  NAMED STRUCTURES:
'       none.
'
'  COMMON BLOCS:
'       none.
'
'  MODIFICATION HISTORY:
'       1/06,   SM - written
'-
'-----------------------------------------------------------------
*/
package export_itwinmanip_doc;

import com.idl.javaidl.*;
import java.awt.event.*;

   // subclass to handle keyboard events
   public class export_itwinmanip_delete extends export_itwinmanip_doc
   {

       public void IDLkeyPressed(JIDLObjectI obj, KeyEvent e, int x, int y){
          // pass to IDL where it will handle delete key press.
		  super.IDLkeyPressed(obj, e, x, y);
       }

       public void IDLkeyReleased(JIDLObjectI obj, KeyEvent e, int x, int y) {
          //  Nothing
       }

      public static void main( String[] argv ) {
         export_itwinmanip_delete example = new export_itwinmanip_delete( );
      }
  }
