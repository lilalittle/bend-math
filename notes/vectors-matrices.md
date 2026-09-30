# Vectors and matrices

**A vector is an arrow and an array — same thing.** `[x, y, z]` points from the
origin to the point (x, y, z); the arrow has a direction and a length. Adding
vectors is tip-to-tail (walk A, then walk B). Scaling stretches or shrinks.
The **dot product** a·b = |a||b|cos θ measures "how much of a points along b"
— projection. You've used it if you've ever written a lighting calculation:
`dot(normal, lightDir)` is brightness.

**A matrix is a function on vectors.** Multiplying a matrix by a vector applies
a transform: rotate, scale, shear, project. The columns of the matrix are
where the basis vectors land — read a 2D matrix's columns and you can *see*
the transform.

**Matrix × matrix is composition.** AB means "do B, then A" — right to left,
like `f(g(x))`. This is why CSS `transform: rotate(45deg) translateX(10px)`
applies the translation first: it's matrix multiplication, and function
composition reads right-to-left. Every transform list is a matrix product in
disguise.

**Why 4×4 for 3D.** Translation moves the origin, so it can't be a 3×3 matrix
(linear maps fix the origin). Graphics cheats with **homogeneous coordinates**:
write points as [x, y, z, 1], and the 4×4's extra row/column carries the
translation. CSS `matrix3d(...)` is exactly this — 16 numbers, column-major
(WebGL heritage). The 2D `matrix(a, b, c, d, e, f)` is the same trick with a
3×3 hiding behind six numbers.

**Vocabulary worth having:**

- **Determinant**: the signed area/volume scale factor. Negative = the transform
  mirrors (flips handedness). Zero = it squashes flat (no inverse).
- **Inverse**: the undo matrix. `M⁻¹M = I`, the matrix that does nothing.
- **Rotation matrices** are [cos/sin](trigonometry.md) arranged in a grid —
  orthonormal columns, determinant 1.

## See also

- [The mathematics inside CSS](css-math.md) — `matrix()`, `matrix3d()`, transform order
- [SVG math](svg-math.md) — `feColorMatrix` is a matrix on RGBA vectors
- [Angles and circles](trigonometry.md) — where rotation matrices come from
- [Affine: one word, three ideas](affine.md) — x ↦ Ax + b, and use-at-most-once
- [What algebra is](algebra.md) — linear algebra is algebra with vector-shaped numbers
