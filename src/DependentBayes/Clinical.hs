{-# LANGUAGE DataKinds      #-}
{-# LANGUAGE GADTs          #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies   #-}

-- | A clinical heart-failure counselling model indexed by 'ClinicalPhase'.
--
-- 'HeartModel' has kind @ClinicalPhase -> Type@ and is an instance of the
-- higher-kinded class 'DependentModel'.  Each phase index selects structurally
-- distinct latent, evidence, and prediction types via closed type families.
--
-- The central clinical concept is the /belief–behaviour gap/: a patient's
-- heart-failure risk inferred from objective vitals may substantially exceed
-- the risk implied by their self-reported behaviour.  The @'CounselAction@
-- phase converts that posterior gap into a typed list of 'ClinicalAction's.
module DependentBayes.Clinical
  ( -- * Phase index kind
    ClinicalPhase (..)
    -- * Domain types
  , PatientVitals (..)
  , BehaviorSurvey (..)
  , ClinicalAction (..)
  , RiskScore
  , ComplianceScore
    -- * Higher-kinded model
  , HeartModel (..)
    -- * Inference entry points (hide singleton machinery from callers)
  , heartRiskPosterior
  , heartBehaviorGapPosterior
  , heartCounsel
    -- * Decision rule (exported for testing / demo)
  , deriveActions
  ) where

import Control.Monad.Bayes.Class (MonadDistribution, MonadFactor, beta, score)
import Numeric.Log (Log(..))

import DependentBayes.Core
  ( DependentModel (..)
  , posteriorAndPredict
  , posteriorProgram
  )
import DependentBayes.Singleton.Clinical (Sing(SRiskAssessment, SBehaviorGap, SCounselAction))
import DependentBayes.Clinical.Types (ClinicalPhase(..))

-- ---------------------------------------------------------------------------
-- Domain types
-- ---------------------------------------------------------------------------

-- | Probability of a heart-failure event, in [0, 1].
type RiskScore      = Double

-- | Aggregate behavioural-adherence score, in [0, 1].
type ComplianceScore = Double

data PatientVitals = PatientVitals
  { systolicBP       :: Double  -- ^ mmHg
  , ejectionFraction :: Double  -- ^ %; clinically healthy >= 55
  , bmi              :: Double  -- ^ kg/m^2
  , patientAge       :: Int     -- ^ years
  } deriving (Show, Eq)

data BehaviorSurvey = BehaviorSurvey
  { weeklyExerciseHours :: Double  -- ^ self-reported hours per week
  , sodiumAdherence     :: Double  -- ^ 0 (never) to 1 (always)
  , medicationAdherence :: Double  -- ^ 0 (never) to 1 (always)
  } deriving (Show, Eq)

-- | Typed clinical interventions.  When listed together they are
--   implicitly ordered from most to least urgent.
data ClinicalAction
  = ContinueMonitoring
  | RecommendExercise
  | ReduceSodiumIntake
  | MedicationCounseling
  | ReferToCardiologist
  deriving (Show, Eq, Ord)

-- ---------------------------------------------------------------------------
-- Higher-kinded model  (HeartModel :: ClinicalPhase -> Type)
--
-- 'DependentModel' has kind  (k -> Type) -> Constraint.
-- 'HeartModel' satisfies it at  k = ClinicalPhase.
-- The three associated type families each produce a different concrete type
-- for each constructor of 'ClinicalPhase'.
-- ---------------------------------------------------------------------------

-- | Phantom-indexed wrapper.  The type index carries no runtime value;
--   all model content lives in the 'DependentModel' instance.
data HeartModel (phase :: ClinicalPhase) = HeartModel

instance DependentModel HeartModel where

  -- Each phase index selects a structurally distinct latent state ...
  type LatentState HeartModel 'RiskAssessment = RiskScore
  type LatentState HeartModel 'BehaviorGap    = (RiskScore, ComplianceScore)
  type LatentState HeartModel 'CounselAction  = (RiskScore, ComplianceScore)

  -- ... a structurally distinct evidence type ...
  type Evidence HeartModel 'RiskAssessment = PatientVitals
  type Evidence HeartModel 'BehaviorGap    = (PatientVitals, BehaviorSurvey)
  type Evidence HeartModel 'CounselAction  = (PatientVitals, BehaviorSurvey)

  -- ... and a structurally distinct prediction type.
  -- Only 'CounselAction diverges from its latent state.
  type Prediction HeartModel 'RiskAssessment = RiskScore
  type Prediction HeartModel 'BehaviorGap    = (RiskScore, ComplianceScore)
  type Prediction HeartModel 'CounselAction  = [ClinicalAction]

  -- Weakly-informative Beta priors.
  -- Beta(1,4): prior mean risk ~20%;  Beta(2,2): symmetric compliance prior.
  prior SRiskAssessment = beta 1.0 4.0
  prior SBehaviorGap    = (,) <$> beta 1.0 4.0 <*> beta 2.0 2.0
  prior SCounselAction  = (,) <$> beta 1.0 4.0 <*> beta 2.0 2.0

  -- Score latent states against observed evidence.
  -- vitalLogLikelihood / behaviorLogLikelihood return log-probabilities (Double);
  -- Exp wraps them into the Log Double that score expects.
  likelihood SRiskAssessment risk vitals =
    score $ Exp (vitalLogLikelihood risk vitals)
  likelihood SBehaviorGap (risk, compliance) (vitals, survey) = do
    score $ Exp (vitalLogLikelihood    risk       vitals)
    score $ Exp (behaviorLogLikelihood compliance survey)
  likelihood SCounselAction (risk, compliance) (vitals, survey) = do
    score $ Exp (vitalLogLikelihood    risk       vitals)
    score $ Exp (behaviorLogLikelihood compliance survey)

  -- Return latent unchanged except at 'CounselAction, where the posterior
  -- is projected into a typed list of clinical recommendations.
  predict SRiskAssessment risk               = pure risk
  predict SBehaviorGap    riskComp           = pure riskComp
  predict SCounselAction  (risk, compliance) = pure (deriveActions risk compliance)

-- ---------------------------------------------------------------------------
-- Likelihood helpers
-- ---------------------------------------------------------------------------

-- | Log-likelihood of vitals given a risk score.
--   Higher risk <-> elevated systolic BP and reduced ejection fraction.
vitalLogLikelihood :: RiskScore -> PatientVitals -> Double
vitalLogLikelihood risk (PatientVitals bp ef _bmi _age) =
  normalLogDensity (110 + 40 * risk) 15 bp
  + normalLogDensity (65  - 30 * risk)  8 ef

-- | Log-likelihood of survey answers given a compliance score.
--   Full compliance predicts ~7 h/week exercise and high adherence scores.
behaviorLogLikelihood :: ComplianceScore -> BehaviorSurvey -> Double
behaviorLogLikelihood c (BehaviorSurvey ex sod med) =
  normalLogDensity (7 * c) 2    ex
  + normalLogDensity c     0.15 sod
  + normalLogDensity c     0.10 med

normalLogDensity :: Double -> Double -> Double -> Double
normalLogDensity mu sigma x =
  let z = (x - mu) / sigma
  in  negate (0.5 * z * z) - log sigma - 0.5 * log (2 * pi)

-- ---------------------------------------------------------------------------
-- Clinical decision rule
-- ---------------------------------------------------------------------------

-- | Map a posterior (risk, compliance) sample to an intervention plan.
--
-- The /belief-behaviour gap/ @risk - compliance@ drives escalation:
--
-- * high risk + large gap  -> refer + full intervention stack
-- * high risk + small gap  -> medication counselling + monitoring
-- * lower risk + large gap -> lifestyle interventions
-- * lower risk + small gap -> continue monitoring
deriveActions :: RiskScore -> ComplianceScore -> [ClinicalAction]
deriveActions risk compliance =
  let gap        = risk - compliance
      urgent     = risk >= highRiskThreshold
      misaligned = gap  >= behaviorGapThreshold
  in case (urgent, misaligned) of
       (True,  True)  -> [ ReferToCardiologist, MedicationCounseling
                         , ReduceSodiumIntake,  RecommendExercise ]
       (True,  False) -> [MedicationCounseling, ContinueMonitoring, RecommendExercise]
       (False, True)  -> [ReduceSodiumIntake, RecommendExercise, ContinueMonitoring]
       (False, False) -> [ContinueMonitoring]

highRiskThreshold, behaviorGapThreshold :: Double
highRiskThreshold    = 0.60
behaviorGapThreshold = 0.25

-- ---------------------------------------------------------------------------
-- Inference entry points
-- ---------------------------------------------------------------------------

-- | Estimate heart-failure risk from a single patient's vitals.
heartRiskPosterior
  :: (MonadDistribution m, MonadFactor m)
  => PatientVitals
  -> m RiskScore
heartRiskPosterior = posteriorProgram @_ @HeartModel SRiskAssessment

-- | Jointly infer risk and behavioural compliance from vitals + survey.
heartBehaviorGapPosterior
  :: (MonadDistribution m, MonadFactor m)
  => (PatientVitals, BehaviorSurvey)
  -> m (RiskScore, ComplianceScore)
heartBehaviorGapPosterior = posteriorProgram @_ @HeartModel SBehaviorGap

-- | Full pipeline: infer (risk, compliance) and project to a counselling plan.
heartCounsel
  :: (MonadDistribution m, MonadFactor m)
  => (PatientVitals, BehaviorSurvey)
  -> m ((RiskScore, ComplianceScore), [ClinicalAction])
heartCounsel = posteriorAndPredict @_ @HeartModel SCounselAction

