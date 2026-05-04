// =============================================================================
// Anemoia-PiZero — Bottom Shell
// =============================================================================
// Modifies the original Anemoia-ESP32 module-based bottom shell for use with
// a Raspberry Pi Zero instead of an ESP32-DevKit.
//
// Changes from the original:
//   REMOVED  — TP4056 USB charging port slot (left wall)   → filled
//   REMOVED  — SS12F17 power switch slot (right wall)      → filled
//   REMOVED  — Sound holes in bottom face                  → filled / never cut
//   ADDED    — mini-HDMI slot on top edge (Z≈0 wall)
//   ADDED    — Micro-USB PWR slot on top edge (Z≈0 wall)
//   ADDED    — Micro-USB OTG slot on top edge (Z≈0 wall)
//   ADDED    — Micro-SD card slot on right edge (X-max wall)
//   ADDED    — 4× M2.5 standoff posts with pilot holes (one per Pi Zero corner)
//
// Coordinate system (inherited from original STL):
//   X :    0 → 174.2 mm   case width  (landscape orientation)
//   Y :    0 →  15.4 mm   case depth  (bottom half thickness;
//                                       Y=0 = outer front face,
//                                       Y=15.4 = inner surface / open top)
//   Z : -57.1 →   2.6 mm  case height (Z=0 ≈ parting seam = TOP edge of case
//                                       when held normally with screen facing you;
//                                       Z=-57 = bottom edge)
//
// Pi Zero placement — top-right corner, processor facing up:
//   Pi Zero PCB:  65mm wide × 30mm tall
//   Pi left  edge : X = 104.2 mm  (= 174.2 - 5mm margin - 65mm)
//   Pi right edge : X = 169.2 mm  (= 174.2 - 5mm margin)
//   Pi top   edge : Z =  -5.0 mm  (= 0 - 5mm margin from top wall)
//   Pi bottom edge: Z = -35.0 mm  (= -5 - 30mm)
//
//   Port edge (mini-HDMI + 2× micro-USB) faces the TOP wall  (Z≈0)
//   SD card slot faces the RIGHT wall (X≈174mm)
//   Processor (SoC) faces UP (toward open/inner side, Y-max direction)
//
// Dependencies:
//   Requires the original STL at the relative path below.
//   Render and export as Anemoia-PiZero-Bottom.stl for slicing.
// =============================================================================

// ── Path to the original bottom shell STL ────────────────────────────────────
original_stl = "../../../3d-model/Anemoia-ESP32/Anemoia-ESP32-Bottom.stl";

// =============================================================================
// Parameters
// =============================================================================

// ── Tolerances ────────────────────────────────────────────────────────────────
tol = 0.3;   // general print tolerance added to cutout dimensions (mm)
eps = 0.1;   // small epsilon to avoid z-fighting in previews

// ── Case bounds (from original STL) ──────────────────────────────────────────
case_x_max = 174.2;
case_z_top =   2.6;   // Z of outer top-edge wall face
case_z_bot = -57.1;   // Z of outer bottom-edge wall face

// ── Pi Zero PCB dimensions & placement ───────────────────────────────────────
pi_pcb_w      = 65.0;    // Pi Zero PCB width  (along X)
pi_pcb_h      = 30.0;    // Pi Zero PCB height (along Z)
pi_margin_top = 5.0;     // gap between Pi port edge and top wall (inner)
pi_margin_right = 5.0;   // gap between Pi right edge and right wall (inner)

pi_x0 = case_x_max - pi_margin_right - pi_pcb_w;  // = 104.2 mm (Pi left  edge)
pi_x1 = case_x_max - pi_margin_right;              // = 169.2 mm (Pi right edge)
pi_z1 = -pi_margin_top;                            // =  -5.0 mm (Pi top   edge, port side)
pi_z0 = pi_z1 - pi_pcb_h;                         // = -35.0 mm (Pi bottom edge)

// ── Pi Zero mounting hole positions (M2.5, 3.5mm from each corner) ────────────
// Pi Zero holes are at (3.5, 3.5) from each corner of the PCB.
// In case coords (Pi left=pi_x0, Pi top=pi_z1):
//   top-left:     X = pi_x0 + 3.5,  Z = pi_z1 - 3.5
//   top-right:    X = pi_x1 - 3.5,  Z = pi_z1 - 3.5
//   bottom-left:  X = pi_x0 + 3.5,  Z = pi_z0 + 3.5
//   bottom-right: X = pi_x1 - 3.5,  Z = pi_z0 + 3.5
standoff_hole_inset = 3.5;   // Pi Zero mounting hole inset from PCB corner (mm)

