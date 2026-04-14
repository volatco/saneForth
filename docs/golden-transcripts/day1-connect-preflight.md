# Day 1 Connect Preflight Transcript

Captured on: `2026-04-14`
Command: `timeout 8s make connect`
Source log: `/tmp/day1-baseline-raw.txt`

## Transcript

```text
./scripts/connect-volatco.sh
Volatco connection guide (inside saneForth):

1. HI
2. DISKS
   - Make sure you see ../projects/VOLATCO/... paths
3. If not, run:
   &INCLUDE ../Projects/VOLATCO/custom.txt
   DISKS
4. SERIAL LOAD
5. 1 PORT      (Port_B rigs usually use 1 PORT)
   - expected: "Using port /dev/ttyUSBx ok"
6. PLUG
   - expected: "ok"
7. Press Enter, reset J4 briefly, then press Space
8. expected target banner: "G144A12 polyFORTH development system"
9. On banner:
   20 DRIVE HI

If it does not connect:
- Run: id                  (should include dialout)
- If "PORT can't open it!": wrong tty index or permissions
- If "PORT ok" but no banner: board power, J4 reset timing, or TX/RX/GND path
Autodetected runtime port: 1 PORT (single ttyUSB device present (/dev/ttyUSB1))
Legacy runtime device expected by media: /dev/ttyUSB1
Detected serial device(s): /dev/ttyUSB1

Starting saneForth...
stty: 'standard input': Inappropriate ioctl for device
stty: 'standard input': Inappropriate ioctl for device
/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/af3/sfux/afk: line 7: 24528 Bad system call         (core dumped) ./$1
stty: 'standard input': Inappropriate ioctl for device
make: *** [Makefile:15: connect] Error 1
```

## Notes

- This capture verifies preflight guidance and port autodetection output.
- It is not a full runtime transcript; runtime launch failed in this environment with `Bad system call` (including PTY attempt).
