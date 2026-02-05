# saneForth

The machine client that connects over serial to a Volatco board. This branch is for sF386/UNIX, aF3 for UNIX.

Note this code is Alpha.

## Installing aF3 systems in Linux

Dependencies are on KDE Konsole and Plasma desktop.

Unzip to make  ~/af3

Copy saneFORTH-G144A12.profile into `~/.local./share/konsole` which hopefully can be made usable without some sort of registration. This profile configures the konsole and conditions it to invoke the correct script with the correct working directory.

Copy `~/af3/sf.desktop` (icon) to the desktop. This icon, when activated, should invoke konsole using the above profile which should cause it to start saneFORTH at 14 points, turn the screen blue with white characters, size the screen as 80x25, configure with stty to allow direct reading of one character at a time from keyboard, and sF should display an ID line and say `hi`. You respond to this by typing `HI`.

## Connecting to Volatco to develop in polyForth

1. Connect the profile in konsole: "Settings..Profile", create a new profile called saneForth-GA144A12. Add the initial directory to your machine's path plus: "../af3/sfux"; and set the command with this path as: "af3/sfux/afk sf6a0.exe". Save the profile as default as this will be the easist way to spawn a new terminal. Save the profile.
2. Run `chmod 775 afk`.
3. Open a new konsole window.
4. When you see `hi`, type `HI`.
5. Type `SERIAL LOAD`.
6. Type `PLUG`.
7. Hit 'enter'.
8. Breifly connect a jumper across J4.
9. Hit 'space'.
10. If successful, you will see the words: `G144A12 polyFORTH development system`.

### Things to investigate

* We see that the tty enumeration most-times will select `ttyUSB0` for the FTDI chips in the DSD device, but also can sometimes assign it `ttyUSB1`. Is there a way to minimize confusion and lock the assignment?
    - Because of this, 4THDISK has a change to block 792, line 11 where Port is 0.
    - Visualization of this can be done by: `dmesg | grep tty`.