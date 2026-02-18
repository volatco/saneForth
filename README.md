# saneForth

The most powerful machine client that connects over serial to a Volatco board. This branch is for `sF386/UNIX`.

## Running the aF3 system in Debian Linux

### Preparation

Configure system to install 32-bit (i386) packages:

Ubuntu/Debian:
```
sudo dpkg --add-architecture i386
sudo apt update
```

Install 32bit libraries:

Ubuntu/Debian:

`sudo apt install libncurses6:i386 libc6:i386 libstdc++6:i386`

### Installation

Clone the repo into your home directory

`git clone https://github.com/volatco/saneForth.git`


Change directory to location of saneForth executable file

`cd saneForth/af3/sfux/`

Set saneForth executable file as executable

`chmod 755 sf6a0.exe`

Run saneForth

`./sf6a0.exe`

When you see `hi`, type `HI`

```
sF386/UX.6a0 01/18/26
hi HI
```

When you see `A T H E N A`, type `WHO` for a quick confirmation

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

Then it should respond this

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

### Connecting to Volatco to develop in polyForth

In order for a Volatco computer to respond correctly to a common Debian desktop, a special terminal needs to be formatted.

1. Open konsole: "Settings..Profile", create a new profile called `saneForth-GA144A12`. Add the initial directory to your machine's path plus: `../af3/sfux`; and set the command with this path as: `af3/sfux/afk sf6a0.exe`. Save the profile as default as this will be the easist way to spawn a new terminal. Set "Initial terminal size" to 80 columns by 25 rows. Deselect "Start in the same directory as current session". Save the profile.
2. Run `chmod 755 afk`.
3. Open a new konsole window.
4. When you see `hi`, type `HI`.
5. Type `SERIAL LOAD`.
6. Type `PLUG`.
7. Hit 'enter'.
8. BrIefly connect the provided insulated jumper across `J4`.
    - Better yet, use the RST button system.
9. Hit 'space'.
10. If successful, you will see the words: `G144A12 polyFORTH development system`.
11. Type `20 DRIVE HI` to load the system.
11. Type `ctrl-X` to leave polyForth. If you don't know, type `WHO`.
12. Type `EMPTY` to logout.

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

![full-setup](/designs/rst-switch.jpg)