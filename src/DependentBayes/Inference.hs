{-# LANGUAGE AllowAmbiguousTypes  #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

module DependentBayes.Inference
  ( inferPosterior
  , inferPosteriorBatch
  , inferAndPredict
  , posteriorKernel
  ) where

import Control.Monad.Bayes.Class (MonadDistribution, MonadFactor)
import Data.Kind (Type)
import Data.Singletons (Sing)
import DependentBayes.Core
  ( DependentModel
  , posteriorAndPredict
  , posteriorProgram
  , posteriorProgramBatch
  )

posteriorKernel
  :: forall k (model :: k -> Type) (ix :: k) m.
     (DependentModel model, MonadDistribution m, MonadFactor m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix)
posteriorKernel = posteriorProgram @k @model

inferPosterior
  :: forall k (model :: k -> Type) (ix :: k) m.
     (DependentModel model, MonadDistribution m, MonadFactor m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix)
inferPosterior = posteriorKernel @k @model

inferPosteriorBatch
  :: forall k (model :: k -> Type) (ix :: k) m t.
     (DependentModel model, MonadDistribution m, MonadFactor m, Foldable t)
  => Sing (ix :: k)
  -> t (Evidence model ix)
  -> m (LatentState model ix)
inferPosteriorBatch = posteriorProgramBatch @k @model

inferAndPredict
  :: forall k (model :: k -> Type) (ix :: k) m.
     (DependentModel model, MonadDistribution m, MonadFactor m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix, Prediction model ix)
inferAndPredict = posteriorAndPredict @k @model


