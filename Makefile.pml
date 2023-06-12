include VARS

PACKAGE_NAME=pml
VERSION=2.03
VERSIONPATCH=-mint-20191013
SOURCE_DIR=$(BUILD_DIR)/$(PACKAGE_NAME)-$(VERSION)
COMPIL_DIR=$(BUILD_DIR)/$(PACKAGE_NAME)-$(VERSION)$(VERSIONPATCH)-$(VERSIONBIN)
GIT_SRC=
ARCHIVE_SRC_FILE=$(PACKAGE_NAME)-$(VERSION).tar.bz2
ARCHIVE_PATCH_FILE=$(PACKAGE_NAME)-$(VERSION)$(VERSIONPATCH).patch.bz2
PACKAGE_FILE=$(PACKAGE_NAME)-$(VERSION)$(VERSIONPATCH)-$(VERSIONBIN)-$(VERSIONBUILD).tgz

BINARY_DIR=$(COMPIL_DIR)/binary-package
LOCAL_PREFIX_DIR=$(BINARY_DIR)$(PREFIX)

M68K_PREFIX=$(PREFIX)/m68k-atari-mint
CFLAGS=

ifneq "$(GCC)" ""
  GCC_BUILD_DIR=$(dir $(GCC))
  CC=$(GCC) -B$(GCC_BUILD_DIR) -B$(M68K_PREFIX)/bin/ -B$(M68K_PREFIX)/lib/ -isystem $(M68K_PREFIX)/include -isystem $(M68K_PREFIX)/sys-include
else
  CC=m68k-atari-mint-gcc
endif


##########################################
.PHONY: all clean extract patch configure compile packaging install

all:		extract patch configure compile packaging install

clean:	
ifeq "$(BUILD_DIR)" ""
	@echo "BUILD_DIR is not set" && exit 1
endif
	rm -rf "$(COMPIL_DIR)"
	rm -rf "$(SOURCE_DIR)"
	rm -rf "$(PACKAGES_DIR)/$(PACKAGE_FILE)"


##########################################
extract:	$(SOURCE_DIR)

patch:		$(SOURCE_DIR)/_patch_$(PACKAGE_NAME)

configure:

compile:
	@echo CC=$(GCC) GCC build dir=$(GCC_BUILD_DIR)
	cd "$(SOURCE_DIR)/pmlsrc" && \
	sed -i ".bak" "s:^\(CROSSDIR =\).*:\1 $(M68K_PREFIX):g" Makefile Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:^\(AR =\).*:\1 m68k-atari-mint-ar:g" Makefile Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:^\(CC =\).*:\1 $(CC):g" Makefile Makefile.32 Makefile.16
	make -j $(NUM_CPUS) --directory="$(SOURCE_DIR)/pmlsrc"
	make --directory="$(SOURCE_DIR)/pmlsrc" install CROSSDIR=$(LOCAL_PREFIX_DIR)/m68k-atari-mint

	make --directory="$(SOURCE_DIR)/pmlsrc" clean
	cd "$(SOURCE_DIR)/pmlsrc" && \
	sed -i ".bak" "s:^\(CFLAGS =.*\):\1 -m68020-60:g" Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:^\(CROSSLIB =.*\):\1/m68020-60:g" Makefile
	make -j $(NUM_CPUS) --directory="$(SOURCE_DIR)/pmlsrc"
	make --directory="$(SOURCE_DIR)/pmlsrc" install CROSSDIR=$(LOCAL_PREFIX_DIR)/m68k-atari-mint

	make --directory="$(SOURCE_DIR)/pmlsrc" clean
	cd "$(SOURCE_DIR)/pmlsrc" && \
	sed -i ".bak" "s:-m68020-60:-mcpu=5475:g" Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:m68020-60:m5475:g" Makefile
	make -j $(NUM_CPUS) --directory="$(SOURCE_DIR)/pmlsrc"
	make --directory="$(SOURCE_DIR)/pmlsrc" install CROSSDIR=$(LOCAL_PREFIX_DIR)/m68k-atari-mint

	cd "$(SOURCE_DIR)/pmlsrc" && \
	sed -i ".bak" "s:^\(CFLAGS =.*\) -m5475 -DNO_INLINE_MATH:\1:g" Makefile.32 Makefile.16 && \
	sed -i ".bak" "s:^\(CROSSLIB =.*\)/m5475:\1:g" Makefile

packaging:	$(PACKAGES_DIR)/$(PACKAGE_FILE)

install:	packaging
	tar xvzf "$(PACKAGES_DIR)/$(PACKAGE_FILE)" --directory $(dir $(PREFIX))


##########################################
# extract sources
$(SOURCE_DIR):
ifneq "$(ARCHIVE_SRC_FILE)" ""
	$(MAKE) FILE="$(ARCHIVE_SRC_FILE)" fetch
	tar xvjf "$(ARCHIVES_DIR)/$(ARCHIVE_SRC_FILE)" --directory "$(BUILD_DIR)"
endif
ifneq "$(GIT_SRC)" ""
	mkdir -p "$(dir $(SOURCE_DIR))"
	git clone --depth 1 $(GIT_SRC) $(SOURCE_DIR)/
endif


# apply patch to sources
$(SOURCE_DIR)/_patch_$(PACKAGE_NAME):
ifneq "$(VERSIONPATCH)" ""
	$(MAKE) FILE="$(ARCHIVE_PATCH_FILE)" fetch
	bzcat "$(ARCHIVES_DIR)/$(ARCHIVE_PATCH_FILE)" | patch -p1 --directory $(SOURCE_DIR) && touch "$(SOURCE_DIR)/_patch_$(PACKAGE_NAME)"
endif


# build distribution package
$(PACKAGES_DIR)/$(PACKAGE_FILE): compile
	-rm -rf "$(LOCAL_PREFIX_DIR)"/lib/m68020-60/mshort
	-rm -rf "$(LOCAL_PREFIX_DIR)"/lib/m5475/mshort
	tar cvzf "$@" --directory "$(dir $(LOCAL_PREFIX_DIR))" $(notdir $(LOCAL_PREFIX_DIR)) 
