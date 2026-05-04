// =============================================================================
// Anemoia-PiZero — Bottom Shell
// =============================================================================
// Modifies the original Anemoia-ESP32 bottom shell for use with a
// Raspberry Pi Zero build.
//
// Changes from the original ESP32 bottom shell:
//   1. Left side-wall hole (TP4056 Micro-USB charger) is plugged.
//   2. Right side-wall hole (SS12F17 power switch) is plugged.
//   3. Two Micro-USB port slots are cut through the top wall for the
//      Pi Zero's PWR and OTG ports (Pi processor faces up toward top shell).
//   4. Four new M2.5 standoff cylinders are added to the inner floor,
//      positioned for the Pi Zero 58 × 23 mm mounting-hole pattern.
//      Each standoff has a 2.7 mm pilot hole for an M2.5 × 6 mm self-tapping
//      screw.
//
// ── Coordinate system (inherited from original STL) ───────────────────────────
//   X :   -3.6  →  170.6 mm   case width  (174 mm, landscape)
//   Y :    0.4  →   15.8 mm   case depth  (Y=0.4  outer back face,
//                                           Y=15.8 parting seam / open face)
//   Z :  -57.1  →    2.6 mm   case height (Z= 2.6  top wall outer face,
//                                           Z=-57.1 bottom wall outer face)
//
// ── Walls ─────────────────────────────────────────────────────────────────────
//   Inner cavity floor    :  Y ≈ 2.0 mm  (floor of the component well)
//   Top wall inner face   :  Z ≈ 1.0 mm  (→ outer face Z=2.6, ~1.6 mm thick)
//   Side walls (X=-3.6 / X=170.6): short walls, ~2 mm thick
//
// ── Pi Zero placement ─────────────────────────────────────────────────────────
//   Pi Zero PCB            :  X = 85 → 150 mm  (65 × 30 mm PCB)
//   Processor              :  facing UP (toward top shell / parting face)
//   USB PWR port centre    :  X ≈ 105.5 mm, exits through top wall (Z = 2.6)
//   USB OTG port centre    :  X ≈ 122.5 mm, exits through top wall (Z = 2.6)
//   MicroSD card           :  underside at X ≈ 145 mm — no wall slot needed
//
// ── Pi Zero mounting-hole pattern ─────────────────────────────────────────────
//   Hole spacing           :  58 mm (X) × 23 mm (Z)
//   PCB centred in X from 85 mm : margin = (65−58)/2 = 3.5 mm
//   Standoff centres (X)   :  88.5 mm  and  146.5 mm
//   Standoff centres (Z)   :  pizero_z_centre − 11.5 mm  and  + 11.5 mm
//     where pizero_z_centre is the midpoint of the Pi Zero along Z (configurable).
//
// Dependencies:
//   Requires the original ESP32 bottom STL at the relative path below.
//   Render (F6) and export as Anemoia-PiZero-Bottom.stl for slicing.
// =============================================================================

// ── Path to the original bottom shell STL ────────────────────────────────────
original_stl = "../../../3d-model/Anemoia-ESP32/Anemoia-ESP32-Bottom.stl";

// ── Tolerances ────────────────────────────────────────────────────────────────
tol = 0.3;   // general fit tolerance (added to slot/hole dims)
eps = 0.1;   // small overlap to avoid coincident-face artefacts

// =============================================================================
// USB port slot parameters
// =============================================================================
// Micro-USB connector body: ~7.5 mm wide × ~2.8 mm tall.
// Added tol on each dimension for clearance.

usb_slot_w = 7.5 + tol * 2;   // slot width  in X  (≈ 8.1 mm)
usb_slot_h = 2.8 + tol * 2;   // slot height in Y  (≈ 3.4 mm)

// Port centres on the Pi Zero (X axis)
usb_pwr_x = 105.5;
usb_otg_x = 122.5;

// Top wall: outer Z=2.6, inner Z=1.0  →  cut from Z=1.0−eps through Z=2.6+eps
top_wall_z_inner = 1.0;
top_wall_z_outer = 2.6;

// Slot Y span: centred in the wall depth (Y=0.4 … 15.8).
// The Pi Zero PCB sits near the parting face, so we centre the slot
// in the full wall depth to give cable clearance on both sides.
wall_y_min = 0.4;
wall_y_max = 15.8;
slot_y_centre = (wall_y_min + wall_y_max) / 2;   // ≈ 8.1 mm

