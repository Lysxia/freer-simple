{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE CPP #-}
{-|
Module      : Control.Monad.Freer
Description : Freer - an extensible effects library
Copyright   : Allele Dev 2016
License     : BSD-3
Maintainer  : allele.dev@gmail.com
Stability   : experimental
Portability : POSIX

-}
module Control.Monad.Freer (
  Member,
  Members,
  Eff,
  run,
  runM,
  runNat,
  runNatS,
  handleRelay,
  handleRelayS,
  send,
  Arr,

  NonDetEff(..),
  makeChoiceA,
  msplit
) where

#if !MIN_VERSION_base(4,8,0)
import Control.Applicative (pure)
#endif

import Control.Monad.Freer.Internal

runNat
  :: Member m r
  => (forall a. e a -> m a) -> Eff (e ': r) w -> Eff r w
runNat f = handleRelay pure (\v -> (send (f v) >>=))

runNatS
  :: Member m r
  => s -> (forall a. s -> e a -> m (s, a)) -> Eff (e ': r) w -> Eff r w
runNatS s0 f =
  handleRelayS s0 (const pure) (\s v -> (send (f s v) >>=) . uncurry)
