# singleton-bayes

`singleton-bayes` explores dependent-style Bayesian programming in ordinary Haskell. It combines [`singletons`](https://hackage.haskell.org/package/singletons) and [`monad-bayes`](https://hackage.haskell.org/package/monad-bayes) so inference stays in familiar probabilistic monads while model structure is indexed at the type level.

## Why this library is unique

In much of the Haskell PPL ecosystem, one typically chooses between:

- dynamic model selection with runtime tags, or
- static models with one fixed latent/evidence shape.

`singleton-bayes` makes a different trade: model families are higher-kinded (`model :: k -> Type`), and each index carries its own latent and evidence types. Singleton witnesses transport that index from runtime to types, so one program can remain generic while each branch stays precise.

## Current direction: toward a fuller inference framework

The project remains intentionally small, but now includes a thin, reusable inference layer:

- `posteriorProgram`: condition on one observation
- `posteriorProgramBatch`: condition on many observations
- `posteriorAndPredict`: posterior state plus typed prediction output
- `inferPosteriorBatch` / `inferAndPredict`: ergonomic wrappers in `DependentBayes.Inference`

This keeps the original design intent intact while opening a clear path toward richer inference backends and model tooling.

## Modules

- `DependentBayes.Types`: index kind (`Mode`) and singleton bridge utilities
- `DependentBayes.Core`: `DependentModel`, posterior skeletons, prediction hook
- `DependentBayes.Inference`: small inference-facing entry points
- `DependentBayes.Example`: toy model showing index-specific latent/evidence/prediction types

## Quick try

```bash
cabal run singleton-bayes-demo
cabal test singleton-bayes-spec
```

## License

MIT


