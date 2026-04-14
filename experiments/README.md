## Volatco experiments

This page contains some experiments with external hardware that one can perform with a Volatco.

* LED blink [tutorial](#led-blink)
* Automate a motorized face [tutorial](#face-automation)
* Critical Volatco Plan #1 [runbook](#critical-volatco-plan-1)

### LED Blink

Using a Volatco and a suitable polyForth program, you can do the simplest tutorial where a LED blinks at chosen intervals.

Required items:

* Volatco.
* FTDI interface module or pluggable power/ftdi module.
* Breadboard
* A LED

Run source file: `experiments/blink-led-1sec-block-4800.f`

### Critical Volatco Plan #1

Run `experiments/blink-led-1sec-block-4800.f` on a Volatco.

Required items:

* Volatco
* FTDI interface module or pluggable power/FTDI module
* LED and resistor (see wiring note at top of the source file)

Run sequence:

1. Host checks:
   * `make doctor`
   * `make connect`
2. In saneForth, check project context before serial:
   * `HI`
   * `DISKS`
   * confirm `../projects/VOLATCO/...`
   * if missing: `&INCLUDE ../Projects/VOLATCO/custom.txt`
3. Connect to board:
   * `SERIAL LOAD`
   * `1 PORT` (or `0 PORT` depending on adapter index)
   * `PLUG`
   * press Enter, reset, press Space
4. On target banner:
   * `20 DRIVE HI`
5. Load experiment file:
   * `&INCLUDE ../experiments/blink-led-1sec-block-4800.f`
6. Start experiment:
   * `BLINK-1SEC`

If include path lookup fails, paste the file contents at the prompt, then run `BLINK-1SEC`.
Stop the loop with a board reset.

Continuous fan whine after serial connect:

* This usually means a process is staying busy, not a one-time spike.
* Common causes:
  * ModemManager repeatedly probing `/dev/ttyUSB*`
  * a serial tool stuck in a retry loop
  * USB reconnect flapping
* Check while reproducing:
  * `top`
  * `dmesg -w`
  * `journalctl -fu ModemManager`
* Quick isolation:
  * `sudo systemctl stop ModemManager`
  * if fan noise drops, apply Volatco rules:
    * `make serial-harden`
    * `sudo cp udev/99-volatco-ftdi.rules /etc/udev/rules.d/99-volatco-ftdi.rules`
    * `sudo udevadm control --reload-rules`
    * `sudo udevadm trigger --subsystem-match=tty --subsystem-match=usb-serial`
    * `sudo systemctl restart ModemManager`
* Check for stuck serial tools:
  * `ps -ef | rg 'sf6a0|afk|minicom|screen|picocom'`

### Face automation

Using a Volatco and a suitable polyForth program, you can have a face blink its eyes and move its mouth speaking example phrases.

Required items:

* Volatco.
* FTDI interface module or pluggable power/ftdi module.
* 6612FNG - Can be obtained by a ROB-15550 Adafruit breakout board.
* Motorized face - we use one that was scavaged from an old toy.
