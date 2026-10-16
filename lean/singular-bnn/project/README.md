# Singular Bayesian Neural Networks: posterior geometry in Lean

Formalization of three linked results from Mame Diarra Toure and David A. Stephens,
*Singular Bayesian Neural Networks*:
https://arxiv.org/abs/2602.00387

1. Constrained support: if W = A * transpose B with r factor columns, rank W <= r,
   and every probability law on the factors pushes forward to probability one on
   the set of matrices of rank at most r.
2. Measure zero: when r < min(m,n), this low-rank set has zero Lebesgue measure.
3. Singularity: under the same dimension condition, the induced measure is
   mutually singular to Lebesgue measure in the full weight space.

No independence, Gaussian, or density assumption is imposed on the factor law.
The third Lean theorem is stronger than the probability-law statement: it holds
for any measure on the factor space.

## Build

Install Lean through elan, then run in this directory:

```sh
lake exe cache get
lake build
lake env lean Audit.lean
```

The toolchain and all dependency revisions are pinned in the project files.
The first build needs internet access to obtain the compiler, Mathlib, and its
cached dependencies; later builds can use those local dependencies.

## Files

- `SingularBNN.lean`: root module included in the default build.
- `SingularBNN/Geometry.lean`: definitions, helper lemmas, and complete proofs.
- `Audit.lean`: exact-statement checks, canonical-volume check, and axiom audit.
- `lakefile.toml`: project and Mathlib dependency.
- `lake-manifest.json`: resolved dependency revisions.
- `lean-toolchain`: exact compiler version.

## Proof structure

The factor map is continuous and its value has rank at most r. This establishes
probability-one concentration on the low-rank set.

A nonzero multivariate real polynomial has a null zero set: split off one
variable, select a nonzero coefficient polynomial, apply the induction hypothesis
to it, use finiteness of the remaining univariate roots, and apply Fubini.
Coordinate reindexing and matrix flattening transfer this result to matrices.

The leading (r+1)-by-(r+1) minor is a nonzero polynomial: a rectangular matrix
containing an identity block evaluates it to one. Rank at most r forces this
minor to vanish. Containment in that polynomial zero set proves measure zero.

The minor's zero set is closed. Its complement has zero induced measure, while
the zero set has zero Lebesgue measure. This witnesses mutual singularity.

## Scope

This project verifies these statements and their supporting lemmas, not the
whole paper, the covariance formulas, generalization bounds, or experiments.
Standard results from Mathlib are reused. The audit permits only the standard
Lean axioms `propext`, `Classical.choice`, and `Quot.sound`.
