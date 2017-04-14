/*
  Copyright (c) 2002-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
 */

//
// array2d: object for demonstrating array passing between IDL and Java
//

public class array2d 
{
 short[][]   m_as;
 long[][]    m_aj;

 // ctor
 public array2d() {
   int SIZE1 = 3;
   int SIZE2 = 4;

   // default ctor creates a fixed number of elements
   m_as = new short[SIZE1][SIZE2];
   m_aj = new long[SIZE1][SIZE2];

   for (int i=0; i<SIZE1; i++) {
     for (int j=0; j<SIZE2; j++) {
       m_as[i][j] = (short)(i*10+j);
       m_aj[i][j] = (long)(i*10+j);
     }
   }

 }


 // Mutators
 public void setShorts(short[][] _as) {
   m_as = _as;
 }
 public short[][] getShorts() {return m_as;}
 public short getShortByIndex(int i, int j) {return m_as[i][j];}


 public void setLongs(long[][] _aj) {
   m_aj = _aj;
 }
 public long[][] getLongs() {return m_aj;}
 public long getLongByIndex(int i, int j) {return m_aj[i][j];}

}


