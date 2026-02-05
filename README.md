# saneForth

The machine client that connects over serial to a Volatco board. This branch is for `sF386/UNIX`, `aF3` for UNIX.

## Running the aF3 systems in Debian Linux

This is performed on a KDE Plasma desktop using Konsole.

Run `chmod 755 sf6a0.exe`.

_Connecting to Volatco to develop in polyForth_

In order for a Volatco computer to respond correctly to a common Debian desktop, a special terminal needs to be formatted.

1. Open konsole: "Settings..Profile", create a new profile called `saneForth-GA144A12`. Add the initial directory to your machine's path plus: `../af3/sfux`; and set the command with this path as: `af3/sfux/afk sf6a0.exe`. Save the profile as default as this will be the easist way to spawn a new terminal. Set "Initial terminal size" to 80 columns by 25 rows. Deselect "Start in the same directory as current session". Save the profile.
2. Run `chmod 755 afk`.
3. Open a new konsole window.
4. When you see `hi`, type `HI`.
5. Type `SERIAL LOAD`.
6. Type `PLUG`.
7. Hit 'enter'.
8. Breifly connect the provided insulated jumper across `J4`.
9. Hit 'space'.
10. If successful, you will see the words: `G144A12 polyFORTH development system`.
11. Type `ctrl-X` to leave polyForth. If you don't know, type `WHO`.
12. Type `EMPTY` to logout.

### Things to investigate

* We see that the tty enumeration most-times will select `ttyUSB0` for the FTDI chips in the DSD device, but also can sometimes assign it `ttyUSB1`. Is there a way to minimize confusion and lock the assignment?
    - Because of this, 4THDISK has a change to block 792, line 11 where Port is 0.
    - Visualization of this can be done by: `dmesg | grep tty`.