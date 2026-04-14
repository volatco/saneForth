# saneForth Repository Analysis

## Scope

This analysis is based on the current repository contents in:

- `/af3/sfux` (runtime + disk images)
- `/Projects/DEFAULT` and `/Projects/VOLATCO` (project data)
- top-level documentation and notes

## Executive Summary

This repository is a legacy/embedded FORTH development workspace for Volatco hardware. It ships a host-side `sF386/UNIX` executable and multiple fixed-size block-disk images used by `arrayForth` / `polyFORTH` workflows over serial.

The center of gravity is not conventional source files; it is block media (`.src`, `.blk`, `4THDISK`, `Project`, etc.) that the host environment mounts and edits.

## What The Main Components Do

### 1) Host Runtime (`af3/sfux`)

- `sf6a0.exe` is the runtime binary invoked on Linux (despite `.exe`, it is ELF 32-bit i386).
- `afk` and `afx` are terminal wrappers that set raw-ish TTY mode and run the executable.
- `saneFORTH-G144A12.profile` and `sF.desktop` are launcher/profile helpers for Konsole/XTerm workflows.

Relevant files:

- [README.md](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/README.md)
- [af3/sfux/sf6a0.exe](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/af3/sfux/sf6a0.exe)
- [af3/sfux/afk](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/af3/sfux/afk)
- [af3/sfux/afx](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/af3/sfux/afx)
- [af3/sfux/saneFORTH-G144A12.profile](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/af3/sfux/saneFORTH-G144A12.profile)

### 2) Project Payloads (`Projects/*`)

Two configured projects exist:

- `DEFAULT`
- `VOLATCO`

Each project has:

- source image (`*.src`)
- backup image (`*-back.src`)
- object image (`OBJ-*`)
- concordance (`conc`)
- customization script (`custom.txt`)
- notes/doc text files

Relevant files:

- [Projects/VOLATCO/custom.txt](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/Projects/VOLATCO/custom.txt)
- [Projects/DEFAULT/custom.txt](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/Projects/DEFAULT/custom.txt)
- [Projects/VOLATCO/VOLATCO.src](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/Projects/VOLATCO/VOLATCO.src)
- [Projects/DEFAULT/DEFAULT.src](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/Projects/DEFAULT/DEFAULT.src)

### 3) Hardware/Operations Documentation

- The top-level README describes serial bring-up and provisioning flow (`SERIAL LOAD`, `PLUG`, `DRIVE HI`, etc.).
- `VOLATCO-Notes.txt` and logs capture board testing/provisioning history.
- `designs/` contains reset button mechanical artifacts.

Relevant files:

- [Projects/VOLATCO/VOLATCO-Notes.txt](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/Projects/VOLATCO/VOLATCO-Notes.txt)
- [Projects/VOLATCO/logs/Install-pF.txt](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/Projects/VOLATCO/logs/Install-pF.txt)
- [af3/WARNING](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/af3/WARNING)

## Media/Layout Findings

### Fixed Block Geometry

Most key media are exactly `4,915,200` bytes (`4800 * 1024`), for example:

- `af3/sfux/Project`
- `af3/sfux/Projback`
- `af3/sfux/pFDISK.blk`
- `Projects/VOLATCO/VOLATCO.src`

This aligns with project comments stating “These 4800 blocks are visible to both sF and pF.”

### 4THDISK Variant

`4THDISK` and related files are `4,976,640` bytes (`4860 * 1024`), indicating an additional 60 blocks versus the 4800 project media.

### Block Content Characteristics

- `*.src` / `Project` style files present as fixed-length block text (classic FORTH block media, not line-oriented source).
- Some media (`pFDISK.blk`) are tokenized/binary dictionary data.
- `4THDISK` contains plain FORTH text in specific blocks (for example, block 792 in README discussion).

## How Project Selection Works

The `arrayForth 3 *.lnk` files embed startup include directives for `../Projects/<name>/custom.txt`.

Then `custom.txt` defines:

- project directory symbol (`PROJDIR`)
- serial port assignments (`A-COM`, `B-COM`, etc.)
- logical media mappings via `CALLED"` to source/backup/object/concordance files
- writable flags and transition into `AFORTH`

In practice, this is the binding layer between the host executable and the selected on-disk project corpus.

## Operational Notes and Risks

- The host executable depends on 32-bit userspace libraries on modern Debian/Ubuntu.
- [af3/WARNING](/home/cartheur/ame/aiventure/aiventure-github/volatco/saneForth/af3/WARNING) notes a Debian Trixie `ld-linux.so.2` mapping anomaly with a hole in expected `.bss`.
- Serial device naming (`ttyUSB0` vs `ttyUSB1`) is documented as an active operational pain point.

## Practical Orientation For New Work

If you need to make user-visible changes:

1. Pick project: `VOLATCO` or `DEFAULT`.
2. Edit the project media through the running FORTH environment (not by normal text editing).
3. Keep `custom.txt` and launcher/profile settings aligned to your local serial topology.
4. Use notes/log files as the source of truth for board-specific bring-up behavior.

If you need modern developer ergonomics (diffs, CI, code review), this repo would need an export/import pipeline that converts block images to canonical text.
