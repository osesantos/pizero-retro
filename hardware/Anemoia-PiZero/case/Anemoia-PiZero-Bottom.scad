// =============================================================================
// Anemoia-PiZero — Bottom Shell
// =============================================================================
// Modifies the original Anemoia-ESP32 module-based bottom shell for use with
// a Raspberry Pi Zero instead of an ESP32-DevKit.
//
// Changes from the original:
//   REMOVED  — TP4056 USB charging port slot (left wall)
//   REMOVED  — SS12F17 power switch slot (right wall)
//   ADDED    — Micro-USB PWR port slot on bottom edge  (Pi Zero PWR port)
//   ADDED    — Micro-USB OTG port slot on bottom edge  (Pi Zero OTG port)
//   ADDED    — 2× M2.5 standoff holes for Pi Zero mounting
//
// Coordinate system (inherited from original STL):
//   X : 0 → 174.2 mm   case width  (landscape orientation)
//   Y : 0 → 15.4 mm    case depth  (bottom half thickness)
//   Z : -57.1 → 2.6 mm case height (Z=0 is the top parting seam)
//
// Pi Zero placement:
//   Pi Zero PCB spans X = 85 → 150 mm, with its port edge at Z ≈ -38 mm
//   (Pi Zero 30mm wide, bottom edge of Pi = bottom of case side)
//   Ports face the Z-min (bottom) edge of the case.
//
// Dependencies:
//   Requires the original STL at the relative path below.
//   Render and export as Anemoia-PiZero-Bottom.stl for slicing.
// =============================================================================

// ── Path to the original bottom shell STL ────────────────────────────────────
// Adjust if your working directory differs.
original_stl = "../../../3d-model/Anemoia-ESP32/Anemoia-ESP32-Bottom.stl";

// =============================================================================
// Parameters — tweak these if your specific components differ
// =============================================================================

// ── Tolerances ────────────────────────────────────────────────────────────────
tol = 0.3;    // general print tolerance added to cutout dimensions (mm)
eps = 0.1;    // small epsilon to avoid z-fighting in previews

// ── Micro-USB port slot dimensions ───────────────────────────────────────────
// Standard Micro-USB plug opening: 8.0mm wide × 3.5mm tall
// We add tolerance and round the corners with a small fillet (approximated)
usb_slot_w  = 8.0 + tol * 2;   // 8.6mm wide
usb_slot_h  = 3.5 + tol * 2;   // 4.1mm tall
usb_slot_d  = 4.0;              // depth of slot into case wall (wall is ~2mm, 4mm ensures clean cut)

// ── Pi Zero port X positions (measured from left end of Pi Zero PCB) ─────────
// Pi Zero PCB left edge sits at X = 85mm in the case
pi_x_offset = 85;               // X position of Pi Zero left edge in case coords

// Pi Zero port offsets from its own left edge (from datasheet):
pi_usb_pwr_offset = 20.5;       // USB PWR port centre from Pi Zero left edge
pi_usb_otg_offset = 37.5;       // USB OTG port centre from Pi Zero left edge

// Port centres in case X coordinates:
usb_pwr_cx = pi_x_offset + pi_usb_pwr_offset;   // = 105.5mm
usb_otg_cx = pi_x_offset + pi_usb_otg_offset;   // = 122.5mm

// ── Bottom edge Z position ────────────────────────────────────────────────────
// The bottom face of the case is at Z ≈ -57mm.
// The USB ports on the Pi Zero bottom edge protrude into this wall.
// Pi Zero PCB sits at Z ≈ -8mm (top of Pi PCB) to Z ≈ -38mm (bottom of Pi PCB).
// The port connector body sits centred on the bottom edge of the Pi PCB.
// Port body centre Z ≈ -38 - 2 = -40mm (accounting for connector below PCB)
usb_port_cz = -40;              // Z centre of USB port slots

