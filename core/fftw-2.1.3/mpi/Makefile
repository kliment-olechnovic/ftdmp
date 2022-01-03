# Generated automatically from Makefile.in by configure.
# Makefile.in generated automatically by automake 1.4 from Makefile.am

# Copyright (C) 1994, 1995-8, 1999 Free Software Foundation, Inc.
# This Makefile.in is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

# The mpi stuff is only compiled if FFTW was configured with
# the --enable-mpi option.  This requires us to use the combination
# of foo_* and EXTRA_* variables below.


SHELL = /bin/sh

srcdir = .
top_srcdir = ..
prefix = /usr/local
exec_prefix = ${prefix}

bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
libexecdir = ${exec_prefix}/libexec
datadir = ${prefix}/share
sysconfdir = ${prefix}/etc
sharedstatedir = ${prefix}/com
localstatedir = ${prefix}/var
libdir = ${exec_prefix}/lib
infodir = ${prefix}/info
mandir = ${prefix}/man
includedir = ${prefix}/include
oldincludedir = /usr/include

DESTDIR =

pkgdatadir = $(datadir)/fftw
pkglibdir = $(libdir)/fftw
pkgincludedir = $(includedir)/fftw

top_builddir = ..

ACLOCAL = aclocal
AUTOCONF = autoconf
AUTOMAKE = automake

INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL} $(AM_INSTALL_PROGRAM_FLAGS)
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_SCRIPT = ${INSTALL_PROGRAM}
transform = s,x,x,

NORMAL_INSTALL = :
PRE_INSTALL = :
POST_INSTALL = :
NORMAL_UNINSTALL = :
PRE_UNINSTALL = :
POST_UNINSTALL = :
host_alias = x86_64-unknown-linux-gnu
host_triplet = x86_64-unknown-linux-gnu
AS = @AS@
CCthreads = 
DLLTOOL = @DLLTOOL@
F77 = f77
FFTW_MPI_INCLUDELIST = 
FFTW_MPI_LIBLIST = 
FFTW_MPI_PROGLIST = 
FFTW_PREFIX = 
FFTW_THREADS_INCLUDELIST = 
FFTW_THREADS_LIBLIST = 
FFTW_THREADS_PROGLIST = 
FLIBS =  -l gfortran -l m -L/usr/lib/gcc/x86_64-linux-gnu/7 -L/usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu -L/usr/lib/gcc/x86_64-linux-gnu/7/../../../../lib -L/lib/x86_64-linux-gnu -L/lib/../lib -L/usr/lib/x86_64-linux-gnu -L/usr/lib/../lib -L/usr/lib/gcc/x86_64-linux-gnu/7/../../.. -lgfortran -lm -lgcc_s -lquadmath -lm
LD = /usr/bin/ld
LIBTOOL = $(SHELL) $(top_builddir)/libtool
LN_S = ln -s
MAKEINFO = /home/kliment/git/ftdock-mod-plus/fftw-2.1.3/missing makeinfo
MPICC = mpicc
MPILIBS = 
NM = /usr/bin/nm -B
OBJDUMP = @OBJDUMP@
PACKAGE = fftw
PERL = perl
RANLIB = ranlib
SHARED_VERSION = 2.0.5
SHARED_VERSION_INFO = 2:5:0
THREADLIBS = 
VERSION = 2.1.3

lib_LTLIBRARIES = 
include_HEADERS = 
noinst_PROGRAMS = 

EXTRA_LTLIBRARIES = libfftw_mpi.la                     librfftw_mpi.la

EXTRA_HEADERS = fftw_mpi.h rfftw_mpi.h 
EXTRA_PROGRAMS = test_sched test_transpose_mpi fftw_mpi_test rfftw_mpi_test
EXTRA_DIST = README.f77

CC = mpicc

FFTWDIR = ../fftw
RFFTWDIR = ../rfftw
INCLUDES = -I$(srcdir)/../tests            -I$(srcdir)/$(FFTWDIR) -I$(srcdir)/$(RFFTWDIR) -I$(srcdir)


libfftw_mpi_la_SOURCES =                           sched.c sched.h TOMS_transpose.c TOMS_transpose.h                          transpose_mpi.c fftwnd_mpi.c fftw_mpi.c                          fftw_mpi.h 			 fftw_f77_mpi.c fftw_f77_mpi.h

libfftw_mpi_la_LDFLAGS =                           -version-info 2:5:0                          -rpath $(libdir)


librfftw_mpi_la_SOURCES =                            rfftwnd_mpi.c rfftw_mpi.h 			  rfftw_f77_mpi.c

librfftw_mpi_la_LDFLAGS =                            -version-info 2:5:0                           -rpath $(libdir)


