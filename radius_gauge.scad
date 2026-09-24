// Corner radius gauge: a set of L-shaped chips, each with an inside corner of known radius.
// Press a chip onto the device corner - the one that sits flush with no gap
// and no rocking is the radius. Number engraved on each chip = radius in mm.

$fn = 96;

radii      = [2, 3, 4, 5, 6, 7, 8];   // override: -D 'radii=[9,10,11,12,13,14,15,16]'
arm        = 6;     // arm width (solid part)
reach      = max(radii) + 6;   // inside length of each arm, past the corner
cols       = 4;     // chips per row on the bed
thick      = 3;     // chip thickness
spacing    = 4;     // gap between chips on the bed
text_size  = 3.5;
text_depth = 0.6;

cell = arm + reach;

module chip(r) {
    difference() {
        cube([cell, cell, thick]);
        // pocket with rounded inside corner at (arm, arm)
        translate([arm, arm, -1])
            hull()
                for (x = [r, cell + r], y = [r, cell + r])
                    translate([x, y, 0]) cylinder(r = r, h = thick + 2);
        // radius label on the solid corner
        translate([arm / 2, arm / 2, thick - text_depth])
            linear_extrude(text_depth + 1)
                text(str(r), size = text_size, halign = "center", valign = "center",
                     font = "Liberation Sans:style=Bold");
    }
}

for (i = [0 : len(radii) - 1])
    translate([(i % cols) * (cell + spacing), floor(i / cols) * (cell + spacing), 0])
        chip(radii[i]);
