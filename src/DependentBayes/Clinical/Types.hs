{-# LANGUAGE DataKinds #-}

-- | The clinical phase kind, independent of implementation.
module DependentBayes.Clinical.Types
  ( ClinicalPhase(..)
  ) where

data ClinicalPhase
  = RiskAssessment   -- ^ infer P(HF | vitals)
  | BehaviorGap      -- ^ jointly infer (risk, adherence)
  | CounselAction    -- ^ project to a typed intervention plan
  deriving (Eq, Ord, Show)

