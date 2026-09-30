# SVG math

SVG is a coordinate-system machine with a path language on top. The math is
small but dense — and the arc command is the fiddliest piece of applied
geometry in all of frontend.

## Two coordinate systems

Every SVG has a **viewport** (pixels on screen) and a **viewBox** (user units).
The mapping between them is an **affine transform**: scale + translate,
computed from `viewBox="minX minY w h"` against the viewport size.
`preserveAspectRatio` chooses the letterboxing strategy — which uniform scale
to use and where to center. "Why is my SVG stretched?" is always this mapping.

## Paths

`M` (move), `L` (line), `C` (cubic Bézier), `Q` (quadratic Bézier) — the curve
commands are **parametric polynomials** with control points. The `C` command's
two control points are the handles you drag in design tools; same math as CSS
`cubic-bezier` easing.

**The `A` (arc) command** is the boss fight: `A rx ry x-axis-rotation
large-arc-flag sweep-flag x y`. Given two endpoints and an ellipse, there are
**four** possible arcs; the two flags pick one: large-arc chooses the big vs
small arc, sweep chooses the clockwise vs counterclockwise direction. The
endpoint-to-center conversion (in the SVG spec) is real ellipse geometry —
rotating into the ellipse's frame, solving for the center, computing start and
sweep angles. This is genuinely the hardest math in routine frontend work.

## Transforms and animation

The `transform` attribute is the [same matrix story as CSS](css-math.md) —
`translate/rotate/scale/matrix` compose right-to-left.

`stroke-dasharray` + animated `stroke-dashoffset` ("marching ants," line-drawing
effects) is arithmetic on a periodic pattern along path length; the
`pathLength` attribute normalizes any path to a chosen length so the dash math
stays simple.

## Gradients and filters

`linearGradient`'s `(x1,y1)→(x2,y2)` is a vector; color stops are 1D
interpolation along it. `feGaussianBlur` is **convolution** with a Gaussian
kernel — weighted averaging over a neighborhood. `feColorMatrix` multiplies
each pixel's RGBA **vector** by a 5×4 matrix — [linear algebra](vectors-matrices.md)
per pixel, including the alpha row most people forget.

## See also

- [The mathematics inside CSS](css-math.md) — transforms, easing, color: the shared machinery
- [Vectors and matrices](vectors-matrices.md) — affine maps, homogeneous coordinates
- [Angles and circles](trigonometry.md) — what's hiding inside arc flags
