import pymap3d as pm

origin = (52.006259, 4.368762, 50)

points = {
    'A': (52.063129, 4.470840, 5000),
    'B': (52.063129, 4.470840, 0),
    'C': (52.073060, 4.394729, 0),
    'D': (51.965790, 4.256091, 10000),
}

for name, point in points.items():
    lat, lon, alt = point
    e, n, u = pm.geodetic2enu(lat, lon, alt, *origin)
    print(f'{name}: [{e:.1f}, {n:.1f}, {u:.1f}]')