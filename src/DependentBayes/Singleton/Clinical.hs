{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

-- | ClinicalPhase singleton instances.
--   The @data instance Sing (phase :: ClinicalPhase)@ lives here
--   rather than in 'DependentBayes.Clinical' to break the import cycle
--   between that module and 'DependentBayes.Singleton'.
module DependentBayes.Singleton.Clinical
  ( Sing(SRiskAssessment, SBehaviorGap, SCounselAction)
  ) where

import DependentBayes.Singleton (Sing)
import DependentBayes.Clinical.Types (ClinicalPhase(..))

-- | Singleton GADT for 'ClinicalPhase'.
data instance Sing (phase :: ClinicalPhase) where
  SRiskAssessment :: Sing 'RiskAssessment
  SBehaviorGap    :: Sing 'BehaviorGap
  SCounselAction  :: Sing 'CounselAction

