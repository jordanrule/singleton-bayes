# singleton-bayes

`singleton-bayes` is a small Haskell library for indexed Bayesian models. It combines [`singletons`](https://hackage.haskell.org/package/singletons) and [`monad-bayes`](https://hackage.haskell.org/package/monad-bayes) so model structure can vary by a type-level index while inference remains in ordinary probabilistic monads.

## Why this is unusual in Haskell

Most Haskell probabilistic code is either untyped at the model boundary (tags and runtime checks) or strongly typed but monolithic (one latent/evidence shape per model). This library takes a third route:

- a model family is **higher-kinded**: `model :: k -> Type`
- each index `ix :: k` has its own latent and evidence types
- singleton witnesses connect runtime choice to the corresponding type-level branch

In short, it offers a lightweight dependent-style interface without leaving the existing `monad-bayes` ecosystem.

## Core abstraction

```haskell
class DependentModel (model :: k -> Type) where
  type LatentState model (ix :: k) :: Type
  type Evidence model (ix :: k) :: Type
```

`DependentBayes.Core` provides `posteriorProgram`, a reusable prior/likelihood skeleton parameterized by the singleton index witness.

## Modules

- `DependentBayes.Types`: index kind (`Mode`) and singleton bridge utilities
- `DependentBayes.Core`: `DependentModel` and generic posterior program
- `DependentBayes.Inference`: small inference-facing wrappers
- `DependentBayes.Example`: concrete toy model instance

## Scope

This project is intentionally minimal: it demonstrates a typed pattern for model families, not a complete inference framework.

## Demo

```bash
cabal run singleton-bayes-demo
cabal test singleton-bayes-spec
```

## License

MIT


