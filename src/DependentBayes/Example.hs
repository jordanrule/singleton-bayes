{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}

module DependentBayes.Example
  ( ToyModel(..)
  , examplePosterior
  ) where

import Control.Monad.Bayes.Class (MonadCond, MonadSample)
import Data.Singletons (Sing)
import DependentBayes.Core (DependentModel(..), posteriorProgram)
import DependentBayes.Types (Mode(..), Observation, Latent)

data ToyModel (mode :: Mode) = ToyModel

instance DependentModel ToyModel where
  type LatentState ToyModel 'Static = Latent 'Static
  type LatentState ToyModel 'Adaptive = Latent 'Adaptive

  type Evidence ToyModel 'Static = Observation 'Static
  type Evidence ToyModel 'Adaptive = Observation 'Adaptive

  prior SStatic = pure 0.0
  prior SAdaptive = pure (0.0, 0.0)

  likelihood SStatic _ _ = pure ()
  likelihood SAdaptive _ _ = pure ()

examplePosterior
  :: (MonadSample m, MonadCond m)
  => Sing (mode :: Mode)
  -> Evidence ToyModel mode
  -> m (LatentState ToyModel mode)
examplePosterior = posteriorProgram

