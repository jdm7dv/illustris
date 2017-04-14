/*
  Copyright (c) 2002-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
 */

//
// For a given class, query or print superclasses, public constructors, 
// public methods and public fields using reflection
//

import java.lang.reflect.*;
import java.util.*;

public class PublicMembers
{  
  // ******************************************************************
  //
  // Purpose: given a Class, print the constructors
  //
  // ******************************************************************
   public static void printConstructors(String sClass) {
      Class cl = getClassFromName(sClass);
      if (cl != null)
         printConstructors(cl);
   }
         
   public static String[] getConstructors(Class cl) {
      Constructor[] constructors = cl.getDeclaredConstructors();
      String[] v = new String[constructors.length];
      int v_count = 0;

      for (int i = 0; i < constructors.length; i++) {
         Constructor c = constructors[i];
         int mods = c.getModifiers();
         if (Modifier.isPublic(mods)) {
            String s = new String();
            Class[] paramTypes = c.getParameterTypes();
            String name = c.getName();
            s = Modifier.toString(mods);
            s = s + " " + name + "(";
            for (int j = 0; j < paramTypes.length; j++) {
               if (j > 0) s = s + ", ";
               s = s + convertParamType(paramTypes[j]);
            }
            s = s + ");";
            v[v_count++] = s;
         }
      }

      // copy contents into new array
      String[] newV = null;
      if (v_count > 0) {
         newV = new String[v_count];
         for (int j = 0; j < v_count; j++) 
            newV[j] = v[j];
      }

      return newV;
   }

   private static void printConstructors(Class cl) {
      String[] v = getConstructors(cl);
      if (v != null)
         for (int i = 0; i < v.length; i++) {
            System.out.println(v[i]);
         }
   }
   
  // ******************************************************************
  //
  // Purpose: given a Class, print the methods
  //
  // ******************************************************************
   public static void printMethods(String sClass) {
      Class cl = getClassFromName(sClass);
      if (cl != null)
         printMethods(cl);
   }
   public static String[] getMethods(Class cl) {
      Method[] methods = cl.getDeclaredMethods();
      String[] v = new String[methods.length];
      int v_count = 0;

      for (int i = 0; i < methods.length; i++) {
         Method m = methods[i];
         int mods = m.getModifiers();
         if (Modifier.isPublic(mods)) {
            String s = new String();
            Class retType = m.getReturnType();
            Class[] paramTypes = m.getParameterTypes();
            String name = m.getName();
            s = s + Modifier.toString(mods);
            s = s +" " + retType.getName() + " " + name + "(";
            for (int j = 0; j < paramTypes.length; j++) {
               if (j > 0) s = s + ", ";
               s = s + convertParamType(paramTypes[j]);
            }
            s = s + ");";
            v[v_count++] = s;
         }
      }

      // copy contents into new array
      String[] newV = null;
      if (v_count > 0) {
         newV = new String[v_count];
         for (int j = 0; j < v_count; j++) 
            newV[j] = v[j];
      }

      return newV;
   }

   private static void printMethods(Class cl) {
      String[] v = getMethods(cl);
      if (v != null)
         for (int i = 0; i < v.length; i++) {
            System.out.println(v[i]);
         }
   }

  // ******************************************************************
  //
  // Purpose: given a Class, print the fields
  //
  // ******************************************************************
   public static void printFields(String sClass) {
      Class cl = getClassFromName(sClass);
      if (cl != null)
         printFields(cl);
   }

   public static String[] getFields(Class cl) {
      Field[] fields = cl.getDeclaredFields();
      String[] v = new String[fields.length];
      int v_count = 0;

      for (int i = 0; i < fields.length; i++) {
         Field f = fields[i];
         int mods = f.getModifiers();
         if (Modifier.isPublic(mods)) {
            String s = new String();
            Class type = f.getType();
            String name = f.getName();

            s = s + Modifier.toString(mods);
            s = s + " " + type.getName() + " " + name + ";";

            v[v_count++] = s;
         }
      }

      // copy contents into new array
      String[] newV = null;
      if (v_count > 0) {
         newV = new String[v_count];
         for (int j = 0; j < v_count; j++) 
            newV[j] = v[j];
      }

      return newV;
   }

   private static void printFields(Class cl) {
      String[] v = getFields(cl);
      if (v != null)
         for (int i = 0; i < v.length; i++) {
            System.out.println(v[i]);
         }
   }


  // ******************************************************************
  //
  // Purpose: given a Class, print the superclasses
  //
  // ******************************************************************
   public static void printSuperclasses(String sClass) {
      Class cl = getClassFromName(sClass);
      if (cl != null)
         printSuperclasses(cl);
   }

   private static void printSuperclasses(Class cl) {
      Class subclass = cl;
      Class superclass = subclass.getSuperclass();
      while (superclass != null) {
         String className = superclass.getName();
         System.out.println(className);
         subclass = superclass;
         superclass = subclass.getSuperclass();
      }
   }


  // ******************************************************************
  //
  // Purpose: given a Class, Print all public constructores, fields and methods
  //
  // ******************************************************************
   public static void printAllMembers(String sClass) {
      Class cl = getClassFromName(sClass);
      if (cl != null) {
         System.out.println("Class:" + sClass);

         System.out.println("------ Superclasses:");
         printSuperclasses(cl);

         System.out.println("------ Fields:");
         printFields(cl);

         System.out.println("------ Ctors:");
         printConstructors(cl);

         System.out.println("------ Methods:");
         printMethods(cl);
      }
   }

  // ******************************************************************
  //
  // Purpose: some utilities
  //
  // ******************************************************************
  private static Class getClassFromName(String sClass) {
 
      Class cl = null;
      try {
        cl = Class.forName(sClass);
     } catch(Throwable e) {
         System.err.println("Class "+sClass+" not found.");
        cl = null;
     }
     return cl;
  }
  private static String convertParamType(Class param) {
     return param.getName();
  }

  // ******************************************************************
  //
  // main:
  //
  //   Usage: java com.rsi.javab.PublicMembers <classname>
  //
  // ******************************************************************

  public static void main(String[] args) {  
   
     if (args.length != 1) {
        System.err.println("  Usage: java PublicMembers <classname>");
       return;
     }

     String name = args[0];

     printAllMembers(name);

  }



}
