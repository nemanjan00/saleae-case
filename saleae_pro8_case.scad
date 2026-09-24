// Saleae Logic Pro 8 case with permanent micro-USB 3.0 retention

$fn = 64;

// What to render: "assembly", "bottom", "top", "top_print" (flipped for printing),
//                 "plug", "print" (both parts laid flat)
part = "assembly";

// --- Device (Saleae Logic Pro 8), measured ---
dev_w    = 54.62;  // X - along the probe / USB faces
dev_d    = 54.62;  // Y - from probe face to USB face (device is square)
dev_h    = 12.88;  // Z - including feet
dev_feet = 1;      // feet height (body starts this far above the floor)
dev_r    = 12;     // vertical corner radius, measured with radius gauge

// Pocket = device + clearance
dev_clear   = 0.25;  // per side, X/Y
dev_clear_z = 0.3;   // total, above the device
pk_w = dev_w + 2 * dev_clear;
pk_d = dev_d + 2 * dev_clear;
pk_h = dev_h + dev_clear_z;
pk_r = dev_r + dev_clear;

// Rounded-corner box, corners rounded in XY plane, origin at bottom-left
module rounded_box(w, d, h, r) {
    hull()
        for (x = [r, w - r], y = [r, d - r])
            translate([x, y, 0]) cylinder(r = r, h = h);
}

module device() {
    rounded_box(dev_w, dev_d, dev_h, dev_r);
}

module pocket() {
    rounded_box(pk_w, pk_d, pk_h, pk_r);
}

// --- Case ---
case_wall  = 3;   // side wall thickness (added on each side)
case_floor = 2;   // floor under the device
case_roof  = 2;   // roof above the device

case_w = pk_w + 2 * case_wall;
case_d = pk_d + 2 * case_wall;
case_h = case_floor + pk_h + case_roof;
case_r = 2;   // outer corner radius; smaller than dev_r + case_wall leaves
              // extra material in the corners for the screws

// Device origin (front-left-bottom corner) inside the case
dev_x0 = case_wall + dev_clear;
dev_y0 = case_wall + dev_clear;
dev_z0 = case_floor;

// Split plane runs through the USB plug center (body center, above the feet)
bottom_h = dev_z0 + dev_feet + (dev_h - dev_feet) / 2;
top_h    = case_h - bottom_h;

// --- Screws: M2 flat cylindrical head, hex socket, from the top, self-tapping ---
// Heads sit proud on the roof (no counterbore). Use M2x12.
screw_pilot_d = 1.6;   // pilot hole in bottom half (PETG self-tap)
screw_clear_d = 2.3;   // clearance hole in top half
screw_head_d  = 3.8;   // head diameter (preview only) PLACEHOLDER - measure
screw_head_h  = 1.6;   // head height   (preview only) PLACEHOLDER - measure
screw_len     = 12;
screw_depth   = 6.5;   // pilot hole depth into the bottom half

// Screw axis: midway between outer corner and pocket corner, on the diagonal
screw_off_outer  = case_r * (1 - 1 / sqrt(2));
screw_off_pocket = case_wall + pk_r * (1 - 1 / sqrt(2));
screw_off = (screw_off_outer + screw_off_pocket) / 2;
screw_pos = [for (x = [screw_off, case_w - screw_off],
                  y = [screw_off, case_d - screw_off]) [x, y]];

// Material left around the clearance hole (to pocket / to outside faces)
echo(screw_wall_to_pocket =
         norm([1, 1] * (case_wall + pk_r - screw_off)) - pk_r - screw_clear_d / 2);
echo(screw_wall_to_outside = screw_off - screw_clear_d / 2);

module screw_model() {
    color("DimGray") for (p = all_screw_pos) translate([p[0], p[1], 0]) {
        translate([0, 0, case_h]) difference() {
            cylinder(d = screw_head_d, h = screw_head_h);
            translate([0, 0, screw_head_h - 1]) cylinder(d = 1.73, h = 2, $fn = 6);  // 1.5 mm hex
        }
        translate([0, 0, case_h - screw_len]) cylinder(d = 2, h = screw_len);
    }
}

