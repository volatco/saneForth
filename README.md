# saneForth

The most powerful machine client that connects over serial to a Volatco board. This branch is for `sF386/UNIX`.

## Quick start (recommended)

1. Run `make doctor`.
2. If checks are acceptable, run `make connect`.
3. In saneForth follow prompts:
   - `HI`
   - `DISKS` (confirm `../projects/VOLATCO/...`)
   - `SERIAL LOAD`
   - `1 PORT` (Port_B bench)
   - `PLUG`, then Enter + reset + Space
4. On `G144A12 polyFORTH development system`, run `20 DRIVE HI`.

Available helper commands:

- `make check-env` verifies serial visibility, `dialout`, and i386 packages.
- `make doctor` runs diagnostics before connection attempts.
- `make run` launches saneForth from `af3/sfux`.
- `make connect` launches saneForth and prints the Volatco connection guide.
- `make serial-harden` prints exact udev hardening steps for Port_B FTDI.

## Modernization exploration

- Two-week Go exploration plan: `docs/go-exploration-plan.md`

### Preparation

Configure system to install 32-bit (i386) packages:

Ubuntu/Debian:
```
sudo dpkg --add-architecture i386
sudo apt update
```

_Install 32-bit libraries_

Ubuntu/Debian:

`sudo apt install libncurses6:i386 libc6:i386 libstdc++6:i386`

### Known constraints

- `sf6a0.exe` is a 32-bit i386 Linux binary and requires 32-bit userspace libraries.
- This repo uses FORTH block media (`.src`, `.blk`, `Project`, `4THDISK`) as primary source artifacts.
- Running saneForth updates stateful media in `af3/sfux` and `Projects/*`; this is expected and will show as a dirty Git workspace.
- There is a Debian Trixie loader note in `af3/WARNING` about a possible `.bss` mapping hole on at least one VM setup.
- USB serial device assignment may vary (`ttyUSB0` vs `ttyUSB1`), which can require local port adjustments.

### Pre-test checklist (when batteries are charged)

1. Connect board + serial adapter and power on.
2. Run `make doctor` and confirm no hard blockers.
3. Run `make connect`.
4. In saneForth follow prompts: `HI`, `DISKS`, `SERIAL LOAD`, `1 PORT` (Port_B bench), `PLUG`, reset, space.
5. On banner, run `20 DRIVE HI`.

### Serial hardening for Port_B FTDI (recommended)

To reduce garbled serial behavior on this bench:

1. Run `make serial-harden`.
2. Apply the printed sudo commands to install udev rules.
3. Re-plug adapter or trigger udev as printed.
4. Verify stable alias `/dev/volatco-port-b` and low latency timer.

If your fan spins up right after plugging serial, ModemManager is usually probing the new tty.
Apply the Volatco udev rule so this adapter is ignored by ModemManager:

1. Print the exact commands:
   - `make serial-harden`
2. Apply rules:
   - `sudo cp udev/99-volatco-ftdi.rules /etc/udev/rules.d/99-volatco-ftdi.rules`
   - `sudo udevadm control --reload-rules`
   - `sudo udevadm trigger --subsystem-match=tty --subsystem-match=usb-serial`
   - `sudo systemctl restart ModemManager`
3. Verify:
   - `ls -l /dev/volatco-port-b /dev/serial/by-id/*VOLATCO_Port_B*`
   - `cat /sys/bus/usb-serial/devices/ttyUSB*/latency_timer`
4. Optional quick check while plugging:
   - `top`
   - `dmesg -w`

### Known Good Configuration (Port_B bench)

This setup has been verified working:

- Adapter identity: `/dev/serial/by-id/usb-Cartheur_VOLATCO_Port_B_CAR00-0001B-if00-port0`
- Runtime port selection: `SERIAL LOAD` then `1 PORT`
- udev hardening active: `/dev/volatco-port-b -> ttyUSB1`
- udev hardening active: `ID_MM_DEVICE_IGNORE=1`
- udev hardening active: `ID_MM_PORT_IGNORE=1`
- udev hardening active: `/sys/bus/usb-serial/devices/ttyUSB1/latency_timer = 1`
- Successful target banner after reset + space: `pF/G144.03b1 12/21/18`

### Manual installation and launch

Clone the repo into your home directory:

`git clone https://github.com/volatco/saneForth.git`


Change directory to location of saneForth executable file:

`cd saneForth/af3/sfux/`

Set saneForth executable file as executable:

`chmod 755 sf6a0.exe`

Run saneForth:

`./sf6a0.exe`

When you see `hi`, type `HI`:

```
sF386/UX.6a0 01/18/26
hi HI
```

When you see `A T H E N A`, type `WHO` for a quick confirmation:

```
   A T H E N A    i386/NT  saneFORTH Development System
   Copyrighted (c) software, see block 0 for Notices.
----------------------------------------------------------------
   Integrated arrayForth-3/GLOW  6a0 environment.
----------------------------------------------------------------
SYSTEM              Displays this system-wide help screen.
UTILITIES           Displays the major utilities available.
DISKS               Displays current major disk assignments.
AFORTH              Compiles or selects arrayForth environment.

RELOAD   HI         Reloads the entire system WARMLY.
mm/dd/yy NOW        Sets today's date.
hh:mm HOURS         Sets the current time.


Today's date is 2/18/26  Time 01:35:37 ok
```

