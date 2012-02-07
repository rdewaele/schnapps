###################################
# HTTP/FTP URL fetching with curl #
###################################
# directory index fetching: silent, follow redirections
CURLIDX:=curl -s -L
# archive fetching: follow redirections, show simple progress bar
CURLGET:=curl -L -\\\#

###########################################
# link filtering (html parsing) with perl #
###########################################
# parse html and print items linked to
LINKFLTR:=perl -MHTML::LinkExtor -le \
	'HTML::LinkExtor->new(sub{shift; %attr = @_; print $$attr{href}})->parse_file(*STDIN)'

###########
# Mirrors #
###########
# this mirror automatically redirects to some mirror, supposedly close to the user
GNU_MIRROR_ROOT := http://ftpmirror.gnu.org
# apache servers typically support this style of ordering for directory listings
SORTED_IDX      := ?C=M;O=D

# Binutils (requires support for sorting index by date)
MIRROR_BINUTILS_GET := $(GNU_MIRROR_ROOT:%=%/binutils)
MIRROR_BINUTILS_IDX := $(MIRROR_BINUTILS_GET:%=%/$(SORTED_IDX))

# GCC (requires support for sorting index by date)
MIRROR_GCC_ROOT := $(GNU_MIRROR_ROOT:%=%/gcc)
MIRROR_GCC_RIDX := $(MIRROR_GCC_ROOT:%=%/$(SORTED_IDX))
MIRROR_GCC_GET  := $(MIRROR_GCC_ROOT:%=%/$(shell $(CURLIDX) '$(MIRROR_GCC_RIDX)' | $(LINKFLTR) | grep -m1 '^gcc.*\/$$'))
MIRROR_GCC_IDX  := $(MIRROR_GCC_GET:%=%/$(SORTED_IDX))

# GDB (requires support for sorting index by date)
MIRROR_GDB_GET := $(GNU_MIRROR_ROOT:%=%/gdb)
MIRROR_GDB_IDX := $(MIRROR_GDB_GET:%=%/$(SORTED_IDX))

# GMP (requires support for sorting index by date)
MIRROR_GMP_GET := $(GNU_MIRROR_ROOT:%=%/gmp)
MIRROR_GMP_IDX := $(MIRROR_GMP_GET:%=%/$(SORTED_IDX))

# Insight (requires support for sorting index by date)
# Not hosted on GNU mirrors, and no redirection alternative, so we chose to hardcode the kernel.org mirror
# XXX In the future, mirror selection could be added to this system.
MIRROR_INSIGHT_GET := http://mirrors.kernel.org/sources.redhat.com/insight/releases
MIRROR_INSIGHT_IDX := $(MIRROR_INSIGHT_GET:%=%/$(SORTED_IDX))

# MPFR (requires support for sorting index by date)
MIRROR_MPFR_GET := $(GNU_MIRROR_ROOT:%=%/mpfr)
MIRROR_MPFR_IDX := $(MIRROR_MPFR_GET:%=%/$(SORTED_IDX))

# MPC
# XXX This one is a bit nasty, as there are no mirrors, and directory listing is forbidden (403)
# We'll just fetch the download page and filter out any links to mpc source archives, and fetch
# the first one, as it should be listed first, under "latest version", which appears before
# "previous versions" on the download page.
# Furthermore, this page only lists gzipped archives!
MIRROR_MPC_IDX := http://www.multiprecision.org/index.php?prog=mpc&page=download

###########
# Targets #
##########
# Binutils: get directory index by date, filter files, get first (=newest) file
BINUTILS := $(shell $(CURLIDX) '$(MIRROR_BINUTILS_IDX)' | $(LINKFLTR) | grep -m1 '^binutils.*\.tar\.bz2$$')

# GCC: get index of latest version dir, filter gcc-core*.tar.bz2 (should have single match)
GCC := $(shell $(CURLIDX) '$(MIRROR_GCC_IDX)' | $(LINKFLTR) | grep -m1 '^gcc-core-.*\.tar\.bz2$$')

# GDB
GDB := $(shell $(CURLIDX) '$(MIRROR_GDB_IDX)' | $(LINKFLTR) | grep -m1 '^gdb-.*\.tar\.bz2$$')

# GMP
GMP := $(shell $(CURLIDX) '$(MIRROR_GMP_IDX)' | $(LINKFLTR) | grep -m1 '^gmp-.*\.tar\.bz2$$')

# MPFR
MPFR := $(shell $(CURLIDX) '$(MIRROR_MPFR_IDX)' | $(LINKFLTR) | grep -m1 '^mpfr-.*\.tar\.bz2$$')

# Insight
INSIGHT := $(shell $(CURLIDX) '$(MIRROR_INSIGHT_IDX)' | $(LINKFLTR) | grep -m1 '^insight-.*\.tar\.bz2$$')

# MPC
MPC := $(shell $(CURLIDX) '$(MIRROR_MPC_IDX)' | $(LINKFLTR) | grep -m1 'mpc-.*\.tar\.gz$$')

# default rule fetches ALL the things
all: $(BINUTILS) $(GCC) $(GDB) $(GMP) $(INSIGHT) $(MPFR)
	@echo ">>> BINUTILS: " "$(BINUTILS)"
	@echo ">>> GCC:      " "$(GCC)"
	@echo ">>> GDB:      " "$(GDB)"
	@echo ">>> GMP:      " "$(GMP)"
	@echo ">>> INSIGHT:  " "$(INSIGHT)"
	@echo ">>> MPFR:     " "$(MPFR)"
	@echo ">>> MPC:      " "$(MPC)"

# --- All rules below are in the same format, and they fetch the different packages. --- #

$(BINUTILS):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_BINUTILS_GET)/$@' -o $@

$(GCC):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_GCC_GET)/$@' -o $@

$(GDB):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_GDB_GET)/$@' -o $@

$(GMP):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_GMP_GET)/$@' -o $@

$(MPFR):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_MPFR_GET)/$@' -o $@

$(INSIGHT):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_INSIGHT_GET)/$@' -o $@

.PHONY: all