so_tl_x = pi_x0 + standoff_hole_inset;   // top-left     standoff X
so_tr_x = pi_x1 - standoff_hole_inset;   // top-right    standoff X
so_tl_z = pi_z1 - standoff_hole_inset;   // top standoffs Z
so_bl_z = pi_z0 + standoff_hole_inset;   // bottom standoffs Z

// ── Standoff post geometry ────────────────────────────────────────────────────
standoff_post_h  = 3.0;   // post height above inner floor (mm) — lifts PCB off floor
standoff_post_od = 5.5;   // outer diameter of post (mm) — ~1.4mm wall around M2.5 hole
standoff_pilot_d = 2.7;   // M2.5 pilot hole diameter (mm)

// Posts sit on the inner floor. Inner floor Y position ≈ 1.5mm (floor thickness).
// Pilot holes cut downward into the post top, depth = post height + floor = through post.
standoff_floor_y = 1.5;   // Y coordinate of inner floor surface (approximate)

// ── TOP-edge port slots (Z≈0 wall, cut along Z-axis) ─────────────────────────
// Port positions are measured from the Pi Zero LEFT edge (pi_x0) along X.
// Pi Zero datasheet port centres from left edge of PCB:
//   mini-HDMI centre:    ~12.4 mm
//   micro-USB PWR centre: ~37.0 mm  (labelled "PWR IN")
//   micro-USB OTG centre: ~54.0 mm  (labelled "USB")
//
// Port slot dimensions (physical connector + tol):
//   mini-HDMI:   11.4mm wide × 4.0mm tall
//   micro-USB:    8.0mm wide × 3.5mm tall

hdmi_cx = pi_x0 + 12.4;   // mini-HDMI centre X in case coords
usb_pwr_cx = pi_x0 + 37.0; // USB PWR centre X
usb_otg_cx = pi_x0 + 54.0; // USB OTG centre X

hdmi_slot_w  = 11.4 + tol * 2;
hdmi_slot_h  =  4.0 + tol * 2;
usb_slot_w   =  8.0 + tol * 2;
usb_slot_h   =  3.5 + tol * 2;
top_slot_d   =  4.0;   // cut depth into/through the top wall (wall ≈ 2mm, 4mm clears it)

// Y centre of port slots: mid-depth of the bottom shell
top_slot_y_centre = 7.7;   // ≈ 15.4 / 2

// Z position: slots cut downward from the top wall face.
// The top wall outer face is at Z ≈ +2.6mm; we cut from above (Z=+eps) downward.
// Port connector body sits just inside the wall, so Z centre is at:
//   Pi top edge (Z=-5) + half of connector height protrusion above PCB ≈ Z ≈ -3mm
// We cut a generous slot from Z=+eps down through the wall to Z = -(top_slot_d).
// Slot Z range: Z = case_z_top + eps  →  Z = case_z_top - top_slot_d  (downward)

// ── RIGHT-edge SD card slot (X≈174mm wall, cut along X-axis) ─────────────────
// Pi Zero micro-SD card slot is on the underside of the PCB, opening at the
// long edge opposite the port edge. With the Pi oriented as above:
//   SD card faces the RIGHT wall (X-max).
// SD card slot centre Z from Pi top edge: ~20mm down from Pi top edge
//   → Z = pi_z1 - 20 = -5 - 20 = -25mm
// SD card slot dimensions:
//   12.0mm wide (along Z) × 1.5mm tall (along Y)
sd_slot_w     = 12.0 + tol * 2;   // slot width along Z
sd_slot_h     =  1.5 + tol * 2;   // slot height along Y (card thickness)
sd_slot_d     =  4.0;              // cut depth into right wall
sd_slot_z_ctr = pi_z1 - 20.0;     // Z centre of SD slot = -25mm
sd_slot_y_ctr = top_slot_y_centre; // same Y centre as other slots

// ── Plug block dimensions (filling old cutouts from original STL) ─────────────
// Old TP4056 USB slot: left wall (X≈0), Z = -24 to -32mm
plug_usb_z0  = -33;    plug_usb_z1  = -23;
plug_usb_y0  =  0;     plug_usb_y1  =  15.5;
plug_usb_x0  = -4;     plug_usb_x1  =   2;

// Old power switch slot: right wall (X≈170), Z = -30 to -40mm
plug_sw_z0   = -42;    plug_sw_z1   = -28;
plug_sw_y0   =  1.5;   plug_sw_y1   =   9;
plug_sw_x0   = 168;    plug_sw_x1   = 175;

