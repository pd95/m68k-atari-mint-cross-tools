include VARS

# Default cross compiler
#export CC=$(shell which m68k-atari-mint-gcc)
ARCH1=x86_64
ARCH2=i386

##########################################
all:	init_dirs binutils mintbin gcc gemlib distrib

init_dirs: $(BUILD_DIR) $(PACKAGES_DIR) $(ARCHIVES_DIR) $(PREFIX)

clean:
ifeq "$(BUILD_DIR)" ""
	@echo "BUILD_DIR is not set" && exit 1
endif
	rm -rf "$(BUILD_DIR)"
	rm -rf "$(ARCHIVES_DIR)/gcclibs/$(ARCH)"

gcc:	$(BUILD_DIR)/gcclibs gcc464

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
$(BUILD_DIR) $(PACKAGES_DIR) $(PREFIX) $(ARCHIVES_DIR):
	mkdir -p "$@"

$(ARCHIVES_DIR)/gcclibs/$(ARCH)/:
	$(MAKE) -f Makefile.gcclibs

$(BUILD_DIR)/gcclibs:		$(ARCHIVES_DIR)/gcclibs/$(ARCH)/
	mkdir -p "$(BUILD_DIR)/gcclibs"
	cp -rf "$(ARCHIVES_DIR)/gcclibs/$(ARCH)/"* "$(BUILD_DIR)/gcclibs/"

fetch:
	if [ ! -f "$(ARCHIVES_DIR)/$(FILE)" ] ; then cd $(ARCHIVES_DIR) ; curl -O -f "http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$(FILE)" ; else echo "** Patch file $(FILE) already load." ; fi
