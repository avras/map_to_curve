#!/usr/bin/sage
import sys
import sage.schemes.elliptic_curves.isogeny_small_degree as isd
try:
    from sagelib.common import find_z_sswu, generic_sswu_map_to_curve
except ImportError:
    sys.exit("Error loading preprocessed sage files. Try running `make`")

# BN254 scalar field size
r = 21888242871839275222246405745257275088548364400416034343698204186575808495617

# Fr = BN254 scalar field
Fr = GF(r)

# Grumpkin curve
Grumpkin = EllipticCurve(Fr, [0, -17])

isos = [i for i in isd.isogenies_prime_degree(Grumpkin, 59) if i.codomain().j_invariant() not in (0, 1728)]

print("Number of isogenies =", len(isos))
iso = isos[0].dual()
print("Selected isogeny:")
print(iso)

print("\nRational maps of selected isogeny")
rat_map = iso.rational_maps()
print(rat_map)

print("\nDegrees of rational maps")
print("x-coordinate numerator degree =", rat_map[0].numerator().degree())
print("x-coordinate denominator degree =", rat_map[0].denominator().degree())
print("y-coordinate numerator degree =", rat_map[1].numerator().degree())
print("y-coordinate denominator degree =", rat_map[1].denominator().degree())

# GrumpkinPrime is the domain of the isogeny map which Grumpkin as the co-domain
GrumpkinPrime = iso.domain()
assert(GrumpkinPrime.a2() == 0)
assert(GrumpkinPrime.a4() != 0)
assert(GrumpkinPrime.a6() != 0)

A = GrumpkinPrime.a4()
B = GrumpkinPrime.a6()
Z = find_z_sswu(Fr, A, B)
print("Z used in SSWU:", Z)

r = Fr.random_element()
grumpkin_prime_point = generic_sswu_map_to_curve(Fr, A, B, Z, r)
print("Field element:", r)
print("Mapped point on GrumpkinPrime:", grumpkin_prime_point)
print("Is point on GrumpkinPrime curve?", GrumpkinPrime.is_on_curve(grumpkin_prime_point[0], grumpkin_prime_point[1]))

grumpkin_point_x = rat_map[0](grumpkin_prime_point[0], grumpkin_prime_point[1])
grumpkin_point_y = rat_map[1](grumpkin_prime_point[0], grumpkin_prime_point[1])
grumpkin_point = Grumpkin.point([grumpkin_point_x, grumpkin_point_y, Fr(1)])

# Checking that directly applying the rational maps
# yields the same point as the in-built isogeny mapping
assert(grumpkin_point == iso(grumpkin_prime_point))

print("Mapped point on Grumpkin:", grumpkin_point)
print("Is point on Grumpkin curve?", Grumpkin.is_on_curve(grumpkin_point_x, grumpkin_point_y))