CLEANFILES = xyzfftw_mpi.h xyzrfftw_mpi.h

test_sched_SOURCES = test_sched.c
test_sched_LDADD = libfftw_mpi.la                    $(FFTWDIR)/libfftw.la 


test_transpose_mpi_SOURCES = test_transpose_mpi.c
test_transpose_mpi_LDADD = libfftw_mpi.la                            $(FFTWDIR)/libfftw.la 


fftw_mpi_test_SOURCES = fftw_mpi_test.c
fftw_mpi_test_LDADD = ../tests/test_main.o                       libfftw_mpi.la                       $(FFTWDIR)/libfftw.la 


rfftw_mpi_test_SOURCES = rfftw_mpi_test.c
rfftw_mpi_test_LDADD = ../tests/test_main.o                        librfftw_mpi.la                        libfftw_mpi.la 		       $(RFFTWDIR)/librfftw.la                        $(FFTWDIR)/libfftw.la                        


# for some reason, automake tries to use autoheader in order to
# generate config.h.in, and fails because config.h.in is GNU-lly
# incorrect.  Just disable autoheader
AUTOHEADER = echo
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_HEADER = ../fftw/config.h ../fftw/fftw.h
CONFIG_CLEAN_FILES = 
LTLIBRARIES =  $(lib_LTLIBRARIES)


DEFS = -DHAVE_CONFIG_H -I. -I$(srcdir) -I../fftw -I../fftw
CPPFLAGS = 
LDFLAGS = 
LIBS = -lm 
libfftw_mpi_la_LIBADD = 
libfftw_mpi_la_OBJECTS =  sched.lo TOMS_transpose.lo \
transpose_mpi.lo fftwnd_mpi.lo fftw_mpi.lo fftw_f77_mpi.lo
librfftw_mpi_la_LIBADD = 
librfftw_mpi_la_OBJECTS =  rfftwnd_mpi.lo \
rfftw_f77_mpi.lo
PROGRAMS =  $(noinst_PROGRAMS)

test_sched_OBJECTS =  test_sched.o
test_sched_DEPENDENCIES =  libfftw_mpi.la \
$(FFTWDIR)/libfftw.la
test_sched_LDFLAGS = 
test_transpose_mpi_OBJECTS =  test_transpose_mpi.o
test_transpose_mpi_DEPENDENCIES =  libfftw_mpi.la \
$(FFTWDIR)/libfftw.la
test_transpose_mpi_LDFLAGS = 
fftw_mpi_test_OBJECTS =  fftw_mpi_test.o
fftw_mpi_test_DEPENDENCIES =  ../tests/test_main.o \
libfftw_mpi.la \
$(FFTWDIR)/libfftw.la
fftw_mpi_test_LDFLAGS = 
rfftw_mpi_test_OBJECTS =  rfftw_mpi_test.o
rfftw_mpi_test_DEPENDENCIES =  ../tests/test_main.o \
librfftw_mpi.la libfftw_mpi.la \
$(RFFTWDIR)/librfftw.la \
$(FFTWDIR)/libfftw.la
rfftw_mpi_test_LDFLAGS = 
CFLAGS = -O6 -fomit-frame-pointer -Wall -W -Wcast-qual -Wpointer-arith -Wcast-align -pedantic -fno-schedule-insns -fschedule-insns2 -malign-double -fstrict-aliasing
COMPILE = $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
LTCOMPILE = $(LIBTOOL) --mode=compile $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(LIBTOOL) --mode=link $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@
HEADERS =  $(include_HEADERS)

DIST_COMMON =  Makefile.am Makefile.in


DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)

TAR = gtar
GZIP_ENV = --best
SOURCES = $(libfftw_mpi_la_SOURCES) $(librfftw_mpi_la_SOURCES) $(test_sched_SOURCES) $(test_transpose_mpi_SOURCES) $(fftw_mpi_test_SOURCES) $(rfftw_mpi_test_SOURCES)
OBJECTS = $(libfftw_mpi_la_OBJECTS) $(librfftw_mpi_la_OBJECTS) $(test_sched_OBJECTS) $(test_transpose_mpi_OBJECTS) $(fftw_mpi_test_OBJECTS) $(rfftw_mpi_test_OBJECTS)

all: all-redirect
.SUFFIXES:
.SUFFIXES: .S .c .lo .o .s
$(srcdir)/Makefile.in: Makefile.am $(top_srcdir)/configure.in $(ACLOCAL_M4) 
	cd $(top_srcdir) && $(AUTOMAKE) --gnu --include-deps mpi/Makefile

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$(subdir)/$@ CONFIG_HEADERS= $(SHELL) ./config.status


mostlyclean-libLTLIBRARIES:

