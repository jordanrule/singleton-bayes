{-# LANGUAGE AllowAmbiguousTypes  #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

module DependentBayes.Core
  ( DependentModel(..)
  , posteriorProgram
  , posteriorProgramBatch
  , posteriorAndPredict
  , IndexedProgram(..)
  ) where

import Control.Monad.Bayes.Class (MonadDistribution, MonadFactor)
import Data.Kind (Type)
import DependentBayes.Singleton (Sing)

class DependentModel (model :: k -> Type) where
  type LatentState model (ix :: k) :: Type
  type Evidence model (ix :: k) :: Type
  type Prediction model (ix :: k) :: Type

  prior :: MonadDistribution m => Sing ix -> m (LatentState model ix)
  likelihood
    :: MonadFactor m
    => Sing ix
    -> LatentState model ix
    -> Evidence model ix
    -> m ()

  -- Optional projection for downstream tasks (forecasting, decoding, etc.).
  -- Subclasses should override if Prediction differs from LatentState.
  predict
    :: Monad m
    => Sing ix
    -> LatentState model ix
    -> m (Prediction model ix)

posteriorProgram
  :: forall k (model :: k -> Type) (ix :: k) m.
     (DependentModel model, MonadDistribution m, MonadFactor m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix)
posteriorProgram ix evidence = do
  latent <- prior @k @model ix
  likelihood @k @model ix latent evidence
  pure latent

posteriorProgramBatch
  :: forall k (model :: k -> Type) (ix :: k) m t.
     (DependentModel model, MonadDistribution m, MonadFactor m, Foldable t)
  => Sing (ix :: k)
  -> t (Evidence model ix)
  -> m (LatentState model ix)
posteriorProgramBatch ix evidences = do
  latent <- prior @k @model ix
  mapM_ (likelihood @k @model ix latent) evidences
  pure latent

posteriorAndPredict
  :: forall k (model :: k -> Type) (ix :: k) m.
     (DependentModel model, MonadDistribution m, MonadFactor m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix, Prediction model ix)
posteriorAndPredict ix evidence = do
  latent <- posteriorProgram @k @model ix evidence
  prediction <- predict @k @model ix latent
  pure (latent, prediction)

newtype IndexedProgram (f :: k -> Type) (ix :: k) a =
  IndexedProgram { runIndexedProgram :: Sing ix -> f ix -> a }


