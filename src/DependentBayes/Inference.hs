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

import Control.Monad.Bayes.Class (MonadCond, MonadSample)
import Data.Singletons (Sing)
import DependentBayes.Core
  ( DependentModel
  , posteriorAndPredict
  , posteriorProgram
  , posteriorProgramBatch
  )

posteriorKernel
  :: (DependentModel model, MonadSample m, MonadCond m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix)
posteriorKernel = posteriorProgram

inferPosterior
  :: (DependentModel model, MonadSample m, MonadCond m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix)
inferPosterior = posteriorKernel

inferPosteriorBatch
  :: (DependentModel model, MonadSample m, MonadCond m, Foldable t)
  => Sing (ix :: k)
  -> t (Evidence model ix)
  -> m (LatentState model ix)
inferPosteriorBatch = posteriorProgramBatch

inferAndPredict
  :: (DependentModel model, MonadSample m, MonadCond m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix, Prediction model ix)
inferAndPredict = posteriorAndPredict


