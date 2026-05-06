// =============================================================================
// pizero-retro — Top Shell
// =============================================================================
// Pure parametric OpenSCAD — no STL dependency.
//
// Printing orientation : face DOWN  (Z = 0 is the outer face / screen side).
//                        Parting face at Z = top_depth, open toward bottom shell.
//
// Coordinate system (X, Y across the case outer footprint):
//   X :   0 → 146 mm   (case width,  left → right)
//   Y :   0 →  64 mm   (case height, bottom edge → top edge)
//   Z :   0 →   8 mm   (shell depth, outer face → parting face)
//
// Screen window (rectangular cutout through the 2 mm face plate):
//   X :  43 → 103 mm   (60 mm wide, centred on the 142 mm PCB)
//   Y : 19.6 →  62 mm  (42.4 mm tall, top edge flush with inner top wall)
//
// Button holes (⌀ 6.8 mm, through face plate at Z = 0):
//   D-pad Up    : X = 19.4   Y = 36.8
//   D-pad Down  : X = 19.4   Y = 17.8
//   D-pad Left  : X = 12.1   Y = 27.3
//   D-pad Right : X = 26.7   Y = 27.3
//   Select      : X = 23.6   Y = 52.1
//   B           : X = 134.2  Y = 27.4
//   A           : X = 118.7  Y = 27.4
//   Start       : X = 124.2  Y = 52.1
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
wall      = 2;                          // face plate & side wall thickness (mm)
corner_r  = 3;                          // outer corner radius (mm)
inner_r   = max(0, corner_r - wall);    // inner corner radius → 1 mm

case_w    = pcb_w + 2 * wall;           // 146 mm
case_h    = pcb_h + 2 * wall;           // 64 mm
top_depth = 8;                          // total top shell depth (mm)

// ── Screen window ─────────────────────────────────────────────────────────────
screen_w = 60;
screen_h = 42.4;

// centred in X; top edge flush with inner top wall
screen_x = wall + (pcb_w - screen_w) / 2;   // 43 mm from case left
screen_y = (case_h - wall) - screen_h;       // 19.6 mm from case bottom

// ── Button hole diameter ──────────────────────────────────────────────────────
btn_d = 6.8;

// ── Button positions  [X, Y] in case outer coordinates ───────────────────────
//
// D-pad cluster centre: 17.4 mm from PCB left, 25.3 mm from PCB bottom
dpad_cx = wall + 17.4;   // 19.4 mm from case left
dpad_cy = wall + 25.3;   // 27.3 mm from case bottom

dpad_v = 9.5;   // up / down spacing from cluster centre
dpad_h = 7.3;   // left / right spacing from cluster centre

btn_up    = [dpad_cx,            dpad_cy + dpad_v];  // [19.4, 36.8]
btn_down  = [dpad_cx,            dpad_cy - dpad_v];  // [19.4, 17.8]
btn_left  = [dpad_cx - dpad_h,   dpad_cy];           // [12.1, 27.3]
btn_right = [dpad_cx + dpad_h,   dpad_cy];           // [26.7, 27.3]

// Select: 9.9 mm from PCB top, 21.6 mm from PCB left
btn_select = [wall + 21.6,
              (case_h - wall) - 9.9];                // [23.6, 52.1]

// B: 9.8 mm from PCB right, 25.4 mm from PCB bottom
btn_b      = [(case_w - wall) - 9.8,
              wall + 25.4];                          // [134.2, 27.4]

// A: 15.5 mm to the left of B, same Y
btn_a      = [btn_b[0] - 15.5,
              btn_b[1]];                             // [118.7, 27.4]

// Start: 9.9 mm from PCB top, 19.8 mm from PCB right
btn_start  = [(case_w - wall) - 19.8,
              (case_h - wall) - 9.9];               // [124.2, 52.1]

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

// Single button hole through the face plate
module button_hole(pos) {
    translate([pos[0], pos[1], -eps])
        cylinder(h = wall + 2 * eps, d = btn_d);
}

// ── Main model ────────────────────────────────────────────────────────────────

difference() {

    // 1. Outer shell
    rounded_box(case_w, case_h, top_depth, corner_r);

    // 2. Inner cavity — floor at Z = wall, open at parting face (Z = top_depth)
    translate([wall, wall, wall])
        rounded_box(case_w - 2 * wall,
                    case_h - 2 * wall,
                    top_depth - wall + eps,
                    inner_r);

    // 3. Screen window — cut through face plate
    translate([screen_x, screen_y, -eps])
        cube([screen_w, screen_h, wall + 2 * eps]);

    // 4. Button holes — cut through face plate
    button_hole(btn_up);
    button_hole(btn_down);
    button_hole(btn_left);
    button_hole(btn_right);
    button_hole(btn_select);
    button_hole(btn_b);
    button_hole(btn_a);
    button_hole(btn_start);
}
