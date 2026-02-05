# saneForth

The machine client that connects over serial to a Volatco board. This branch is for sF386/UNIX, aF3 for UNIX.

Note this code is Alpha.

## Installing aF3 systems in Linux

Dependencies are on KDE Konsole and Plasma desktop.

Unzip to make  ~/af3

Copy saneFORTH-G144A12.profile into `~/.local./share/konsole` which hopefully can be made usable without some sort of registration. This profile configures the konsole and conditions it to invoke the correct script with the correct working directory.

Copy `~/af3/sf.desktop` (icon) to the desktop. This icon, when activated, should invoke konsole using the above profile which should cause it to start saneFORTH at 14 points, turn the screen blue with white characters, size the screen as 80x25, configure with stty to allow direct reading of one character at a time from keyboard, and sF should display an ID line and say `hi`. You respond to this by typing `HI`.