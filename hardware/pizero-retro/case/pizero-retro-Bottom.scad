// =============================================================================
// pizero-retro — Bottom Shell
// =============================================================================
// Pure parametric OpenSCAD — no STL dependency.
//
// Printing orientation : back face DOWN  (Z = 0 is the outer back face).
//                        Parting face at Z = bottom_depth, open toward top shell.
//
// Coordinate system (X, Y across the case outer footprint):
//   X :   0 → 146 mm   (case width,  left → right)
//   Y :   0 →  64 mm   (case height, bottom edge → top edge)
//   Z :   0 →  12 mm   (shell depth, outer back face → parting face)
//
// USB port cutout (24 mm wide × 6 mm tall) in the bottom edge wall (Y = 0):
//   X :  46 →  70 mm   (starts 46 mm from the left outer edge)
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
corner_r     = 3;                          // outer corner radius (mm)
inner_r      = max(0, corner_r - wall);    // inner corner radius → 1 mm

case_w       = pcb_w + 2 * wall;           // 146 mm
case_h       = pcb_h + 2 * wall;           // 64 mm
bottom_depth = 12;                         // total bottom shell depth (mm)

// ── USB port cutout parameters ────────────────────────────────────────────────
// Rectangular slot through the bottom edge wall (Y = 0 → Y = wall).
// Adjust usb_z_start and usb_z_height to align with your Pi Zero USB ports.

usb_x_start  = 46;   // mm from case left outer edge
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

    // 1. Outer shell
    rounded_box(case_w, case_h, bottom_depth, corner_r);

    // 2. Inner cavity — floor at Z = wall, open at parting face (Z = bottom_depth)
    translate([wall, wall, wall])
        rounded_box(case_w - 2 * wall,
                    case_h - 2 * wall,
                    bottom_depth - wall + eps,
                    inner_r);

    // 3. USB port cutout — slot through the bottom edge wall (Y = 0)
    translate([usb_x_start, -eps, usb_z_start])
        cube([usb_w, wall + 2 * eps, usb_z_height]);
}