clean-libLTLIBRARIES:
	-test -z "$(lib_LTLIBRARIES)" || rm -f $(lib_LTLIBRARIES)

distclean-libLTLIBRARIES:

maintainer-clean-libLTLIBRARIES:

install-libLTLIBRARIES: $(lib_LTLIBRARIES)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(libdir)
	@list='$(lib_LTLIBRARIES)'; for p in $$list; do \
	  if test -f $$p; then \
	    echo "$(LIBTOOL)  --mode=install $(INSTALL) $$p $(DESTDIR)$(libdir)/$$p"; \
	    $(LIBTOOL)  --mode=install $(INSTALL) $$p $(DESTDIR)$(libdir)/$$p; \
	  else :; fi; \
	done

uninstall-libLTLIBRARIES:
	@$(NORMAL_UNINSTALL)
	list='$(lib_LTLIBRARIES)'; for p in $$list; do \
	  $(LIBTOOL)  --mode=uninstall rm -f $(DESTDIR)$(libdir)/$$p; \
	done

.c.o:
	$(COMPILE) -c $<

.s.o:
	$(COMPILE) -c $<

.S.o:
	$(COMPILE) -c $<

mostlyclean-compile:
	-rm -f *.o core *.core

clean-compile:

distclean-compile:
	-rm -f *.tab.c

maintainer-clean-compile:

.c.lo:
	$(LIBTOOL) --mode=compile $(COMPILE) -c $<

.s.lo:
	$(LIBTOOL) --mode=compile $(COMPILE) -c $<

.S.lo:
	$(LIBTOOL) --mode=compile $(COMPILE) -c $<

mostlyclean-libtool:
	-rm -f *.lo

clean-libtool:
	-rm -rf .libs _libs

distclean-libtool:

maintainer-clean-libtool:

libfftw_mpi.la: $(libfftw_mpi_la_OBJECTS) $(libfftw_mpi_la_DEPENDENCIES)
	$(LINK)  $(libfftw_mpi_la_LDFLAGS) $(libfftw_mpi_la_OBJECTS) $(libfftw_mpi_la_LIBADD) $(LIBS)

librfftw_mpi.la: $(librfftw_mpi_la_OBJECTS) $(librfftw_mpi_la_DEPENDENCIES)
	$(LINK)  $(librfftw_mpi_la_LDFLAGS) $(librfftw_mpi_la_OBJECTS) $(librfftw_mpi_la_LIBADD) $(LIBS)

mostlyclean-noinstPROGRAMS:

clean-noinstPROGRAMS:
	-test -z "$(noinst_PROGRAMS)" || rm -f $(noinst_PROGRAMS)

distclean-noinstPROGRAMS:

maintainer-clean-noinstPROGRAMS:

test_sched: $(test_sched_OBJECTS) $(test_sched_DEPENDENCIES)
	@rm -f test_sched
	$(LINK) $(test_sched_LDFLAGS) $(test_sched_OBJECTS) $(test_sched_LDADD) $(LIBS)

test_transpose_mpi: $(test_transpose_mpi_OBJECTS) $(test_transpose_mpi_DEPENDENCIES)
	@rm -f test_transpose_mpi
	$(LINK) $(test_transpose_mpi_LDFLAGS) $(test_transpose_mpi_OBJECTS) $(test_transpose_mpi_LDADD) $(LIBS)

fftw_mpi_test: $(fftw_mpi_test_OBJECTS) $(fftw_mpi_test_DEPENDENCIES)
	@rm -f fftw_mpi_test
	$(LINK) $(fftw_mpi_test_LDFLAGS) $(fftw_mpi_test_OBJECTS) $(fftw_mpi_test_LDADD) $(LIBS)

rfftw_mpi_test: $(rfftw_mpi_test_OBJECTS) $(rfftw_mpi_test_DEPENDENCIES)
	@rm -f rfftw_mpi_test
	$(LINK) $(rfftw_mpi_test_LDFLAGS) $(rfftw_mpi_test_OBJECTS) $(rfftw_mpi_test_LDADD) $(LIBS)

install-includeHEADERS: $(include_HEADERS)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(includedir)
	@list='$(include_HEADERS)'; for p in $$list; do \
	  if test -f "$$p"; then d= ; else d="$(srcdir)/"; fi; \
	  echo " $(INSTALL_DATA) $$d$$p $(DESTDIR)$(includedir)/$$p"; \
	  $(INSTALL_DATA) $$d$$p $(DESTDIR)$(includedir)/$$p; \
	done

uninstall-includeHEADERS:
	@$(NORMAL_UNINSTALL)
	list='$(include_HEADERS)'; for p in $$list; do \
	  rm -f $(DESTDIR)$(includedir)/$$p; \
	done

