/*
'  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
'       rights reserved. Unauthorized reproduction is prohibited.
'
'+
'  FILE:
'       arrays_example.java
'
'  CALLING SEQUENCE: None.
'
'  PURPOSE:
'       Demonstrates how to use the stock Java object in a simple Java
'       application that defines arrays, passes them to IDL, multiplies them, and
'       and then returns the result to the Java application using setIDLVariable,
'       executeString and setIDLVariable wrapper object methods. For instructions
'       on using this Java file, search the Online Help index for the name of this file.
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

public class arrays_example implements JIDLOutputListener
{
   // Define ostock as a private member variable
   java_IDL_connect ostock;

   public arrays_example( )
   {
      ostock = new java_IDL_connect( );
      ostock.createObject( );
      ostock.addIDLOutputListener( this );
   }

   private void arrayManipulation(  )
   {
      try {
         String a = "a";
         String b = "b";
         int[] aArray = {0, 1, 2, 3, 4, 5};
         int[] bArray = {5, 4, 3, 2, 1, 0};

         ostock.setIDLVariable(a, new JIDLArray(aArray));
         ostock.setIDLVariable(b, new JIDLArray(bArray));

         ostock.executeString("c = MATRIX_MULTIPLY(a,b)");
         ostock.executeString("HELP, c, /FULL");

         String c = "c";
         int[][] cArray = new int[6][6];

         // Access the array in a JIDLArray and then convert
         // to native array.
         JIDLArray jarray = ( JIDLArray ) ostock.getIDLVariable( c );
         int[][] cjarray = (int[][])jarray.arrayValue( );

         System.out.println("Results of multiplying aArray" );
         for (int i = 0; i < aArray.length; i++) {
            int aVal = aArray[i];
            System.out.print(aVal + " ");
            }
            System.out.println();

         System.out.println("times bArray " );
         for (int i = 0; i < bArray.length; i++) {
            int bVal = bArray[i];
            System.out.print(bVal + " ");
         }
         System.out.println();
         System.out.println("equals: ");
         outputArray(cjarray);
         }

         catch ( JIDLException e ) {
            System.out.println( "Caught an error" );
            e.printStackTrace( );
         }
      }

   // cleanup
   private void destroyWrapper( )
   {
	  ostock.destroyObject( );
   }

   public static void outputArray(int[][] array) {
      int row = array.length;
      int col = array[0].length;

      for(int index2 = 0; index2 < col;index2++) {
         System.out.print("(");
         for(int index1 = 0; index1 < row;index1++) {
            System.out.print(" " + array[index1][index2]);
         }
         System.out.println(" )");
         }
         System.out.println();
      }

   // implement JIDLOutputListener
   public void IDLoutput( JIDLObjectI obj, String sMessage )
   {
      System.out.println( sMessage );
   }

   public static void main( String[] args )
   {
      arrays_example example = new arrays_example( );
      example.arrayManipulation( );
      example.destroyWrapper( );
   }
}
