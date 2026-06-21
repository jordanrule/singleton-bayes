{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

module DependentBayes.Inference
  ( inferPosterior
  , posteriorKernel
  ) where

import Control.Monad.Bayes.Class (MonadCond, MonadSample)
import Data.Singletons (Sing)
import DependentBayes.Core (DependentModel, posteriorProgram)

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


