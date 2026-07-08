{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}

-- | Mode-specific singleton instances.
module DependentBayes.Singleton.Mode
  ( Sing(SStatic, SAdaptive)
  ) where

import Data.Kind (Type)
import DependentBayes.Singleton (Sing)
import DependentBayes.Types (Mode(..))

-- Mode-specific Sing instances
data instance Sing (m :: Mode) where
  SStatic   :: Sing 'Static
  SAdaptive :: Sing 'Adaptive