// ── Pi Zero standoff holes (M2.5, 2.7mm drill) ───────────────────────────────
// Pi Zero mounting holes: 3.5mm diameter, 3.5mm from each corner edge
// Pi Zero PCB: 65mm × 30mm
// Mounting holes at: (3.5, 3.5) and (61.5, 3.5) from Pi Zero bottom-left corner
// In case coords (Pi Zero left=85, bottom=Z-38+15=Z-23 from Pi top):
// We place 2 holes on the floor of the bottom shell
standoff_d        = 2.7;        // M2.5 drill diameter (mm)
standoff_depth    = 6.0;        // how deep to drill into floor standoffs (mm)
pi_standoff_1_x   = pi_x_offset + 3.5;    // = 88.5mm
pi_standoff_2_x   = pi_x_offset + 61.5;   // = 146.5mm
// Z position of mounting holes (Pi Zero top edge in case coords ≈ -8mm from seam)
// Pi is 30mm wide → bottom edge at -8-30 = -38mm
// Hole Y=3.5mm from top edge of Pi → in case Z = -8 - 3.5 = -11.5mm
pi_standoff_z     = -11.5;
// Holes are on the inner floor (Y face), at Y = inner floor ≈ 5mm (standoff tops)
pi_standoff_y     = 0;          // from bottom of case, through standoff top

// ── Plug block dimensions (filling old cutouts) ───────────────────────────────
// Old TP4056 USB slot: left wall (X≈0), Z = -24 to -32mm, Y = 0 to 15mm
plug_usb_z0  = -33;    plug_usb_z1  = -23;
plug_usb_y0  =  0;     plug_usb_y1  =  15.5;
plug_usb_x0  = -4;     plug_usb_x1  =  2;      // covers the wall interior

// Old power switch slot: right wall (X≈170), Z = -30 to -40mm, Y = 2 to 8mm
plug_sw_z0   = -42;    plug_sw_z1   = -28;
plug_sw_y0   =  1.5;   plug_sw_y1   =  9;
plug_sw_x0   = 168;    plug_sw_x1   = 175;

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
    }

    // ── Cut: USB PWR port slot on bottom edge ─────────────────────────────────
    // Slot is centred at (usb_pwr_cx, Y=through-wall, usb_port_cz)
    // Bottom edge of case is at Z = -57mm; slot cuts upward from there
    translate([usb_pwr_cx - usb_slot_w / 2,
               -eps,
               usb_port_cz - usb_slot_h / 2])
        cube([usb_slot_w, usb_slot_d + eps, usb_slot_h]);

    // ── Cut: USB OTG port slot on bottom edge ─────────────────────────────────
    translate([usb_otg_cx - usb_slot_w / 2,
               -eps,
               usb_port_cz - usb_slot_h / 2])
        cube([usb_slot_w, usb_slot_d + eps, usb_slot_h]);

    // ── Cut: Pi Zero standoff hole 1 ─────────────────────────────────────────
    // Cuts a pilot hole into the top of the existing floor standoffs so an
    // M2.5 self-tapping screw can secure the proto board / Pi Zero assembly.
    translate([pi_standoff_1_x,
               pi_standoff_y - eps,
               pi_standoff_z])
        cylinder(h = standoff_depth + eps, d = standoff_d, $fn = 16);

    // ── Cut: Pi Zero standoff hole 2 ─────────────────────────────────────────
    translate([pi_standoff_2_x,
               pi_standoff_y - eps,
               pi_standoff_z])
        cylinder(h = standoff_depth + eps, d = standoff_d, $fn = 16);
}

// =============================================================================
// Visual reference markers (rendered only in preview, not in export)
// Uncomment the block below to see port positions in the OpenSCAD preview.
// =============================================================================
// %color("red", 0.5) {
//     // USB PWR slot outline
//     translate([usb_pwr_cx - usb_slot_w/2, -1, usb_port_cz - usb_slot_h/2])
//         cube([usb_slot_w, 1, usb_slot_h]);
//     // USB OTG slot outline
//     translate([usb_otg_cx - usb_slot_w/2, -1, usb_port_cz - usb_slot_h/2])
//         cube([usb_slot_w, 1, usb_slot_h]);
// }
