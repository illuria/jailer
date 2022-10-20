#
# jailer Makefile
#
.POSIX:

include config.mk

install:
	# Install the main executable and library files
	@$(INSTALL) -m 544 -C $(PROG) $(BINDIR)/
	@$(MKDIR) -p $(LIBDIR)/init
	@$(INSTALL) -C lib/init/* $(LIBDIR)/init/
	@$(INSTALL) -C lib/jail*  $(LIBDIR)/
	# Compress and install man pages
	@mkdir -p ${MANDIR}
	@for i in man/*.8; do \
		gzip -fk $$i; \
	done
	@${INSTALL} -C -m 444 man/*.8.gz ${MANDIR}
	# Handle man links
	@for i in ${MLINKS}; do                                          \
		ln -fs ${MANDIR}/$${i%:*}.8.gz ${MANDIR}/$${i#*:}.8.gz ; \
	done
	# Clean up ./man dir
	@rm -f man/*.8.gz

deinstall:
	$(RM) $(LIBDIR)
	$(RM) $(BINDIR)/$(PROG)
	$(RM) $(MANDIR)/$(PROG)*.8.gz

.MAIN: clean
clean: ;
