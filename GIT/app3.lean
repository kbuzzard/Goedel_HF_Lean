import Mathlib.Tactic
import GIT.app1
import GIT.app2

open Classical

suppress_compilation

variable {S : Type u} [HF S]

namespace HF

def function (x : S) : Prop := (∀ y ∈ x, ∃ z z', y = ord_pair z z')
    ∧ (∀ u v v', ((ord_pair u v) ∈ x) → ((ord_pair u v') ∈ x) → v = v')

def dom (x : S) : S := pred_set (union_set (union_set x)) (fun u ↦ ∃ v, (ord_pair u v) ∈ x)

lemma exists_output_of_func (x y : S) (x_is_func : function x) (y_in_dom : y ∈ dom x) :
        ∃! z, ord_pair y z ∈ x := by
    rw [function] at x_is_func; cases' x_is_func with _ func2
    simp_rw [dom, pred_set_iff, union_set_iff] at y_in_dom
    rw [ExistsUnique]
    aesop

def output (x y : S) (x_is_func : function x) (y_in_dom : y ∈ dom x) : S :=
       (exists_output_of_func x y x_is_func y_in_dom).choose

lemma output_iff (x y : S) (x_is_func : function x) (y_in_dom : y ∈ dom x) :
        z = output x y x_is_func y_in_dom ↔ ord_pair y z ∈ x := by
    have := (exists_output_of_func x y x_is_func y_in_dom).choose_spec
    cases' this with h1 h2
    specialize h2 z; aesop

inductive ConstTerm : S → Prop
  | empty : ConstTerm (∅ : S)
  | enlarge {x y} (hx : ConstTerm x) (hy : ConstTerm y) : ConstTerm (x ◁ y)

namespace ordinal

def Functional (φ : ordinal S → S → Prop) (k : ordinal S) : Prop := ∃! y, φ k y

def p_function (φ : ordinal S → S → Prop) (k : ordinal S) (hφ : Functional φ k) : S
        := (hφ).choose

lemma p_function_iff (φ : ordinal S → S → Prop) (k : ordinal S) (hφ : Functional φ k) (y : S) :
    p_function φ k hφ = y ↔ φ k y := by
  have := (hφ).choose_spec; rw [p_function]
  refine ⟨by intro _; simp_all, ?_⟩
  intro phi
  cases' this with _ h
  specialize h y
  simp_all

def Seq (s : S) (k : ordinal S) : Prop := function s ∧ k ≠ ∅ ∧ dom s = k.1

lemma exists_output_of_Seq (s : S) (k l : ordinal S) (seq : Seq s k) (l_in_k : l ∈ k) :
        ∃! z, ord_pair l.1 z ∈ s := by
    rw [Seq] at seq; rcases seq with ⟨s_is_func, ⟨k_neq_emp, dom_is_k⟩⟩
    rw [mem, ← dom_is_k] at l_in_k
    exact exists_output_of_func s l.1 s_is_func l_in_k

def output_of_Seq (s : S) (k l : ordinal S) (seq : Seq s k) (l_in_k : l ∈ k) : S :=
        (exists_output_of_Seq s k l seq l_in_k).choose

lemma output_of_Seq_iff (s : S) (k l : ordinal S) (seq : Seq s k) (l_in_k : l ∈ k) :
        output_of_Seq s k l seq l_in_k = z ↔ ord_pair l.1 z ∈ s := by
    have := (exists_output_of_Seq s k l seq l_in_k).choose_spec
    cases' this with h1 h2
    specialize h2 z; aesop

lemma predec_mem_aux (k l : ordinal S) (k_in_l : k ∈ l) (k_neq_emp : k ≠ ∅) : predec k k_neq_emp ∈ l := by
    rw [mem_iff_subset, sbst, sbst_eq] at k_in_l
    cases' k_in_l with k_sbst_l k_neq_l
    have := predec_mem k k_neq_emp
    specialize k_sbst_l (predec k k_neq_emp) this
    exact k_sbst_l

