import ../signed-core/Core.bend as C
import ./Core2.bend as Core2

# ============================================================
# signed-core-v2/LAWS.bend
#
# Universal linear-extension theorem: B²=0 on every basis cell
# ⟹ B²=0 on every chain.
#
# The per-cell certificate (cell_zc) is a first-order dependent
# function over finite data (Nat, Z -> ZeroChain), NOT a
# higher-order operator. cell_zc_ok certifies it against the
# normalized linear double boundary on each singleton.
# ============================================================

law b2_universal:
  for ~cell_zc: (@cell: Nat -> @a: C.Z -> Core2.ZeroChain)
  for t: C.Table
  for cell_zc_ok: (@cell: Nat -> @a: C.Z -> {Core2.to_chain(cell_zc(cell, a)) == Core2.chnorm(Core2.b2(t, Core2.single(cell, a))) : C.Chain})
  for c: C.Chain
  {C.chain_is_zero(Core2.to_chain(Core2.b2z(cell_zc, c))) == True{} : Bool}
