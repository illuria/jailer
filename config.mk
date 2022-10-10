PROG=	jailer
PREFIX=	/usr/local
BINDIR=	$(DESTDIR)$(PREFIX)/sbin
LIBDIR=	$(DESTDIR)$(PREFIX)/lib/jailer

MANDIR=	$(DESTDIR)$(PREFIX)/share/man/man8
MLINKS=	jailer-create:jailer-destroy \
	jailer-start:jailer-stop     \
	jailer-start:jailer-list

RM=	/bin/rm -rf
MKDIR=	/bin/mkdir
