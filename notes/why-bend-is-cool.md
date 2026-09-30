# Why Bend is cool

## The old dream

Write code that looks like Python; get performance that looks like CUDA —
*without* writing threads, locks, or kernels. Every generation of languages
has promised automatic parallelism. It kept failing for a real reason: naively
evaluating functional programs in parallel either **duplicates shared work
exponentially** or drowns in synchronization overhead.

## The trick, in two parts

**Interaction nets** (Lafont, 1990): compute on a graph where each reduction
step is *local* — it only touches neighboring nodes — and the system is
*confluent*: if a net can reduce two different ways, both ways reach the same
result in the same number of steps. If the order of steps doesn't matter, the
steps can happen **simultaneously on different cores without colliding**.
That's the entire parallelism story in one property — no locks, because local
rewrites on a graph have nothing to race over. ([How Bend works](https://towardsdatascience.com/how-bend-works-a-parallel-programming-language-that-feels-like-python-but-scales-like-cuda-48be5bf0fc2c/))

**[Affine types](affine.md)** make it *sound*. Use-at-most-once means no value
is ever aliased: when the runtime splits work across cores, there is no shared
state to fight over and no hidden duplication cost. Duplication still exists —
you just ask for it with `+`, so the cost is visible in the source instead of
lurking in the runtime. The type system *is* the thread-safety proof. (Bend is
[affine by default](https://github.com/akitaonrails/bend-tests/blob/HEAD/docs/language-notes.md):
a variable is used at most once; `+x` opts into reuse; `type T is Data` opts a
type into copyability.)

## What it feels like

`a b = f(x) g(y)` forks two calls across CPU cores. `f!(x)` sends the call —
and the parallel calls under it — to the GPU. You write ordinary-looking
functional code (pattern matching, recursion, ADTs) and the pipeline
(Bend → HVM, the interaction-net runtime → C/CUDA) parallelizes whatever can
be parallelized. Same program, CPU or GPU, zero kernels written by you.

## The honest caveats

- Parallelism needs *balanced* work — forking two trivial calls gains nothing.
- Values are affine: closures and arrays can't be freely shared across threads
  (experimental `@unsafe` sharing exists).
- On this VM, `bend run` executes single-threaded (the `bend` binary is
  Node-based); real multicore needs compiled C via clang 14+.
- Bend 2 is young: verbose (everything annotated, nothing inferred), a small
  Base library, and a young compiler with blind spots.

The bet, stated plainly: affine types buy parallelism you don't have to think
about, and [machine-checked laws](rgr-loop.md) buy refactoring you don't have
to fear. No other language offers that combination.

## See also

- [Affine: one word, three ideas](affine.md) — the type-system half of the trick
- [The RGR loop](rgr-loop.md) — the proof half of the bet
- [Mathematics, for a frontend engineer](frontend-math.md) — the translation dictionary
