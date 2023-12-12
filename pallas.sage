#!/usr/bin/sage
import sys
import sage.schemes.elliptic_curves.isogeny_small_degree as isd
try:
    from sagelib.common import find_z_sswu, generic_sswu_map_to_curve
except ImportError:
    sys.exit("Error loading preprocessed sage files. Try running `make`")

# Pallas scalar field size
r = 0x40000000000000000000000000000000224698fc0994a8dd8c46eb2100000001

# Fr = Pallas scalar field
Fr = GF(r)

# Vesta curve
Vesta = EllipticCurve(Fr, [0, 5])

isos = [i for i in isd.isogenies_prime_degree(Vesta, 3) if i.codomain().j_invariant() not in (0, 1728)]

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

# VestaPrime is the domain of the isogeny map which Vesta as the co-domain
VestaPrime = iso.domain()
assert(VestaPrime.a2() == 0)
assert(VestaPrime.a4() != 0)
assert(VestaPrime.a6() != 0)

A = VestaPrime.a4()
B = VestaPrime.a6()
Z = find_z_sswu(Fr, A, B)
print("Z used in SSWU:", Z)

r = Fr.random_element()
vesta_prime_point = generic_sswu_map_to_curve(Fr, A, B, Z, r)
print("Field element:", r)
print("Mapped point on VestaPrime:", vesta_prime_point)
print("Is point on VestaPrime curve?", VestaPrime.is_on_curve(vesta_prime_point[0], vesta_prime_point[1]))

vesta_point_x = rat_map[0](vesta_prime_point[0], vesta_prime_point[1])
vesta_point_y = rat_map[1](vesta_prime_point[0], vesta_prime_point[1])
vesta_point = Vesta.point([vesta_point_x, vesta_point_y, Fr(1)])

# Checking that directly applying the rational maps
# yields the same point as the in-built isogeny mapping
assert(vesta_point == iso(vesta_prime_point))

print("Mapped point on Vesta:", vesta_point)
print("Is point on Vesta curve?", Vesta.is_on_curve(vesta_point_x, vesta_point_y))