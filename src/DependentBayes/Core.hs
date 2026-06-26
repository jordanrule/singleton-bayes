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

import Control.Monad.Bayes.Class (MonadCond, MonadSample)
import Data.Kind (Type)
import Data.Singletons (Sing)

class DependentModel (model :: k -> Type) where
  type LatentState model (ix :: k) :: Type
  type Evidence model (ix :: k) :: Type
  type Prediction model (ix :: k) :: Type
  type Prediction model ix = LatentState model ix

  prior :: MonadSample m => Sing ix -> m (LatentState model ix)
  likelihood
    :: MonadCond m
    => Sing ix
    -> LatentState model ix
    -> Evidence model ix
    -> m ()

  -- Optional projection for downstream tasks (forecasting, decoding, etc.).
  predict
    :: Monad m
    => Sing ix
    -> LatentState model ix
    -> m (Prediction model ix)
  predict _ latent = pure latent

posteriorProgram
  :: forall model k ix m.
     (DependentModel model, MonadSample m, MonadCond m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix)
posteriorProgram ix evidence = do
  latent <- prior ix
  likelihood ix latent evidence
  pure latent

posteriorProgramBatch
  :: forall model k ix m t.
     (DependentModel model, MonadSample m, MonadCond m, Foldable t)
  => Sing (ix :: k)
  -> t (Evidence model ix)
  -> m (LatentState model ix)
posteriorProgramBatch ix evidences = do
  latent <- prior ix
  mapM_ (likelihood ix latent) evidences
  pure latent

posteriorAndPredict
  :: forall model k ix m.
     (DependentModel model, MonadSample m, MonadCond m)
  => Sing (ix :: k)
  -> Evidence model ix
  -> m (LatentState model ix, Prediction model ix)
posteriorAndPredict ix evidence = do
  latent <- posteriorProgram ix evidence
  prediction <- predict ix latent
  pure (latent, prediction)

newtype IndexedProgram (f :: k -> Type) (ix :: k) a =
  IndexedProgram { runIndexedProgram :: Sing ix -> f ix -> a }


