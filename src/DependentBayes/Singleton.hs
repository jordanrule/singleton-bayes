{-# LANGUAGE DataKinds   #-}
{-# LANGUAGE DatatypeContexts  #-}
{-# LANGUAGE GADTs       #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds   #-}
{-# LANGUAGE TypeFamilies #-}

-- | Polymorphic singleton witnesses for dependent types.
module DependentBayes.Singleton
  ( Sing
  ) where

import Data.Kind (Type)

-- Polymorphic Sing as a data family that can be instantiated per kind
-- Specific instances are defined in modules that use them (e.g., Singleton.Mode for Mode)
data family Sing :: forall k. k -> Type

