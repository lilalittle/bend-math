# The exterior derivative

**d** is a single operator that takes a k-form and produces a (k+1)-form by
measuring *how the k-form changes around the boundary* of each (k+1)-piece.

Picture the hilly landscape again — height is a 0-form:

- **d of a 0-form** on a little trail: how much you climbed. Which way is
  downhill, how steep. This is the *gradient*.
- **d of a 1-form** on a little patch: the circulation around the patch's rim.
  How much the field swirls. This is the *curl*.
- **d of a 2-form** on a little volume: the net outflow through the volume's
  skin. This is the *divergence*.

One operator, three familiar faces. The miracle is that they're not three
separate inventions — they're d at levels 0, 1, 2.

The other half of d's character: **[d² = 0](d2-zero.md)**. Apply d twice and you
get nothing — because the boundary of a boundary is empty.

## See also

- [Differential forms](differential-forms.md) — what d acts on
- [Boundary of a boundary](boundary-of-boundary.md) — the geometry behind d² = 0
- [Gradient, curl, divergence](gradient-curl-divergence.md) — d's three classical disguises
- [Stokes' theorem](stokes-theorem.md) — ∫ dω = ∫ ω over the boundary; d's reason for existing
