import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.LinearAlgebra.Matrix.MvPolynomial
import Mathlib.Topology.Instances.Matrix
import Mathlib.Topology.Algebra.MvPolynomial
import Mathlib.Algebra.MvPolynomial.Equiv
import Mathlib.Algebra.MvPolynomial.Funext
import Mathlib.MeasureTheory.Constructions.Pi
import Mathlib.MeasureTheory.Measure.MutuallySingular
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.MeasureTheory.Measure.Haar.Unique
import Mathlib.MeasureTheory.Measure.Lebesgue.EqHaar
import Mathlib.Tactic

/-!
Posterior geometry for Singular Bayesian Neural Networks
by Mame Diarra Toure and David A. Stephens.

Constrained support, the measure-zero low-rank set, and singularity.
The factor law is arbitrary: no independence or Gaussian assumption is needed.
The matrix measure below is the product of Lebesgue measures on its entries.
-/

open MeasureTheory

namespace SingularBNN

abbrev Weight (m n : Nat) := Matrix (Fin m) (Fin n) Real

noncomputable instance weightMeasureSpace (m n : Nat) : MeasureSpace (Weight m n) :=
  inferInstanceAs (MeasureSpace (Fin m -> Fin n -> Real))

instance weightBorelSpace (m n : Nat) : BorelSpace (Weight m n) :=
  inferInstanceAs (BorelSpace (Fin m -> Fin n -> Real))

instance weightSecondCountable (m n : Nat) : SecondCountableTopology (Weight m n) :=
  inferInstanceAs (SecondCountableTopology (Fin m -> Fin n -> Real))

instance weightLocallyCompact (m n : Nat) : LocallyCompactSpace (Weight m n) :=
  inferInstanceAs (LocallyCompactSpace (Fin m -> Fin n -> Real))

instance weightSigmaFinite (m n : Nat) : SigmaFinite (volume : Measure (Weight m n)) :=
  inferInstanceAs (SigmaFinite (volume : Measure (Fin m -> Fin n -> Real)))

instance weightHaar (m n : Nat) : Measure.IsAddHaarMeasure (volume : Measure (Weight m n)) := by
  letI := isAddHaarMeasure_volume_pi (Fin n)
  exact Measure.pi.isAddHaarMeasure (fun _ : Fin m => (volume : Measure (Fin n -> Real)))

abbrev Factors (m n r : Nat) := Prod (Weight m r) (Weight n r)

def factorMap {m n r : Nat} (p : Factors m n r) : Weight m n :=
  p.1 * p.2.transpose

def LowRank (m n r : Nat) : Set (Weight m n) :=
  {W | W.rank <= r}

noncomputable def inducedPosterior {m n r : Nat}
    (q : Measure (Factors m n r)) : Measure (Weight m n) :=
  q.map factorMap

theorem rank_factorMap_le {m n r : Nat} (p : Factors m n r) :
    (factorMap p).rank <= r :=
  (Matrix.rank_mul_le_left _ _).trans (Matrix.rank_le_width p.1)

theorem continuous_factorMap {m n r : Nat} :
    Continuous (factorMap : Factors m n r -> Weight m n) := by
  unfold factorMap
  fun_prop

theorem posterior_lowRank_mass_one {m n r : Nat}
    (q : Measure (Factors m n r)) [IsProbabilityMeasure q] :
    inducedPosterior q (LowRank m n r) = 1 := by
  have hpre : Set.preimage (factorMap (m := m) (n := n) (r := r))
      (LowRank m n r) = Set.univ := by
    ext p
    simp only [Set.mem_preimage, LowRank, Set.mem_setOf_eq, Set.mem_univ, iff_true]
    exact rank_factorMap_le p
  have hmap : inducedPosterior q Set.univ = 1 := by
    rw [inducedPosterior, Measure.map_apply continuous_factorMap.measurable MeasurableSet.univ]
    simp
  apply le_antisymm ((measure_mono (Set.subset_univ _)).trans_eq hmap)
  have h := show q (Set.preimage factorMap (LowRank m n r)) <= inducedPosterior q (LowRank m n r) from
    Measure.le_map_apply continuous_factorMap.measurable.aemeasurable (LowRank m n r)
  simpa only [hpre, measure_univ, inducedPosterior] using h





