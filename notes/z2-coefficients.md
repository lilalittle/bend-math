# Why Z/2 coefficients

The playground proves d² = 0 over **booleans** — the field with two elements,
Z/2 — instead of real numbers. Why is that legitimate?

Over Z/2, addition is XOR: 0 + 0 = 0, 0 + 1 = 1, 1 + 1 = 0. Crucially,
**x + x = 0 for every x**, and subtraction *is* addition. The entire proof of
d² = 0 rests on one fact: every edge-difference appears twice and cancels.
That fact needs x + x = 0 — which Z/2 has, and which the reals also have
(x + (−x) = 0, just with signs to track).

So Z/2 keeps the *combinatorial skeleton* of the theorem and discards the
analytic flesh: no limits, no real numbers, no signs. The cancellation pattern
is identical; only the bookkeeping is simpler. And it's *computable* — every
case reduces to `False{}`, which is why `{==}` can close the proof.

The idea survives the upgrade: redo the proof over integers and the same
cancellation happens with signs; over reals nothing changes structurally.
Z/2 is the cheapest coefficients that tell the truth.

## See also

- [d² = 0](d2-zero.md) — the theorem this justifies
- [Differential forms](differential-forms.md) — forms can take coefficients in any ring
