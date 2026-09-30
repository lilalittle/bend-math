# What algebra actually is

**The start:** arithmetic with unknowns. 2x + 3 = 7 — find x. Solving is
*undoing operations*: subtract 3 (undo the +3), divide by 2 (undo the ×2).
Every equation you solved in school was "peel the operations off in reverse."

**The leap:** stop caring *which* numbers; care about the *rules*. Addition of
integers, XOR of booleans, concatenation of strings — different stuff, same
shape: combining two things into one, with an identity element and a way to
undo. Algebra is the study of those shapes.

You already live in one: **boolean algebra**. `&&`, `||`, `!` in every `if`
statement obey laws — De Morgan's `!(a && b) === !a || !b` is a theorem you
use without thinking. The [playground's XOR](z2-coefficients.md) is addition
in the tiniest number system there is.

**The zoo, in one breath:**

- A **group**: one operation you can always undo. Integers under +, rotations
  of a square, Rubik's cube moves. (Undoing is the whole game.)
- A **ring**: two operations that play nicely, like + and × on integers.
- A **field**: a ring where division (by nonzero) works — rationals, reals,
  and Z/p for prime p. Z/2, the playground's booleans, is the smallest field.

**Linear algebra** is algebra where the "numbers" are [vectors](vectors-matrices.md)
and the operations are matrix-shaped. Same game, bigger pieces.

**Why it matters here:** every time you rearrange code freely — factor out a
common subexpression, reorder independent operations — you're leaning on an
algebraic law. Bend `law`s are those instincts made explicit and
machine-checked. The [vector calculus identities](https://github.com/lilalittle/bend-packages/issues/68)
are algebra; [d² = 0](d2-zero.md) is algebra.

## See also

- [Why Z/2 coefficients](z2-coefficients.md) — the smallest field, in action
- [d² = 0](d2-zero.md) — an algebraic law with geometric meaning
- [Vectors and matrices](vectors-matrices.md) — linear algebra from the graphics side
- [Mathematics, for a frontend engineer](frontend-math.md) — the translation dictionary
