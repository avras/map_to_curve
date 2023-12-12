#!/usr/bin/sage
import sage.schemes.elliptic_curves.isogeny_small_degree as isd

# BN254 scalar field size
r = 21888242871839275222246405745257275088548364400416034343698204186575808495617

# Fr = BN254 scalar field
Fr = GF(r)

# Grumpkin curve
Grumpkin = EllipticCurve(Fr, [0, -17])

# Based on code from Appendix A of https://eprint.iacr.org/2019/403
for p_test in primes(100):
     isos = [i for i in isd.isogenies_prime_degree(Grumpkin, p_test) if i.codomain().j_invariant() not in (0, 1728)]
     if len(isos) > 0:
        print(p_test)
        exit()