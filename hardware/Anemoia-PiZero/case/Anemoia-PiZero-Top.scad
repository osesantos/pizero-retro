// =============================================================================
// Anemoia-PiZero — Top Shell
// =============================================================================
// Modifies the original Anemoia-ESP32 module-based top shell for use with
// a Raspberry Pi Zero build.
//
// The top shell requires minimal changes — the screen window and button holes
// are the same dimensions as the original. The only structural difference is
// that the original top shell had no port cutouts (all ports were on the bottom
// shell's side walls), so nothing needs to be plugged.
//
// This file exists as a clean base for any future modifications (e.g. slightly
// widening the screen window if your specific ILI9341 module PCB is wider,
// or adding a label recess). For now it imports the original STL unchanged.
//
// Coordinate system (inherited from original STL):
//   X :   -3.6 → 170.6 mm   case width  (landscape)
//   Y :   -0.2 → 9.4 mm     case depth  (top half thickness, ~9.6mm)
//   Z : -122.8 → -63.1 mm   case height (Z=0 is the top parting seam,
//                                         so top shell Z values are negative)
//
// Screen window (rectangular cutout in the face of the top shell):
//   X : 52 → 122 mm   (70mm wide)
//   Z spans roughly the full height of the shell
//   The ILI9341 module active area (43×57mm landscape) fits comfortably.
//
// Button holes (6× circular through-holes, ~5–6mm diameter):
//   Left  cluster (D-pad):   X ≈ 10–38mm
//   Right cluster (A/B):     X ≈ 132–160mm
//   These are unchanged from the original.
//
// To modify the screen window width (if needed):
//   Uncomment and adjust the SCREEN WINDOW TRIM section below.
//
// Dependencies:
//   Requires the original STL at the relative path below.
//   Render and export as Anemoia-PiZero-Top.stl for slicing.
// =============================================================================

// ── Path to the original top shell STL ───────────────────────────────────────
original_stl = "../../../3d-model/Anemoia-ESP32/Anemoia-ESP32-Top.stl";

// ── Tolerances ────────────────────────────────────────────────────────────────
tol = 0.3;
eps = 0.1;

// =============================================================================
// Optional: Screen window adjustment
// If your ILI9341 module PCB is slightly wider than the existing 70mm window,
// uncomment the difference block below and adjust the trim values.
// =============================================================================

// Screen window current bounds (from STL analysis):
//   X: 52mm → 122mm   (70mm wide)
//   Z: full shell height
// The window is already cut in the original STL — these parameters would WIDEN it.

screen_trim_enable = false;   // set to true to widen the screen window
screen_trim_left   = 0;       // additional mm to remove from left edge of window
screen_trim_right  = 0;       // additional mm to remove from right edge of window
screen_window_x0   = 52;      // current left edge of screen window in X
screen_window_x1   = 122;     // current right edge of screen window in X
screen_window_z0   = -123;    // bottom of shell in Z
screen_window_z1   = -63;     // top of shell in Z
screen_window_y_depth = 12;   // full depth of top shell (cut through)

// =============================================================================
// Main model
// =============================================================================

if (screen_trim_enable) {
    difference() {
        import(original_stl, convexity = 10);

        // Widen screen window on left side
        if (screen_trim_left > 0)
            translate([screen_window_x0 - screen_trim_left - eps,
                       -eps,
                       screen_window_z0 - eps])
                cube([screen_trim_left + eps,
                      screen_window_y_depth + eps * 2,
                      screen_window_z1 - screen_window_z0 + eps * 2]);

        // Widen screen window on right side
        if (screen_trim_right > 0)
            translate([screen_window_x1 - eps,
                       -eps,
                       screen_window_z0 - eps])
                cube([screen_trim_right + eps,
                      screen_window_y_depth + eps * 2,
                      screen_window_z1 - screen_window_z0 + eps * 2]);
    }
} else {
    // No modifications — import original shell as-is
    import(original_stl, convexity = 10);
}
