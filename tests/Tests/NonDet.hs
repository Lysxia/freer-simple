module Tests.NonDet (tests) where

import Control.Applicative ((<|>))
import Control.Monad (guard, msum, mzero)
import Data.List ((\\))

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.QuickCheck (testProperty)

import Control.Monad.Freer (Eff, Member, run)
import Control.Monad.Freer.NonDet (NonDet, makeChoiceA, msplit)

tests :: TestTree
tests = testGroup "NonDet tests"
  [ testProperty "Primes in 2..n generated by ifte"
      $ \n' -> let n = abs n' in testIfte [2 .. n] == primesTo n
  ]

-- https://wiki.haskell.org/Prime_numbers
primesTo :: Int -> [Int]
primesTo m = sieve [2 .. m]
  where
    -- Function (\\) is set-difference for unordered lists.
    sieve (x:xs) = x : sieve (xs \\ [x, (x + x) .. m])
    sieve []     = []

ifte :: Member NonDet r => Eff r a -> (a -> Eff r b) -> Eff r b -> Eff r b
ifte t th el = msplit t >>= maybe el (\(a,m) -> th a <|> (m >>= th))

generatePrimes :: Member NonDet r => [Int] -> Eff r Int
generatePrimes xs = do
    n <- gen
    ifte
        (gen >>= \d -> guard $ d < n && n `mod` d == 0)
        (const mzero)
        (pure n)
  where
    gen = msum (pure <$> xs)

testIfte :: [Int] -> [Int]
testIfte = run . makeChoiceA . generatePrimes
