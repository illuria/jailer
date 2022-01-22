#
# jailer Makefile
#
.POSIX:

include config.mk

install:
	$(INSTALL) -m 544 -C $(PROG) $(BINDIR)/
	$(MKDIR) -p $(LIBDIR)/init
	$(INSTALL) -C lib/init/* $(LIBDIR)/init/
	$(INSTALL) -C lib/jail*  $(LIBDIR)/

deinstall:
	$(RM) $(LIBDIR)
	$(RM) $(BINDIR)/$(PROG)

.MAIN: clean
clean: ;
