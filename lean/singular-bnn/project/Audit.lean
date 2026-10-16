import SingularBNN

run_cmd do
  let env <- Lean.getEnv
  let permitted : List Lean.Name := [`propext, `Classical.choice, `Quot.sound]
  let mut count := 0
  for idx in [:env.header.moduleNames.size] do
    let moduleName := env.header.moduleNames[idx]!
    if moduleName.toString.startsWith "SingularBNN." then
      for name in env.header.moduleData[idx]!.constNames do
        let axioms <- Lean.collectAxioms name
        unless axioms.all (fun a => permitted.contains a) do
          throwError "Unexpected axiom dependency in {name}: {axioms}"
        Lean.logInfo ("AXIOM|" ++ name.toString ++ "|" ++
          String.intercalate "," (axioms.toList.map Lean.Name.toString))
        count := count + 1
  Lean.logInfo ("DECLARATIONS_CHECKED|" ++ toString count)

open MeasureTheory SingularBNN

example {m n r : Nat} (p : Factors m n r) : (factorMap p).rank <= r :=
  rank_factorMap_le p

example {m n r : Nat} (q : Measure (Factors m n r)) [IsProbabilityMeasure q] :
    inducedPosterior q (LowRank m n r) = 1 :=
  posterior_lowRank_mass_one q

example {m n r : Nat} (hr : r < min m n) : volume (LowRank m n r) = 0 :=
  lowRank_volume_zero hr

example {m n r : Nat} (q : Measure (Factors m n r)) (hr : r < min m n) :
    (inducedPosterior q).MutuallySingular (volume : Measure (Weight m n)) :=
  inducedPosterior_mutuallySingular q hr

example (m n : Nat) :
    (volume : Measure (Weight m n)) =
      (Measure.pi (fun _ : Fin m => (volume : Measure (Fin n -> Real)))) := rfl

#print axioms SingularBNN.posterior_lowRank_mass_one
#print axioms SingularBNN.lowRank_volume_zero
#print axioms SingularBNN.inducedPosterior_mutuallySingular
