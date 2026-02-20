PREFIX ?= /opt/cross-mint
TARGET ?= m68k-atari-mint

CC = $(PREFIX)/bin/$(TARGET)-gcc
OBJDUMP = $(PREFIX)/bin/$(TARGET)-objdump
FILE_CMD ?= file

BUILD_DIR ?= build
LIBCMINI_ROOT ?= $(PREFIX)/m68k-atari-mint/libcmini
ROOT_DIR ?= ..

CFLAGS_COMMON ?= -O2
LDFLAGS_COMMON ?=
LDLIBS_COMMON ?=

LIBCMINI_CFLAGS ?= -I$(LIBCMINI_ROOT)/include
LIBCMINI_LDFLAGS ?= -s -nostdlib $(LIBCMINI_ROOT)/lib/crt0.o
LIBCMINI_LDLIBS ?= -L$(LIBCMINI_ROOT)/lib -lgcc -lcmini -lgcc

HELLO_DEFAULT_BIN := $(BUILD_DIR)/hello-default.tos
HELLO_MINIMAL_OBJ := $(BUILD_DIR)/hello-minimal.o
HELLO_MINIMAL_BIN := $(BUILD_DIR)/hello-minimal.tos
HELLO_GEM_BIN := $(BUILD_DIR)/hello-gem.prg

.PHONY: all clean check check_all \
	hello_world hello_world_gem hello_world_minimal \
	qed_check qed_build_check qed_build

all: hello_world hello_world_gem hello_world_minimal

hello_world: $(HELLO_DEFAULT_BIN)

hello_world_minimal: hello_world $(HELLO_MINIMAL_BIN)

hello_world_gem: $(HELLO_GEM_BIN)

check: all
	@echo "All test binaries were built and validated."

check_all: check qed_build_check
	@echo "All tests including QED were validated."

qed_build:
	$(MAKE) -C "$(ROOT_DIR)" PREFIX="$(PREFIX)" cflib qed

qed_check:
	@qed_app=$$(ls -1dt "$(ROOT_DIR)"/compile/qed-*-mint-macos-bin-*/binary-package/qed/qed*.app 2>/dev/null | head -n1); \
	test -n "$$qed_app" || { echo "No QED app found. Run 'make -C tests qed_build_check' or build cflib/qed first."; exit 1; }; \
	$(FILE_CMD) "$$qed_app" | grep -q "Atari ST M68K contiguous executable"; \
	$(OBJDUMP) -f "$$qed_app" | grep -q "file format a.out-mintprg"; \
	$(OBJDUMP) -d "$$qed_app" | grep -q "Disassembly of section .text:"

qed_build_check: qed_build qed_check
	@echo "QED build and validation passed."

$(BUILD_DIR):
	mkdir -p "$@"

$(HELLO_DEFAULT_BIN): hello.c | $(BUILD_DIR)
	$(CC) $(CFLAGS_COMMON) $(LDFLAGS_COMMON) -o "$@" "$<" $(LDLIBS_COMMON)
	@$(FILE_CMD) "$@" | grep -q "Atari ST M68K contiguous executable"
	@$(OBJDUMP) -f "$@" | grep -q "file format a.out-mintprg"
	@$(OBJDUMP) -t "$@" | grep -q "___libc_main"

$(HELLO_GEM_BIN): hello_gem.c | $(BUILD_DIR)
	$(CC) $(CFLAGS_COMMON) -o "$@" "$<" -lgem
	@$(FILE_CMD) "$@" | grep -q "Atari ST M68K contiguous executable"
	@$(OBJDUMP) -f "$@" | grep -q "file format a.out-mintprg"
	@$(OBJDUMP) -t "$@" | grep -q "_mt_form_alert"

$(HELLO_MINIMAL_OBJ): hello.c | $(BUILD_DIR)
	$(CC) $(CFLAGS_COMMON) $(LIBCMINI_CFLAGS) -c -o "$@" "$<"

$(HELLO_MINIMAL_BIN): $(HELLO_MINIMAL_OBJ)
	$(CC) -o "$@" $(LIBCMINI_LDFLAGS) "$(HELLO_MINIMAL_OBJ)" $(LIBCMINI_LDLIBS)
	@$(FILE_CMD) "$@" | grep -q "Atari ST M68K contiguous executable"
	@$(OBJDUMP) -f "$@" | grep -q "file format a.out-mintprg"
	@strings "$@" | grep -q "Hello world"
	@test "$$(wc -c < "$@")" -lt "$$(wc -c < "$(HELLO_DEFAULT_BIN)")"

clean:
	rm -rf "$(BUILD_DIR)"
