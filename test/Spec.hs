{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}

module Main where

import Data.List (isInfixOf)
import DependentBayes.Clinical (ClinicalAction(..), Recommendation(..), deriveRecommendation)
import System.Exit (exitFailure)

check :: Bool -> String -> IO ()
check True _ = pure ()
check False msg = do
  putStrLn msg
  exitFailure

main :: IO ()
main = do
  let recommendation = deriveRecommendation 0.72 0.30

  check
    (recommendationActions recommendation == [ReferToCardiologist, MedicationCounseling, ReduceSodiumIntake, RecommendExercise])
    "recommendation actions did not match the expected plan"

  check
    (isInfixOf "belief" (clinicianRationale recommendation))
    "clinician rationale should mention the belief-behaviour gap"

  check
    (isInfixOf "clinician" (patientExplanation recommendation))
    "patient explanation should preserve the clinician-patient relationship"

  putStrLn "singleton-bayes spec passed"

