# Why Bend is cool

## The old dream

Write code that looks like Python; get performance that looks like CUDA —
*without* writing threads, locks, or kernels. The usual price of parallelism
is reasoning about sharing: which threads touch what, when, and whether they
collide.

## The trick, as the guide tells it

Bend's parallelism primitive is the **parallel call notation**:

```python
a b = pow2(p) pow2(p)  # the two calls run in parallel
```

A parallel call promises the compiler two things: the calls are **independent**,
and they take **roughly the same time**. Then the guide says the key sentence:

> *Since Bend is pure and affine, the first point always holds.*

That's the whole trick, and [affine types](affine.md) are half of it. Purity
means no side effects to collide; **affine-by-default** (use at most once)
means no value is ever aliased behind your back. Independence isn't something
you have to establish — the type system already did. The second promise,
balanced workload, is yours to keep.

Underneath is "a contention-free, binary fork-join machine": every task is
handed to a core exactly once and never moved afterwards — fast and
GPU-friendly, but you must keep the work balanced. A `!` after a function name
(`pow2!(20n)`) hands that call and every parallel call inside it to the GPU,
with a unified heap (zero-cost CPU↔GPU moves on unified-memory chips).

Sharing is explicit and priced: a `+` value read by every lane costs an atomic
per read. The type system doesn't just prevent data races — it puts the cost
of sharing in the source where you can see it.

## What it feels like

You write ordinary-looking functional code — pattern matching, recursion,
ADTs — and mark what's parallel with juxtaposition (`a b = ...`) and `!`.
Same program, CPU or GPU, zero kernels written. The JavaScript target just
runs sequentially (it's the fast-dev target, not the fast-run target).

## The honest caveats

- The independence promise is free; the *balance* promise is yours. Fork two
  uneven calls and the speedup is sub-ideal. Divergent work (n-queens) stays
  faster on CPU; uniform numeric work (mandelbrot, nbody) shines on GPU.
- Values are affine: closures and arrays can't be freely shared across lanes.
- `bend run` on this VM executes single-threaded (the `bend` binary is
  Node-based); real multicore/GPU needs a native compile via clang 14+.
- Bend 2 is young: verbose (everything annotated, nothing inferred), a small
  Base library, and a young compiler with blind spots.

The bet, stated plainly: affine types buy parallelism whose safety you don't
have to think about (and whose sharing costs you can see), and
[machine-checked laws](rgr-loop.md) buy refactoring you don't have to fear.
No other language offers that combination.

*Source: `bend guide` (Bend 2.0.27), "Parallelism" section. An earlier version
of this note described a Bend → HVM → C/CUDA pipeline from the Bend 1 era;
the Bend 2 guide describes the fork-join model above, so the note was
rewritten.*

## See also

- [Affine: one word, three ideas](affine.md) — the type-system half of the trick
- [The RGR loop](rgr-loop.md) — the proof half of the bet
- [Mathematics, for a frontend engineer](frontend-math.md) — the translation dictionary
