#  Cross-platform makefile automating the build process for a GNU-based
#  cross-compiler for ARM bare-board targets.  See README for details.
#
#  Copyright (C) 2009-2012 Robrecht Dewaele
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.


# ------------------------------------------------------------------------------
# PREREQUISITES (needed for this makefile to work)
# ------------------------------------------------------------------------------
# This makefile expects a few things from the tarballs in the tar folder:
#  - each tarball has one of the names in $(PACKAGES) as proper prefix
#  - each tarball extracts its contents to a folder with the same
#    proper prefix as the tarball filename
#  - there is exactly one tarball for each of these names
# This allows you to update any of the tarballs in the tar folder, as long
# as these conditions are fulfilled. (The first two rules are common practice
# and are true by default for the GNU packages in this list)
# Note: All the targets in this makefile also depend on these conditions, and
#       changing names in $(PACKAGES) won't change target names of course. This
#       variable is used for the purpose of the 'sources' target only.
# ------------------------------------------------------------------------------

#
# VARIABLE DEFINITIONS
#

# Contains the package names, 'sources' and 'builds' targets are hereupon based.
PACKAGES     = binutils gcc gdb gmp insight mpfr mpc newlib openocd lpc21isp qemu

# Folder locations, respecively:
# tarballs, sources, build, install.
TAR_DIR     = $(PWD)/tar
SRC_DIR     = $(PWD)/src
BLD_DIR     = $(PWD)/build
INS_DIR     = $(PWD)/install

# Contains all folders to be able to create a (nice) static pattern rule.
DIRECTORIES = $(TAR_DIR) $(SRC_DIR) $(BLD_DIR) $(INS_DIR)

# Add source directory prefix.
SOURCES    := $(PACKAGES:%=$(SRC_DIR)/%)
# Add build directory prefix.
BUILDS     := $(PACKAGES:%=$(BLD_DIR)/%)

# Create $(GCC_DEPS), the target for included gcc dependencies:
# libgmp and libmpfr.
SRC_GCC     = $(filter %gcc, $(SOURCES))
GCC_DEPS    = $(SRC_GCC)/gmp $(SRC_GCC)/mpfr

# Extend PATH to avoid the use of full paths in some targets.
PATH       := $(PATH):$(INS_DIR)/bin

# miscellaneous
DATE        = `date +%F_%H-%M-%S`


#
# GLOBAL CONFIGURE OPTIONS
#

# global
CFG_OPT      = --disable-shared --disable-werror --prefix=$(INS_DIR)
# toolchain (binutils, gcc and newlib)
TC_OPT       = $(CFG_OPT) --target=arm-elf --enable-interwork --enable-multilib \
							 --with-float=soft
# package-specific
GMP_OPT      = $(CFG_OPT)
MPFR_OPT     = $(CFG_OPT) --with-gmp=$(INS_DIR)
MPC_OPT      = $(CFG_OPT) --with-mpfr=$(INS_DIR) --with-gmp=$(INS_DIR)
BINUTILS_OPT = $(TC_OPT)
# XXX GCC: --with-system-zlib fixes compile failure on some systems
# see http://gcc.gnu.org/ml/gcc-help/2011-01/msg00011.html
GCC_OPT      = $(TC_OPT) \
							 --enable-languages="c" --with-newlib --with-gnu-as --with-gnu-ld --without-headers \
               --with-mpc=$(INS_DIR) --with-mpfr=$(INS_DIR) --with-gmp=$(INS_DIR)
NEWLIB_OPT   = $(TC_OPT) --disable-newlib-supplied-syscalls --with-mpfr=$(INS_DIR) --with-gmp=$(INS_DIR)
GDB_OPT      = $(TC_OPT)
INSIGHT_OPT  = $(TC_OPT)
OPENOCD_OPT  = --prefix=$(INS_DIR) --enable-ft2232_libftdi

