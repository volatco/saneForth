# saneForth

This is the development branch.

## 260423

A couple of notes to avoid frustration, suggest the following procedure -- more steps than abs necessary but should work every time.

1. plug both USB-C in, A first B second so that A is 0 and B is 1.
2. Start aF3.  say `HI`  `AFORTH`  to get it all loaded.
3. Insert no-boot jumper on board.
4. Say: `0 SELFTEST`  (key in SUDO pasword when asked) and let it run to OK completion.
5. Say:  `HOST LOAD TALK`
6. Pull no-boot jumper
6. Say: `RESET`
7. Say: `SERIAL LOAD PLUG` and hit space, see `hi`.
8. Say: `20 DRIVE  HI` (loading code from PC disk)
9. Say: `AFORTH`
10. Say: `1585 LOAD ` and look at pin `715.17`.
11. Say: `1585 LIST  4 T` and edit the first value for different period, then `1585 LOAD` to activate it.

## Test results

_Leveled power over period_

* Power-on-hold
  - USB Hub
  - VOL01 -> USB-C
          -> USB-C
  - `lsusb`
  - Shows two FTDI chips present.
  - Started 1315.

* Stabalized power at 1.7855 VDC, Max - 1.7862, Min - 1.7849 VDC | 7e-4 and 6e-4 respecitively
* Quasi-stable power: 4.5454 VDC: Max - 4.5716, Min - 4.4829 VDC | 262e-4 and 625e-4 respectively

![onstate](/images/leveled_power.jpg)

* Power level (before connecing to VOL00)
  - Scope volatge test
  - J1:1P8, J7, J8: Absolute percentage differences: 0.0392% and 0.0336%.
  - J1:5P0: Absolute percentage differences: 0.5765% and 1.3751%.
* Program FTDI chips
  - xml file
  - FTDI writing app
*  arrayForth3
  - Install process and guide
* aF3 -> GA144-pF
