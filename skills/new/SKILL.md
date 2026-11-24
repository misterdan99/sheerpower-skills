---
name: new
description: Create a new Sheerpower console program in house style, compiled clean before it is handed over.
argument-hint: <program_name> <what the program should do>
disable-model-invocation: true
---

# New Sheerpower program: $ARGUMENTS

1. Load the **sheerpower:language** skill if it is not loaded yet; use **sheerpower:help** for any
   statement or function you are not sure of.
2. Write `<program_name>.spsrc` in the current folder (never in a temporary folder):
   - a first comment line naming the file and saying what the program does;
   - `option abort`;
   - named constants (`const`) for every fixed number or text;
   - the main code, short, calling routines whose names have an underscore;
   - the routines below the main code, callers before callees, each with a header comment: a border line,
     the name spaced out, then Brief description / Expected on entry / Locals used / Results on exit.
   - REAL (bare names) for every number; clusters rather than parallel arrays.
3. Compile: `cmd /c "sp4gl <program_name>.spsrc /validate 2>&1"` (Bash: `cmd //c ...`) until it is clean; on
   Linux, `sp4gl <program_name>.spsrc /validate 2>&1`.
4. If the program needs no input, run it once headless (`cmd /c "sp4gl <program_name>.spsrc /headless < nul
   2>&1"`; on Linux `sp4gl <program_name>.spsrc /headless < /dev/null 2>&1`) and check what it printed; if it
   reads input, run it with a small input file.
5. Report the file, what it does, and the output of the run.
