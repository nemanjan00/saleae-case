# Saleae Logic Pro 8 case

3D-printable two-part case for the Saleae Logic Pro 8 that permanently captures
the micro-USB 3.0 plug, so the cable can't be pulled out or wiggled loose.

- Split through the USB plug center; the plug overmold is enclosed in a shroud
  whose end wall only passes the strain relief
- Probe opening with engraved channel numbers 0–7
- LED window and logo windows (top and bottom)
- Fully parametric OpenSCAD (`saleae_pro8_case.scad`)

## Build

```sh
openscad -D 'part="bottom"'    -o case_bottom.stl saleae_pro8_case.scad
openscad -D 'part="top_print"' -o case_top.stl    saleae_pro8_case.scad
```

Other `part` values: `assembly` (preview with plug and screws), `top`, `plug`, `print`.

## Print

PETG, 0.2 mm layers, 3–4 perimeters, no supports. The top half is exported
upside down (roof on the bed).

## Assembly

6× M2×12 screws (4 corners + 2 at the USB shroud), self-tapping into the bottom half.

1. Plug the USB cable into the Saleae.
2. Lay the device with the plug into the bottom half.
3. Put the top half on and screw together.

## Radius gauge

`radius_gauge.scad` prints a set of inside-corner chips for measuring corner radii
(default 2–8 mm; `-D 'radii=[9,10,11,12,13,14,15,16]'` for larger).
