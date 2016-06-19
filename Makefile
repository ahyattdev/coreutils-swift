SWIFTC ?= xcrun -sdk macosx swiftc
SWIFTFLAGS ?=
DESTDIR ?=

PWD = $(shell pwd)
BUILD_ROOT ?= build
BUILD_LIB_ROOT = $(BUILD_ROOT)/lib
BUILD_BIN_ROOT = $(BUILD_ROOT)/bin

BUILD_FOLDERS = $(BUILD_BIN_ROOT) $(BUILD_LIB_ROOT)

LIBS = CommandLine Rainbow

LIB_PRODUCTS = $(LIBS:%=$(BUILD_LIB_ROOT)/lib%.dylib) $(LIBS:%=$(BUILD_LIB_ROOT)/%.swiftmodule) $(LIBS:%=$(BUILD_LIB_ROOT)/%.swiftdoc)

BINARIES = ls whoami uname env sleep wc echo yes true false pwd mkdir date domainname sync

BIN_PRODUCTS = $(BINARIES:%=$(BUILD_BIN_ROOT)/%)

all: $(LIB_PRODUCTS) $(BIN_PRODUCTS)

$(BUILD_LIB_ROOT)/%.swiftmodule: $(BUILD_LIB_ROOT)/lib%.dylib

$(BUILD_LIB_ROOT)/%.swiftdoc: $(BUILD_LIB_ROOT)/lib%.dylib

$(BUILD_LIB_ROOT)/lib%.dylib: lib/%/*.swift | $(BUILD_FOLDERS)
	$(SWIFTC) \
	-emit-library \
	-o $(BUILD_LIB_ROOT)/lib$*.dylib \
	-Xlinker -install_name \
	-Xlinker @rpath/../lib/lib$*.dylib \
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
	-Xlinker -rpath \
	-Xlinker @executable_path \
	$(SWIFTFLAGS) \
	src/*.swift src/$*/*.swift

.PHONY: create-build-folder

$(BUILD_FOLDERS):
	mkdir -p $@

clean:
	rm -rf $(BUILD_ROOT)

set-path:
	export PATH=$(BUILD_BIN_ROOT):$(PATH)

install:
