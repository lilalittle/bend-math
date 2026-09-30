# Vector calculus identities (rung 2)

The complete red → green → refactor loop for **bend-packages#68**: the
workhorse identities — div(curl F) = 0, curl(grad f) = 0, div(grad f) = Δf —
proved over exact types (Z/2 booleans, no floats anywhere).

## The math (30 seconds)

Grad, curl, and div are the discrete exterior derivative `d` at levels 0, 1, 2:

- **grad** of a 0-form on an edge: the endpoint difference `f(j) - f(i)`
- **curl** of a 1-form on a face: the circulation around the boundary edges
- **div** of a 2-form on a tetrahedron: the flux through the 4 faces

Laws 1 and 2 are **d² = 0 in disguise**: the boundary of a boundary is empty.
On a face, each edge-difference appears twice (curl of grad); on a
tetrahedron, each of the 6 edges borders exactly 2 of the 4 faces (div of
curl). Over Z/2, x + x = 0, so everything cancels. Law 3 says div(grad f) is
the discrete Laplacian — and, less vacuously, that the Laplacian doesn't
depend on which orientation convention you read the edges with.

## The loop

**🔴 Red** — `LAWS.bend` states the three laws; `PROOF.bend` holds `?TODO`:

```
$ bend PROOF.bend
Error: 3 TODOs found.
The code is incomplete, and not a valid proof yet.
```

**🟢 Green** — three focused lemmas, each proved by brute-force case analysis
(8, 64, and 8 cases); the fillers delegate to them:

```
$ bend PROOF.bend
All terms check.
```

The 64-case lemma is the honest cost of having no proof automation — every
case is "each edge appears twice." This is the thing
[bend-packages#75](https://github.com/lilalittle/bend-packages/issues/75)
should eliminate.

**🔵 Refactor** — the pure-algebra lemmas move to `Algebra.bend`; `PROOF.bend`
keeps only the thin fillers delegating through `Alg`. The checker guards the
split by unfolding definitions across the import:

```
$ bend PROOF.bend
All terms check.
```

`Algebra.bend` is the seed of a publishable package: geometry stays in the
laws, algebra leaves as a module. (`grad_curl_cancel` restates d2-zero's
`xor_cancel3` locally so this folder is self-contained; unifying them is a
packaging TODO.)

## Bend lessons this cost us

- In `PROOF.bend`, definitions from `LAWS.bend` must be referenced **qualified**
  (`Laws.curl_of_grad`) — even in lemma return types. An unqualified name in
  that position fails with "expected: a defined name."
- Extra modules are fine: `PROOF.bend` can import `./Algebra.bend as Alg`
  alongside `./LAWS.bend as Laws`; law-filling still resolves.
- Brute force scales to 64 cases without complaint (0.3 s) — the checker, not
  the human, is the limit on tedium.

## Files

- `LAWS.bend` — the spec: grad/curl/div, the three compositions, the three laws
- `Algebra.bend` — the extracted proof lemmas (pure algebra)
- `PROOF.bend` — the fillers (final state)
- `RED.txt` / `GREEN.txt` / `REFACTOR.txt` — the checker transcripts