Then it should respond this:

```
   A T H E N A    i386/NT  saneFORTH Development System
   Copyrighted (c) software, see block 0 for Notices.
----------------------------------------------------------------
   Integrated arrayForth-3/GLOW  6a0 environment.
----------------------------------------------------------------
SYSTEM              Displays this system-wide help screen.
UTILITIES           Displays the major utilities available.
DISKS               Displays current major disk assignments.
AFORTH              Compiles or selects arrayForth environment.

RELOAD   HI         Reloads the entire system WARMLY.
mm/dd/yy NOW        Sets today's date.
hh:mm HOURS         Sets the current time.


Today's date is 2/18/26  Time 01:35:37 ok
WHO
WHO sF on x86.  ok
```

### Manual Konsole profile setup (alternative path)

Use this if you prefer launching from a dedicated Konsole profile.

1. Open Konsole and create a new profile named `saneFORTH-G144A12`.
2. Set initial directory to `<repo>/af3/sfux`.
3. Set command to `<repo>/af3/sfux/afk sf6a0.exe`.
4. Set terminal size to 80 columns by 25 rows.
5. Deselect "Start in the same directory as current session".
6. Save the profile.
7. Run `chmod 755 af3/sfux/afk`.
8. Open a new Konsole window with that profile.
9. At `hi`, type `HI`.
10. Continue with the fast path below (`DISKS`, `SERIAL LOAD`, `1 PORT`, `PLUG`).

### Fast path: IDE to Volatco board

Use this sequence when working from an IDE-integrated terminal:

1. Open terminal in `af3/sfux` and run `./afk sf6a0.exe`.
2. At `hi`, type `HI`.
3. Type `DISKS` and verify paths point to `../projects/VOLATCO/...`.
4. If `DISKS` is not using Volatco files, run `&INCLUDE ../Projects/VOLATCO/custom.txt` and then run `DISKS` again.
5. Type `SERIAL LOAD`.
6. On the Port_B bench, use `1 PORT` (for `/dev/ttyUSB1`).
7. Type `PLUG`.
8. Press Enter, briefly reset the board on `J4` (or reset button), then press Space.
9. When `G144A12 polyFORTH development system` appears, type `20 DRIVE HI`.

If there is no target banner:

1. Run `id` and confirm your user is in `dialout`.
2. Check current serial assignment with `dmesg | grep tty`.
3. Retry `SERIAL LOAD`, `1 PORT`, `PLUG`, then reset + space timing.

### Legacy polyForth sequence (manual)

This is the traditional operator sequence after launch:

1. When you see `hi`, type `HI`.
2. Run `chmod 755 afk`.
3. Type `SERIAL LOAD`.
4. Type `PLUG`.
5. Hit Enter.
6. Briefly connect the provided insulated jumper across `J4`.
    - Better yet, use the RST button system.
7. Hit Space.
8. If successful, you will see: `G144A12 polyFORTH development system`.
9. Type `20 DRIVE HI` to load the system.
10. Type `ctrl-X` to leave polyForth. If you do not know where you are, type `WHO`.
11. Type `EMPTY` to logout.

### Building an executable

Before being able to do this, you will need to be completely out of AFORTH; you can run the command `GOLD`.

1. `COMPILER LOAD`
2. `UNIX LOAD`
3. `801 LOAD`
4. upload <name of the file>, for example `upload volatco.exe`.

_Extra things to do_

Explore the beauty of a self-replicating system.

### Details to investigate

* We see that the tty enumeration most-times will select `ttyUSB0` for the FTDI chips in the DSD device, but also can sometimes assign it `ttyUSB1`. Is there a way to minimize confusion and lock the assignment?
    - Because of this, 4THDISK has a change to block 792, line 11 where Port is 0.
    - Visualization of this can be done by: `dmesg | grep tty`.

### The reset pin header

The 1x2 header `J4` is ordinarily done by temporarily shorting the pins with an external wire. Since this is a crude method, in the 'designs' folder is a reset holder, push-button switch, and JST 2.54mm. The complete appratus with a Volatco in case and the USB FTDI is shown here.

<!--![full-setup](/designs/rst-switch.jpg)-->

### GPIO

* Use the startup routine in the readme of the saneForth repo.
* Start with pin `715.17`. Set the oscilloscope channel 1 to `J10`, pin 2 with ground on pin 1.
	- Note that pin 1 is at the top right looking at the board in normal orientation. Pin 2 is at the immediate left.
* 1581 `LIST` to see wht the program is doing to the pin.
* 1581 `LOAD` to run the program.
	- `1581 LOAD STREAMER ?`
* Snorkel and ganglia next.

#### Visual prototype proof

* Setup with a ~1v8 LED and a 47-ohm resistor.
* Run `1581 LOAD` that will oscillate the pin once a second.
* Change the codeblock such that the program will blink twice a second.
* Rerun `1581 LOAD`.