// ── Facing wall (Y=0 outer face) — shave and replace ─────────────────────────
// The original ESP32 STL has a speaker circle with small holes on the outer
// facing wall (Y=0 face). We cannot fill over it because the geometry is on
// the outer skin itself. Instead we:
//   1. CUT (difference): shave off the entire outer skin to a depth of
//      facing_skin_depth, removing the speaker circle completely.
//   2. ADD (union): put back a clean flat slab of the same thickness.
// The outer wall face is at Y=0.4mm, inner solid wall at Y=2.0mm.
// The speaker circle emboss protrudes inward from Y=2.0 up to Y≈3.6mm.
// We shave to Y=3.6 (past all circle geometry) and replace with a solid slab.
facing_skin_depth = 3.6;   // shave depth: past the speaker circle emboss (Y=0 → 3.6)
facing_wall_x0    = -eps;
facing_wall_x1    = case_x_max + eps;
facing_wall_z0    = case_z_bot - eps;
facing_wall_z1    = case_z_top + eps;

// =============================================================================
// Main model
// =============================================================================

difference() {
    union() {
        // ── Base: original bottom shell ───────────────────────────────────────
        import(original_stl, convexity = 10);

        // ── Fill old TP4056 USB charging port hole (left wall) ────────────────
        translate([plug_usb_x0, plug_usb_y0, plug_usb_z0])
            cube([plug_usb_x1 - plug_usb_x0,
                  plug_usb_y1 - plug_usb_y0,
                  plug_usb_z1 - plug_usb_z0]);

        // ── Fill old power switch slot (right wall) ───────────────────────────
        translate([plug_sw_x0, plug_sw_y0, plug_sw_z0])
            cube([plug_sw_x1 - plug_sw_x0,
                  plug_sw_y1 - plug_sw_y0,
                  plug_sw_z1 - plug_sw_z0]);

        // ── Restore flat facing wall (added back after shaving, see difference below) ──
        translate([facing_wall_x0, 0, facing_wall_z0])
            cube([facing_wall_x1 - facing_wall_x0,
                  facing_skin_depth,
                  facing_wall_z1 - facing_wall_z0]);

        // ── Standoff posts — all 4 Pi Zero mounting corners ──────────────────
        // Posts are cylinders rising from the inner floor toward Y-max (open side).
        // Orientation: cylinder axis along Y.
        // translate to (X, floor_Y, Z) then extrude upward in Y.

        // Top-left standoff
        translate([so_tl_x, standoff_floor_y, so_tl_z])
            rotate([90, 0, 0])
                cylinder(h = standoff_post_h, d = standoff_post_od,
                         center = false, $fn = 32);

        // Top-right standoff
        translate([so_tr_x, standoff_floor_y, so_tl_z])
            rotate([90, 0, 0])
                cylinder(h = standoff_post_h, d = standoff_post_od,
                         center = false, $fn = 32);

        // Bottom-left standoff
        translate([so_tl_x, standoff_floor_y, so_bl_z])
            rotate([90, 0, 0])
                cylinder(h = standoff_post_h, d = standoff_post_od,
                         center = false, $fn = 32);

        // Bottom-right standoff
        translate([so_tr_x, standoff_floor_y, so_bl_z])
            rotate([90, 0, 0])
                cylinder(h = standoff_post_h, d = standoff_post_od,
                         center = false, $fn = 32);
    }

    // =========================================================================
    // Cutouts
    // =========================================================================

    // ── Shave outer facing wall (Y=0 face) to remove speaker circle ─────────
    // Removes the entire outer skin including all ESP32 speaker holes/embossing.
    // The clean flat slab added in union() replaces it.
    translate([facing_wall_x0, -eps, facing_wall_z0])
        cube([facing_wall_x1 - facing_wall_x0,
              facing_skin_depth + eps,
              facing_wall_z1 - facing_wall_z0]);

    // ── mini-HDMI slot — top edge wall (Z≈0) ─────────────────────────────────
    // Slot cuts through the top wall from outside (Z=+eps) downward (Z direction).
    translate([hdmi_cx - hdmi_slot_w / 2,
               top_slot_y_centre - hdmi_slot_h / 2,
               case_z_top - top_slot_d])
        cube([hdmi_slot_w,
              hdmi_slot_h,
              top_slot_d + eps]);

    // ── micro-USB PWR slot — top edge wall ───────────────────────────────────
    translate([usb_pwr_cx - usb_slot_w / 2,
               top_slot_y_centre - usb_slot_h / 2,
               case_z_top - top_slot_d])
        cube([usb_slot_w,
              usb_slot_h,
              top_slot_d + eps]);

    // ── micro-USB OTG slot — top edge wall ───────────────────────────────────
    translate([usb_otg_cx - usb_slot_w / 2,
               top_slot_y_centre - usb_slot_h / 2,
               case_z_top - top_slot_d])
        cube([usb_slot_w,
              usb_slot_h,
              top_slot_d + eps]);

    // ── micro-SD card slot — right edge wall (X≈174mm) ───────────────────────
    // Slot cuts through the right wall from outside (X = case_x_max + eps) inward.
    translate([case_x_max - sd_slot_d,
               sd_slot_y_ctr - sd_slot_h / 2,
               sd_slot_z_ctr - sd_slot_w / 2])
        cube([sd_slot_d + eps,
              sd_slot_h,
              sd_slot_w]);

    // ── Standoff pilot holes — M2.5 through each post ────────────────────────
    // Holes drilled from the open top (Y-max direction) down through each post.
    // translate to post centre (X, Y = open top + eps, Z) and drill downward.

    // Top-left pilot hole
    translate([so_tl_x,
               standoff_floor_y + standoff_post_h + eps,
               so_tl_z])
        rotate([90, 0, 0])
            cylinder(h = standoff_post_h + standoff_floor_y + eps * 2,
                     d = standoff_pilot_d, $fn = 16);

    // Top-right pilot hole
    translate([so_tr_x,
               standoff_floor_y + standoff_post_h + eps,
               so_tl_z])
        rotate([90, 0, 0])
            cylinder(h = standoff_post_h + standoff_floor_y + eps * 2,
                     d = standoff_pilot_d, $fn = 16);

    // Bottom-left pilot hole
    translate([so_tl_x,
               standoff_floor_y + standoff_post_h + eps,
               so_bl_z])
        rotate([90, 0, 0])
            cylinder(h = standoff_post_h + standoff_floor_y + eps * 2,
                     d = standoff_pilot_d, $fn = 16);

    // Bottom-right pilot hole
    translate([so_tr_x,
               standoff_floor_y + standoff_post_h + eps,
               so_bl_z])
        rotate([90, 0, 0])
            cylinder(h = standoff_post_h + standoff_floor_y + eps * 2,
                     d = standoff_pilot_d, $fn = 16);
}

