# Anemoia-PiZero Case Files

OpenSCAD modifications to the original Anemoia-ESP32 module-based enclosure,
adapted for the Raspberry Pi Zero build.

---

## Files

| File | Description |
|---|---|
| `Anemoia-PiZero-Bottom.scad` | Modified bottom shell — removes ESP32-era port holes, adds Pi Zero USB port slots and standoff pilot holes |
| `Anemoia-PiZero-Top.scad` | Top shell — imported unchanged; screen window and button holes are already correct. Contains optional screen window widening parameters if needed. |

Both files import the original STLs from `3d-model/Anemoia-ESP32/` by relative
path. **Open the `.scad` files from the repo root, or adjust the `original_stl`
path at the top of each file if you open them from a different working directory.**

---

## What changed from the original

### Bottom shell

| Change | Original | Pi Zero |
|---|---|---|
| Left wall cutout | Micro-USB charging port (TP4056) | **Filled/removed** |
| Right wall cutout | SS12F17 power switch slot | **Filled/removed** |
| Bottom edge | No cutouts | **2× Micro-USB slots added** (PWR + OTG) |
| Floor standoffs | ESP32-DevKit mounting pattern | **2× M2.5 pilot holes added** for Pi Zero |

### Top shell

No structural changes. The existing 70mm screen window fits a standard
ILI9341 2.8" module in landscape orientation. Button holes are unchanged.

---

## Pi Zero placement inside the case

```
Case X axis (174mm wide, landscape):
  0mm ─────[buttons]──── 52mm ────[screen]──── 122mm ────[Pi Zero]──── 174mm
                                                            85mm        150mm

Pi Zero PCB: X = 85 → 150mm
  USB PWR port centre: X ≈ 105.5mm  (slot on bottom edge)
  USB OTG port centre: X ≈ 122.5mm  (slot on bottom edge)
  MicroSD card: underside at X ≈ 145mm — accessed by opening the case, no wall slot needed
```

---

## How to render and export

1. Open `Anemoia-PiZero-Bottom.scad` in OpenSCAD.
2. Press **F6** to render (may take 1–2 minutes — the STL import is large).
3. Go to **File → Export → Export as STL** and save as `Anemoia-PiZero-Bottom.stl`.
4. Repeat for `Anemoia-PiZero-Top.scad` → `Anemoia-PiZero-Top.stl`.
5. Slice both STLs with your slicer of choice.

> [!NOTE]
> OpenSCAD's preview mode (F5) renders the STL import as a grey placeholder —
> this is normal. Use F6 (full render) to see the actual geometry with all
> modifications applied.

---

## Recommended print settings

| Setting | Value |
|---|---|
| Material | PLA or PETG |
| Layer height | 0.2mm |
| Infill | 20% gyroid |
| Walls | 3 perimeters |
| Supports | None required (both shells print flat-side down) |
| Bed adhesion | Brim (recommended for the top shell — long thin part) |

---

## Standoff notes

The bottom shell has four existing standoffs from the original design.
The `.scad` file drills **M2.5 pilot holes** (2.7mm diameter) into the standoffs
nearest to the Pi Zero mounting hole positions.

Use **M2.5 × 6mm self-tapping screws** to secure the proto board assembly.
If the standoffs are not in a convenient position after a test fit, use
**double-sided foam tape** (3M VHB) instead — this is adequate for a USB-only
powered build with no vibration.

---

## Adjusting the screen window

If your specific ILI9341 module has a wider PCB than expected, open
`Anemoia-PiZero-Top.scad` and set:

```scad
screen_trim_enable = true;
screen_trim_left   = 2;   // mm to add on left
screen_trim_right  = 2;   // mm to add on right
```

Then re-render and export.
