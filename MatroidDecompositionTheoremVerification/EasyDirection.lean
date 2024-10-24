import MatroidDecompositionTheoremVerification.ForMathlib.MatrixTU
import MatroidDecompositionTheoremVerification.ForMathlib.Sets

open scoped Matrix

/-- The finite field on two elements. -/
abbrev Z2 : Type := ZMod 2

infixr:91 " ᕃ " => Insert.insert

infix:61 " ⫗ " => Disjoint

section construction_from_matrices

variable {α : Type} [DecidableEq α] {X Y : Set α} [∀ x, Decidable (x ∈ X)] [∀ y, Decidable (y ∈ Y)]

/-- Given matrix `B`, is the set of columns `S` in the (standard) representation [`1` | `B`] `Z2`-independent? -/
def Matrix.IndepCols (B : Matrix X Y Z2) (S : Set α) : Prop :=
  ∃ hs : S ⊆ X ∪ Y,
    LinearIndependent Z2
      ((Matrix.fromColumns 1 B).submatrix id
        (fun s : S =>
          if hsX : s.val ∈ X then Sum.inl ⟨s, hsX⟩ else
          if hsY : s.val ∈ Y then Sum.inr ⟨s, hsY⟩ else
          ((hs s.property).elim hsX hsY).elim :
        S → X ⊕ Y)
      ).transpose

/-- The empty set of columns in linearly independent. -/
theorem Matrix.IndepCols_empty (B : Matrix X Y Z2) : B.IndepCols ∅ := by
  sorry

/-- A subset of a linearly independent set of columns in linearly independent. -/
theorem Matrix.IndepCols_subset (B : Matrix X Y Z2) (I J : Set α) (hBJ : B.IndepCols J) (hIJ : I ⊆ J) :
    B.IndepCols I := by
  sorry

/-- A nonmaximal linearly independent set of columns can be augmented with another linearly independent column. -/
theorem Matrix.IndepCols_aug (B : Matrix X Y Z2) (I J : Set α)
    (hBI : B.IndepCols I) (nonmax : ¬Maximal B.IndepCols I) (hBJ : Maximal B.IndepCols J) :
    ∃ x ∈ J \ I, B.IndepCols (x ᕃ I) := by
  sorry

/-- Any set of columns has the maximal subset property. -/
theorem Matrix.IndepCols_maximal (B : Matrix X Y Z2) (S : Set α) :
    Matroid.ExistsMaximalSubsetProperty B.IndepCols S := by
  sorry

/-- Binary matroid generated by its standard representation matrix, expressed as `IndepMatroid`. -/
def Matrix.toIndepMatroid (B : Matrix X Y Z2) : IndepMatroid α where
  E := X ∪ Y
  Indep := B.IndepCols
  indep_empty := B.IndepCols_empty
  indep_subset := B.IndepCols_subset
  indep_aug := B.IndepCols_aug
  indep_maximal S _ := B.IndepCols_maximal S
  subset_ground _ := Exists.fst

/-- Binary matroid generated by its standard representation matrix, expressed as `Matroid`. -/
def Matrix.toMatroid (B : Matrix X Y Z2) : Matroid α := B.toIndepMatroid.matroid

end construction_from_matrices

/-- Binary matroid on the ground set `X ∪ Y` where `X` and `Y` are bundled. -/
structure BinaryMatroid (α : Type) [DecidableEq α] extends Matroid α where
  X : Set α
  Y : Set α
  decmemX : ∀ x, Decidable (x ∈ X)
  decmemY : ∀ y, Decidable (y ∈ Y)
  hXY : X ⫗ Y
  B : Matrix X Y Z2
  hE : E = X ∪ Y
  hB : toMatroid = B.toMatroid

variable {α : Type} [DecidableEq α]

theorem BinaryMatroid.Indep_eq (M : BinaryMatroid α) : have := M.decmemX; have := M.decmemY; M.Indep = M.B.IndepCols :=
  M.hB ▸ rfl