/-- A nonzero real polynomial in finitely many variables vanishes on a null set. -/
theorem polynomial_zero_volume_fin (k : Nat) (p : MvPolynomial (Fin k) Real)
    (hp : Not (p = 0)) :
    volume {x : Fin k -> Real | MvPolynomial.eval x p = 0} = 0 := by
  classical
  induction k with
  | zero =>
    have hn : forall x : Fin 0 -> Real, Not (MvPolynomial.eval x p = 0) := by
      intro x hx
      apply hp
      apply MvPolynomial.funext
      intro y
      have hy : y = x := Subsingleton.elim _ _
      simp [hy, hx]
    have hempty : {x : Fin 0 -> Real | MvPolynomial.eval x p = 0} = {} := by
      ext x
      simp [hn x]
    rw [hempty, measure_empty]
  | succ k ih =>
    let P := MvPolynomial.finSuccEquiv Real k p
    have hP : Not (P = 0) := by
      intro hz
      apply hp
      apply (MvPolynomial.finSuccEquiv Real k).injective
      simpa only [map_zero] using hz
    have hex : exists j : Nat, Not (P.coeff j = 0) := by
      by_contra! h
      exact hP (Polynomial.ext fun i => by simpa using h i)
    let j := Classical.choose hex
    have hj : Not (P.coeff j = 0) := Classical.choose_spec hex
    have htail : Filter.Eventually
        (fun x : Fin k -> Real => Not (MvPolynomial.eval x (P.coeff j) = 0))
        (ae volume) := by
      apply ae_iff.mpr
      simpa only [not_not] using ih (P.coeff j) hj
    have hsec : Filter.Eventually
        (fun x : Fin k -> Real =>
          volume {y : Real | MvPolynomial.eval (Fin.cons y x) p = 0} = 0)
        (ae volume) := by
      filter_upwards [htail] with x hx
      have hspec : Not (Polynomial.map (MvPolynomial.eval x) P = 0) := by
        intro hz
        have hc := congrArg (fun Q : Polynomial Real => Q.coeff j) hz
        simp only [Polynomial.coeff_map, Polynomial.coeff_zero] at hc
        exact hx hc
      simpa only [MvPolynomial.eval_eq_eval_mv_eval', P, Polynomial.IsRoot.def] using
        (Polynomial.finite_setOf_isRoot hspec).measure_zero volume
    have hm : MeasurableSet {z : Prod (Fin k -> Real) Real |
        MvPolynomial.eval (Fin.cons z.2 z.1) p = 0} := by
      exact (isClosed_eq (p.continuous_eval.comp (by fun_prop)) continuous_const).measurableSet
    have hprod : (volume : Measure (Prod (Fin k -> Real) Real))
        {z | MvPolynomial.eval (Fin.cons z.2 z.1) p = 0} = 0 := by
      apply Measure.measure_prod_null_of_ae_null hm
      exact hsec
    have hsplit := volume_preserving_piFinSuccAbove
      (fun _ : Fin (k + 1) => Real) 0
    have hswap : MeasurePreserving Prod.swap
        ((volume : Measure Real).prod (volume : Measure (Fin k -> Real)))
        ((volume : Measure (Fin k -> Real)).prod (volume : Measure Real)) :=
      Measure.measurePreserving_swap
    have h := (hswap.comp hsplit).quasiMeasurePreserving.preimage_null hprod
    convert h using 2
    ext x
    simp only [Set.mem_setOf_eq, Set.mem_preimage, Function.comp_apply,
      MeasurableEquiv.piFinSuccAbove_apply]
    have hcons : Fin.cons ((Fin.insertNthEquiv (fun _ : Fin (k + 1) => Real) 0).symm x).swap.2
        ((Fin.insertNthEquiv (fun _ : Fin (k + 1) => Real) 0).symm x).swap.1 = x := by
      ext i
      refine Fin.cases ?_ (fun j => ?_) i
      next => simp [Fin.insertNthEquiv]
      next => simp [Fin.insertNthEquiv, Fin.tail]
    rw [hcons]


/-- Reindexing the variables preserves the null-set conclusion. -/
theorem polynomial_zero_volume {s : Type} [Fintype s]
    (p : MvPolynomial s Real) (hp : Not (p = 0)) :
    volume {x : s -> Real | MvPolynomial.eval x p = 0} = 0 := by
  classical
  let e := Fintype.equivFin s
  let P := MvPolynomial.renameEquiv Real e p
  have hP : Not (P = 0) := by
    intro hz
    apply hp
    apply (MvPolynomial.renameEquiv Real e).injective
    simpa only [map_zero] using hz
  have hfin := polynomial_zero_volume_fin (Fintype.card s) P hP
  have h := (volume_measurePreserving_piCongrLeft
    (fun _ : Fin (Fintype.card s) => Real) e).quasiMeasurePreserving.preimage_null hfin
  convert h using 2
  ext x
  simp [P, MvPolynomial.renameEquiv_apply, MvPolynomial.eval_rename,
    MeasurableEquiv.piCongrLeft, Equiv.piCongrLeft, Function.comp_def]

/-- Flattening a matrix is a continuous additive equivalence, so it preserves null sets. -/
theorem matrix_polynomial_zero_volume {m n : Nat}
    (p : MvPolynomial (Prod (Fin m) (Fin n)) Real) (hp : Not (p = 0)) :
    volume {W : Weight m n |
      MvPolynomial.eval (fun ij : Prod (Fin m) (Fin n) => W ij.1 ij.2) p = 0} = 0 := by
  let e : AddEquiv (Weight m n) (Prod (Fin m) (Fin n) -> Real) :=
    { toEquiv := (Equiv.curry (Fin m) (Fin n) Real).symm
      map_add' := by intros; rfl }
  have he : Continuous e := by
    change Continuous (fun W : Weight m n => fun ij : Prod (Fin m) (Fin n) => W ij.1 ij.2)
    fun_prop
  have hei : Continuous e.symm := by
    change Continuous (fun x : Prod (Fin m) (Fin n) -> Real => fun i j => x (i, j))
    fun_prop
  letI : Measure.IsAddHaarMeasure (Measure.map e (volume : Measure (Weight m n))) :=
    e.isAddHaarMeasure_map volume he hei
  have hac := Measure.absolutelyContinuous_isAddHaarMeasure
    (Measure.map e (volume : Measure (Weight m n))) volume
  have hz := hac (polynomial_zero_volume p hp)
  rw [Measure.map_apply he.measurable
    (isClosed_eq p.continuous_eval continuous_const).measurableSet] at hz
  exact hz

noncomputable def minorPolynomial (m n r : Nat) (hm : r < m) (hn : r < n) :
    MvPolynomial (Prod (Fin m) (Fin n)) Real :=
  Matrix.det (Matrix.of (fun i j : Fin (r + 1) => MvPolynomial.X
    (Fin.castLE (Nat.succ_le_of_lt hm) i, Fin.castLE (Nat.succ_le_of_lt hn) j)))

theorem eval_minorPolynomial {m n r : Nat} (hm : r < m) (hn : r < n)
    (W : Weight m n) :
    MvPolynomial.eval (fun ij : Prod (Fin m) (Fin n) => W ij.1 ij.2) (minorPolynomial m n r hm hn) =
      (W.submatrix (Fin.castLE (Nat.succ_le_of_lt hm))
        (Fin.castLE (Nat.succ_le_of_lt hn))).det := by
  unfold minorPolynomial
  rw [(MvPolynomial.eval (fun ij : Prod (Fin m) (Fin n) => W ij.1 ij.2)).map_det]
  congr 1
  ext i j
  simp

theorem minorPolynomial_ne_zero {m n r : Nat} (hm : r < m) (hn : r < n) :
    Not (minorPolynomial m n r hm hn = 0) := by
  classical
  let W : Weight m n := Matrix.of (fun i j => if i.val = j.val then 1 else 0)
  have hsub : W.submatrix (Fin.castLE (Nat.succ_le_of_lt hm))
      (Fin.castLE (Nat.succ_le_of_lt hn)) = (1 : Matrix (Fin (r + 1)) (Fin (r + 1)) Real) := by
    ext i j
    simp [W, Matrix.submatrix_apply, Matrix.one_apply, Fin.ext_iff]
  have he : MvPolynomial.eval (fun ij : Prod (Fin m) (Fin n) => W ij.1 ij.2)
      (minorPolynomial m n r hm hn) = 1 := by
    rw [eval_minorPolynomial, hsub, Matrix.det_one]
  intro hz
  rw [hz, map_zero] at he
  exact zero_ne_one he

theorem lowRank_minor_zero {m n r : Nat} (hm : r < m) (hn : r < n)
    (W : Weight m n) (hW : Membership.mem (LowRank m n r) W) :
    MvPolynomial.eval (fun ij : Prod (Fin m) (Fin n) => W ij.1 ij.2) (minorPolynomial m n r hm hn) = 0 := by
  rw [eval_minorPolynomial]
  by_contra hdet
  let S := W.submatrix (Fin.castLE (Nat.succ_le_of_lt hm))
    (Fin.castLE (Nat.succ_le_of_lt hn))
  have hu : IsUnit S := (Matrix.isUnit_iff_isUnit_det S).mpr
    (isUnit_iff_ne_zero.mpr hdet)
  have hS : S.rank = r + 1 := by
    simpa using Matrix.rank_of_isUnit S hu
  have hle : S.rank <= r :=
    (Matrix.rank_submatrix_le W _ _).trans hW
  omega

/-- The set of real m-by-n matrices of rank at most r has zero Lebesgue measure. -/
theorem lowRank_volume_zero {m n r : Nat} (hr : r < min m n) :
    volume (LowRank m n r) = 0 := by
  have hm : r < m := lt_of_lt_of_le hr (min_le_left _ _)
  have hn : r < n := lt_of_lt_of_le hr (min_le_right _ _)
  apply measure_mono_null (fun W hW => lowRank_minor_zero hm hn W hW)
  exact matrix_polynomial_zero_volume _ (minorPolynomial_ne_zero hm hn)

/-- Every measure on the factors induces a measure singular to Lebesgue measure. -/
theorem inducedPosterior_mutuallySingular {m n r : Nat}
    (q : Measure (Factors m n r)) (hr : r < min m n) :
    (inducedPosterior q).MutuallySingular (volume : Measure (Weight m n)) := by
  have hm : r < m := lt_of_lt_of_le hr (min_le_left _ _)
  have hn : r < n := lt_of_lt_of_le hr (min_le_right _ _)
  let Z : Set (Weight m n) := {W |
    MvPolynomial.eval (fun ij : Prod (Fin m) (Fin n) => W ij.1 ij.2) (minorPolynomial m n r hm hn) = 0}
  have hZ : MeasurableSet Z := by
    exact (isClosed_eq
      ((minorPolynomial m n r hm hn).continuous_eval.comp (by fun_prop))
      continuous_const).measurableSet
  have hvol : volume Z = 0 :=
    matrix_polynomial_zero_volume _ (minorPolynomial_ne_zero hm hn)
  have hpre : Set.preimage (factorMap : Factors m n r -> Weight m n) (compl Z) = {} := by
    ext p
    change Not (Membership.mem Z (factorMap p)) <-> False
    have hz : Membership.mem Z (factorMap p) :=
      lowRank_minor_zero hm hn (factorMap p) (rank_factorMap_le p)
    simp only [hz, not_true_eq_false]
  have hq : inducedPosterior q (compl Z) = 0 := by
    change (Measure.map factorMap q) (compl Z) = 0
    have hmap : (Measure.map factorMap q) (compl Z) =
        q (Set.preimage factorMap (compl Z)) :=
      Measure.map_apply continuous_factorMap.measurable hZ.compl
    rw [hmap, hpre, measure_empty]
  refine Exists.intro (compl Z) ?_
  constructor
  next => exact hZ.compl
  constructor
  next => exact hq
  next => simpa only [compl_compl] using hvol


end SingularBNN