# for QEMU, we disable ALL the things
PYTHON       = python # can be overridden with command arguments
QEMU_OPT     = --prefix=$(INS_DIR) \
							 --target-list='arm-softmmu' \
							 --python=$(PYTHON) \
							 --audio-drv-list='' --audio-card-list='' --disable-debug-tcg \
							 --disable-sparse --disable-strip --disable-werror --disable-sdl \
						 	 --disable-vnc --disable-xen --disable-brlapi --disable-vnc-tls \
						 	 --disable-vnc-sasl --disable-vnc-jpeg --disable-vnc-png \
						 	 --disable-vnc-thread --disable-curses --disable-smartcard-nss \
							 --disable-fdt --disable-bluez --disable-slirp --disable-kvm \
							 --disable-nptl --disable-system --disable-user --disable-docs \
							 --disable-linux-user --disable-bsd-user --disable-guest-base \
							 --disable-pie --disable-uuid --disable-vde --disable-linux-aio \
							 --disable-attr --disable-blobs --disable-curl --disable-spice \
							 --disable-libiscsi --disable-smartcard --disable-opengl \
							 --disable-vhost-net --disable-usb-redir --disable-guest-agent \
							 --disable-xfsctl


#
# GENERIC TARGET DEFINITIONS
#

# default: make all
# TODO make package-clean rules
.PHONY all:
all:
	@echo "--------------------------------------------------------------------------------"
	@echo "ATTENTION"
	@echo "If you're running for the first time, please run 'make update-packages'. This"
	@echo "will download the latest versions of all packages needed for this toolchain."
	@echo "You can also opt to manually download some packages and put them in the 'tar'"
	@echo "directory."
	@echo "If building Qemu fails with an error looking like the following:"
	@echo "  File \"schnapps/src/qemu/scripts/qapi-commands.py\", line 376"
	@echo "    except getopt.GetoptError, err:"
	@echo "                             ^"
	@echo "  SyntaxError: invalid syntax"
	@echo "Then you're using python 3, but qemu expects python 2."
	@echo "Try 'make PYTHON=python2 qemu', where python2 is the command to launch python 2."
	@echo "--------------------------------------------------------------------------------"
	@echo
	@echo "Common targets:"
	@echo "toolchain       -> arm-elf-gcc, with newlib as C library, and binutils"
	@echo "gdb             -> GNU Debugger"
	@echo "insight         -> Insight, a front-end for GDB"
	@echo "openocd         -> openOCD, an on-chip debugger"
	@echo "lpc21isp        -> lpc21isp, an in-circuit programming (ISP) tool"
	@echo "qemu            -> Qemu processor emulator"
	@echo
	@echo "Other targets (normally only used as part of 'toolchain', in this order):"
	@echo "binutils        -> GNU binutils"
	@echo "gcc-gcc         -> GCC without libraries (bootstrap for newlib)"
	@echo "newlib          -> newlib standard C library"
	@echo "gcc-all         -> GCC with libraries"

# alternative: toolchain only
toolchain: binutils gcc-all newlib

# extracting all sources
sources: $(SOURCES)


#
# ABSTRACTION TARGET DEFINITIONS
#

# basic directories
$(DIRECTORIES): %:
	mkdir $@

# individual building directories
# The '|' syntax allows for prerequisites that don't cause the target to be
# updated when the prerequisite is updated. It is needed here because the folder
# timestamp gets updated every time files are created in it.
$(BUILDS): $(BLD_DIR)/%: | $(BLD_DIR)
	mkdir $@

# directories in the installation dir - currently only used by lpc21isp
$(INS_DIR)/%: | $(INS_DIR)
	mkdir $@

# The '$(TAR_DIR)/%*' prerequisite will make the rule execute when a new tarball
# is provided for a given package. TODO make this actually work :p
$(SOURCES): $(SRC_DIR)/%: $(wildcard $(TAR_DIR)/%*) | $(SRC_DIR)
	$(MAKE) -C $(TAR_DIR) $*
	@# Start with a fresh folder, i.e. when a tarball got updated.
	rm -rf $(SRC_DIR)/$**
	tar xf $(TAR_DIR)/$** -C $(SRC_DIR)
	mv $(SRC_DIR)/$** $@

