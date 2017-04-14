/*
'  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
'       rights reserved. Unauthorized reproduction is prohibited.
'
'+
'  FILE:
'       hello_example.java
'
'  CALLING SEQUENCE: None.
'
'  PURPOSE:
'       Demonstrates how to use the stock Java object in a simple Hello
'       World application that relies on the stock methods of the wrapper object.
'       For instructions on using this Java file, search the Online Help index
'       for the name of this file.
'
'  MAJOR TOPICS: Bridges
'
'  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
'       Classpath must reference javaidlb.jar
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
import com.idl.javaidl.*;

public class hello_example implements JIDLOutputListener
{
   // Define ostock as a private member variable
   java_IDL_connect ostock;


   public hello_example( )
   {
      ostock = new java_IDL_connect( );
      ostock.createObject( );
      ostock.addIDLOutputListener( this );
      ostock.executeString("PRINT, 'Hello World!'");
   }

   // cleanup.
   private void destroyWrapper( )
   {
	  ostock.destroyObject( );
   }

   // implement JIDLOutputListener to print IDL output
   public void IDLoutput( JIDLObjectI obj, String sMessage )
   {
      System.out.println( sMessage );
   }

   public static void main( String[] args )
   {
      hello_example example = new hello_example( );
      example.destroyWrapper( );
   }
}