// =============================================================================
// Visual reference markers (preview only — not included in export)
// Uncomment to verify port and standoff positions in OpenSCAD preview.
// =============================================================================
// %color("red", 0.5) {
//     // mini-HDMI slot outline
//     translate([hdmi_cx - hdmi_slot_w/2, top_slot_y_centre - hdmi_slot_h/2,
//                case_z_top - top_slot_d])
//         cube([hdmi_slot_w, hdmi_slot_h, top_slot_d]);
//     // USB PWR slot outline
//     translate([usb_pwr_cx - usb_slot_w/2, top_slot_y_centre - usb_slot_h/2,
//                case_z_top - top_slot_d])
//         cube([usb_slot_w, usb_slot_h, top_slot_d]);
//     // USB OTG slot outline
//     translate([usb_otg_cx - usb_slot_w/2, top_slot_y_centre - usb_slot_h/2,
//                case_z_top - top_slot_d])
//         cube([usb_slot_w, usb_slot_h, top_slot_d]);
//     // SD card slot outline
//     translate([case_x_max - sd_slot_d, sd_slot_y_ctr - sd_slot_h/2,
//                sd_slot_z_ctr - sd_slot_w/2])
//         cube([sd_slot_d, sd_slot_h, sd_slot_w]);
// }
// %color("blue", 0.5) {
//     // Standoff post outlines
//     translate([so_tl_x, standoff_floor_y, so_tl_z]) rotate([90,0,0])
//         cylinder(h=standoff_post_h, d=standoff_post_od, $fn=32);
//     translate([so_tr_x, standoff_floor_y, so_tl_z]) rotate([90,0,0])
//         cylinder(h=standoff_post_h, d=standoff_post_od, $fn=32);
//     translate([so_tl_x, standoff_floor_y, so_bl_z]) rotate([90,0,0])
//         cylinder(h=standoff_post_h, d=standoff_post_od, $fn=32);
//     translate([so_tr_x, standoff_floor_y, so_bl_z]) rotate([90,0,0])
//         cylinder(h=standoff_post_h, d=standoff_post_od, $fn=32);
// }
