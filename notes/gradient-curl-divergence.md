# Gradient, curl, divergence

The three musketeers of vector calculus are [d](exterior-derivative.md) in
three disguises:

- **Gradient** (d of a 0-form): stand on a hillside — gradient points downhill,
  steepest descent, length proportional to steepness. It turns "height
  everywhere" into "which way water flows."
- **Curl** (d of a 1-form): stick a paddlewheel in a stream — curl measures how
  much and which way it spins. A draining bathtub has curl; a straight uniform
  current doesn't.
- **Divergence** (d of a 2-form): draw a tiny bubble around a point — divergence
  is the net outflow through the skin. A faucet has positive divergence (source);
  a drain has negative (sink); a uniform current has zero.

The two great identities are [d² = 0](d2-zero.md) wearing overalls:

- **curl(grad f) = 0** — a hill can't make water flow in a circle. Walk any loop
  on the hillside: every uphill is matched by a downhill. The boundary of the
  loop's interior contributes nothing.
- **div(curl F) = 0** — a swirl has no source. What flows into any bubble flows
  back out; the field just goes around.

These are the workhorses of field theory — and the target of
[bend-packages#68](https://github.com/lilalittle/bend-packages/issues/68),
the next rung after the playground.

## See also

- [The exterior derivative](exterior-derivative.md) — the single operator behind all three
- [d² = 0](d2-zero.md) — why the two identities hold
- [The divergence theorem](divergence-theorem.md) — divergence's starring role
