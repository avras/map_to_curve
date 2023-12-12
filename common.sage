#!/usr/bin/sage

# Script from https://www.rfc-editor.org/rfc/rfc9380.html#sswu-z-code
# Used to find z used in simplified SSWU map
# Arguments:
# - F, a field object, e.g., F = GF(2^521 - 1)
# - A and B, the coefficients of the curve y^2 = x^3 + A * x + B
def find_z_sswu(F, A, B):
    R.<xx> = F[]                       # Polynomial ring over F
    g = xx^3 + F(A) * xx + F(B)        # y^2 = g(x) = x^3 + A * x + B
    ctr = F.gen()
    while True:
        for Z_cand in (F(ctr), F(-ctr)):
            # Criterion 1: Z is non-square in F.
            if is_square(Z_cand):
                continue
            # Criterion 2: Z != -1 in F.
            if Z_cand == F(-1):
                continue
            # Criterion 3: g(x) - Z is irreducible over F.
            if not (g - Z_cand).is_irreducible():
                continue
            # Criterion 4: g(B / (Z * A)) is square in F.
            if is_square(g(B / (Z_cand * A))):
                return Z_cand
        ctr += 1

# Modified version of following code
# https://github.com/cfrg/draft-irtf-cfrg-hash-to-curve/blob/main/poc/generic_map.sage#L37
def inv0(F, x):
    if F(x) == 0:
        return F(0)
    return F(1) / F(x)

# Simplified version of following code
# https://github.com/cfrg/draft-irtf-cfrg-hash-to-curve/blob/664b13592116cecc9e52fb192dcde0ade36f904e/poc/common.sage#L40
def sgn0(F, x):
    return ZZ(F(x)) % 2


def generic_sswu_map_to_curve(F, A, B, Z, u):
        tv1 = inv0(F, Z^2 * u^4 + Z * u^2)
        x1 = (-B / A) * (1 + tv1)
        if tv1 == 0:
            x1 = B / (Z * A)
        gx1 = x1^3 + A * x1 + B
        x2 = Z * u^2 * x1
        gx2 = x2^3 + A * x2 + B
        if gx1.is_square():
            x = x1
            y = gx1.sqrt()
        else:
            x = x2
            y = gx2.sqrt()
        if sgn0(F, u) != sgn0(F, y):
            y = -y
        return (x, y)