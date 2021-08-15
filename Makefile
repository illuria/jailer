#
# jailer Makefile
#

PREFIX?=/usr/local
BINDIR=$(DESTDIR)$(PREFIX)/sbin
LIBDIR=$(DESTDIR)$(PREFIX)/lib/jailer

CP=/bin/cp
INSTALL=/usr/bin/install
LN=/bin/ln
MKDIR=/bin/mkdir

PROG=jailer
MAN=$(PROG).8

install:
	$(MKDIR) -p $(BINDIR)
	$(INSTALL) -m 544 $(PROG) $(BINDIR)/

	$(MKDIR) -p $(LIBDIR)/init
	$(INSTALL) lib/init/* $(LIBDIR)/init/
	$(MKDIR) -p $(LIBDIR)
	$(INSTALL) lib/jailer-* $(LIBDIR)/

.MAIN: clean
clean: ;
