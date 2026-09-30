# RGR step zero: d² = 0 on a triangle

The complete red → green → refactor loop for proof-driven development in Bend 2,
demonstrated on the smallest non-vacuous model of **d² = 0** — the seed of Stokes' theorem.

## The math (30 seconds)

A 0-form puts a value on each vertex of a triangle. Its exterior derivative `d`
puts on each edge the *difference* of the endpoint values. The derivative of a
1-form puts on the face the signed sum over the boundary edges. **d² = 0** says
the boundary of a boundary is empty: every edge is counted twice, and x + x = 0.
We work over Z/2 (booleans), where subtraction is XOR.

## The loop

**🔴 Red** — `LAWS.bend` states the law; `PROOF.bend` holds `?TODO`:

```
$ bend PROOF.bend
Error: 1 TODO found.
The code is incomplete, and not a valid proof yet.
```

The failing law *is* the frontier of what we know. This is the honest state:
the theorem is stated before it is understood.

**🟢 Green** — prove it by brute force: 8 cases (each of a, b, c true/false),
every case computes to `False{}`, `{==}` closes each one:

```
$ bend PROOF.bend
All terms check.
```

You cannot green a proof you don't understand — the proof attempt *is* the studying.
Here the studying says: d² = 0 is true because every edge-difference appears twice.

**🔵 Refactor** — the case analysis never used the triangle, only the algebra of
XOR. Extract it as a standalone lemma `xor_cancel3`; `d2_zero` follows by
unfolding the definitions. The checker guards the restructuring:

```
$ bend PROOF.bend
All terms check.
```

The extracted lemma is pure algebra — reusable by the vector-calculus identities
next. This is where a publishable package is born: geometry stays in the law,
algebra leaves as a lemma.

## Bend lessons this cost us

- `import Base` is required for `Bool`, `Bool.xor`, etc.
- Term-level `!=` / `==` don't exist: equality of values is `T.is_eq(a, b)`;
  `==` lives only in proposition types. Boolean XOR is `Bool.xor(x, y)`.
- Constructors are `True{}` / `False{}` in term position.
- The affine checker rejects a variable used twice: mark reusable params `+`
  (`def d2(+a: Bool, +b: Bool, +c: Bool)`).
- Law-fillers take plain params and delegate to a helper when a variable is
  needed more than once (`def Laws.d2_zero(a, b, c): d2_zero_aux(a, b, c)`).
- Definitional unfolding works through defs in proof types: the refactored
  filler typechecks because `d2(a,b,c)` *computes to* the lemma's left-hand side.

## Files

- `LAWS.bend` — the spec: d₀, d₁, d₂ and the law `d2_zero`
- `PROOF.bend` — the refactored proof (final state)
- `RED.txt` / `GREEN.txt` / `REFACTOR.txt` — the checker transcripts
