import ./LAWS.bend as Laws
import ./Core2.bend as Core2
import ../signed-core/Core.bend as C

# ============================================================
# signed-core-v2/PROOF.bend
#
# The universal theorem is proven by zchain_is_zero: b2z builds
# a ZeroChain (manifestly (p,p) coefficients) from the per-cell
# certificates, and every ZeroChain denotes zero by
# nat_is_eq_refl — no boolean reflection, no combining needed.
# ============================================================

def Laws.b2_universal(cell_zc, t, cell_zc_ok, c):
  Core2.zchain_is_zero(Core2.b2z(cell_zc, c))