def psi (G : S → S) (k : ordinal S) (y : S) : Prop := (k = ∅ ∧ y = ∅) ∨
        (∃ (k_neq_emp : k ≠ ∅) (s : S) (seq : Seq s k), y = G (output_of_Seq s k (predec k k_neq_emp) seq (predec_mem k k_neq_emp))
        ∧ ∀ n, (n_in_k : n ∈ k) → ((n = ∅ ∧ output_of_Seq s k n seq n_in_k = ∅) ∨ ∃ (n_neq_emp : n ≠ ∅),
        output_of_Seq s k n seq n_in_k = G (output_of_Seq s k (predec n n_neq_emp) seq (predec_mem_aux n k n_in_k n_neq_emp))))

lemma psi_iff_emp (G : S → S) (k : ordinal S) (y : S) (k_eq_emp : k = ∅) : psi G k y ↔ y = ∅ := by
    rw [psi]
    aesop

lemma psi_iff_not_emp (G : S → S) (k : ordinal S) (y : S) (k_neq_emp : k ≠ ∅) :
    psi G k y ↔ (∃ (s : S) (seq : Seq s k), y = G (output_of_Seq s k (predec k k_neq_emp) seq (predec_mem k k_neq_emp)) ∧
    ∀ n, (n_in_k : n ∈ k) → ((n = ∅ ∧ output_of_Seq s k n seq n_in_k = ∅) ∨ ∃ (n_neq_emp : n ≠ ∅),
    output_of_Seq s k n seq n_in_k = G (output_of_Seq s k (predec n n_neq_emp) seq (predec_mem_aux n k n_in_k n_neq_emp)))) := by
  rw [psi]
  aesop

def psi_seq1 : S := single (ord_pair ∅ ∅)

lemma psi_seq1_eq_seq : Seq (psi_seq1) (succ (∅ : ordinal S)) := by
  rw [Seq]; constructor
  · simp_rw [function, psi_seq1, single_iff, ord_pair_equal]
    aesop
  · refine ⟨succ_neq_emp ∅, ?_⟩
    simp_rw [dom, exten_prop, pred_set_iff, union_set_iff, succ, HF.succ, enlarge_iff]; intro u
    have in_empty_false : u ∈ (∅ : ordinal S).1 ↔ False := by have := set_notin_empty u; aesop
    simp_rw [in_empty_false, false_or, psi_seq1, single_iff, ord_pair_equal]
    refine ⟨by aesop, ?_⟩
    intro h; simp only [exists_eq_left, h, exists_eq_right]
    refine ⟨?_, by aesop⟩
    use single ∅
    simp_rw [ord_pair, pair_iff, single_iff]
    aesop

def psi_seq2 (G : S → S) (s : S) (k : ordinal S) (k_neq_emp : k ≠ ∅) (seq : Seq s k) : S
    := s ◁ (ord_pair k.1 (G (output_of_Seq s k (predec k k_neq_emp) seq (predec_mem k k_neq_emp))))

