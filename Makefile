BASE_DIR=$(CURDIR)

# Source and destination directories
export ARCHIVES_DIR=$(BASE_DIR)/archive
export BUILD_DIR=$(BASE_DIR)/compil
export PACKAGES_DIR=$(BASE_DIR)/packages

# Installation location
export PREFIX=/opt/cross-mint

# Add search path for cross tools
export PATH:=$(PATH):/opt/cross-mint/bin

# Default cross compiler
export CC=$(shell which m68k-atari-mint-gcc)
ARCH1=x86_64
ARCH2=i386

##########################################
export VERSIONBIN=bin-$(shell uname -s  | tr "[:upper:]" "[:lower:]")
export VERSIONBINCPU=$(VERSIONBIN)-$(shell uname -m  | tr "[:upper:]" "[:lower:]")
export VERSIONBUILD=$(shell date +%Y%m%d)

##########################################
all:	init_dirs binutils mintbin gcc gemlib distrib

init_dirs:	$(BUILD_DIR) $(PACKAGES_DIR) $(PREFIX)
	mkdir -p "$(BUILD_DIR)/dep_libs"
	cp -rf "$(ARCHIVES_DIR)/dep_libs/$(shell uname -p)/"* "$(BUILD_DIR)/dep_libs/"

clean:
	rm -rf "$(BUILD_DIR)"

gcc:	gcc464

binutils mintbin mintlib pml gemlib cflib qed gcc464 gemma:	init_dirs
	$(MAKE) -f Makefile.$@

distrib:
	cd "$(dir $(PREFIX))" && \
	tar cvzf "$(PACKAGES_DIR)/m68k-cross-mint-$(VERSIONBINCPU)-$(VERSIONBUILD).tgz" \
		--exclude .DS_Store --exclude "._*" cross-mint

universal_distrib:
	rm -rf "$(BUILD_DIR)/universal_distrib/"
	mkdir -p "$(BUILD_DIR)/universal_distrib/$(ARCH1)" "$(BUILD_DIR)/universal_distrib/$(ARCH2)"
	tar xzf "$(PACKAGES_DIR)/m68k-cross-mint-$(VERSIONBIN)-$(ARCH1)-$(VERSIONBUILD).tgz"     --exclude "._*" -C "$(BUILD_DIR)/universal_distrib/$(ARCH1)/"
	tar xzf "$(PACKAGES_DIR)/m68k-cross-mint-$(VERSIONBIN)-$(ARCH2)-$(VERSIONBUILD).tgz"  --exclude "._*" -C "$(BUILD_DIR)/universal_distrib/$(ARCH2)/"
	cd "$(BUILD_DIR)/universal_distrib/$(ARCH1)/" && \
	  find . -type f -perm +wxr \( ! -name "*lib*" -or -name "*ranlib*" \) -print -exec lipo -create -arch $(ARCH1) {} -arch $(ARCH2) ../$(ARCH2)/{} -output {} ";" && \
	  echo "--------- Universal Binaries linked ----------"
	find "$(BUILD_DIR)/universal_distrib/$(ARCH1)/cross-mint" -type f -perm +rwx -ls -exec lipo -info {} ";"
	rm -rf "$(BUILD_DIR)/universal_distrib/$(ARCH2)"
	tar cvzf "$(PACKAGES_DIR)/m68k-cross-mint-$(VERSIONBIN)-universal-$(VERSIONBUILD).tgz" \
		--exclude .DS_Store --exclude "._*" -C "$(BUILD_DIR)/universal_distrib/$(ARCH1)/" cross-mint

###########################################
$(BUILD_DIR) $(PACKAGES_DIR) $(PREFIX):
	mkdir -p "$@"
