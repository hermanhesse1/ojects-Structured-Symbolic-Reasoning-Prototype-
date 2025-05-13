# ojects-Structured-Symbolic-Reasoning-Prototype:
This is a foundational approach to integrating Haskell for core symbolic logic processing with Python for high-level orchestration and data pipelining. It features a simple Haskell module compiled into a shared library, callable from Python using ctypes via a Foreign Function Interface. 
The current example showcases a basic "inference" task (counting positive integers) to illustrate the FFI setup, project structure, and potential for building more complex symbolic reasoning engines. It serves as a template for leveraging Haskell's strong typing and functional paradigms for logic components within a Python ecosystem.
The code involves the following: Haskell core logic module.
FFI export for C-compatible function calls.
Python ctypes interface for loading and calling Haskell functions.
Example data pipeline and benchmarking in Python.
Makefile for easy compilation of the Haskell shared library.
Unit tests for the FFI bridge.

# Structured Symbolic Reasoning Prototype

## 1. Overview

This project is a minimalist prototype of a "symbolic reasoning engine." It demonstrates the integration of **Haskell** for core logic and **Python** for orchestration, data pipelining, and evaluation. The central idea is to leverage Haskell's strengths in functional programming and type safety for defining reasoning steps (conceptually inspired by category-theoretic abstractions like functors and monads, though simplified in this initial prototype) and then to call this Haskell core from Python using a Foreign Function Interface (FFI).

The current example implements a very simple "inference" task: **counting positive integers in a list**. While this task is trivial, it serves to showcase:
- The FFI mechanism between Python and Haskell.
- A basic project structure for such hybrid systems.
- A pipeline for data generation, execution, and benchmarking.

This prototype is intended as a foundational example that could be extended for more complex symbolic reasoning tasks.

## 2. Project Structure

The project is organized as follows:

symbolica-prototype/├── haskell/                # Haskell core logic│   ├── Logic.hs            # Main Haskell source file with FFI exports│   └── Makefile            # Makefile to compile the Haskell code into a shared library├── python/                 # Python scripts for orchestration and interface│   ├── interface.py        # Python ctypes wrapper for Haskell functions│   └── pipeline.py         # Data generation, Haskell invocation, evaluation, benchmarking├── data/                   # Sample data files (currently conceptual)│   └── facts.json          # Toy dataset of “facts” (placeholder for more complex logic)├── tests/                  # Unit tests│   └── test_logic.py       # Unit tests for the Python-Haskell FFI bridge└── README.md               # This file: project overview, build/run instructions
## 3. Core Components

### 3.1. Haskell Reasoning Core (`haskell/Logic.hs`)

- **`Logic.hs`**: Contains the Haskell function `internalCountPositives` which performs the actual counting.
- **FFI Export**: The function `count_positives` is exposed via Haskell's FFI using `foreign export ccall`. This makes it callable from C-compatible languages.
- **Data Marshalling**: Uses `Foreign.C.Types`, `Foreign.Ptr`, `Foreign.Storable`, and `Foreign.Marshal.Array` for handling C data types (like `CInt`) and marshalling arrays between Haskell and C memory representations.

### 3.2. Python–Haskell Integration (`python/interface.py`)

- **`ctypes` Library**: Python's built-in `ctypes` library is used to load the compiled Haskell shared library (`.so` on Linux, `.dylib` on macOS, `.dll` on Windows).
- **Function Signature Definition**: `argtypes` (argument types) and `restype` (return type) are defined for the loaded Haskell function to ensure correct data interpretation.
- **Wrapper Function**: `count_positives_haskell(data_list)` provides a Python-friendly interface. It handles:
    - Converting a Python list of integers into a C-compatible array (`ctypes.c_int * n`).
    - Calling the Haskell FFI function.
    - Returning the result as a Python integer.
- **Dynamic Library Path**: The script attempts to locate the Haskell library in a sibling `haskell/` directory.

### 3.3. Data Pipeline and Evaluation (`python/pipeline.py`)

- **Data Generation**: `generate_dataset()` creates lists of random integers for testing.
- **Baseline Python Implementation**: `count_positives_python()` provides a pure Python version of the counting logic for comparison and verification.
- **Experiment Orchestration**: `run_experiment()`:
    - Generates datasets.
    - Executes and times both the Python and Haskell implementations.
    - Compares their results for correctness.
    - Calculates and prints average execution times over multiple runs.
    - Provides a simple performance comparison.

### 3.4. Unit Testing (`tests/test_logic.py`)

- **`unittest` Framework**: Uses Python's standard `unittest` module.
- **Test Cases**: Includes various test cases for `count_positives_haskell`, such as empty lists, all positives, all negatives, mixed values, and boundary conditions.
- **Skipping Tests**: If the Haskell library cannot be loaded, the FFI tests are skipped with a message.

## 4. Build and Run Instructions

### 4.1. Prerequisites

