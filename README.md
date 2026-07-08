# singleton-bayes

`singleton-bayes` explores dependent-style Bayesian programming in ordinary Haskell. It combines [`singletons`](https://hackage.haskell.org/package/singletons) and [`monad-bayes`](https://hackage.haskell.org/package/monad-bayes) so inference stays in familiar probabilistic monads while model structure is indexed at the type level.

## Why this library is unique

In much of the Haskell PPL ecosystem, one typically chooses between:

- dynamic model selection with runtime tags, or
- static models with one fixed latent/evidence shape.

`singleton-bayes` makes a different trade: model families are higher-kinded (`model :: k -> Type`), and each index carries its own latent and evidence types. Singleton witnesses transport that index from runtime to types, so one program can remain generic while each branch stays precise.

## Current direction: toward a fuller inference framework

The project remains intentionally small, but now includes a reusable inference layer:

- `DependentModel`: higher-kinded class with index-dependent latent/evidence/prediction types
- `posteriorProgram`: condition on one observation
- `posteriorProgramBatch`: condition on many observations  
- `posteriorAndPredict`: posterior state plus typed prediction output

This keeps the original design intent intact while opening a clear path toward richer inference backends and model tooling.

## Clinical example sketch: heart-failure counselling

The theory behind `singleton-bayes` is illustrated in `DependentBayes.Clinical` (sketch only, not yet integrated).

A **clinical workup** indexed by `ClinicalPhase` could map each phase to structurally distinct types:

| Phase | `LatentState` | `Evidence` | `Prediction` |
|---|---|---|---|
| `'RiskAssessment` | `RiskScore` | `PatientVitals` | `RiskScore` |
| `'BehaviorGap` | `(RiskScore, ComplianceScore)` | `(PatientVitals, BehaviorSurvey)` | same |
| `'CounselAction` | `(RiskScore, ComplianceScore)` | `(PatientVitals, BehaviorSurvey)` | `[ClinicalAction]` |

The central insight: a patient's inferred heart-failure risk may exceed the risk implied by their self-reported behaviour. The **belief–behaviour gap** drives escalation of interventions.

```haskell
deriveActions :: RiskScore -> ComplianceScore -> [ClinicalAction]
deriveActions risk compliance =
  case (risk >= 0.60, risk - compliance >= 0.25) of
    (True,  True)  -> [ReferToCardiologist, MedicationCounseling, ...]
    (True,  False) -> [MedicationCounseling, ContinueMonitoring, ...]
    -- ...
```

The type checker enforces this routing: `[ClinicalAction]` is the `Prediction` type only at `'CounselAction`. Passing a `'RiskAssessment` singleton where the system expects `'CounselAction` is a compile error.

## Modules

- `DependentBayes.Types`: index kind (`Mode`) and type families
- `DependentBayes.Singleton`: polymorphic singleton data family
- `DependentBayes.Singleton.Mode`: Mode-specific singleton instances
- `DependentBayes.Core`: `DependentModel` class and posterior combinators
- `DependentBayes.Example`: toy model showing index-specific types
- `DependentBayes.Clinical`: sketch of clinical counselling model (not yet integrated)

## Quick try

```bash
cabal build
cabal run singleton-bayes-demo
```

## License

MIT


