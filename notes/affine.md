# Affine: one word, three ideas

"Affine" shows up in geometry, graphics, and type systems — three ideas that
rhyme. In every case it means *linear, plus a little slack* — linearity with
the dangerous part removed or explicitly priced.

## 1. Affine maps

An affine map is **x ↦ Ax + b**: a linear map A *plus a translation* b. Every
CSS transform — translate, rotate, scale, skew, `matrix()` — is one.
(Perspective is the one that isn't; it's projective.)

What they preserve: straight lines stay straight, parallel lines stay
parallel, ratios of distances *along a line* are kept (midpoints stay
midpoints). What they don't: angles, lengths, circles — an affine map can
turn a circle into an ellipse without blinking.

## 2. Affine combinations

A weighted average whose weights **sum to 1**: t·P + (1−t)·Q. That's `lerp`.
Bézier curves are *iterated* affine combinations (de Casteljau's algorithm) —
CSS `cubic-bezier` easing and SVG `C` curves are affine combinations all the
way down. Note the fine print: weights summing to 1 alone does **not** keep
the result between the inputs — weights 2 and −1 sum to 1 but give 2P−Q,
which extrapolates past P away from Q. Staying inside the segment (the convex
hull) additionally requires **nonnegative** weights; that's a *convex*
combination. Bézier easing stays in [0,1] because its weights (the Bernstein
polynomials) are nonnegative on [0,1] — not merely because they sum to 1.

## 3. Affine spaces: points vs vectors

A vector space has an origin. An **affine space** is a vector space that's
*forgotten its origin*. Consequence, and it's a real one: positions are
**points**, displacements are **vectors**. You may add a vector to a point
(move), subtract two points (get the displacement), but adding two points is
meaningless — "New York + Boston" is nonsense; "New York + 3 miles north" is
an address. Every shader bug where someone adds two positions is this
distinction collecting its debt.

## 4. Affine types

A value of **affine type** can be used *at most once*. (Linear = exactly once;
affine = at most once — dropping is allowed.) Rust's ownership is the famous
example: move semantics mean no aliasing, hence no data races.

**Bend is affine by default**: a variable is used at most once unless the
binder is marked `+x`, and `type T is Data` declares a type copyable. This is
the rule you tripped over in the playground — law-filling defs can't take `+`
params, so proofs delegate to helpers. The compiler is telling you the
duplication cost up front instead of hiding it.

## Why the rhyme matters

In all four senses, "affine" removes the dangerous freedom: affine maps drop
the fixed origin, affine combinations drop extrapolation, affine spaces drop
point-plus-point, affine types drop uncontrolled duplication. That last one is
[why Bend is cool](why-bend-is-cool.md).

## See also

- [Why Bend is cool](why-bend-is-cool.md) — what affine types buy: parallelism without locks
- [The mathematics inside CSS](css-math.md) — affine maps in stylesheets
- [Vectors and matrices](vectors-matrices.md) — the linear half of x ↦ Ax + b
- [Mathematics, for a frontend engineer](frontend-math.md) — `const` as the poor man's affinity
