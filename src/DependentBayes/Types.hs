{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module DependentBayes.Types
  ( Mode(..)
  , SomeMode(..)
  , Sing
  , SingI
  , sing
  , Observation
  , Latent
  , parseMode
  , renderMode
  , withSomeMode
  , latentSpaceName
  ) where

import Data.Char (toLower)
import Data.Kind (Type)
import Data.Singletons (Sing, SingI, sing)
import Data.Singletons.TH (singletons)

singletons
  [d|
    data Mode
      = Static
      | Adaptive
      deriving (Eq, Ord, Show)
    |]

type family Latent (mode :: Mode) :: Type where
  Latent 'Static = Double
  Latent 'Adaptive = (Double, Double)

type family Observation (mode :: Mode) :: Type where
  Observation 'Static = Double
  Observation 'Adaptive = (Double, Double)

data SomeMode where
  SomeMode :: Sing (mode :: Mode) -> SomeMode

withSomeMode :: SomeMode -> (forall (mode :: Mode). Sing mode -> r) -> r
withSomeMode (SomeMode s) f = f s

renderMode :: Sing (mode :: Mode) -> String
renderMode SStatic = "static"
renderMode SAdaptive = "adaptive"

parseMode :: String -> Maybe SomeMode
parseMode raw =
  case map toLower raw of
    "static" -> Just (SomeMode SStatic)
    "adaptive" -> Just (SomeMode SAdaptive)
    _ -> Nothing

latentSpaceName :: Sing (mode :: Mode) -> String
latentSpaceName SStatic = "scalar latent"
latentSpaceName SAdaptive = "pair latent"


