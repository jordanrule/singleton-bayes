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
  , IndexedProgram(..)
  ) where

import Control.Monad.Bayes.Class (MonadCond, MonadSample)
import Data.Kind (Type)
import Data.Singletons (Sing)

class DependentModel (model :: k -> Type) where
  type LatentState model (ix :: k) :: Type
  type Evidence model (ix :: k) :: Type

  prior :: MonadSample m => Sing ix -> m (LatentState model ix)
  likelihood
    :: MonadCond m
    => Sing ix
    -> LatentState model ix
    -> Evidence model ix
    -> m ()

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

newtype IndexedProgram (f :: k -> Type) (ix :: k) a =
  IndexedProgram { runIndexedProgram :: Sing ix -> f ix -> a }


