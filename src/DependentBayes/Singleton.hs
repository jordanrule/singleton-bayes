{-# LANGUAGE DataKinds   #-}
{-# LANGUAGE GADTs       #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds   #-}
{-# LANGUAGE TypeFamilies #-}

-- | Polymorphic singleton witnesses for dependent types.
module DependentBayes.Singleton
  ( Sing
  ) where

import Data.Kind (Type)

-- Polymorphic Sing as a data family, instantiated per kind.
-- See 'DependentBayes.Singleton.Mode' and 'DependentBayes.Singleton.Clinical'.
data family Sing :: forall k. k -> Type