// =============================================================================
// Pi Zero standoff parameters
// =============================================================================
// New raised standoff cylinders added to the inner floor (Y=2.0).

standoff_od    = 5.0;    // outer diameter of standoff post (mm)
standoff_h     = 3.5;    // height above the inner floor (mm)
pilot_hole_d   = 2.7;    // M2.5 pilot hole diameter (mm)

// Pi Zero PCB starts at X=85 mm; 65 mm PCB, mounting holes 58 mm apart in X.
//   Margin from PCB edge to hole centre = (65 - 58) / 2 = 3.5 mm
pizero_x_left  = 85.0 + 3.5;   //  88.5 mm
pizero_x_right = 85.0 + 3.5 + 58.0;   // 146.5 mm

// Z centre for the Pi Zero: place it roughly mid-height of the case interior.
// Inner Z range (inside cavity) ≈ -55 to 1.  Pi Zero PCB is 30 mm tall.
// Position the Pi Zero Z centre at Z = -20 (adjust after test fit).
pizero_z_centre = -20.0;
pizero_z_top    = pizero_z_centre + 11.5;   //  -8.5 mm
pizero_z_bot    = pizero_z_centre - 11.5;   // -31.5 mm

// Inner floor Y position (standoffs sit on the floor)
floor_y = 2.0;

// =============================================================================
// Plug dimensions for the original ESP32 side-wall holes
// =============================================================================
// Original holes (measured from STL edge triangles):
//   Both left and right holes span Z = -53 → -1.5, Y = 2.4 → 14.8
//   Left  hole : X outer face at X = -3.6, inner face at X ≈ -1.0
//   Right hole : X outer face at X = 170.6, inner face at X ≈ 168.6

plug_z0 = -53.0 - eps;
plug_z1 = -1.5  + eps;
plug_y0 =   2.4 - eps;
plug_y1 =  14.8 + eps;
plug_thickness = 3.0;   // enough to completely fill & slightly overfill

// =============================================================================
// Helper modules
// =============================================================================

// A single micro-USB slot through the top wall, centred at x_centre.
module usb_slot(x_centre) {
    translate([x_centre - usb_slot_w / 2,
               slot_y_centre - usb_slot_h / 2,
               top_wall_z_inner - eps])
        cube([usb_slot_w,
              usb_slot_h,
              (top_wall_z_outer - top_wall_z_inner) + eps * 2]);
}

// A single Pi Zero standoff post with M2.5 pilot hole.
// Placed at (x, floor_y, z); post extends in the +Y direction (into the open cavity).
// OpenSCAD cylinders are Z-axis aligned; rotate −90° around X to point in +Y.
module pizero_standoff(x, z) {
    translate([x, floor_y, z])
    rotate([-90, 0, 0])          // Z→+Y : cylinder now grows in +Y from Y=floor_y
    difference() {
        cylinder(h = standoff_h, d = standoff_od,   center = false, $fn = 32);
        cylinder(h = standoff_h + eps, d = pilot_hole_d, center = false, $fn = 32);
    }
}

// =============================================================================
// Main model
// =============================================================================

union() {
    difference() {
        // ── 1. Original ESP32 bottom shell ────────────────────────────────────
        import(original_stl, convexity = 10);

        // ── 3. Micro-USB slots through the top wall ───────────────────────────
        usb_slot(usb_pwr_x);
        usb_slot(usb_otg_x);
    }

    // ── 2. Plug the original ESP32 side-wall holes ────────────────────────────

    // Left wall plug (fills TP4056 charging-port hole)
    translate([-3.6 - eps, plug_y0, plug_z0])
        cube([plug_thickness + eps, plug_y1 - plug_y0, plug_z1 - plug_z0]);

    // Right wall plug (fills power-switch hole)
    translate([170.6 - plug_thickness, plug_y0, plug_z0])
        cube([plug_thickness + eps, plug_y1 - plug_y0, plug_z1 - plug_z0]);

    // ── 4. Pi Zero standoff posts ─────────────────────────────────────────────
    pizero_standoff(pizero_x_left,  pizero_z_top);
    pizero_standoff(pizero_x_right, pizero_z_top);
    pizero_standoff(pizero_x_left,  pizero_z_bot);
    pizero_standoff(pizero_x_right, pizero_z_bot);
}