- **GHC (Glasgow Haskell Compiler)**: Required to compile the Haskell code.
    - Installation: Visit [haskell.org/ghc/](https://www.haskell.org/ghc/)
    - Ensure `ghc` is in your system's PATH.
- **Python**: Version 3.6+ recommended.
    - `ctypes` is part of the standard library. No external pip packages are needed for this core prototype.
- **Make**: Typically available on Linux and macOS. On Windows, you might use `make` within environments like MinGW/MSYS2 or WSL.

### 4.2. Step 1: Compile the Haskell Core

1.  Navigate to the `haskell/` directory:
    ```bash
    cd path/to/symbolica-prototype/haskell
    ```
2.  Run `make` to compile `Logic.hs` into a shared library:
    ```bash
    make
    ```
    This command will:
    - Invoke GHC with appropriate flags (`-O2 -shared -dynamic -fPIC`).
    - Create a shared library file in the `haskell/` directory. The name will be:
        - `liblogic.so` (Linux)
        - `liblogic.dylib` (macOS)
        - `liblogic.dll` (Windows, if using MinGW/MSYS2 `make` and `ghc`)

    If you encounter issues, ensure GHC is correctly installed and check the output from `make` for errors.

### 4.3. Step 2: Run the Python Pipeline

1.  Navigate to the `python/` directory:
    ```bash
    cd path/to/symbolica-prototype/python
    # Or, if you were in haskell/: cd ../python
    ```
2.  Execute the `pipeline.py` script:
    ```bash
    python pipeline.py
    ```
    The script will:
    - Attempt to load the Haskell shared library.
    - Run the benchmarking experiment.
    - Print results, timings, and verification status.

    If `interface.py` cannot find or load the Haskell library, it will print an error message, and `pipeline.py` will indicate that the Haskell part cannot be run.

### 4.4. Step 3: Run Unit Tests (Optional)

1.  Navigate to the **project root directory** (`symbolica-prototype/`):
    ```bash
    cd path/to/symbolica-prototype
    ```
2.  Run the tests using Python's `unittest` module:
    ```bash
    python -m unittest tests.test_logic
    ```
    Alternatively, you can navigate to the `tests/` directory and run:
    ```bash
    # cd tests
    # python test_logic.py
    ```
    The tests verify the correctness of the `count_positives_haskell` FFI wrapper.

## 5. Design Rationale & Future Extensions

- **Category-Theoretic Inspiration (Conceptual)**: While this prototype's logic (`count_positives`) is extremely simple, the overall architecture (Haskell core for logic, Python for orchestration) is designed to be a starting point. For more advanced symbolic reasoning, one could:
    - Define custom algebraic data types (ADTs) in Haskell to represent logical formulas, terms, or knowledge bases.
    - Implement inference rules as Haskell functions.
    - Use Haskell's powerful type system to ensure correctness.
    - Employ monads (e.g., a custom `LogicMonad` or `StateT KnowledgeBase IO`) to manage state (like a knowledge base), handle non-determinism (e.g., in proof search), or sequence complex computations.
- **FFI Overhead**: For very trivial functions like the current example, the overhead of the FFI call itself (data marshalling, context switching) might be significant compared to the actual computation. The benefits of using Haskell via FFI become more apparent for more computationally intensive or complex logic that benefits from Haskell's features.
- **Error Handling**: The current error handling is basic (primarily checking if the library loads). A production-grade system would require more robust error propagation and handling mechanisms between Haskell and Python (e.g., using error codes, custom exception types).
- **Data Serialization**: For passing complex data structures (beyond simple arrays of integers) between Python and Haskell, more sophisticated serialization/deserialization techniques would be needed (e.g., JSON, Protocol Buffers, or custom binary formats).
- **Build Systems**: For larger Haskell projects, tools like `Stack` or `Cabal` are commonly used for dependency management and building. For Python, `Poetry` or `PDM` can manage dependencies and virtual environments.

## 6. Troubleshooting

- **`Error loading Haskell library` / `OSError: ... cannot open shared object file ...` (in `interface.py` or `pipeline.py`)**:
    - **Did you compile?** Ensure you have run `make` in the `haskell/` directory successfully.
    - **Is the library present?** Verify that the shared library file (`liblogic.so`, `liblogic.dylib`, or `liblogic.dll`) exists in the `haskell/` directory.
    - **Path issues?** `interface.py` attempts to locate the library using a relative path (`../haskell/liblogic.<ext>`). If your project structure is different, this path might need adjustment.
    - **OS-specific library paths (less likely with relative pathing)**:
        - On Linux, ensure the directory containing the `.so` file is in your `LD_LIBRARY_PATH` if not using a direct path load.
        - On macOS, similar considerations apply for `DYLD_LIBRARY_PATH`.
- **`ghc: command not found` (during `make`)**:
    - GHC is not installed, or its `bin` directory is not in your system's PATH environment variable. Revisit the GHC installation instructions.
- **Test Failures in `test_logic.py`**:
    - Ensure the Haskell library is compiled and loaded correctly. If tests are skipped, it's likely a library loading issue.
    - If tests fail, compare the output with the expected values in the test cases. This could indicate an issue in the Haskell logic, the FFI marshalling, or the Python wrapper.

This prototype serves as a foundational example for integrating Haskell and Python, enabling developers to leverage Haskell's strengths for core computational or logical tasks within a broader Python-driven ecosystem.