// --- Probe cutout (front wall, Y = 0) ---
probe_w       = 26.2;  // probe connector width  (X)
probe_h       = 7.3;   // probe connector height (Z)
probe_top_off = 1.0;   // device top to connector top PLACEHOLDER ("almost on top")
probe_clear   = 0.4;   // per side
probe_cut_r   = 1;     // corner radius of the opening

probe_cut_w = probe_w + 2 * probe_clear;
probe_cut_h = probe_h + 2 * probe_clear;
probe_cz    = dev_z0 + dev_h - probe_top_off - probe_h / 2;   // connector center Z

module probe_cutout() {
    translate([case_w / 2, case_wall + 1, probe_cz])
        rotate([90, 0, 0])
            translate([-probe_cut_w / 2, -probe_cut_h / 2, 0])
                rounded_box(probe_cut_w, probe_cut_h, case_wall + 2, probe_cut_r);
}

// --- Micro-USB 3.0 (Micro-B SuperSpeed) plug, back wall (Y = case_d) ---
// Port is centered on the back face of the device, horizontally and vertically.
// Metal shell: approx. per USB 3.0 Micro-B spec. Overmold: PLACEHOLDERS - measure your cable.
usb_usb2_w    = 6.85;  // metal: USB 2.0 part width
usb_usb3_w    = 4.9;   // metal: SuperSpeed part width
usb_gap       = 0.4;   // metal: gap between the two parts
usb_metal_h   = 1.8;   // metal: height
usb_chamfer   = 0.6;   // metal: bottom corner chamfer on USB 2.0 part
usb_metal_l   = 6.0;   // metal: insertion length (goes into device)
usb_flip      = false; // true = SuperSpeed part on the -X side

usb_mold_w    = 15.1;  // overmold width  (X), measured
usb_mold_h    = 7.54;  // overmold height (Z), measured
usb_mold_l    = 21;    // overmold length (Y) from device face, measured (excl. metal)
usb_mold_r    = 1.5;   // overmold corner radius (as seen from the end) PLACEHOLDER
usb_mold_end_r = 4;    // rounding of the cable-side end, horizontal and vertical, measured
                       // (vertical is capped at half the overmold height)
usb_mold_gap  = 0.2;   // gap between device face and overmold when fully inserted
usb_cable_d   = 7.6;   // strain relief diameter (7.54 measured, rounded up) - sets exit hole
usb_wire_d    = 6;     // cable diameter, measured (preview only)
usb_relief_l  = 10;    // strain relief length (preview only) PLACEHOLDER

usb_x = case_w / 2;
usb_z = bottom_h;                   // centered on device body (above the feet)
usb_y = dev_y0 + dev_d;             // device back face

usb_metal_w = usb_usb2_w + usb_gap + usb_usb3_w;

// Cross-section of the metal shell, centered on origin (X = width, Y = height)
module usb_metal_profile() {
    c = usb_chamfer;
    x2 = -usb_metal_w / 2;                       // USB 2.0 part left edge
    x3 = x2 + usb_usb2_w + usb_gap;              // SuperSpeed part left edge
    h = usb_metal_h / 2;
    mirror([usb_flip ? 1 : 0, 0, 0]) {
        polygon([[x2 + c, -h], [x2 + usb_usb2_w - c, -h], [x2 + usb_usb2_w, -h + c],
                 [x2 + usb_usb2_w, h], [x2, h], [x2, -h + c]]);
        translate([x3, -h]) square([usb_usb3_w, usb_metal_h]);
    }
}

// Overmold end profile, centered on origin
module usb_mold_profile() {
    offset(r = usb_mold_r) offset(delta = -usb_mold_r)
        square([usb_mold_w, usb_mold_h], center = true);
}