$(TAR_DIR)/%:
	$(MAKE) -C $(TAR_DIR) $*

update-packages:
	$(MAKE) -C $(TAR_DIR)


#
# SPECIFIC TARGET DEFINITIONS
#
#  These targets make use of empty target files because their execution depends
#  solely on their prerequisites, or the first time they are executed.

# GMP
gmp: $(SRC_DIR)/gmp $(BLD_DIR)/gmp
	cd $(BLD_DIR)/gmp && \
		$</configure $(GMP_OPT) && \
		$(MAKE) all && \
		$(MAKE) check && \
		$(MAKE) install
	touch $@

# MPFR
mpfr: $(SRC_DIR)/mpfr $(BLD_DIR)/mpfr gmp
	cd $(BLD_DIR)/mpfr && \
		$</configure $(MPFR_OPT) && \
		$(MAKE) all && \
		$(MAKE) check && \
		$(MAKE) install
	touch $@

# MPC
mpc: $(SRC_DIR)/mpc $(BLD_DIR)/mpc mpfr gmp
	cd $(BLD_DIR)/mpc && \
		$</configure $(MPC_OPT) && \
		$(MAKE) all && \
		$(MAKE) check && \
		$(MAKE) install
	touch $@

# BINUTILS
binutils: $(SRC_DIR)/binutils $(BLD_DIR)/binutils
	cd $(BLD_DIR)/binutils && \
		$</configure $(BINUTILS_OPT) && \
		$(MAKE) all && \
		$(MAKE) install
	touch $@

# GCC: FIRST STAGE
gcc-gcc: $(SRC_DIR)/gcc $(BLD_DIR)/gcc gmp mpfr mpc binutils
	cd $(BLD_DIR)/gcc && \
		$</configure $(GCC_OPT) && \
		$(MAKE) all-gcc && \
		$(MAKE) install-gcc
	touch $@

# NEWLIB
newlib: $(SRC_DIR)/newlib $(BLD_DIR)/newlib gcc-gcc
	cd $(BLD_DIR)/newlib && \
		$</configure $(NEWLIB_OPT) && \
		$(MAKE) all && \
		$(MAKE) install
	touch $@

# GCC: SECOND (= final) STAGE
gcc-all: binutils gcc-gcc newlib
	cd $(BLD_DIR)/gcc && \
		$(MAKE) all && \
		$(MAKE) install
	touch $@

# GDB
gdb: $(SRC_DIR)/gdb $(BLD_DIR)/gdb
	cd $(BLD_DIR)/gdb && \
		$</configure $(GDB_OPT) && \
		$(MAKE) all && \
		$(MAKE) install
	touch $@

# INSIGHT
insight: $(SRC_DIR)/insight $(BLD_DIR)/insight
	cd $(BLD_DIR)/insight && \
		$</configure $(INSIGHT_OPT) && \
		$(MAKE) all && \
		$(MAKE) install
	touch $@

# openOCD
# XXX Current version (0.5.0) doesn't support out-of-source builds!
# This is why we don't change to the source dir instead.
#openocd: $(SRC_DIR)/openocd $(BLD_DIR)/openocd
openocd: $(SRC_DIR)/openocd
	cd $< && \
		$</configure $(OPENOCD_OPT) && \
		$(MAKE) all && \
		$(MAKE) install
	touch $@

# lpc21isp
# The build system of lpc21isp is nothing more than a simple makefile.
lpc21isp: $(SRC_DIR)/lpc21isp | $(INS_DIR)/bin
	cd $< && \
		$(MAKE) \
		&& cp lpc21isp $(INS_DIR)/bin
	touch $@

# QEMU
qemu: $(SRC_DIR)/qemu $(BLD_DIR)/qemu
	cd $(BLD_DIR)/qemu && \
		$</configure $(QEMU_OPT) && \
		$(MAKE) all && \
		$(MAKE) install
	touch $@


# CLEANING UP
.PHONY mrproper:
mrproper:
	rm -rf $(filter-out %/tar, $(DIRECTORIES)) $(PACKAGES) gcc-gcc gcc-all
