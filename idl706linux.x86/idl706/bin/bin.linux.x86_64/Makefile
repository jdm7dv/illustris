# Linux (X864_64 64-bit)
#
# Motif version 2.2.2 has known problems that adversely affect IDL widgets.
# Version 2.2.3 or later should be used.

IDLDIR=../..
BINDIR=$(IDLDIR)/bin/bin.linux.x86_64
CALLTEST=$(IDLDIR)/external/callable/calltest
LDFLAGS= -L$(BINDIR) -lidl -Wl,-rpath,. -Wl,-rpath $(BINDIR)\
	/usr/X11R6/lib64/libXm.a \
	-lXp -L/usr/X11R6/lib64 -lXpm -lXmu -lXext -lXt -lSM -lICE \
	-lXinerama -lX11 -ldl -ltermcap -lrt -lm -lpthread

idl.new :
	gcc -o idl.new $(BINDIR)/main.o $(LDFLAGS)
	rm -f idlde.new; ln idl.new idlde.new


# Build the C language calltest program.
calltest :
	gcc -I$(IDLDIR)/external/include -o calltest $(CALLTEST).c $(LDFLAGS)
