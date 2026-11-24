---
name: run
description: Run a Sheerpower program. Given a program, compile it and open it in its own console window for the user to use, then report how it ended. Given a program and an answers file, run it headless (no window) with the answers typed in and report what it printed, its exit code and any error. Given nothing, open the Sheerpower console.
argument-hint: "[program.spsrc] [answers file]"
---

# Run a Sheerpower program

What `$ARGUMENTS` holds decides the form:

| The user typed | What happens |
|---|---|
| `/sheerpower:run game.spsrc` | compile it, then open it in its own window: the user types there |
| `/sheerpower:run` | open the Sheerpower console for the user |
| `/sheerpower:run game.spsrc answers.txt` | compile it, run it headless with answers.txt typed in, report the output |

A window opens on the USER's screen: open one only when the user asked to use the program or the console.  When you
test a program yourself, always use the headless form -- with an answers file, or `nul` for none.

The program must not be in a temporary folder: sp4gl refuses to run a program from one.

**On Linux** there is no Sheerpower window: a program and the console run in a terminal.  The headless form below
works the same, with `sp4gl` run directly (no `cmd /c`) and `< /dev/null` for no input.  For a program the user
wants to use, or the console, the plugin's hook leaves a note (**LINUX**): tell the user to type `sp4gl
<program>` (or `sp4gl` alone, for the console) in a terminal of their own -- you cannot type into it for them --
and offer the headless run when they want you to test it.

## A program in its own window (a program, no answers file)

When the user types `/sheerpower:run <program>`, the plugin's hook acts the moment they press Enter (a Sheerpower
compile takes a fraction of a second) and leaves a note saying what it did:
- **ALREADY OPENED** -- it compiled clean and its window is open.  Do not start it again: run the note's
  `run_window.ps1 -wait` command IN THE BACKGROUND (`run_in_background`), tell the user in one short line that it is
  running in its own window, where they type, and report when the background command finishes (step 3).
- **COMPILE FAILED** -- no window was opened; the compiler's messages are in the note.  Handle them as
  `COMPILE FAILED` in step 3.
- **NO PROGRAM** -- tell the user; you may list the `.spsrc` files in that folder whose names are close.

Without a note (the hook did not run):

1. Start it IN THE BACKGROUND (`run_in_background`), so the conversation goes on while the user works in the window,
   with the script `run_window.ps1` in this skill's folder -- one command does it all:
   `powershell -NoProfile -ExecutionPolicy Bypass -File "<this skill's folder>\run_window.ps1" "<the program as typed>"`
   It adds `.spsrc` to a name without an extension, compiles the program, and only when it builds clean opens it in
   its own Sheerpower window (in the program's folder) and waits until the window closes.
2. Tell the user it will open in its own window, where they type; you will hear when it ends.
3. When the background command finishes, read its output and report:
   - `NOT FOUND` -- there is no such program (`.spsrc` was tried too).  Say so; you may list the `.spsrc` files in
     that folder whose names are close.
   - `COMPILE FAILED` -- the compiler's messages follow; no window was opened.  Show the user each error (line,
     message, the `Help>>` advice) and the fix you suggest, then ASK before changing their file.  Edit it only
     when they say yes, then run it again.
   - `ENDED` -- the program finished (or the user closed its window).
   - `ENDED WITH AN ERROR` -- the error file's first lines follow: the message, the failing line and the variables.
     Explain the cause in plain words and offer the fix -- again, ask before changing their file.
   A program WITHOUT `option abort` that stops on an error keeps its window open, with the message at the console
   prompt, until the user closes it; its window title names the error.

## The console (nothing given)

When the user types `/sheerpower:run` alone, the plugin's hook opens the console the moment they press Enter and
leaves a note saying so.  With that note, do NOT open it again: tell the user in one short line that the Sheerpower
REPL console is open.  Without it (the hook did not run), run
`powershell -NoProfile -ExecutionPolicy Bypass -File "<this skill's folder>\run_window.ps1"` (no program): it opens
the console in the current folder and returns at once.  Tell the user it is open: at its prompt a statement runs as
soon as it is entered, and `run 'game.spsrc'` runs a program.

## Headless, with an answers file (a program and an answers file)

1. A name without an extension gets `.spsrc`.  Compile first: `cmd /c "sp4gl <program> /validate 2>&1"` (Linux: `sp4gl <program> /validate 2>&1`).  On errors,
   show them with the fix you suggest and ask before changing the user's file, as above.
2. Run: PowerShell `cmd /c "sp4gl <program> /headless < <answers file> 2>&1"`; Bash `cmd //c "..."`; Linux `sp4gl <program> /headless < <answers file> 2>&1`.  Each line of
   the answers file is typed in at the next prompt.  Never leave out `/headless` here: that opens a window.  A program
   without `option abort` that hits an uncaught exception waits for console input -- add `option abort`.
3. Exit code: 0 ended normally, `abort n` gives n, 1 = an uncaught exception.  On 1, read the newest
   `<program>_error_<timestamp>.txt` beside the program: it names the failing statement and shows the variables.
   Under /headless each input prompt shows in the output with `? ` and the answer echoed.
4. Report the output, the exit code and, on a failure, the cause from the error file.
