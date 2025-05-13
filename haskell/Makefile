# File: haskell/Makefile
# Description: Makefile to compile the Haskell Logic.hs into a shared library.

# Compiler and flags
GHC = ghc
# -O2: Optimization level 2
# -shared: Create a shared library
# -dynamic: Link against dynamic Haskell runtime (recommended for shared libs)
# -fPIC: Position Independent Code (required for shared libraries)
# -v: Verbose output (optional, for debugging build process)
GHC_FLAGS = -O2 -shared -dynamic -fPIC

# Source file
SOURCE_HS = Logic.hs

# Determine OS to set the correct shared library extension
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    # macOS
    TARGET_LIB_NAME = liblogic.dylib
else ifeq ($(UNAME_S),Linux)
    # Linux
    TARGET_LIB_NAME = liblogic.so
else ifneq (,$(findstring MINGW,$(UNAME_S)))
    # Windows (MinGW/MSYS2)
    TARGET_LIB_NAME = liblogic.dll
else ifneq (,$(findstring CYGWIN,$(UNAME_S)))
    # Windows (Cygwin)
    TARGET_LIB_NAME = liblogic.dll
else
    # Default to .so for other Unix-like systems
    TARGET_LIB_NAME = liblogic.so
endif

# Output target: the shared library
TARGET_LIB = $(TARGET_LIB_NAME)

# Default target: build the library
all: $(TARGET_LIB)

# Rule to build the shared library
# $< refers to the first prerequisite (Logic.hs)
# $@ refers to the target (liblogic.so/dylib/dll)
$(TARGET_LIB): $(SOURCE_HS)
	@echo "Compiling Haskell source $(SOURCE_HS) to shared library $(TARGET_LIB)..."
	$(GHC) $(GHC_FLAGS) -o $@ $<
	@echo "Build complete: $(TARGET_LIB)"

# Clean rule: remove compiled files
clean:
	@echo "Cleaning Haskell build artifacts..."
	rm -f *.o *.hi $(TARGET_LIB_NAME) liblogic.dll liblogic.so liblogic.dylib # Remove all possible variants
	@echo "Clean complete."

# Phony targets: targets that don't represent actual files
.PHONY: all clean

# To use this Makefile:
# 1. Ensure GHC is installed and in your PATH.
# 2. Navigate to this 'haskell' directory in your terminal.
# 3. Run 'make' to build the library.
# 4. Run 'make clean' to remove build artifacts.
