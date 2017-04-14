=====================================

IDL-Java Bridge  v6.1  Examples

=====================================


I. Building the examples


The examples shipped with IDL come in two pieces, the IDL .pro code 
and the Java code.  The examples have been compiled into 
jbexamples.jar using the provided makefile.

If you need to recompile the examples, ensure that javac is in your 
PATH and type 'make' from the command line.  This will compile the 
.java files into .class files and then jar the .class files into 
jbexamples.jar

If you add additional .java files that you wish to be added into 
jbexamples.jar, simply edit makefile and add the <myFilename>.class 
to the EXAMPLES symbol.  Once the new jbexamples.jar is recompiled,
remember to replace the one the bridge is looking for, which is located
in the default location of <IDL>/resource/bridges/import/java/.



II. Basic Examples


hellojava.pro 
-------------
A simple 'hello world' procedure.  This example creates a java 
String object and prints this string to IDL.


hellojava2.pro 
--------------
(uses HelloWorld.java)

A slightly more complex 'hello world' procedure.  This example 
instantiates a Java object called HelloWorld and calls a method 
sayHello that prints to Java's standard output (System.out).  This 
text appears in IDL.


bridgeversion.pro
-----------------
Using the IDLJavaBridgeSession object, this procedure retrieves a 
version object and displays the Java VM version, the bridge version 
and the bridge build date.


arraydemo.pro
-------------
(uses array2d.java)
This procedure demonstrates simple passing of array of data back 
and forth between IDL and a Java class.


javaprops.pro
-------------
This procedure queries the java.lang.System object for properties 
related to the Java virtual machine.  For example, it shows the 
current classpath, the JVM version, etc.  This example is useful 
for verifying that the bridge is pointing to the expected JVM.


allprops.pro
------------
This procedure queries the java.lang.System object for all of
the properties and uses a Java Enumeratioj object to extract each
of the properties.  IDL is then used to sort this list and print it.

Note that, due to the number of calls from IDL into Java this is
not the most efficient manner to do this.  In practice, this would 
be accomplished more efficiently by creating a class that would 
query the Properties, enumerate over them and return an array of 
strings to IDL.


exception.pro
-------------
(uses showexcept.pro)
This procedure calls Java code that throws an Exception to 
demonstrate the use of IDLJavaBridgeSession to query the last 
exception.  This exception is of type java.lang.Throwable.  

The utility procedure SHOWEXCEPT will print out information about
the exception and is useful for debugging your own IDL-Java work.
After getting an 'Exception thrown' in IDL, simply type 'showexcept' 
at the IDL prompt to get information about the exception.



III. Advanced Examples


publicmembers.pro
-----------------
(uses PublicMembers.java)
This function queries the given class and dumps a list of 
superclasses, public constructors, public data members and 
public methods to the IDL console.  This is useful for determining 
what may be done with a given class without having to exit IDL.

It may be used from within IDL, using publicmembers.pro:

IDL> publicmembers, 'java.lang.String'


Or it may be used from the command line using only java:

> java -cp . PublicMembers java.lang.String


Note that publicmembers.pro only uses the printAllMembers method.
There are several public members that may be useful in other contexts,
such as getMethods, which returns an array of Strings representing 
the signatures of available methods.


showgreyimage.pro
-----------------
(uses GreyBandsImage.java)
This procedure demonstrates pulling an Image from Java and displaying 
it in IDL.  GreyBandsImage creates a 4-band color image in Java 
consisting of bands of grey color.  The IDL procedure showgreyimage 
instantiates GreyBandsImage and then queries for the data.  IDL's TV 
is then called to display the image.

IDL> showgreyimage


urlread.pro
-----------
(uses URLReader.java)
This function allows the user to specify an URL and to pull the data 
from this URL into IDL as an array of bytes.   Java does the  work of 
connecting to the URL and downloading the data.  IDL then queries the 
Java object for the data.  

The class URLReader pulls the data into an array of bytes, but with
some extensions using the java.net and java.io packages, this could
easily be modified to read the data in other formats, such as an
array of strings, and to parse the data in some application specific 
manner.  

IDL> byteArray = urlread, 'http://www.ittvis.com'

colo_weather.pro
----------------
(uses WeatherDemo.java)
The example demonstrates querying data via URL, parsing the data 
and passing the result back to IDL.

WeatherData.java connects to NOAA's website, searches the HTML for data 
for North Central Colorado.  This data is then parsed and returned to IDL
where it is print-ed.

IDL> colo_weather