// Overmold solid along +Z from z0 to z1, grown by c per side, cable-side end
// rounded with radius usb_mold_end_r (+ c) horizontally and along the length,
// and vertically capped at half the overmold height
module usb_mold_solid(c, z0, z1) {
    rh = min(usb_mold_end_r, usb_mold_w / 2 - 0.01) + c;   // X
    rv = min(usb_mold_end_r, usb_mold_h / 2 - 0.01) + c;   // Y (height)
    rl = usb_mold_end_r + c;                               // along the plug
    hull() {
        translate([0, 0, z0]) linear_extrude(z1 - z0 - rl)
            offset(delta = c) usb_mold_profile();
        translate([0, 0, z1 - rl]) minkowski() {
            linear_extrude(0.01)
                square([usb_mold_w + 2 * c - 2 * rh, usb_mold_h + 2 * c - 2 * rv], center = true);
            scale([rh, rv, rl]) sphere(r = 1, $fn = 32);
        }
    }
}

// Plug in local coords: origin at device face, +Y points away from device
module usb_plug_local() {
    // metal (inside the device)
    color("Silver") rotate([90, 0, 0])
        linear_extrude(usb_metal_l) usb_metal_profile();
    // overmold
    color("DimGray") rotate([-90, 0, 0])
        usb_mold_solid(0, usb_mold_gap, usb_mold_gap + usb_mold_l);
    // strain relief + cable stub
    color("Black") translate([0, usb_mold_gap + usb_mold_l, 0]) rotate([-90, 0, 0]) {
        cylinder(d1 = usb_cable_d, d2 = usb_wire_d, h = usb_relief_l);
        cylinder(d = usb_wire_d, h = usb_relief_l + 15);
    }
}

// --- USB shroud: encloses the plug overmold, cable exits through a smaller hole ---
// The split plane runs through the plug center, so each half holds half the plug.
// Shroud is full case height so its screws match the corner screws (M2x12).
usb_clear        = 0.3;   // clearance per side around the overmold (X/Z)
usb_clear_len    = 0.1;   // extra pocket length behind the overmold - keep ~0, set
                          // negative for a slight crush fit; play here = plug can back out
usb_shroud_wall  = 1.5;   // material between overmold pocket and shroud screw hole
usb_shroud_side  = 1.5;   // material between shroud screw hole and outside
usb_shroud_end   = 3;     // end wall thickness (the part that stops the plug)
usb_shroud_r     = 2;     // shroud vertical corner radius
usb_cable_clear  = 0.1;   // clearance per side around the strain relief
usb_flare_r      = 1.5;   // rounded bell-mouth at the cable exit (bend relief)
usb_screw_inset  = 3;     // shroud screws: distance from overmold back end, towards device

usb_mold_end   = usb_y + usb_mold_gap + usb_mold_l;   // Y of overmold back end
usb_pocket_end = usb_mold_end + usb_clear_len;
usb_shroud_y1  = usb_pocket_end + usb_shroud_end;     // outer end face of shroud

usb_screw_dx = usb_mold_w / 2 + usb_clear + usb_shroud_wall + screw_clear_d / 2;
usb_shroud_w = 2 * (usb_screw_dx + screw_clear_d / 2 + usb_shroud_side);
usb_screw_pos = [for (sx = [-1, 1]) [usb_x + sx * usb_screw_dx, usb_mold_end - usb_screw_inset]];

all_screw_pos = concat(screw_pos, usb_screw_pos);

// 2D profile helper, extruded along +Y from y0 to y1 at plug center
module usb_extrude(y0, y1) {
    translate([usb_x, y0, usb_z]) rotate([-90, 0, 0])
        linear_extrude(y1 - y0) rotate(180) children();
}

module usb_shroud_outer() {
    y0 = case_d - case_wall;
    translate([usb_x - usb_shroud_w / 2, y0, 0])
        rounded_box(usb_shroud_w, usb_shroud_y1 - y0, case_h, usb_shroud_r);
}

