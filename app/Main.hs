module Main where

import Control.Monad.Bayes.Sampler.Strict (sampleIOfixed)
import Control.Monad.Bayes.Weighted       (runWeightedT)

import DependentBayes.Clinical
  ( PatientVitals(..), BehaviorSurvey(..)
  , Recommendation(..), deriveActions, deriveRecommendation, heartCounsel
  )

-- | Example patient: elevated BP, reduced EF, poor self-reported behaviour.
exampleVitals :: PatientVitals
exampleVitals = PatientVitals
  { systolicBP       = 145
  , ejectionFraction = 40
  , bmi              = 31
  , patientAge       = 67
  }

exampleSurvey :: BehaviorSurvey
exampleSurvey = BehaviorSurvey
  { weeklyExerciseHours = 0.5
  , sodiumAdherence     = 0.3
  , medicationAdherence = 0.4
  }

main :: IO ()
main = do
  putStrLn "=== singleton-bayes: heart-failure counselling demo ===\n"

  -- Pure decision logic (no sampling required)
  let risk       = 0.72 :: Double
      compliance = 0.30 :: Double
      gap        = risk - compliance
      planPure   = deriveActions risk compliance
      recommendation = deriveRecommendation risk compliance

  putStrLn "Illustrative posterior summary"
  putStrLn $ "  risk score    : " ++ show risk
  putStrLn $ "  compliance    : " ++ show compliance
  putStrLn $ "  gap           : " ++ show gap
  putStrLn $ "  plan (pure)   : " ++ show (recommendationActions recommendation)
  putStrLn $ "  clinician rationale: " ++ clinicianRationale recommendation
  putStrLn $ "  patient explanation: " ++ patientExplanation recommendation
  putStrLn ""

  -- Full probabilistic pipeline: sample prior, condition on vitals + survey,
  -- project latent state to a typed [ClinicalAction].
  -- runWeighted adds importance-weight tracking; sampleIOfixed draws one sample.
  putStrLn "Running heartCounsel (weighted sampler, one draw)..."
  ((latent, actions), _w) <-
    sampleIOfixed $ runWeightedT $ heartCounsel (exampleVitals, exampleSurvey)
  putStrLn $ "  posterior latent : " ++ show latent
  putStrLn $ "  counselling plan : " ++ show actions


