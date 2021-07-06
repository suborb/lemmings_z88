# Lemmings z88

This repository contains the source code for the z88 port of ZX Spectrum version of Lemmings.

## Compilation

To compile you'll need a modern version of z88dk setup and
available in the path. The application can then be generated
by invoking `make`.

An .epr file for burning to EPROM and a .app file for installing using OZ5 is generated.

## Background

The source code is pretty much as it was when released in 2000, so
contains (amongst other things):

- Wonky whitespace
- Commented out code
- Cryptic labels
- Development comments/queries from the disassembly
- False comments

The following changes have been made:

- Update to assemble with the version of z80asm within z88dk
- Updates to remove old email addresses
- Updates to fix some typos

As a result, the version has been bumped.

## Controls

The following keys are available during the game:

```
1       - Decrease release rate
2       - Increase release rate
3-0     - Select Lemming types

ESC     - Armageddon!!!
<       - Scroll level left
>       - Scroll level right

Q       - Cursor Up
A       - Cursor Down
O       - Cursor Left
P       - Cursor Right
[SPACE] - Select Lemming
M       - Track Lemming
H       - Pause
```

## Samples

The samples were originally sourced from the Amiga version of Lemmings and then
processed to run on a beeper. Unfortunately I've no memory of what tools I used
to achieve this.

## Levels

Again I can't remember how these were processed - extracted from tape, run through ZIP and the PK header removed from vague memory.

## Acknowledgements

The ZX Spectrum version of Lemmings was originally published by Psygnosis.

The decompression code used was written Garry Lancaster.




