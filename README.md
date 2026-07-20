# singleton-bayes

`singleton-bayes` explores dependent-style Bayesian programming in ordinary Haskell. It combines [`singletons`](https://hackage.haskell.org/package/singletons) and [`monad-bayes`](https://hackage.haskell.org/package/monad-bayes) so inference stays in familiar probabilistic monads while model structure is indexed at the type level.

## Why this library is unique

In much of the Haskell PPL ecosystem, one typically chooses between:

- dynamic model selection with runtime tags, or
- static models with one fixed latent/evidence shape.

`singleton-bayes` makes a different trade: model families are higher-kinded (`model :: k -> Type`), and each index carries its own latent and evidence types. Singleton witnesses transport that index from runtime to types, so one program can remain generic while each branch stays precise.

## Toward a fuller inference framework: heart-failure counselling

`DependentBayes.Clinical` is a working inference model that shows what this abstraction is for.

A clinical workup is indexed by the `ClinicalPhase` kind. `HeartModel :: ClinicalPhase -> Type` satisfies the higher-kinded class constraint `DependentModel (model :: k -> Type)` at `k = ClinicalPhase`. Three closed type families then map each phase index to structurally distinct latent, evidence, and prediction types:

| Phase | `LatentState` | `Evidence` | `Prediction` |
|---|---|---|---|
| `'RiskAssessment` | `RiskScore` | `PatientVitals` | `RiskScore` |
| `'BehaviorGap` | `(RiskScore, ComplianceScore)` | `(PatientVitals, BehaviorSurvey)` | same |
| `'CounselAction` | `(RiskScore, ComplianceScore)` | `(PatientVitals, BehaviorSurvey)` | `[ClinicalAction]` |

The central clinical insight is the **belief–behaviour gap**: a patient's heart-failure risk inferred from objective vitals may substantially exceed the risk implied by their self-reported behaviour. At the `'CounselAction` phase the `predict` hook converts the continuous posterior `(risk, compliance)` into a typed recommendation list, and the demo now packages that output with a clinician-facing rationale and a patient-facing explanation:

```haskell
deriveActions :: RiskScore -> ComplianceScore -> [ClinicalAction]
deriveActions risk compliance =
  case (risk >= 0.60, risk - compliance >= 0.25) of
    (True,  True)  -> [ReferToCardiologist, MedicationCounseling, ReduceSodiumIntake, RecommendExercise]
    (True,  False) -> [MedicationCounseling, ContinueMonitoring, RecommendExercise]
    (False, True)  -> [ReduceSodiumIntake, RecommendExercise, ContinueMonitoring]
    (False, False) -> [ContinueMonitoring]

-- A clinician-guided package that also makes the reasoning visible to the patient.
data Recommendation = Recommendation
  { recommendationActions :: [ClinicalAction]
  , clinicianRationale     :: String
  , patientExplanation     :: String
  }
```

A patient with systolic BP 145 mmHg, ejection fraction 40 %, low self-reported exercise and medication adherence yields `risk ≈ 0.72, compliance ≈ 0.30` — a gap of 0.42 — and the full intervention stack. The demo now surfaces both the action list and the explanation text so the recommendation can be discussed as part of the clinician-patient relationship rather than as a standalone machine output.

The type checker enforces this routing: `[ClinicalAction]` is the `Prediction` type only at `'CounselAction`. Passing `SCounselAction` where a `'RiskAssessment`-indexed function is expected is a compile error.

The three convenience wrappers hide the singleton machinery from callers entirely:

```haskell
heartRiskPosterior        :: (MonadDistribution m, MonadFactor m)
                          => PatientVitals -> m RiskScore
heartBehaviorGapPosterior :: (MonadDistribution m, MonadFactor m)
                          => (PatientVitals, BehaviorSurvey) -> m (RiskScore, ComplianceScore)
heartCounsel              :: (MonadDistribution m, MonadFactor m)
                          => (PatientVitals, BehaviorSurvey)
                          -> m ((RiskScore, ComplianceScore), [ClinicalAction])
```

## Modules

- `DependentBayes.Types`: index kind (`Mode`) and type families
- `DependentBayes.Singleton`: polymorphic singleton data family
- `DependentBayes.Singleton.Mode`: Mode-specific singleton instances
- `DependentBayes.Singleton.Clinical`: ClinicalPhase-specific singleton instances
- `DependentBayes.Core`: `DependentModel` class and posterior combinators
- `DependentBayes.Example`: toy model showing index-specific types
- `DependentBayes.Clinical.Types`: `ClinicalPhase` kind (separated to break import cycle)
- `DependentBayes.Clinical`: heart-failure counselling model; Beta priors, Normal likelihoods, `deriveActions`, and the new `Recommendation` wrapper for shared decision support

## Quick try

```bash
cabal run singleton-bayes-demo
```

> **macOS note**: if `libffi` is not installed you will get a `ffi.h not found` error.
> Fix it once with `brew install libffi`; the `cabal.project` already sets `extra-include-dirs` to the Homebrew prefix.

## License

MIT


