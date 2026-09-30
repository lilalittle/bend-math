# Mathematics, for a frontend engineer

You already do mathematics all day. Mathematics is programming with the
machine removed: no runtime, no mutation, no floats, no event loop. An
expression just *is*. Here's the translation dictionary — and where it breaks.

## Same concept, both worlds

**Functions.** `const f = x => 2 * x` and f(x) = 2x are the same idea:
input → output. TypeScript's `(x: number) => number` is the notation f: ℝ → ℝ
wearing a different hat.

**Variables.** Math has no `let x = 5; x = 6`. A math variable is `const` that
was never even assignable — it's a *binding*, a name for a value. Once you
write "let n be an integer," n is that integer forever. This is why equational
reasoning works in proofs and breaks in imperative code.

**Equality.** `===` is close to math's `=`: no coercion, a real claim. (JS's
`==` has no mathematical twin — math never coerces.) In Bend, `{a == b}` goes
further: it's not a check, it's a *proposition you must prove*.

**Types are sets.** `type Vec = [number, number]` says "the set of all pairs of
numbers." A type is a set with a membership checker that runs at compile time.
`Array<number>` is the set of finite sequences. A union type is a set union.
When mathematicians say "for all x ∈ S," read it as a for-loop over every
inhabitant of the type.

**Booleans and logic.** `&&`, `||`, `!` are [boolean algebra](algebra.md) —
the same laws govern `if` conditions and circuit design. One divergence:
JS `&&` short-circuits (order matters, side effects happen); math's "and" is
commutative and timeless.

**Recursion is induction.** A recursive function over a tree *is* an inductive
proof waiting to happen. The `diff_correct` proof in this repo does induction
on the `Expr` tree exactly the way you'd write a recursive `eval` — base case,
then "assume it works for the children." If you can write recursion, you can
read induction.

**Composition.** `f(g(x))`, lodash `flow`, Express middleware — that's ∘,
function composition. [Matrix multiplication](vectors-matrices.md) is
composition of transforms; CSS transform lists compose right-to-left for the
same reason.

**Objects are finite functions.** `{a: 1, b: 2}` maps keys to values — a
function with a tiny domain. `Map` is the honest version. A math "function"
is the same idea with no `.has()` and no insertion order.

## Where they diverge

**Mutation and time.** Math has no state, no "later," no event loop. Nothing
changes, so substitution is always safe: if x = 5, you can replace x with 5
anywhere, forever. (Imagine refactoring with that guarantee.)

**Floats aren't reals.** `0.1 + 0.2 !== 0.3` in JS; in math, 0.1 + 0.2 = 0.3
exactly. JS numbers are finite approximations; the [verified reals](https://github.com/lilalittle/bend-packages/issues/77)
issue exists because this gap matters.

**NaN, undefined, null** have no counterparts. Math functions are total on
their domain — `f(x)` is always *something*. No `?.`, no `??`.

**Infinity** is a value in JS (`1/0 === Infinity`); in math it's a concept with
rules, handled via limits. Related but not the same animal.

**Eagerness is meaningless.** Lazy vs eager evaluation is a machine concern.
In math, `2 + 2` doesn't "run" — it *is* 4.

## Reading math as pseudocode

- f: ℝ → ℝ — `function f(x: number): number`
- ∀x. P(x) — "for every x, P holds" (a for-loop over everything)
- ∃x. P(x) — `.find()` that is guaranteed to succeed
- A proof — a program that typechecks; the proposition is its type

## See also

- [What algebra is](algebra.md) — the rules behind the rearranging you already do
- [Vectors and matrices](vectors-matrices.md) — the arrays you already use, as mathematics
- [The RGR loop](rgr-loop.md) — proofs as test-driven development
- [Learning path](learning-path.md) — where this road goes next
