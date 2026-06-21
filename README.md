# singleton-bayes

A tiny Haskell library for **dependent Bayesian types** using:

- [`singletons`](https://hackage.haskell.org/package/singletons) for value-level to type-level witnesses
- [`monad-bayes`](https://hackage.haskell.org/package/monad-bayes) for probabilistic programming
- **higher-kinded types** for the model family itself

The core idea is to index a probabilistic model by a type-level tag and use a singleton witness to select the right latent and evidence types at runtime.

## What this gives you

In ordinary probabilistic code, you can accidentally mix observations from one regime with latent variables from another. This library pushes that mismatch into the type system.

For example, the model family `ToyModel :: Mode -> Type` is indexed by a kind-level `Mode`. The library then associates each mode with its own:

- latent state type
- evidence type
- prior/likelihood definitions

The key abstraction is kind-polymorphic:

```haskell
class DependentModel (model :: k -> Type) where
  type LatentState model (ix :: k) :: Type
  type Evidence model (ix :: k) :: Type
```

That means the model itself is a **higher-kinded type** and can vary over any kind `k`, not just a single closed set of constructors.

## How the pieces fit together

- `DependentBayes.Types`
  - defines an example index kind `Mode`
  - generates singletons for `Mode`
  - provides runtime parsing and pretty-printing for singleton witnesses
- `DependentBayes.Core`
  - defines the kind-polymorphic `DependentModel` class
  - provides `posteriorProgram`, a generic prior + likelihood skeleton
- `DependentBayes.Inference`
  - exposes a small inference-facing wrapper around the core program
- `DependentBayes.Example`
  - includes a tiny concrete model instance to show how the types line up

## Theory in brief

This library is not full dependent type theory. Haskell with `singletons` gives a practical approximation:

1. Put an index at the type level.
2. Reify that index with a singleton.
3. Use the singleton to choose a type-safe branch of the model.
4. Use `monad-bayes` to perform sampling and conditioning inside a probabilistic monad.

The result is a form of **dependent-style Bayesian programming**: the model structure depends on the type-level index, while inference stays in the monad-bayes ecosystem.

## Safety considerations

### What is enforced by the type system

- You cannot call a model branch with the wrong latent/evidence type.
- Runtime selection of the model still produces a singleton witness, so the branch chosen at runtime is reflected at the type level.
- The model family is explicit and kind-polymorphic, so the structure of the model is visible in types.

### What is **not** guaranteed

- Statistical correctness is not guaranteed by the type system.
- A well-typed prior can still be a bad prior.
- A well-typed likelihood can still encode a nonsense or numerically unstable model.
- The singleton bridge ensures type alignment, not inference quality.
- The library does not prove that posterior inference converges or that a backend is appropriate for a given model.

### Practical advice

- Prefer total functions when constructing singleton witnesses.
- Keep the index kind small and explicit.
- Use separate model families for materially different assumptions.
- Treat the types as a guardrail, not a proof of domain correctness.
- Validate posterior behavior empirically.

## Demo

If you have the Haskell toolchain and the dependencies installed, the demo executable prints a small singleton-backed example:

```bash
cabal run singleton-bayes-demo
```

You can also run the smoke test harness:

```bash
cabal test singleton-bayes-spec
```

## License

MIT