lemma psi_seq2_eq_seq (G : S → S) (s : S) (k : ordinal S) (k_neq_emp : k ≠ ∅) (seq : Seq s k)
    (hseq : ∀ (n : ordinal S) (n_in_k : n ∈ k),
    n = ∅ ∧ output_of_Seq s k n seq n_in_k = ∅ ∨
    ∃ (n_neq_emp : n ≠ ∅), output_of_Seq s k n seq n_in_k = G (output_of_Seq s k (predec n n_neq_emp) seq (predec_mem_aux n k n_in_k n_neq_emp)))
    : Seq (psi_seq2 G s k k_neq_emp seq) (succ k) := by
  have seq' := seq; rcases seq' with ⟨⟨func1, func2⟩, ⟨_, dom⟩⟩
  simp_rw [HF.dom, exten_prop, pred_set_iff, union_set_iff] at dom
  have arg_in_k (z z' : S) (ord_in_s : ord_pair z z' ∈ s) : z ∈ k.1 := by
      specialize dom z; rw [← dom]
      refine ⟨?_, by use z'⟩
      use single z; simp only [single_iff, and_true]
      use ord_pair z z'; refine ⟨by assumption, ?_⟩
      simp_rw [ord_pair, pair_iff, true_or]
  rw [Seq]; constructor
  · simp_rw [function, psi_seq2, enlarge_iff, ord_pair_equal]
    refine ⟨by aesop, ?_⟩
    intros u v v' h1 h2
    cases' h1 with c1 c2
    · cases' h2 with c3 c4
      · specialize func2 u v v' c1 c3; exact func2
      · specialize arg_in_k u v c1; simp only [c4] at arg_in_k
        exfalso; apply set_notin_set k.1; assumption
    · cases' h2 with c3 c4
      · specialize arg_in_k u v' c3; simp only [c2] at arg_in_k
        exfalso; apply set_notin_set k.1; assumption
      · simp_all
  · refine ⟨by exact succ_neq_emp k, ?_⟩
    simp_rw [HF.dom, exten_prop, pred_set_iff, union_set_iff, psi_seq2, succ, HF.succ, enlarge_iff]; intro u
    specialize dom u
    constructor
    · intro h; rcases h with ⟨_, ⟨v, h_ord⟩⟩
      rw [ord_pair_equal] at h_ord
      cases' h_ord with h_ord u_eq_k
      · specialize arg_in_k u v h_ord; left; exact arg_in_k
      · right; cases' u_eq_k with h _; exact h
    · intro h; cases' h with u_in_k u_eq_k
      · rw [← dom] at u_in_k; rcases u_in_k with ⟨⟨y, ⟨⟨y', ⟨y'_in_s, y_in_y'⟩⟩, u_in_y⟩⟩, ⟨v, ord_in_s⟩⟩
        constructor
        · use y; refine ⟨?_, by assumption⟩
          use y'; refine ⟨?_, by assumption⟩
          left; assumption
        · use v; left; assumption
      · constructor
        · use single k.1; rw [single_iff]
          refine ⟨?_, by assumption⟩
          use ord_pair (k.1) (G (output_of_Seq s k (predec k k_neq_emp) seq (predec_mem k k_neq_emp)))
          rw [ord_pair, pair_iff]; refine ⟨?_,by left; rfl⟩
          right; rfl
        · use G (output_of_Seq s k (predec k k_neq_emp) seq (predec_mem k k_neq_emp))
          right; rw [u_eq_k]

