{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}

module DependentBayes.Example
  ( ToyModel(..)
  , examplePosterior
  , examplePosteriorBatch
  , exampleForecast
  ) where

import Control.Monad.Bayes.Class (MonadCond, MonadSample)
import Data.Singletons (Sing)
import DependentBayes.Core (DependentModel(..), posteriorAndPredict, posteriorProgram, posteriorProgramBatch)
import DependentBayes.Types (Mode(..), Observation, Latent)

data ToyModel (mode :: Mode) = ToyModel

instance DependentModel ToyModel where
  type LatentState ToyModel 'Static = Latent 'Static
  type LatentState ToyModel 'Adaptive = Latent 'Adaptive

  type Evidence ToyModel 'Static = Observation 'Static
  type Evidence ToyModel 'Adaptive = Observation 'Adaptive

  type Prediction ToyModel 'Static = Double
  type Prediction ToyModel 'Adaptive = Double

  prior SStatic = pure 0.0
  prior SAdaptive = pure (0.0, 0.0)

  likelihood SStatic _ _ = pure ()
  likelihood SAdaptive _ _ = pure ()

  predict SStatic latent = pure latent
  predict SAdaptive (x, y) = pure (x + y)

examplePosterior
  :: (MonadSample m, MonadCond m)
  => Sing (mode :: Mode)
  -> Evidence ToyModel mode
  -> m (LatentState ToyModel mode)
examplePosterior = posteriorProgram

examplePosteriorBatch
  :: (MonadSample m, MonadCond m, Foldable t)
  => Sing (mode :: Mode)
  -> t (Evidence ToyModel mode)
  -> m (LatentState ToyModel mode)
examplePosteriorBatch = posteriorProgramBatch

exampleForecast
  :: (MonadSample m, MonadCond m)
  => Sing (mode :: Mode)
  -> Evidence ToyModel mode
  -> m (LatentState ToyModel mode, Prediction ToyModel mode)
exampleForecast = posteriorAndPredict

