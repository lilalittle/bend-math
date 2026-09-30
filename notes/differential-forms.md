# Differential forms

A **k-form** pins a number to every k-dimensional piece of space:

- a **0-form** pins a number to every *point* — temperature at each location, height of a landscape
- a **1-form** pins a number to every little *path* — work done pushing along it, flow across it
- a **2-form** pins a number to every little *patch* — flux through it
- a **3-form** pins a number to every little *volume* — mass inside it

That's the whole idea. A form is a *measurement device* shaped like the thing
it measures. The "differential" in the name is historical baggage — think
"integrand": a k-form is exactly the kind of thing you integrate over a
k-dimensional region.

Forms can be combined with the **wedge product** (∧), which builds higher forms
from lower ones and is *alternating*: swapping two inputs flips the sign, so
ω ∧ ω = 0. That alternation is the algebraic shadow of orientation — and it's
half of why [d² = 0](d2-zero.md).

## See also

- [The exterior derivative](exterior-derivative.md) — d turns k-forms into (k+1)-forms
- [Why Z/2 coefficients](z2-coefficients.md) — the playground's booleans are 0- and 1-forms over the field with two elements
- [Gradient, curl, divergence](gradient-curl-divergence.md) — what 0-, 1-, 2-forms look like in vector calculus
