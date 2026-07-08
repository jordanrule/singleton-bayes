{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}

module DependentBayes.Types where

import Data.Kind (Type)

-- Index kind
data Mode = Static | Adaptive deriving (Eq, Ord, Show)

-- Type families indexed by Mode
type family Latent (mode :: Mode) :: Type where
  Latent 'Static = Double
  Latent 'Adaptive = (Double, Double)

type family Observation (mode :: Mode) :: Type where
  Observation 'Static = Double
  Observation 'Adaptive = (Double, Double)



