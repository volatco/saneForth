March 2026

Simply replace the corresponding files in af3/sfux.

4THDISK is set for ttyUSB0 on both IDE and SERIAL, and has the code to set minimal latency in the FTDI driver.

Boot saneFORTH from the script or shortcut.

HI            ( to finish loading saneFORTH)

Plug FTDI into the B port (J7, the one on the left of the pair on VOLATCO VOL00-01 board)

SERIAL LOAD   ( to load serial services)
PLUG          ( the first time you do this you'll be
                prompted for SUDO password and keyboard
                will NOT support backspace)

Reset VOLATCO and hit the space bar to autobaud.
You should see the polyFORTH ID line.

Now we are talking to the VOLATCO board.

20 DRIVE HI   ( to do the polyFORTH 9 LOAD)

After HI you can use WHO to see who you're talking to.

AFORTH        ( to compile the arrayForth environment)

Now look at block 1585

1585 LIST

Line 4 has a definition of  run  and the first thing in that definition is the value 2000. which is the number of ms per half cycle of a square wave.  Edit this value (e.g.  F 2000.
       R 500.  )
... to change period of the signal.

Edit or not as you see fit, then say

1585 LOAD      ( to start node 715 going independently).

Each time you say  1585 LOAD  you are reprogramming node 715 so you can carefully edit  run  and then load again to change it.

The shadow ( type  Q )  says what it's all about.

If you screwe it up, get hung etc, reset VOLATCO, say  HI and AFORTH again, look at 1585 and fix what you broke.  NOte that if you do not say FLUSH while soing this, your changes will not have been written to mass storage and so you will most likely not need to do any fixing.

If you deem 1585 to be too unfriendly you could add a definition to block 1560   1585 CONSTANT DEMO  and then after loading AFORTH the word  DEMO  may be used instead.  I don't recommend doing this, though.

Please call my cell number if you need me before say 7 hours from now (now being 0645 CET)

Cheers!!




