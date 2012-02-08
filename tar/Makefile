# XXX Note that running this makefile with multiple jobs can result in
# obnoxious output to the screen, as every curl instance will try to
# display its progress bar. ;-)

###################################
# HTTP/FTP URL fetching with curl #
###################################
# directory index fetching: silent, follow redirections
CURLIDX := curl -s -L
# archive fetching: follow redirections, show simple progress bar
CURLGET := curl -L -\\\#
# curl No ReDirection, silent
CURLNRD := curl -s

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
MIRROR_MPC_ROOT    := http://www.multiprecision.org
MIRROR_MPC_IDX     := $(MIRROR_MPC_ROOT:%=%/index.php?prog=mpc&page=download)
MIRROR_MPC_RELGET  := $(shell $(CURLIDX) '$(MIRROR_MPC_IDX)' | $(LINKFLTR) | grep -m1 'mpc-.*\.tar\.gz$$')
MIRROR_MPC_GETFILE := $(MIRROR_MPC_ROOT:%=%/$(MIRROR_MPC_RELGET))

# Newlib
# XXX Only one (ftp) site hosts the yearly releases.
# The ftp directory contains an up to date index.html file, which lists all releases available, newest one first.
# Note that the links provided by this html file are absolute paths.
MIRROR_NEWLIB_ROOT    := ftp://sources.redhat.com/pub/newlib
MIRROR_NEWLIB_IDX     := $(MIRROR_NEWLIB_ROOT:%=%/index.html)
MIRROR_NEWLIB_GETFILE := $(shell $(CURLIDX) '$(MIRROR_NEWLIB_IDX)' | $(LINKFLTR) | grep -m1 'newlib-.*\.tar\.gz$$')

# OpenOCD
# XXX sourceforge mirror: this download page will redirect to the actual download, so if we don't follow the redirection, we can fetch the filename
MIRROR_OPENOCD_GETFILE := http://sourceforge.net/projects/openocd/files/latest/download

# lpc21isp
# XXX sourceforge mirror: this download page will redirect to the actual download, so if we don't follow the redirection, we can fetch the filename
# Also noteworthy: for some reason the version number is prepended with an underscore instead of a dash in the filename.
MIRROR_LPC21ISP_GETFILE := http://sourceforge.net/projects/lpc21isp/files/latest/download

# Qemu
# XXX Dowload page lists absolute links
MIRROR_QEMU_IDX     := http://wiki.qemu.org/Download
MIRROR_QEMU_GETFILE := $(shell $(CURLIDX) '$(MIRROR_QEMU_IDX)' | $(LINKFLTR) | grep -m1 'qemu-.*\.tar\.gz$$')

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
MPC := $(shell echo '$(MIRROR_MPC_RELGET)' | sed -e 's/.*\/mpc-/mpc-/') 

# Newlib
NEWLIB := $(shell echo '$(MIRROR_NEWLIB_GETFILE)' | sed -e 's/.*\/newlib-/newlib-/') 

# OpenOCD
OPENOCD := $(shell $(CURLNRD) '$(MIRROR_OPENOCD_GETFILE)' | $(LINKFLTR) | sed -e 's/.*\/openocd-/openocd-/' -e 's/\?.*//')

# lpc21isp
LPC21ISP := $(shell $(CURLNRD) '$(MIRROR_LPC21ISP_GETFILE)' | $(LINKFLTR) | sed -e 's/.*\/lpc21isp_/lpc21isp_/' -e 's/\?.*//')

# Qemu
QEMU := $(shell echo '$(MIRROR_QEMU_GETFILE)' | sed -e 's/.*\/qemu-/qemu-/') 

# default rule fetches ALL the things
all: $(BINUTILS) $(GCC) $(GDB) $(GMP) $(INSIGHT) $(MPFR) $(MPC) $(NEWLIB) $(OPENOCD) $(LPC21ISP) $(QEMU)
	@echo ">>> BINUTILS: " "$(BINUTILS)"
	@echo ">>> GCC:      " "$(GCC)"
	@echo ">>> GDB:      " "$(GDB)"
	@echo ">>> GMP:      " "$(GMP)"
	@echo ">>> INSIGHT:  " "$(INSIGHT)"
	@echo ">>> MPFR:     " "$(MPFR)"
	@echo ">>> MPC:      " "$(MPC)"
	@echo ">>> NEWLIB:   " "$(NEWLIB)"
	@echo ">>> OPENOCD:  " "$(OPENOCD)"
	@echo ">>> LPC21ISP: " "$(LPC21ISP)"
	@echo ">>> QEMU:     " "$(QEMU)"

# clean XXX removes anything with '.tar' in the name!
clean:
	rm -rf *.tar*

# --- All rules below are in the same format, and they fetch the different packages. --- #

# XXX on some systems, something weird happens: curl shows its progress bar twice
# This is classified as "not our problem".

$(BINUTILS):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_BINUTILS_GET)/$@' -o $@ 2>&1 | grep \\\#
	
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

$(MPC):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_MPC_GETFILE)' -o $@

$(NEWLIB):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_NEWLIB_GETFILE)' -o $@

$(OPENOCD):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_OPENOCD_GETFILE)' -o $@

$(LPC21ISP):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_LPC21ISP_GETFILE)' -o $@

$(QEMU):
	@echo downloading file: $@
	@$(CURLGET) '$(MIRROR_QEMU_GETFILE)' -o $@

.PHONY: all