module usb_cavity() {
    rc = usb_cable_d / 2 + usb_cable_clear;
    // overmold pocket, from inside the case to the back of the overmold
    translate([usb_x, 0, usb_z]) rotate([-90, 0, 0])
        usb_mold_solid(usb_clear, usb_y - 1, usb_pocket_end);
    // cable exit
    usb_extrude(usb_pocket_end - 1, usb_shroud_y1 + 1)
        circle(r = rc);
    // rounded bell-mouth on the outer face
    translate([usb_x, usb_shroud_y1 - usb_flare_r, usb_z]) rotate([-90, 0, 0])
        rotate_extrude()
            difference() {
                square([rc + usb_flare_r, usb_flare_r + 0.01]);
                translate([rc + usb_flare_r, 0]) circle(r = usb_flare_r);
            }
}

module usb_plug() {
    translate([usb_x, usb_y, usb_z]) usb_plug_local();
}

// --- LED window (roof, probe side, right-hand when viewed from the probe side) ---
// Offsets are measured on the device from its front-right corner.
led_off_x = 12;   // from device right edge (+X side)
led_off_y = 12;   // from device front edge (probe side)
led_d     = 3;    // hole diameter

led_x = dev_x0 + dev_w - led_off_x;
led_y = dev_y0 + led_off_y;

module led_hole() {
    translate([led_x, led_y, case_floor + pk_h - 1])
        cylinder(d = led_d, h = case_roof + 2);
}

// --- Logo windows (roof and floor, centered) ---
logo_size     = 32;   // bottom window: 30 mm logo + 1 mm margin each side
logo_size_top = 36;   // top window, enlarged so the LED shows through it
logo_r    = 3;    // corner radius
logo_dx   = 0;    // shift from roof center (+X = right, seen from probe side)
logo_dy   = 0;    // shift from roof center (+Y = towards USB)

// Through-cut starting at z0, thickness t (roof or floor)
module logo_window(z0, t, size) {
    translate([case_w / 2 + logo_dx - size / 2,
               case_d / 2 + logo_dy - size / 2,
               z0 - 1])
        rounded_box(size, size, t + 2, logo_r);
}

module shell() {
    difference() {
        union() {
            rounded_box(case_w, case_d, case_h, case_r);
            usb_shroud_outer();
        }
        translate([case_wall, case_wall, case_floor]) pocket();
        probe_cutout();
        usb_cavity();
    }
}

module case_bottom() {
    difference() {
        intersection() {
            shell();
            translate([-1, -1, -1]) cube([case_w + 2, case_d + 100, bottom_h + 1]);
        }
        for (p = all_screw_pos)
            translate([p[0], p[1], bottom_h - screw_depth])
                cylinder(d = screw_pilot_d, h = screw_depth + 1);
        logo_window(0, case_floor, logo_size);
    }
}

// Top half, in assembled position
module case_top() {
    difference() {
        intersection() {
            shell();
            translate([-1, -1, bottom_h]) cube([case_w + 2, case_d + 100, top_h + 1]);
        }
        for (p = all_screw_pos)
            translate([p[0], p[1], bottom_h - 1])
                cylinder(d = screw_clear_d, h = top_h + 2);
        led_hole();
        logo_window(case_floor + pk_h, case_roof, logo_size_top);
    }
}

if (part == "assembly") {
    case_bottom();
    color("SteelBlue", 0.6) case_top();
    usb_plug();
    screw_model();
    // %translate([dev_x0, dev_y0, dev_z0]) device();  // ghost fit check
} else if (part == "bottom") {
    case_bottom();
} else if (part == "top") {
    case_top();
} else if (part == "top_print") {
    // roof on the bed
    translate([0, 0, case_h]) rotate([0, 180, 0]) translate([-case_w, 0, 0]) case_top();
} else if (part == "plug") {
    usb_plug_local();
} else if (part == "print") {
    case_bottom();
    // flip top upside down so the roof lies on the bed
    translate([2 * case_w + 10, 0, case_h]) rotate([0, 180, 0]) case_top();
}