lemma psi_functional_succ (G : S → S) (k : ordinal S) (y : S) (psi_y : psi G k y) : psi G (succ k) (G y) := by
    rw [psi_iff_not_emp G (succ k) (G y) (succ_neq_emp k)]
    by_cases k_eq_emp : k = ∅
    · rw [psi_iff_emp G k y k_eq_emp] at psi_y; simp_rw [psi_y, k_eq_emp, predec_of_succ]
      use psi_seq1; use psi_seq1_eq_seq
      have h :  output_of_Seq (psi_seq1) (succ ∅) ∅ (psi_seq1_eq_seq) (mem_of_succ ∅) = (∅ : S) := by
        rw [output_of_Seq_iff, psi_seq1, single_iff]; rfl
      simp_rw [h, true_and]
      intros n hn; simp_rw [mem_of_succ_emp_eq_emp] at hn
      aesop
    · rw [psi_iff_not_emp G k y k_eq_emp] at psi_y
      rcases psi_y with ⟨s, ⟨seq, ⟨hy,hseq⟩⟩⟩
      use psi_seq2 G s k k_eq_emp seq; use psi_seq2_eq_seq G s k k_eq_emp seq hseq
      simp [hy, k_eq_emp, predec_of_succ]
      have h : output_of_Seq (psi_seq2 G s k k_eq_emp seq) (succ k) k (psi_seq2_eq_seq G s k k_eq_emp seq hseq) (mem_of_succ k) =
            G (output_of_Seq s k (predec k k_eq_emp) seq (predec_mem k k_eq_emp)) := by
        rw [output_of_Seq_iff, psi_seq2, enlarge_iff]; simp
      simp_rw [h, true_and]
      intros n hn
      by_cases n_eq_emp : n = ∅
      · simp only [n_eq_emp, true_and, not_true_eq_false, IsEmpty.exists_iff, or_false]
        rw [output_of_Seq_iff, psi_seq2, enlarge_iff]; left
        specialize hseq ∅ (contains_empty k k_eq_emp)
        simp only [true_and, ne_eq, not_true_eq_false, IsEmpty.exists_iff, or_false, output_of_Seq_iff] at hseq
        exact hseq
      · right; have n_eq_emp2 : ¬n.1 = ↑(∅ : ordinal S).1 := by aesop
        use n_eq_emp2
        simp_rw [output_of_Seq_iff, psi_seq2, enlarge_iff]
        by_cases n_eq_k : n = k
        · right; have n_eq_k2: n.1 = k.1 := by aesop
          simp_rw [n_eq_k2, ord_pair_equal, true_and, n_eq_k]
          have G_eq (x y : S) (h : x = y) : G x = G y := congrArg G h
          apply G_eq
          rw [output_of_Seq_iff, enlarge_iff]; left
          specialize hseq (predec k k_eq_emp) (predec_mem k k_eq_emp)
          cases' hseq with hseq1 hseq2
          · simp_rw [hseq1]; specialize hseq ∅ (contains_empty k k_eq_emp)
            simp only [true_and, ne_eq, not_true_eq_false, IsEmpty.exists_iff, or_false, output_of_Seq_iff] at hseq
            have this : output_of_Seq s k ∅ seq (contains_empty k k_eq_emp) = ∅ := by rwa [output_of_Seq_iff]
            aesop
          · cases' hseq2 with predec_neq_emp hseq2
            rw [output_of_Seq_iff] at hseq2
            have this : output_of_Seq s k (predec k k_eq_emp) seq (predec_mem k k_eq_emp) =
                    (G (output_of_Seq s k (predec (predec k k_eq_emp) predec_neq_emp) seq (predec_mem_aux (predec k k_eq_emp) k (predec_mem k k_eq_emp) predec_neq_emp))) := by
                rwa [output_of_Seq_iff]
            aesop
        · left
          have n_in_k : n ∈ k := by simp_rw [succ, HF.succ, enlarge_iff] at hn; aesop
          have hseqq := hseq
          specialize hseqq n n_in_k
          simp only [n_eq_emp, false_and, ne_eq, not_false_eq_true, exists_true_left, false_or, output_of_Seq_iff] at hseqq
          have this : output_of_Seq s k (predec n n_eq_emp) seq (predec_mem_aux n k n_in_k ((Iff.of_eq ((congrArg Not (eq_false n_eq_emp)).trans not_false_eq_true)).mpr True.intro)) =
                output_of_Seq (s ◁ ord_pair (k.1) (G (output_of_Seq s k (predec k k_eq_emp) seq (predec_mem k k_eq_emp)))) (succ k) (predec n n_eq_emp) (psi_seq2_eq_seq G s k k_eq_emp seq hseq)
                (predec_mem_aux n (succ k) hn n_eq_emp) := by
            rw [output_of_Seq_iff]
            specialize hseq (predec n n_eq_emp) (predec_mem_aux n k n_in_k n_eq_emp)
            cases' hseq with hseq1 hseq2
            · simp_rw [hseq1]; have hseqq2 := hseq; specialize hseqq2 ∅ (contains_empty k k_eq_emp)
              simp only [true_and, ne_eq, not_true_eq_false, IsEmpty.exists_iff, or_false, output_of_Seq_iff] at hseqq2
              have this : output_of_Seq (s ◁ ord_pair (k.1) (G (output_of_Seq s k (predec k k_eq_emp) seq (predec_mem k k_eq_emp)))) (succ k) ∅ (psi_seq2_eq_seq G s k k_eq_emp seq hseq)
                    (contains_empty (succ k) (succ_neq_emp k)) = ∅ := by
                rw [output_of_Seq_iff, enlarge_iff]; aesop
              aesop
            · cases' hseq2 with predec_neq_emp hseq2
              rw [output_of_Seq_iff] at hseq2
              have this : output_of_Seq (s ◁ ord_pair (k.1) (G (output_of_Seq s k (predec k k_eq_emp) seq (predec_mem k k_eq_emp)))) (succ k) (predec n n_eq_emp) (psi_seq2_eq_seq G s k k_eq_emp seq hseq)
                    (predec_mem_aux n (succ k) hn n_eq_emp) =
                    (G (output_of_Seq s k (predec (predec n n_eq_emp) predec_neq_emp) seq (predec_mem_aux (predec n n_eq_emp) k (predec_mem_aux n k n_in_k n_eq_emp) predec_neq_emp))) := by
                rw [output_of_Seq_iff, enlarge_iff]; aesop
              aesop
          aesop

