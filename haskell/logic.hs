{-# LANGUAGE ForeignFunctionInterface #-}
-- File: haskell/Logic.hs
-- Description: Core logic in Haskell, exposed via FFI for use by Python.
-- This module provides a simple "reasoning" function: counting positive integers in a list.
-- It serves as a basic example of Haskell-Python interoperability.

module Logic (
    -- FFI-exported function available to C-compatible callers (like Python's ctypes)
    count_positives
) where

import Foreign.C.Types      -- Provides C-compatible types like CInt, CDouble, etc.
import Foreign.Ptr          -- For working with raw memory pointers (Ptr a).
import Foreign.Storable     -- For reading from ('peek') and writing to ('poke') memory locations
                            -- where data is stored in a C-compatible way.
import Foreign.Marshal.Array -- Provides functions to work with arrays in C memory,
                            -- like 'peekArray' (read C array into Haskell list)
                            -- and 'pokeArray' (write Haskell list to C array).

-- | Internal Haskell function to perform the core logic: counting positive integers.
--
--   Type: [CInt] -> IO CInt
--   Input: A Haskell list of 'CInt' (C-style integers).
--   Output: An 'IO CInt', representing a computation that will produce a 'CInt'.
--
--   Why 'IO CInt' and not just 'CInt'?
--   1. FFI Interactions: Any function directly involved in FFI (Foreign Function Interface)
--      operations, especially those that might interact with external state or memory
--      managed by C, typically operates within the 'IO' monad. This signals that the
--      function can have side effects.
--   2. Laziness and Evaluation: 'IO' helps ensure that computations are performed when
--      expected, which is crucial when dealing with external calls.
--
--   If this were a purely internal Haskell computation with no FFI involvement,
--   and if it were a pure function, its type might be '[CInt] -> CInt'.
--   However, as it's called by an FFI wrapper, 'IO' is appropriate.
internalCountPositives :: [CInt] -> IO CInt
internalCountPositives xs = do
  -- The core logic: filter out elements greater than 0.
  let positiveElements = filter (\x -> x > 0) xs
  
  -- Get the count of positive elements. 'length' returns an 'Int'.
  let count = length positiveElements
  
  -- Convert the Haskell 'Int' to 'CInt'.
  -- 'fromIntegral' is a polymorphic function that can convert between various
  -- integral types. Here, it converts Int to CInt.
  -- Note: If 'count' were to exceed the maximum value representable by CInt
  -- (e.g., if CInt is 32-bit and count is > 2^31 - 1), 'fromIntegral' would
  -- truncate the value, leading to incorrect results. For this prototype with
  -- typical array sizes, this is unlikely, but in production with potentially
  -- very large counts, error checking or using a larger C type (like CLong)
  -- might be necessary.
  let cIntCount = fromIntegral count
  
  -- 'return' in the context of a 'do' block for an 'IO' action wraps
  -- the pure value 'cIntCount' into an 'IO' context.
  return cIntCount

-- | Foreign Function Interface (FFI) Export: 'count_positives'
--   This Haskell function is made available to be called from C code (and thus
--   from Python using ctypes, which acts as a C FFI client).
--
--   Haskell Signature: Ptr CInt -> CInt -> IO CInt
--   Equivalent C Signature: int count_positives(int* array_ptr, int length);
--
--   Parameters:
--     cIntArrayPtr (Ptr CInt): A pointer to the beginning of an array of C integers.
--                              This memory is allocated and managed by the caller (Python).
--     cLength (CInt):          The number of elements in the C array.
--
--   Returns:
--     IO CInt: An IO action that, when performed, yields the count of positive numbers
--              as a CInt. Python will receive this as a standard integer.
foreign export ccall count_positives :: Ptr CInt -> CInt -> IO CInt
count_positives :: Ptr CInt -> CInt -> IO CInt -- Type signature for clarity, GHC infers it from foreign export
count_positives cIntArrayPtr cLength = do
  -- Convert the CInt length (provided by the C caller) to a Haskell Int.
  -- 'peekArray' expects the length as a Haskell 'Int'.
  -- 'fromIntegral' is safe here as array lengths are typically within Int bounds.
  let arrayLengthAsHaskellInt = fromIntegral cLength

  -- Read the data from the C array into a Haskell list.
  -- 'peekArray' takes the number of elements to read and the pointer to the array.
  -- It safely reads 'arrayLengthAsHaskellInt' elements of type 'CInt'
  -- from the memory location 'cIntArrayPtr' and constructs a Haskell list '[CInt]'.
  -- This is a crucial step for marshalling data from C-managed memory to Haskell.
  haskellListOfCInts <- peekArray arrayLengthAsHaskellInt cIntArrayPtr

  -- Call the internal Haskell function with the now-Haskell-native list.
  internalCountPositives haskellListOfCInts

-- --- Conceptual Examples for Future Expansion (Not currently used by Python) ---
-- These demonstrate how one might use functors or monads for more complex logic,
-- aligning with the "category-theory inspired" aspect of the project description.

-- Example 1: A simple Functor 'FactBox'
-- A functor allows applying a function to a wrapped value without unwrapping it.
-- newtype FactBox a = FactBox a deriving (Show, Functor)

-- 'applyRuleToFactBox' would use fmap (the hallmark of a Functor)
-- applyRuleToFactBox :: (a -> b) -> FactBox a -> FactBox b
-- applyRuleToFactBox rule box = fmap rule box -- or simply 'rule <$> box'

-- Example 2: Monadic sequencing for stateful operations (using IO as an example)
-- A monad can sequence computations, especially those with context (like IO, State, Maybe).

-- A toy "knowledge base" (just a list of strings) and a function to add facts.
-- addFacts :: [String] -> [String] -> IO [String] -- IO used for demonstration
-- addFacts currentKnowledgeBase newFacts = do
--   putStrLn $ "Adding new facts: " ++ show newFacts -- Example of an IO action
--   let updatedKnowledgeBase = currentKnowledgeBase ++ newFacts
--   return updatedKnowledgeBase

-- 'performInferenceSequence' demonstrates chaining 'addFacts' using do-notation (monadic bind).
-- performInferenceSequence :: IO [String]
-- performInferenceSequence = do
--   kb0 <- addFacts [] ["fact: Socrates is a man"]
--   kb1 <- addFacts kb0 ["rule: All men are mortal"]
--   -- In a real system, an inference step would occur here based on kb1
--   let kb2 = kb1 ++ ["inferred_fact: Socrates is mortal"] -- Manual "inference"
--   return kb2