tags: TAGS

ID: $(HEADERS) $(SOURCES) $(LISP)
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	here=`pwd` && cd $(srcdir) \
	  && mkid -f$$here/ID $$unique $(LISP)

TAGS:  $(HEADERS) $(SOURCES)  $(TAGS_DEPENDENCIES) $(LISP)
	tags=; \
	here=`pwd`; \
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	test -z "$(ETAGS_ARGS)$$unique$(LISP)$$tags" \
	  || (cd $(srcdir) && etags $(ETAGS_ARGS) $$tags  $$unique $(LISP) -o $$here/TAGS)

mostlyclean-tags:

clean-tags:

distclean-tags:
	-rm -f TAGS ID

maintainer-clean-tags:

distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)

subdir = mpi

distdir: $(DISTFILES)
	@for file in $(DISTFILES); do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    cp -pr $$/$$file $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir)/$$file || :; \
	  fi; \
	done

info-am:
info: info-am
dvi-am:
dvi: dvi-am
check-am: all-am
check: check-am
installcheck-am:
installcheck: installcheck-am
install-exec-am: install-libLTLIBRARIES
install-exec: install-exec-am

install-data-am: install-includeHEADERS
install-data: install-data-am

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am
install: install-am
uninstall-am: uninstall-libLTLIBRARIES uninstall-includeHEADERS
uninstall: uninstall-am
all-am: Makefile $(LTLIBRARIES) $(PROGRAMS) $(HEADERS)
all-redirect: all-am
install-strip:
	$(MAKE) $(AM_MAKEFLAGS) AM_INSTALL_PROGRAM_FLAGS=-s install
installdirs:
	$(mkinstalldirs)  $(DESTDIR)$(libdir) $(DESTDIR)$(includedir)


mostlyclean-generic:

clean-generic:
	-test -z "$(CLEANFILES)" || rm -f $(CLEANFILES)

distclean-generic:
	-rm -f Makefile $(CONFIG_CLEAN_FILES)
	-rm -f config.cache config.log stamp-h stamp-h[0-9]*

maintainer-clean-generic:
mostlyclean-am:  mostlyclean-libLTLIBRARIES mostlyclean-compile \
		mostlyclean-libtool mostlyclean-noinstPROGRAMS \
		mostlyclean-tags mostlyclean-generic

mostlyclean: mostlyclean-am

clean-am:  clean-libLTLIBRARIES clean-compile clean-libtool \
		clean-noinstPROGRAMS clean-tags clean-generic \
		mostlyclean-am

clean: clean-am

distclean-am:  distclean-libLTLIBRARIES distclean-compile \
		distclean-libtool distclean-noinstPROGRAMS \
		distclean-tags distclean-generic clean-am
	-rm -f libtool

distclean: distclean-am

maintainer-clean-am:  maintainer-clean-libLTLIBRARIES \
		maintainer-clean-compile maintainer-clean-libtool \
		maintainer-clean-noinstPROGRAMS maintainer-clean-tags \
		maintainer-clean-generic distclean-am
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."

maintainer-clean: maintainer-clean-am

.PHONY: mostlyclean-libLTLIBRARIES distclean-libLTLIBRARIES \
clean-libLTLIBRARIES maintainer-clean-libLTLIBRARIES \
uninstall-libLTLIBRARIES install-libLTLIBRARIES mostlyclean-compile \
distclean-compile clean-compile maintainer-clean-compile \
mostlyclean-libtool distclean-libtool clean-libtool \
maintainer-clean-libtool mostlyclean-noinstPROGRAMS \
distclean-noinstPROGRAMS clean-noinstPROGRAMS \
maintainer-clean-noinstPROGRAMS uninstall-includeHEADERS \
install-includeHEADERS tags mostlyclean-tags distclean-tags clean-tags \
maintainer-clean-tags distdir info-am info dvi-am dvi check check-am \
installcheck-am installcheck install-exec-am install-exec \
install-data-am install-data install-am install uninstall-am uninstall \
all-redirect all-am all installdirs mostlyclean-generic \
distclean-generic clean-generic maintainer-clean-generic clean \
mostlyclean distclean maintainer-clean


xyzfftw_mpi.h: fftw_mpi.h
	rm -f fftw_mpi.h
	sed 's/<fftw/<fftw/g;s/<rfftw/<rfftw/g' fftw_mpi.h > fftw_mpi.h

xyzrfftw_mpi.h: rfftw_mpi.h
	rm -f rfftw_mpi.h
	sed 's/<fftw/<fftw/g;s/<rfftw/<rfftw/g' rfftw_mpi.h > rfftw_mpi.h

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
