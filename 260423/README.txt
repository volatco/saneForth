April 2026

Didn't have time to get source bases firmly established & documented.  This should be enough for the initial demo video.  A couple of notes to avoide frustration, suggest the following procedure for the demo (more steps than abs necessary but should work every time):



1. plug both USB-C in, A first B second so that A is 0 and B is 1.

2. Start aF3.  say HI  AFORTH  to get it all loaded.

3. Insert no-boot jumper on board.

4. Say  0 SELFTEST  (key in SUDO pasword when asked) and let it run to OK completion.

5. Say  HOST LOAD TALK

6. Pull no-boot jumper

6. Say  RESET

7. Say  SERIAL LOAD PLUG  and hit space, see hi

8. Say  20 DRIVE  HI  (loading code from PC disk)

9. Say AFORTH

10.  Say  1585 LOAD  and look at pin 715.17

11.  Say  1585 LIST  4 T  and edit the first value for different period,  then  1585 LOAD  to activate it.