/-- The binary matroid on the ground set `X ∪ Y` is regular. -/
def BinaryMatroid.IsRegular (M : BinaryMatroid α) : Prop :=
  ∃ B' : Matrix M.X M.Y ℚ, -- signed version of `B`
    (Matrix.fromColumns (1 : Matrix M.X M.X ℚ) B').TU ∧ -- the matrix is totally unimodular
    ∀ i : M.X, ∀ j : M.Y, if M.B i j = 0 then B' i j = 0 else B' i j = 1 ∨ B' i j = -1 -- `B'` matches `B`

section matrix_level

variable {X₁ Y₁ : Set α} {X₂ Y₂ : Set α} {β : Type} [Field β]

/-- Matrix-level 1-sum for matroids defined by their standard representation matrices. -/
abbrev Matrix.oneSumComposition (A₁ : Matrix X₁ Y₁ β) (A₂ : Matrix X₂ Y₂ β) :
    Matrix (X₁ ⊕ X₂) (Y₁ ⊕ Y₂) β :=
  Matrix.fromBlocks A₁ 0 0 A₂

/-- Matrix-level 2-sum for matroids defined by their standard representation matrices; does not check legitimacy. -/
abbrev Matrix.twoSumComposition (A₁ : Matrix X₁ Y₁ β) (x : Y₁ → β) (A₂ : Matrix X₂ Y₂ β) (y : X₂ → β) :
    Matrix (X₁ ⊕ X₂) (Y₁ ⊕ Y₂) β :=
  Matrix.fromBlocks A₁ 0 (fun i j => y i * x j) A₂

/-- Matrix-level 3-sum for matroids defined by their standard representation matrices; does not check legitimacy. -/
noncomputable abbrev Matrix.threeSumComposition (A₁ : Matrix X₁ (Y₁ ⊕ Fin 2) β) (A₂ : Matrix (Fin 2 ⊕ X₂) Y₂ β)
    (z₁ : Y₁ → β) (z₂ : X₂ → β) (D : Matrix (Fin 2) (Fin 2) β) (D₁ : Matrix (Fin 2) Y₁ β) (D₂ : Matrix X₂ (Fin 2) β) :
    Matrix ((X₁ ⊕ Unit) ⊕ (Fin 2 ⊕ X₂)) ((Y₁ ⊕ Fin 2) ⊕ (Unit ⊕ Y₂)) β :=
  let D₁₂ : Matrix X₂ Y₁ β := D₂ * D⁻¹ * D₁
  Matrix.fromBlocks
    (Matrix.fromRows A₁ (Matrix.row Unit (Sum.elim z₁ ![1, 1]))) 0
    (Matrix.fromBlocks D₁ D D₁₂ D₂) (Matrix.fromColumns (Matrix.col Unit (Sum.elim ![1, 1] z₂)) A₂)

end matrix_level

/-- Matroid-level (independent sets) 1-sum for matroids defined by their standard representation matrices. -/
def BinaryMatroid.oneSum {M₁ M₂ : BinaryMatroid α}
    (hXX : M₁.X ⫗ M₂.X) (hYY : M₁.Y ⫗ M₂.Y) (hXY : M₁.X ⫗ M₂.Y) (hYX : M₁.Y ⫗ M₂.X) :
    BinaryMatroid α :=
  have dmX₁ := M₁.decmemX
  have dmY₁ := M₁.decmemY
  have dmX₂ := M₂.decmemX
  have dmY₂ := M₂.decmemY
  let B : Matrix ↑(M₁.X ∪ M₂.X) ↑(M₁.Y ∪ M₂.Y) Z2 := Matrix.of
    (fun i j =>
      Matrix.oneSumComposition M₁.B M₂.B (
        if hi₁ : i.val ∈ M₁.X then Sum.inl ⟨i, hi₁⟩ else
        if hi₂ : i.val ∈ M₂.X then Sum.inr ⟨i, hi₂⟩ else
        (i.property.elim hi₁ hi₂).elim
      ) (
        if hj₁ : j.val ∈ M₁.Y then Sum.inl ⟨j, hj₁⟩ else
        if hj₂ : j.val ∈ M₂.Y then Sum.inr ⟨j, hj₂⟩ else
        (j.property.elim hj₁ hj₂).elim
      )
    )
  ⟨
    B.toMatroid,
    M₁.X ∪ M₂.X,
    M₁.Y ∪ M₂.Y,
    (Set.decidableUnion _ _ ·),
    (Set.decidableUnion _ _ ·),
    by simp only [Set.disjoint_union_left, Set.disjoint_union_right]; exact ⟨⟨M₁.hXY, hYX.symm⟩, ⟨hXY, M₂.hXY⟩⟩,
    B, rfl, rfl
  ⟩

/-- Matroid-level 2-sum for matroids defined by their standard representation matrices; now checks legitimacy. -/
def BinaryMatroid.twoSum {M₁ M₂ : BinaryMatroid α} {a : α}
    -- TODO should `(hXX : M₁.X ⫗ M₂.X)` and `(hYY : M₁.Y ⫗ M₂.Y)` be required too?
    (hY₁ : a ∉ M₁.Y) (hX₂ : a ∉ M₂.X) (ha : M₁.X ∩ M₂.Y = {a}) (hXY : M₂.X ⫗ M₁.Y) :
    BinaryMatroid α × Prop :=
  have dmX₁ := M₁.decmemX
  have dmY₁ := M₁.decmemY
  have dmX₂ := M₂.decmemX
  have dmY₂ := M₂.decmemY
  let A₁ : Matrix (M₁.X \ {a} : Set α) M₁.Y Z2 := (fun i => M₁.B ⟨i.val, Set.mem_of_mem_diff i.property⟩) -- the top submatrix of `B₁`
  let A₂ : Matrix M₂.X (M₂.Y \ {a} : Set α) Z2 := (fun j => M₂.B · ⟨j.val, Set.mem_of_mem_diff j.property⟩) -- the right submatrix of `B₂`
  let x : M₁.Y → Z2 := M₁.B ⟨a, Set.mem_of_mem_inter_left (by rw [ha]; rfl)⟩ -- the bottom row of `B₁`
  let y : M₂.X → Z2 := (M₂.B · ⟨a, Set.mem_of_mem_inter_right (by rw [ha]; rfl)⟩) -- the left column of `B₂`
  let B : Matrix ↑((M₁.X \ {a} : Set α) ∪ M₂.X) ↑(M₁.Y ∪ (M₂.Y \ {a} : Set α)) Z2 := Matrix.of
    (fun i j =>
      Matrix.twoSumComposition A₁ x A₂ y (
        if hi₁ : i.val ∈ M₁.X \ {a} then Sum.inl ⟨i, hi₁⟩ else
        if hi₂ : i.val ∈ M₂.X then Sum.inr ⟨i, hi₂⟩ else
        (i.property.elim hi₁ hi₂).elim
      ) (
        if hj₁ : j.val ∈ M₁.Y then Sum.inl ⟨j, hj₁⟩ else
        if hj₂ : j.val ∈ M₂.Y \ {a} then Sum.inr ⟨j, hj₂⟩ else
        (j.property.elim hj₁ hj₂).elim
      )
    )
  ⟨
    ⟨
      B.toMatroid,
      (M₁.X \ {a} : Set α) ∪ M₂.X,
      M₁.Y ∪ (M₂.Y \ {a} : Set α),
      (Set.decidableUnion _ _ ·),
      (Set.decidableUnion _ _ ·),
      by
        rw [Set.disjoint_union_right, Set.disjoint_union_left, Set.disjoint_union_left]
        exact ⟨⟨disjoint_left_wo M₁.hXY a, hXY⟩, ⟨disjoint_of_singleton_intersection_both_wo ha,
          disjoint_right_wo M₂.hXY a⟩⟩,
      B, rfl, rfl
    ⟩,
    x ≠ 0 ∧ y ≠ 0
  ⟩

/-- Matroid-level 3-sum for matroids defined by their standard representation matrices; now checks legitimacy. -/
noncomputable def BinaryMatroid.threeSum {M₁ M₂ : BinaryMatroid α} {x₁ x₂ x₃ y₁ y₂ y₃ : α}
    (hXX : M₁.X ∩ M₂.X = {x₁, x₂, x₃}) (hYY : M₁.Y ∩ M₂.Y = {y₁, y₂, y₃}) (hXY : M₁.X ⫗ M₂.Y) (hYX : M₁.Y ⫗ M₂.X) :
    BinaryMatroid α × Prop :=
  have dmX₁ := M₁.decmemX
  have dmY₁ := M₁.decmemY
  have dmX₂ := M₂.decmemX
  have dmY₂ := M₂.decmemY
  have hxxx₁ : {x₁, x₂, x₃} ⊆ M₁.X := hXX.symm.subset.trans Set.inter_subset_left
  have hxxx₂ : {x₁, x₂, x₃} ⊆ M₂.X := hXX.symm.subset.trans Set.inter_subset_right
  have hyyy₁ : {y₁, y₂, y₃} ⊆ M₁.Y := hYY.symm.subset.trans Set.inter_subset_left
  have hyyy₂ : {y₁, y₂, y₃} ⊆ M₂.Y := hYY.symm.subset.trans Set.inter_subset_right
  have x₁inX₁ : x₁ ∈ M₁.X := hxxx₁ (Set.mem_insert x₁ {x₂, x₃})
  have x₁inX₂ : x₁ ∈ M₂.X := hxxx₂ (Set.mem_insert x₁ {x₂, x₃})
  have x₂inX₁ : x₂ ∈ M₁.X := hxxx₁ (Set.insert_comm x₁ x₂ {x₃} ▸ Set.mem_insert x₂ {x₁, x₃})
  have x₂inX₂ : x₂ ∈ M₂.X := hxxx₂ (Set.insert_comm x₁ x₂ {x₃} ▸ Set.mem_insert x₂ {x₁, x₃})
  have x₃inX₁ : x₃ ∈ M₁.X := hxxx₁ (by simp_all)
  have x₃inX₂ : x₃ ∈ M₂.X := hxxx₂ (by simp_all)
  have y₃inY₁ : y₃ ∈ M₁.Y := hyyy₁ (by simp_all)
  have y₃inY₂ : y₃ ∈ M₂.Y := hyyy₂ (by simp_all)
  have y₂inY₁ : y₂ ∈ M₁.Y := hyyy₁ (Set.insert_comm y₁ y₂ {y₃} ▸ Set.mem_insert y₂ {y₁, y₃})
  have y₂inY₂ : y₂ ∈ M₂.Y := hyyy₂ (Set.insert_comm y₁ y₂ {y₃} ▸ Set.mem_insert y₂ {y₁, y₃})
  have y₁inY₁ : y₁ ∈ M₁.Y := hyyy₁ (Set.mem_insert y₁ {y₂, y₃})
  have y₁inY₂ : y₁ ∈ M₂.Y := hyyy₂ (Set.mem_insert y₁ {y₂, y₃})
  --
  let A₁ : Matrix (M₁.X \ {x₁, x₂, x₃} : Set α) ((M₁.Y \ {y₁, y₂, y₃} : Set α) ⊕ Fin 2) Z2 := -- the top left submatrix
    (fun i j => M₁.B ⟨i.val, Set.mem_of_mem_diff i.property⟩
        (j.casesOn (fun j' => ⟨j'.val, Set.mem_of_mem_diff j'.property⟩) ![⟨y₂, y₂inY₁⟩, ⟨y₁, y₁inY₁⟩]))
  let A₂ : Matrix (Fin 2 ⊕ (M₂.X \ {x₁, x₂, x₃} : Set α)) (M₂.Y \ {y₁, y₂, y₃} : Set α) Z2 := -- the bottom right submatrix
    (fun i j => M₂.B (i.casesOn ![⟨x₂, x₂inX₂⟩, ⟨x₃, x₃inX₂⟩] (fun i' => ⟨i'.val, Set.mem_of_mem_diff i'.property⟩))
        ⟨j.val, Set.mem_of_mem_diff j.property⟩)
  let z₁ : (M₁.Y \ {y₁, y₂, y₃} : Set α) → Z2 := -- the middle left "row vector"
    (fun j => M₁.B ⟨x₁, x₁inX₁⟩ ⟨j.val, Set.mem_of_mem_diff j.property⟩)
  let z₂ : (M₂.X \ {x₁, x₂, x₃} : Set α) → Z2 := -- the bottom middle "column vector"
    (fun i => M₂.B ⟨i.val, Set.mem_of_mem_diff i.property⟩ ⟨y₃, y₃inY₂⟩)
  let D_₁ : Matrix (Fin 2) (Fin 2) Z2 := -- the bottom middle 2x2 submatrix
    (fun i j => M₁.B (![⟨x₂, x₂inX₁⟩, ⟨x₃, x₃inX₁⟩] i) (![⟨y₂, y₂inY₁⟩, ⟨y₁, y₁inY₁⟩] j))
  let D_₂ : Matrix (Fin 2) (Fin 2) Z2 := -- the middle left 2x2 submatrix
    (fun i j => M₂.B (![⟨x₂, x₂inX₂⟩, ⟨x₃, x₃inX₂⟩] i) (![⟨y₂, y₂inY₂⟩, ⟨y₁, y₁inY₂⟩] j))
  let D₁ : Matrix (Fin 2) (M₁.Y \ {y₁, y₂, y₃} : Set α) Z2 := -- the bottom left submatrix
    (fun i j => M₁.B (![⟨x₂, x₂inX₁⟩, ⟨x₃, x₃inX₁⟩] i) ⟨j.val, Set.mem_of_mem_diff j.property⟩)
  let D₂ : Matrix (M₂.X \ {x₁, x₂, x₃} : Set α) (Fin 2) Z2 := -- the bottom left submatrix
    (fun i j => M₂.B ⟨i.val, Set.mem_of_mem_diff i.property⟩ (![⟨y₂, y₂inY₂⟩, ⟨y₁, y₁inY₂⟩] j))
  --
  let B : Matrix ↑((M₁.X \ {x₁, x₂, x₃} : Set α) ∪ M₂.X) ↑(M₁.Y ∪ (M₂.Y \ {y₁, y₂, y₃} : Set α)) Z2 := Matrix.of
    (fun i j =>
      Matrix.threeSumComposition A₁ A₂ z₁ z₂ D_₁ D₁ D₂ (
        if hi₁ : i.val ∈ M₁.X \ {x₁, x₂, x₃} then Sum.inl (Sum.inl ⟨i, hi₁⟩) else
        if hi₂ : i.val ∈ M₂.X \ {x₁, x₂, x₃} then Sum.inr (Sum.inr ⟨i, hi₂⟩) else
        if hx₁ : i.val = x₁ then Sum.inl (Sum.inr ()) else
        if hx₂ : i.val = x₂ then Sum.inr (Sum.inl 0) else
        if hx₃ : i.val = x₃ then Sum.inr (Sum.inl 1) else
        (i.property.elim hi₁ (by simp_all)).elim
      ) (
        if hj₁ : j.val ∈ M₁.Y \ {y₁, y₂, y₃} then Sum.inl (Sum.inl ⟨j, hj₁⟩) else
        if hj₂ : j.val ∈ M₂.Y \ {y₁, y₂, y₃} then Sum.inr (Sum.inr ⟨j, hj₂⟩) else
        if hy₁ : j.val = y₁ then Sum.inl (Sum.inr 1) else
        if hy₂ : j.val = y₂ then Sum.inl (Sum.inr 0) else
        if hy₃ : j.val = y₃ then Sum.inr (Sum.inl ()) else
        (j.property.elim (by simp_all) hj₂).elim
      )
    )
  ⟨
    ⟨
      B.toMatroid,
      (M₁.X \ {x₁, x₂, x₃} : Set α) ∪ M₂.X,
      M₁.Y ∪ (M₂.Y \ {y₁, y₂, y₃} : Set α),
      (Set.decidableUnion _ _ ·),
      (Set.decidableUnion _ _ ·),
      by
        rw [Set.disjoint_union_right, Set.disjoint_union_left, Set.disjoint_union_left]
        exact ⟨⟨disjoint_left_wo3 M₁.hXY x₁ x₂ x₃, hYX.symm⟩, ⟨
          disjoint_left_wo3 (disjoint_right_wo3 hXY y₁ y₂ y₃) x₁ x₂ x₃,
          disjoint_right_wo3 M₂.hXY y₁ y₂ y₃⟩⟩,
      B, rfl, rfl
    ⟩,
    IsUnit D_₁ ∧ D_₁ = D_₂ -- the matrix `D_₁ = D_₂` (called D-bar in the book) is invertible
    -- TODO more conditions to check? Something about the 000000000011 column and the 110000000000 row?
  ⟩

/-- Matroid `M` is a result of 1-summing `M₁` and `M₂` (should be equivalent to direct sums). -/
def BinaryMatroid.Is1sum (M : BinaryMatroid α) (M₁ : BinaryMatroid α) (M₂ : BinaryMatroid α) : Prop :=
  ∃ hXX : M₁.X ⫗ M₂.X, ∃ hYY : M₁.Y ⫗ M₂.Y, ∃ hXY : M₁.X ⫗ M₂.Y, ∃ hYX : M₁.Y ⫗ M₂.X,
    M = BinaryMatroid.oneSum hXX hYY hXY hYX

/-- Matroid `M` is a result of 2-summing `M₁` and `M₂` in some way. -/
def BinaryMatroid.Is2sum (M : BinaryMatroid α) (M₁ : BinaryMatroid α) (M₂ : BinaryMatroid α) : Prop :=
  (M₁.X ⫗ M₂.X ∧ M₁.Y ⫗ M₂.Y) ∧ -- TODO some more disjointness?
    ∃ a : α, ∃ hY₁ : a ∉ M₁.Y, ∃ hX₂ : a ∉ M₂.X, ∃ ha : M₁.X ∩ M₂.Y = {a}, ∃ hXY : M₂.X ⫗ M₁.Y,
      let M₀ := BinaryMatroid.twoSum hY₁ hX₂ ha hXY
      M = M₀.fst ∧ M₀.snd

/-- Matroid `M` is a result of 3-summing `M₁` and `M₂` in some way. -/
def BinaryMatroid.Is3sum (M : BinaryMatroid α) (M₁ : BinaryMatroid α) (M₂ : BinaryMatroid α) : Prop :=
  ∃ x₁ x₂ x₃ y₁ y₂ y₃ : α, ∃ hXX : M₁.X ∩ M₂.X = {x₁, x₂, x₃}, ∃ hYY : M₁.Y ∩ M₂.Y = {y₁, y₂, y₃},
    ∃ hXY : M₁.X ⫗ M₂.Y, ∃ hYX : M₁.Y ⫗ M₂.X,
      let M₀ := BinaryMatroid.threeSum hXX hYY hXY hYX
      M = M₀.fst ∧ M₀.snd

/-- Any 1-sum of regular matroids is a regular matroid. -/
theorem BinaryMatroid.Is1sum.isRegular {M : BinaryMatroid α} {M₁ : BinaryMatroid α} {M₂ : BinaryMatroid α}
    (hM : M.Is1sum M₁ M₂) (hM₁ : M₁.IsRegular) (hM₂ : M₂.IsRegular) :
    M.IsRegular := by
  obtain ⟨eX, eY, hMXY⟩ := hM
  obtain ⟨B₁, hB₁, hBB₁⟩ := hM₁
  obtain ⟨B₂, hB₂, hBB₂⟩ := hM₂
  let B' := Matrix.oneSumComposition B₁ B₂
  have hB' : B'.TU
  · apply Matrix.fromBlocks_TU
    · rwa [Matrix.TU_glue_iff] at hB₁
    · rwa [Matrix.TU_glue_iff] at hB₂
  sorry

/-- Any 2-sum of regular matroids is a regular matroid. -/
theorem BinaryMatroid.Is2sum.isRegular {a : α} {M : BinaryMatroid α} {M₁ : BinaryMatroid α} {M₂ : BinaryMatroid α}
    (hM : M.Is2sum M₁ M₂) (hM₁ : M₁.IsRegular) (hM₂ : M₂.IsRegular) :
    M.IsRegular := by
  obtain ⟨eX, eY, hMXY⟩ := hM
  obtain ⟨B₁', hB₁, hBB₁⟩ := hM₁
  obtain ⟨B₂', hB₂, hBB₂⟩ := hM₂
  sorry

/-- Any 3-sum of regular matroids is a regular matroid. -/
theorem BinaryMatroid.Is3sum.isRegular {M : BinaryMatroid α} {M₁ : BinaryMatroid α} {M₂ : BinaryMatroid α}
    (hM : M.Is3sum M₁ M₂) (hM₁ : M₁.IsRegular) (hM₂ : M₂.IsRegular) :
    M.IsRegular := by
  obtain ⟨eX, eY, hMXY⟩ := hM
  obtain ⟨B₁', hB₁, hBB₁⟩ := hM₁
  obtain ⟨B₂', hB₂, hBB₂⟩ := hM₂
  sorry
