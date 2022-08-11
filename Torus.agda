module Torus where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.GroupoidLaws
open import Cubical.HITs.Torus

private
  variable
    ℓ : Level
    A : Type ℓ


-- To correct the boundary

notRefl-filler : {a b c : A} (p : a ≡ b) (q : b ≡ c) → (i j k : I) → A
notRefl-filler p q t i j =
  fill (λ j → compPath-filler p q j i ≡ compPath-filler p q j i)
  (λ j → λ { (i = i0) → refl ; (i = i1) → refl })
  (inS refl) j t

notRefl : {a b c : A} (p : a ≡ b) (q : b ≡ c) → p ∙ q ≡ p ∙ q
notRefl p q i j = notRefl-filler p q i j i1

-- Two cubes only differ at the caps, so it's easy to make a path.
refl≡notRefl : {a b c : A} (p : a ≡ b) (q : b ≡ c) → refl ≡ notRefl p q
refl≡notRefl {a = a} p q i j k =
  hcomp (λ l → λ
    { (i = i0) → compPath-filler p q l k
    ; (i = i1) → notRefl-filler p q j k l
    ; (j = i0) → compPath-filler p q l k
    ; (j = i1) → compPath-filler p q l k
    ; (k = i0) → a
    ; (k = i1) → q l })
  (p k)


-- 🍩
data T² : Type where
  base : T²
  p q : base ≡ base
  surf : p ∙ q ≡ q ∙ p

hcomp-inv : {φ : I} (u : I → Partial φ A) (u0 : A [ φ ↦ u i1 ])
          → hcomp u (hcomp (λ k → u (~ k)) (outS u0)) ≡ outS u0
hcomp-inv u u0 i = hcomp-equivFiller (λ k → u (~ k)) u0 (~ i)

T²≃Torus : T² ≃ Torus
T²≃Torus = isoToEquiv (iso to from to-from from-to)
  where
    sides : {a : A} (p1 p2 : a ≡ a) (i j k : I) → Partial (i ∨ ~ i ∨ j ∨ ~ j) A
    sides p1 p2 i j k (i = i0) = compPath-filler p2 p1 (~ k) j
    sides p1 p2 i j k (i = i1) = compPath-filler' p1 p2 (~ k) j
    sides p1 p2 i j k (j = i0) = p1 (i ∧ k)
    sides p1 p2 i j k (j = i1) = p1 (i ∨ ~ k)

    to : T² → Torus
    to base = point
    to (p i) = line1 i
    to (q j) = line2 j
    to (surf i j) = hcomp (λ k → sides line1 line2 (~ i) j (~ k)) (square (~ i) j)

    from : Torus → T²
    from point = base
    from (line1 i) = p i
    from (line2 j) = q j
    from (square i j) = hcomp (sides p q i j) (surf (~ i) j)

    to-from : ∀ x → to (from x) ≡ x
    to-from point = refl
    to-from (line1 i) = refl
    to-from (line2 i) = refl
    to-from (square i j) = hcomp-inv (sides line1 line2 i j) (inS (square i j))

    from-to : ∀ x → from (to x) ≡ x
    from-to base = refl
    from-to (p i) = refl
    from-to (q i) = refl
    from-to (surf i j) k =
      -- correct two faces while keep others invariant
      hcomp (λ l → λ
        { (i = i0) → refl≡notRefl p q l k j
        ; (i = i1) → refl≡notRefl q p l k j
        ; (j = i0) → base
        ; (j = i1) → base
        ; (k = i0) → from (to (surf i j))
        ; (k = i1) → surf i j })
      (hcomp-inv (λ k → sides p q (~ i) j (~ k)) (inS (surf i j)) k)
