------------------------------------------------------------
README file: <IDL_Directory>
               resource
                 bridges
                   import
                     java
------------------------------------------------------------

IDL-Java Bridge Notes
=====================

Please read this entire document and "Using Java Objects in IDL"
chapter of the IDL Connectivity Bridges manual before proceeding.
The Connecivity Bridges manual is included in the IDL Online Help
system.

The IDL-Java bridge runs on Windows, Linux, Solaris 32-bit,
Solaris 64-bit, and MacOSX (Darwin).

--------------------------------------
I. Installation of the IDL-Java bridge
--------------------------------------

See "Initializing the IDL-Java Bridge" in the "Using Java Objects
in IDL" chapter of the External Development Guide for instructions.

Note:
On Macintosh platforms, IDL uses the version of Java installed along
with the operating system, and ignores any value you place in
IDLJAVAB_LIB_LOCATION.

-------------------
II. Troubleshooting
-------------------

Once you have installed IDL and configured the IDL-Java bridge,
start IDL and try the following IDL commands to confirm that
the bridge is configured correctly:

   IDL> jo = OBJ_NEW("IDLJavaObject$java_lang_string", "java.lang.String")

   IDL> help, jo

IDL should print:

   JO              OBJREF    = <ObjHeapVar1(IDLJAVAOBJECT$JAVA_LANG_STRING)>

Next, try:

   IDL> print, OBJ_CLASS(jo)   

IDL should print:

   IDLJAVAOBJECT$JAVA_LANG_STRING

Finally, destroy your Java object:
   
   IDL> OBJ_DESTROY, jo