def psi_seq3 (s : S) (k : ordinal S) (k_neq_emp : k ≠ ∅) : S
    := pred_set s (fun u ↦ (single (predec k k_neq_emp).1) ∉ u)

lemma psi_seq3_eq_seq (s : S) (k : ordinal S) (k_neq_emp : k ≠ ∅) (predec_neq_emp : predec k k_neq_emp ≠ ∅)
    (seq : Seq s k) : Seq (psi_seq3 s k k_neq_emp) (predec k k_neq_emp) := by
  rw [Seq] at *; rcases seq with ⟨func, ⟨k_neq_emp', dom⟩⟩; rw [neq] at k_neq_emp'
  refine ⟨?_, ⟨by assumption, ?_⟩⟩
  · rw [function] at *
    simp_rw [psi_seq3, pred_set_iff]
    sorry
  · simp_rw [HF.dom, exten_prop, pred_set_iff, union_set_iff, psi_seq3, pred_set_iff] at *
    intro u; specialize dom u
    constructor
    · intro h; rcases h with ⟨⟨y, ⟨⟨y', ⟨⟨y'_in_s, h_ord⟩, y_in_y'⟩⟩, u_in_y⟩⟩, ⟨v, ⟨ord_v_in_s, h_ord_v⟩⟩⟩
      have u_in_k : ((∃ y, (∃ y_1 ∈ s, y ∈ y_1) ∧ u ∈ y) ∧ ∃ v, ord_pair u v ∈ s) := by refine ⟨by aesop, by aesop⟩
      rw [dom] at u_in_k
      have y_neq_predec : u ≠ (predec k k_neq_emp).1 := by by_contra!; apply h_ord_v; rw [← this, ord_pair, pair_iff]; left; rfl
      rw [← succ_predec_of_ord_eq_ord k.1 k.2 k_neq_emp', HF.succ, enlarge_iff, ← predec_1_eq_HF_predec k k_neq_emp k_neq_emp'] at u_in_k
      simp_all
    · intro h; have h' := h; rw [predec_1_eq_HF_predec k k_neq_emp k_neq_emp'] at h'
      have u_in_k : u ∈ k.1 := by rw [← succ_predec_of_ord_eq_ord k.1 k.2 k_neq_emp', HF.succ, enlarge_iff]; left; exact h'
      rw [← dom] at u_in_k
      rcases u_in_k with ⟨⟨y, ⟨⟨y', ⟨y'_in_s, y_in_y'⟩⟩, u_in_y⟩⟩, ⟨v, ord_pair_in_s⟩⟩
      rw [function] at func; rcases func with ⟨hfunc1, hfunc2⟩
      specialize hfunc1 y' y'_in_s; rcases hfunc1 with ⟨z, ⟨z', y'_eq_ord_pair⟩⟩
      constructor
      · use y; refine ⟨?_, by assumption⟩
        use y'; refine ⟨?_, by assumption⟩
        refine ⟨by assumption, ?_⟩
        by_contra!; rw [y'_eq_ord_pair, ord_pair, pair_iff, single_equal] at this
        rw [y'_eq_ord_pair, ord_pair, pair_iff] at y_in_y'
        sorry
      · use v; refine ⟨by assumption, ?_⟩
        by_contra!; rw [ord_pair, pair_iff, single_equal] at this
        cases' this with single pair
        · rw [single] at h
          apply set_notin_set u; exact h
        · have pair : HF.pair u v = single (predec k k_neq_emp).1 := by simp_all
          rw [pair_single] at pair; cases' pair with predec_eq_u _
          rw [predec_eq_u] at h
          apply set_notin_set u; exact h

lemma psi_seq3_eq_seq_if_not_predec (s : S) (k l : ordinal S) (k_neq_emp : k ≠ ∅) (l_in_k : l ∈ k)
    (predec_neq_emp : predec k k_neq_emp ≠ ∅) (seq : Seq s k) (l_in_predec : l ∈ predec k k_neq_emp):
    output_of_Seq (psi_seq3 s k k_neq_emp) (predec k k_neq_emp) l (psi_seq3_eq_seq s k k_neq_emp predec_neq_emp seq) (l_in_predec)
    = output_of_Seq s k l seq l_in_k := by
  have h : ∃ z, output_of_Seq s k l seq l_in_k = z := by use output_of_Seq s k l seq l_in_k
  cases' h with z h
  rw [h, output_of_Seq_iff, psi_seq3, pred_set_iff]
  rw [output_of_Seq_iff] at h; refine ⟨by assumption, ?_⟩
  by_contra!
  rw [ord_pair, pair_iff, single_equal] at this
  have predec_neq_l : (predec k k_neq_emp).1 ≠ l.1 := by
    by_contra!; rw [mem, this] at l_in_predec; apply set_notin_set l.1; assumption
  simp only [predec_neq_l, false_or] at this
  have this : pair l.1 z = single (predec k k_neq_emp).1 := by aesop
  rw [pair_single] at this
  aesop

lemma psi_functional_exists_Gy (G : S → S) (k : ordinal S) (k_neq_emp : k ≠ ∅) (y : S) (psi_y : psi G k y) :
    ∃ y', y = G y' := by rw [psi_iff_not_emp G k y k_neq_emp] at psi_y; aesop

lemma psi_functional_predec (G : S → S) (inj : Function.Injective G) (k : ordinal S) (k_neq_emp : k ≠ ∅)
    (y : S) (psi_y : psi G k (G y)) : psi G (predec k k_neq_emp) y := by
  rw [psi_iff_not_emp G k (G y) k_neq_emp] at psi_y
  by_cases predec_eq_emp : predec k k_neq_emp = ∅
  · rw [psi_iff_emp G (predec k k_neq_emp) y predec_eq_emp]
    simp_rw [predec_eq_emp] at psi_y
    rcases psi_y with ⟨s,⟨seq, ⟨hG, h⟩⟩⟩
    have h' := h
    specialize h ∅ (contains_empty k k_neq_emp)
    simp only [true_and, ne_eq, not_true_eq_false, IsEmpty.exists_iff, or_false] at h
    rw [h] at hG
    aesop
  · rw [psi_iff_not_emp G (predec k k_neq_emp) y predec_eq_emp]
    rcases psi_y with ⟨s,⟨seq, ⟨hG, h⟩⟩⟩
    rw [Function.Injective] at inj; apply inj at hG
    use psi_seq3 s k k_neq_emp; use psi_seq3_eq_seq s k k_neq_emp predec_eq_emp seq
    constructor
    · specialize h (predec k k_neq_emp) (predec_mem k k_neq_emp)
      simp only [predec_eq_emp, false_and, ne_eq, not_false_eq_true, exists_true_left, false_or] at h
      rw [hG, h, congrArg G]
      have predec_predec_in_k : predec (predec k k_neq_emp) predec_eq_emp ∈ k := by
        nth_rw 2 [← succ_of_predec k k_neq_emp]; simp only [succ, mem, HF.succ, enlarge_iff]
        have := predec_mem (predec k k_neq_emp) predec_eq_emp; simp_all
      rw [psi_seq3_eq_seq_if_not_predec s k (predec (predec k k_neq_emp) predec_eq_emp) k_neq_emp predec_predec_in_k predec_eq_emp seq (predec_mem (predec k k_neq_emp) predec_eq_emp)]
    · intros n n_in_predec
      have n_in_k : n ∈ k := by
        rw [← succ_of_predec k k_neq_emp]; simp only [succ, mem, HF.succ, enlarge_iff]; simp_all
      specialize h n n_in_k
      rw [psi_seq3_eq_seq_if_not_predec s k n k_neq_emp n_in_k predec_eq_emp seq]
      by_cases n_eq_emp : n = ∅
      · aesop
      · right; use n_eq_emp
        rw [psi_seq3_eq_seq_if_not_predec s k (predec n n_eq_emp) k_neq_emp (predec_mem_aux n k n_in_k n_eq_emp) predec_eq_emp seq]
        aesop

lemma psi_functional (G : S → S) (inj : Function.Injective G) (k : ordinal S) : Functional (psi G) k := by
    rw [Functional]
    by_contra not_exists
    have set_neq_emp : {l : ordinal S | ¬∃! y, psi G l y} ≠ ∅ := by
        rw [setOf]; by_contra!
        have h : ¬ ∃ l, ¬∃! y, psi G l y := by aesop
        apply h; use k
    let m := min_set {l : ordinal S | ¬∃! y, psi G l y} set_neq_emp
    have m_in_set : m ∈ {l : ordinal S | ¬∃! y, psi G l y} := by apply min_set_in_set
    rw [Set.mem_setOf_eq] at m_in_set
    by_cases m_eq_emp : m = ∅
    · apply m_in_set
      simp_rw [psi]
      use ∅; aesop
    · let n := predec m m_eq_emp
      have n_notin_set : n ∉ {l : ordinal S | ¬∃! y, psi G l y} := by
        simp [predec_of_min_set_notin_set {l : ordinal S | ¬∃! y, psi G l y} set_neq_emp m_eq_emp]
      rw [Set.mem_setOf_eq, not_not] at n_notin_set
      rcases n_notin_set with ⟨y_n, ⟨psi_y_n, uniq_y_n⟩⟩
      apply psi_functional_succ at psi_y_n; rw [succ_of_predec] at psi_y_n
      apply m_in_set
      use G y_n
      refine ⟨by assumption, ?_⟩
      intros y psi_y; have psi_y' := psi_y
      apply psi_functional_exists_Gy G m m_eq_emp y at psi_y'
      cases' psi_y' with y' hy'
      rw [hy'] at psi_y
      apply psi_functional_predec G inj m m_eq_emp y' at psi_y; apply psi_functional_predec G inj m m_eq_emp y_n at psi_y_n
      aesop

theorem exists_recursive_function_on_ordinals_for_empty (G : S → S) (inj : Function.Injective G) :
        ∃ (F : ordinal S → S),
        F = fun k => if eq_emp : k = ∅ then ∅ else G (F (predec k eq_emp)) := by
    use (fun k ↦ p_function (psi G) k (psi_functional G inj k))
    have func_equal (H F : ordinal S → S) (h : ∀ (k : ordinal S), H k = F k) : (fun k => H k) = (fun k => F k) := by simp_all
    specialize func_equal (fun k ↦ p_function (psi G) k (psi_functional G inj k)) (fun k => if eq_emp : k = ∅ then ∅ else G (((fun k ↦ p_function (psi G) k (psi_functional G inj k)) (predec k eq_emp))))
    apply func_equal
    intro k; split_ifs with k_eq_emp
    · rw [p_function_iff, k_eq_emp]
      rw [psi]; left
      refine ⟨rfl, rfl⟩
    · have p_func_eq_y : ∃y, ((fun k ↦ p_function (psi G) k (psi_functional G inj k)) (predec k k_eq_emp)) = y := by
        use ((fun k ↦ p_function (psi G) k (psi_functional G inj k)) (predec k k_eq_emp))
      cases' p_func_eq_y with y p_func_eq_y
      rw [p_func_eq_y, ← succ_of_predec k k_eq_emp]; rw [p_function_iff] at *
      apply psi_functional_succ; assumption

def recursive_function_on_ordinals_for_empty (G : S → S) (inj : Function.Injective G) : ordinal S → S :=
        (exists_recursive_function_on_ordinals_for_empty G inj).choose

lemma recursive_lemma1 (G : S → S) (inj : Function.Injective G) (k : ordinal S) (eq_emp : k = ∅) :
        recursive_function_on_ordinals_for_empty G inj k = ∅ := by
    have := (exists_recursive_function_on_ordinals_for_empty G inj).choose_spec
    rw [recursive_function_on_ordinals_for_empty, this]
    aesop

lemma recursive_lemma2 (G : S → S) (inj : Function.Injective G) (k : ordinal S) (neq_emp : k ≠ ∅) :
        recursive_function_on_ordinals_for_empty G inj k = G (recursive_function_on_ordinals_for_empty G inj (predec k neq_emp)) := by
    have := (exists_recursive_function_on_ordinals_for_empty G inj).choose_spec
    rw [recursive_function_on_ordinals_for_empty]
    sorry

end ordinal
end HF
