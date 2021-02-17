#
# jailio Makefile
#

PREFIX?=/usr/local
BINDIR=$(DESTDIR)$(PREFIX)/sbin
LIBDIR=$(DESTDIR)$(PREFIX)/lib/jailio

CP=/bin/cp
INSTALL=/usr/bin/install
LN=/bin/ln
MKDIR=/bin/mkdir

PROG=jailio
MAN=$(PROG).8

install:
	$(MKDIR) -p $(BINDIR)
	$(INSTALL) -m 544 $(PROG) $(BINDIR)/

	$(MKDIR) -p $(LIBDIR)/init
	$(INSTALL) lib/init/* $(LIBDIR)/init/
	$(MKDIR) -p $(LIBDIR)
	$(INSTALL) lib/jailio-* $(LIBDIR)/

.MAIN: clean
clean: ;
