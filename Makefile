# mussort makefile

SHELL=/bin/bash
VERSION=$(shell ./mussort --version|perl -pi -e 's/^\D+//; chomp')

ifndef prefix
# This little trick ensures that make install will succeed both for a local
# user and for root. It will also succeed for distro installs as long as
# prefix is set by the builder.
prefix=$(shell perl -e 'if($$< == 0 or $$> == 0) { print "/usr" } else { print "$$ENV{HOME}/.local"}')
endif

BINDIR ?= $(prefix)/bin
DATADIR ?= $(prefix)/share
DISTFILES = COPYING Makefile mussort NEWS TODO mussort.1

# Install mussort
install:
	[ ! -e mussort.1 ] && which pod2man &>/dev/null && make --no-print-directory man
	mkdir -p "$(BINDIR)"
	cp mussort "$(BINDIR)"
	chmod 755 "$(BINDIR)/mussort"
	[ -e mussort.1 ] && mkdir -p "$(DATADIR)/man/man1" && cp mussort.1 "$(DATADIR)/man/man1" || true
localinstall:
	mkdir -p "$(BINDIR)"
	ln -sf $(shell pwd)/mussort $(BINDIR)/
	[  -e mussort.1 ] && mkdir -p "$(DATADIR)/man/man1" && ln -sf $(shell pwd)/mussort.1 "$(DATADIR)/man/man1" || true
# Unisntall an installed mussort
uninstall:
	rm -f "$(BINDIR)/mussort"
	rm -f "$(DATADIR)/man/man1/mussort.1"
# Clean up the tree
clean:
	rm -f `find|egrep '~$$'`
	rm -f mussort-$(VERSION).tar.bz2
	rm -rf mussort-$(VERSION)
	rm -f mussort.1
# Verify syntax
test:
	@perl -c mussort
# Create a manpage from the POD
man:
	pod2man --name "mussort" --center "" --release "mussort $(VERSION)" ./mussort ./mussort.1
# Create the tarball
distrib: clean test man
	mkdir -p mussort-$(VERSION)
	cp $(DISTFILES) ./mussort-$(VERSION)
	tar -jcvf mussort-$(VERSION).tar.bz2 ./mussort-$(VERSION)
	rm -rf mussort-$(VERSION)
	rm -f mussort.1
