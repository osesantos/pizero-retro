// =============================================================================
// pizero-retro — Bottom Shell
// =============================================================================
// Pure parametric OpenSCAD — no STL dependency.
//
// Printing orientation : back face DOWN  (Z = 0 is the outer back face).
//                        Parting face at Z = bottom_depth, open toward top shell.
//
// Coordinate system (X, Y across the case outer footprint):
//   X :   0 → 152 mm   (case width,  left → right)
//   Y :   0 →  70 mm   (case height, bottom edge → top edge)
//   Z :   0 →  12 mm   (shell depth, outer back face → parting face)
//
// The back face grows 3 mm beyond the PCB edge on all four sides (expand = 3),
// matching the Top shell. Side walls remain 2 mm thick around the full
// expanded footprint; the 3 mm overhang exists only on the back face.
//
// USB port cutout (24 mm wide × 6 mm tall) in the bottom edge wall (Y = 0):
//   X :  45 →  69 mm   (shifted 4 mm left of original PCB-relative position)
//   Z :   4 →  10 mm   (adjust usb_z_start / usb_z_height if needed)
//
// No screw holes — drill to suit after printing.
// =============================================================================

// ── Smoothness ────────────────────────────────────────────────────────────────
$fn = 64;

// ── Tolerance ─────────────────────────────────────────────────────────────────
eps = 0.1;   // small overlap to avoid coincident-face artefacts

// ── PCB dimensions ────────────────────────────────────────────────────────────
pcb_w = 142;   // mm wide
pcb_h = 60;    // mm tall

// ── Case geometry ─────────────────────────────────────────────────────────────
wall         = 2;                          // back face & side wall thickness (mm)
expand       = 3;                          // extra back-face material beyond PCB on each side
corner_r     = 3;                          // outer corner radius (mm)
inner_r      = max(0, corner_r - wall);    // inner corner radius → 1 mm

case_w       = pcb_w + 2 * wall + 2 * expand;   // 152 mm
case_h       = pcb_h + 2 * wall + 2 * expand;   // 70 mm
bottom_depth = 12;                              // total bottom shell depth (mm)

// ── USB port cutout parameters ────────────────────────────────────────────────
// Rectangular slot through the bottom edge wall (Y = 0 → Y = wall).
// Adjust usb_z_start and usb_z_height to align with your Pi Zero USB ports.
//
// PCB-relative X (expand offset applied in main model). Originally 46 mm in the
// old un-expanded outer coordinate system; shifted 4 mm left → 42 mm PCB-rel
// → outer X = 45 mm after the [expand, …] translate.

usb_x_start  = 42;   // mm from PCB left (outer X = 45 after expand)
usb_w        = 24;   // mm wide  (spans both Pi Zero USB ports)
usb_z_start  = 4;    // mm above the outer back face floor
usb_z_height = 6;    // mm tall  (6 mm suits standard micro-USB connectors)

// ── Helpers ───────────────────────────────────────────────────────────────────

// Solid rounded-rectangle prism
module rounded_box(w, h, d, r) {
    linear_extrude(d)
        hull() {
            translate([r, r])         circle(r = r);
            translate([w - r, r])     circle(r = r);
            translate([r, h - r])     circle(r = r);
            translate([w - r, h - r]) circle(r = r);
        }
}

// ── Main model ────────────────────────────────────────────────────────────────

difference() {

    // 1. Outer shell — expanded footprint (matches Top)
    rounded_box(case_w, case_h, bottom_depth, corner_r);

    // 2. Inner cavity — side walls are exactly `wall` (2 mm) thick around the
    //    full expanded footprint. The back face (Z = 0 → wall) covers the full
    //    152 × 70 mm, so the 3 mm `expand` overhang exists only on the back face.
    translate([wall, wall, wall])
        rounded_box(case_w - 2 * wall,
                    case_h - 2 * wall,
                    bottom_depth - wall + eps,
                    inner_r);

    // 3. USB port cutout — slot through the bottom edge wall (Y = 0).
    //    Wrapped in [expand, expand, 0] so X is PCB-relative; Y still cuts
    //    through the outer wall starting at Y = 0.
    translate([expand + usb_x_start, -eps, usb_z_start])
        cube([usb_w, wall + 2 * eps, usb_z_height]);
}
