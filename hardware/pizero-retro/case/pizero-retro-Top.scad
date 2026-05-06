// =============================================================================
// pizero-retro — Top Shell
// =============================================================================
// Pure parametric OpenSCAD — no STL dependency.
//
// Printing orientation : face DOWN  (Z = 0 is the outer face / screen side).
//                        Parting face at Z = top_depth, open toward bottom shell.
//
// Coordinate system (X, Y across the case outer footprint):
//   X :   0 → 152 mm   (case width,  left → right)
//   Y :   0 →  70 mm   (case height, bottom edge → top edge)
//   Z :   0 →   8 mm   (shell depth, outer face → parting face)
//
// The face plate grows 3 mm beyond the PCB edge on all four sides (expand = 3).
// All interior geometry (cavity, screen, buttons) is offset by [expand, expand]
// so that PCB-relative positions are preserved.
//
// Screen window (rectangular cutout through the 2 mm face plate):
//   X :  43 → 103 mm   (60 mm wide, shifted 3 mm left of PCB centre)
//   Y : 22.6 →  65 mm  (42.4 mm tall, top edge flush with inner top wall)
//
// Button holes (⌀ 6.8 mm, through face plate at Z = 0)
// Buttons are mirrored: D-pad on the RIGHT, A/B/Start on the LEFT.
//
//   D-pad Up    : X = 129.6   Y = 39.8
//   D-pad Down  : X = 129.6   Y = 20.8
//   D-pad Left  : X = 122.3   Y = 30.3
//   D-pad Right : X = 136.9   Y = 30.3
//   Select      : X = 127.2   Y = 55.1
//   B           : X =  14.8   Y = 30.4
//   A           : X =  30.3   Y = 30.4
//   Start       : X =  26.6   Y = 55.1
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
expand    = 3;                          // extra face material beyond PCB on each side
corner_r  = 3;                          // outer corner radius (mm)
inner_r   = max(0, corner_r - wall);    // inner corner radius → 1 mm

case_w    = pcb_w + 2 * wall + 2 * expand;   // 152 mm
case_h    = pcb_h + 2 * wall + 2 * expand;   // 70 mm
top_depth = 8;                               // total top shell depth (mm)

// ── Screen window ─────────────────────────────────────────────────────────────
screen_w = 60;
screen_h = 42.4;

// centred in X over the PCB; top edge flush with inner top wall
// positions are PCB-relative (wall offset), expand is applied in main model
screen_x = wall + (pcb_w - screen_w) / 2 - 3;   // 40 mm from PCB left edge (shifted 3 mm left)
screen_y = (pcb_h + wall) - screen_h;       // 19.6 mm from PCB bottom edge

// ── Button hole diameter ──────────────────────────────────────────────────────
btn_d = 6.8;

// ── Button positions  [X, Y] in PCB-relative coordinates ─────────────────────
// (expand offset applied in main model via translate)
//
// D-pad cluster — mirrored to RIGHT side
// Centre: 17.4 mm from PCB right, 25.3 mm from PCB bottom
dpad_cx = (pcb_w + wall) - 17.4;   // 126.6 mm from PCB left edge
dpad_cy = wall + 25.3;              // 27.3 mm from case bottom (PCB-relative)

dpad_v = 9.5;   // up / down spacing from cluster centre
dpad_h = 7.3;   // left / right spacing from cluster centre

btn_up    = [dpad_cx,            dpad_cy + dpad_v];  // [126.6, 36.8]
btn_down  = [dpad_cx,            dpad_cy - dpad_v];  // [126.6, 17.8]
btn_left  = [dpad_cx - dpad_h,   dpad_cy];           // [119.3, 27.3]
btn_right = [dpad_cx + dpad_h,   dpad_cy];           // [133.9, 27.3]

// Select — mirrored to RIGHT side: 9.9 mm from PCB top, 19.8 mm from PCB right
btn_select = [(pcb_w + wall) - 19.8,
              (pcb_h + wall) - 9.9];                 // [129.2, 52.1] PCB-rel

// B — mirrored to LEFT side: was 15.5 mm left of old B → now 9.8 mm from PCB left
btn_b      = [wall + 9.8,
              wall + 25.4];                          // [11.8, 27.4] PCB-rel

// A — mirrored to LEFT side: was old B position → now 25.3 mm from PCB left
btn_a      = [btn_b[0] + 15.5,
              btn_b[1]];                             // [27.3, 27.4] PCB-rel

// Start — mirrored to LEFT side: 9.9 mm from PCB top, 21.6 mm from PCB left
btn_start  = [wall + 21.6,
              (pcb_h + wall) - 9.9];                // [23.6, 52.1] PCB-rel

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

    // 1. Outer shell — expanded footprint
    rounded_box(case_w, case_h, top_depth, corner_r);

    // 2. Inner cavity — side walls are exactly `wall` (2 mm) thick around the
    //    full expanded footprint. The face plate (Z = 0 → wall) covers the full
    //    152 × 70 mm, so the 3 mm `expand` overhang exists only on the face.
    translate([wall, wall, wall])
        rounded_box(case_w - 2 * wall,
                    case_h - 2 * wall,
                    top_depth - wall + eps,
                    inner_r);

    // All face cutouts are offset by [expand, expand] so that PCB-relative
    // positions are preserved on the expanded face plate.
    translate([expand, expand, 0]) {

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
}
