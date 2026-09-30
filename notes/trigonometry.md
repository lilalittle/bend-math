# Angles, circles, and why radians

**The definition:** on the unit circle (radius 1, centered at origin), the
point at angle θ has coordinates **(cos θ, sin θ)**. That's it — cosine and
sine aren't triangle ratios first; they're *coordinates on a circle*. The
triangle ratios follow.

**Radians** measure angle as *arc length*: θ radians = arc of length θ on the
unit circle. A full turn is 2π ≈ 6.283. π isn't mystical — it's half a turn,
the arc length of a semicircle.

**Why radians are the "real" unit:** calculus only works in radians.
d/dθ sin θ = cos θ *only* in radians; in degrees there's an ugly π/180 factor.
The limit sin θ / θ → 1 as θ → 0 — the fact all of trigonometry's calculus
rests on — is a radians-only statement. Degrees are Babylonian legacy (360 =
nice divisible number); radians are what the math wants.

**Where you already meet them:**

- `Math.sin()`, `Math.cos()` take **radians**. `Math.PI` is there for a reason.
- CSS `rotate()` accepts `deg`, `rad`, `grad`, `turn` — `rotate(1turn)` and
  `rotate(360deg)` are the same angle; `turn` is the honest unit for animations.
- Canvas `arc(x, y, r, startAngle, endAngle)` takes radians.
- SVG arc flags encode angles implicitly (see [SVG math](svg-math.md)).

**Euler's formula** (teaser): e^{iθ} = cos θ + i sin θ. Rotation *is*
multiplication by e^{iθ} — angles add when you multiply. This is the doorway to
complex numbers ([issue](https://github.com/lilalittle/bend-packages/issues/78)):
2D rotation without matrices.

## See also

- [The mathematics inside CSS](css-math.md) — angles in `rotate()`, and turns in animations
- [Vectors and matrices](vectors-matrices.md) — rotation matrices are cos/sin in a grid
- [SVG math](svg-math.md) — arcs, the fiddliest angle math in the frontend
