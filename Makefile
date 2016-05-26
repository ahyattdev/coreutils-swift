OS = $(shell uname)

ifeq ($(OS),Linux)

SWIFTC = swiftc
LIB_EXT = so
SWIFT_LIB_LFLAGS = -Xlinker -rpath=../lib/lib$*.$(LIB_EXT)
SWIFT_BIN_LDFLAGS = -Xlinker -rpath -Xlinker ../lib

endif

ifeq ($(OS),Darwin)

SWIFTC := $(shell xcrun -sdk macosx swiftc)
LIB_EXT = dylib
SWIFT_LIB_LFLAGS = -Xlinker -install_name -Xlinker @rpath/../lib/lib$*.$(LIB_EXT)
SWIFT_BIN_LDFLAGS = -Xlinker -rpath -Xlinker @executable_path

endif

SWIFTFLAGS ?=
DESTDIR ?=

PWD := $(shell pwd)
BUILD_ROOT ?= build
BUILD_LIB_ROOT = $(BUILD_ROOT)/lib
BUILD_BIN_ROOT = $(BUILD_ROOT)/bin

BUILD_FOLDERS = $(BUILD_BIN_ROOT) $(BUILD_LIB_ROOT)

LIBS = CommandLine Rainbow

LIB_PRODUCTS = $(LIBS:%=$(BUILD_LIB_ROOT)/lib%.$(LIB_EXT)) $(LIBS:%=$(BUILD_LIB_ROOT)/%.swiftmodule) $(LIBS:%=$(BUILD_LIB_ROOT)/%.swiftdoc)

BINARIES = ls whoami uname env sleep wc echo yes true false pwd mkdir

BIN_PRODUCTS = $(BINARIES:%=$(BUILD_BIN_ROOT)/%)

all: $(LIB_PRODUCTS) $(BIN_PRODUCTS)

$(BUILD_LIB_ROOT)/%.swiftmodule: $(BUILD_LIB_ROOT)/lib%.$(LIB_EXT)

$(BUILD_LIB_ROOT)/%.swiftdoc: $(BUILD_LIB_ROOT)/lib%.$(LIB_EXT)

$(BUILD_LIB_ROOT)/lib%.$(LIB_EXT): lib/%/*.swift | $(BUILD_FOLDERS)
	$(SWIFTC) \
	-emit-library \
	-o $(BUILD_LIB_ROOT)/lib$*.$(LIB_EXT) \
	$(SWIFT_LIB_LFLAGS) \
	-emit-module \
	-emit-module-path $(BUILD_LIB_ROOT)/$*.swiftmodule \
	-module-name $* \
	-module-link-name $* \
	$(SWIFTFLAGS) \
	lib/$*/*.swift

$(BUILD_BIN_ROOT)/%: $(LIB_PRODUCTS) src/*.swift src/%/*.swift
	$(SWIFTC) \
	-o $(BUILD_BIN_ROOT)/$* \
	-I $(BUILD_LIB_ROOT) \
	-L $(BUILD_LIB_ROOT) \
	$(SWIFT_BIN_LDFLAGS) \
	$(SWIFTFLAGS) \
	src/*.swift src/$*/*.swift

$(BUILD_FOLDERS):
	mkdir -p $@

clean:
	rm -rf $(BUILD_ROOT)

set-path:
	export PATH=$(BUILD_BIN_ROOT):$(PATH)

test:
	BUILD_BIN_ROOT=$(BUILD_BIN_ROOT) ./tests.sh
