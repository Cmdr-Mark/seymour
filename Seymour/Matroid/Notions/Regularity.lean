import Seymour.Matroid.Constructors.StandardRepresentation


/-- Matrix `A` is a TU signing of `U` iff `A` is TU and its entries are the same as in `U` up to signs.
    Do not ask `U.IsTotallyUnimodular` ... see `Matrix.overZ2_isTotallyUnimodular` for example! -/
def Matrix.IsTuSigningOf {X Y : Type} (A : Matrix X Y ℚ) {n : ℕ} (U : Matrix X Y (ZMod n)) : Prop :=
  A.IsTotallyUnimodular ∧ ∀ i j, |A i j| = (U i j).val

/-- Matrix `U` has a TU signing if there is a TU matrix whose entries are the same as in `U` up to signs. -/
def Matrix.HasTuSigning {X Y : Type} {n : ℕ} (U : Matrix X Y (ZMod n)) : Prop :=
  ∃ A : Matrix X Y ℚ, A.IsTuSigningOf U

variable {α : Type}

/-- The main definition of regularity: `M` is regular iff it is constructed from a `VectorMatroid` with a rational TU matrix. -/
def Matroid.IsRegular (M : Matroid α) : Prop :=
  ∃ X Y : Set α, ∃ A : Matrix X Y ℚ, A.IsTotallyUnimodular ∧ (VectorMatroid.mk X Y A).toMatroid = M

/-- Every regular matroid is binary. -/
lemma Matroid.IsRegular.isBinary {M : Matroid α} (hM : M.IsRegular) :
    ∃ V : VectorMatroid α Z2, V.toMatroid = M := by
  obtain ⟨X, Y, A, hA, rfl⟩ := hM
  use ⟨X, Y, Matrix.of (if A · · = 0 then 0 else 1)⟩
  ext I hI
  · simp
  simp only [VectorMatroid.toMatroid_E] at hI
  simp only [VectorMatroid.toMatroid_indep, VectorMatroid.IndepCols]
  constructor <;> intro ⟨hI', hA'⟩ <;> use hI'
  · sorry
  · sorry

/-- Every regular matroid has a standard binary representation. -/
lemma Matroid.IsRegular.isBinaryStd [DecidableEq α] {M : Matroid α} (hM : M.IsRegular) :
    ∃ S : StandardRepr α Z2, S.toMatroid = M := by
  obtain ⟨V, hV⟩ := hM.isBinary
  obtain ⟨S, hS⟩ := V.exists_standardRepr
  rw [←hS] at hV
  exact ⟨S, hV⟩

/-- Matroid `M` that can be represented by a matrix over `Z2` with a TU signing -/
abbrev StandardRepr.HasTuSigning [DecidableEq α] (S : StandardRepr α Z2) : Prop :=
  S.B.HasTuSigning

/-- Matroid constructed from a standard representation is regular iff the binary matrix has a TU signing. -/
lemma StandardRepr.toMatroid_isRegular_iff_hasTuSigning [DecidableEq α] (S : StandardRepr α Z2) :
    S.toMatroid.IsRegular ↔ S.HasTuSigning := by
  sorry
