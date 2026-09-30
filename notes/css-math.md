# The mathematics inside CSS

CSS looks declarative, but it's applied mathematics wearing a stylesheet.
The umbrella map:

## Angles — [notes](trigonometry.md)

`rotate()` takes `deg`, `rad`, `grad`, or `turn`. Radians are the mathematically
natural unit (arc length on the unit circle); `turn` is the honest unit for
animations (`rotate(1turn)` reads better than `360deg`). JS `Math.sin` takes
radians — same circle, same angles.

## Transforms — [notes](vectors-matrices.md)

`translate()`, `rotate()`, `scale()` are **affine maps** — linear maps plus a
translation. `matrix(a,b,c,d,e,f)` is a 3×3 matrix in disguise (homogeneous
coordinates for 2D); `matrix3d(...)` is the full 4×4, column-major.

Three facts that explain 90% of transform confusion:

1. **Order is right-to-left.** `transform: rotate(45deg) translateX(10px)`
   translates *first*, then rotates — matrix multiplication composes
   right-to-left, like `f(g(x))`.
2. **`transform-origin` is conjugation.** `T(p)·M·T(−p)`: translate the origin
   to p, apply M, translate back. "Rotate around the corner" is algebra.
3. **Translation needs the extra dimension.** A 3×3 can't move the origin
   (linear maps fix it), so 2D graphics uses 3×3 homogeneous matrices and 3D
   uses 4×4. The last column of `matrix3d` is the translation vector.

**Perspective** (`perspective: 800px`) is a *projective* transform — it divides
by z, which is what makes distant things small. The `perspective()` transform
function vs the `perspective` property differ in where that division happens
(per-element vs shared vanishing point).

## Easing

`cubic-bezier(x1, y1, x2, y2)` is a **parametric Bézier curve** — the same
mathematics as SVG path curves and canvas drawing. An easing function
reparameterizes time: it maps linear clock-time to "story time." `steps(n)` is
a staircase function — a discontinuous reparameterization, hence the
stop-motion feel.

## Color

`rgb()` is a **vector** in a cube. Color interpolation is vector interpolation —
and *which space* you interpolate in changes the result: naive sRGB
interpolation goes through muddy middles because sRGB isn't perceptually
uniform. Interpolating in linear-light or oklch (a perceptual space) fixes the
banding. `color-interpolation: linearRGB` is choosing your vector space
honestly.

## See also

- [Vectors and matrices](vectors-matrices.md) — the machinery behind every transform
- [Angles and circles](trigonometry.md) — radians, turns, and why
- [SVG math](svg-math.md) — the same matrices in `transform` attributes and filters
- [Affine: one word, three ideas](affine.md) — CSS transforms are affine maps (minus perspective)
- [Mathematics, for a frontend engineer](frontend-math.md) — the translation dictionary
