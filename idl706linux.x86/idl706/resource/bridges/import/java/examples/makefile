#####################################
#
# Makefile for Java examples
#
#####################################


# java files I am going to compile
# (add new files to this list)
#
EXAMPLES = \
    array2d.class \
    helloWorld.class \
	 GreyBandsImage.class \
    URLReader.class \
    WeatherDemo.class \
    PublicMembers.class \
    FrameTest.class \
    FrameTestImageArea.class \
    FrameTestImageAreaResizeListener.class \
    RSIImageArea.class \
    RSIImageFrame.class


# Name of my output .jar file
JARNAME = jbexamples

############################################################
# Java settings 
############################################################
CLASS_PATH = .
JFLAGS = -O -classpath "$(CLASS_PATH)" -deprecation 

############################################################
# Rules
############################################################

.SUFFIXES: .java .class

.java.class : 
	javac $(JFLAGS) $*.java 

current: $(JARNAME).jar

$(JARNAME).jar : $(EXAMPLES) 
	jar cf0 $(JARNAME).jar *.class

clean: 
	rm -f $(EXAMPLES) $(JARNAME).jar *.class
