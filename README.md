# Sheerpower plugin for Claude Code

Helps Claude write, compile and fix Sheerpower 4GL programs on Windows and Linux.

## What it does

- **A compile check after every edit.**  Each time Claude edits or writes a `.spsrc` or `.spinc` file,
  `sp4gl <file> /validate` runs and any errors -- with the compiler's own `Help>>` advice -- go straight
  back to Claude, which fixes them before going on.  An include file is compiled through the program that
  includes it.
- **The language rules** (`sheerpower:language`): the habits from other languages that do not compile in
  Sheerpower, the program shape, routines, text, numbers, arrays and clusters, exceptions and files, each
  with samples that were compiled and run on the engine.
- **A catalog to look things up** (`/sheerpower:help`): every statement and function from the
  Sheerpower tutorial with its form, its meaning and a verified example with its real output, a task index,
  and the known traps.
- **Commands you can type**: `/sheerpower:help` (a name looked up; with nothing after it, the list of commands),
  `/sheerpower:new` (a new program in house style), `/sheerpower:validate` (compile and fix until clean), and
  `/sheerpower:run`:
  - `/sheerpower:run game.spsrc` -- compiles the program and opens it in its own window, where you use it;
    when it ends, Claude says how, and why if it stopped on an error.
  - `/sheerpower:run` -- opens the Sheerpower REPL console, to try statements, write short programs and run programs.
  - `/sheerpower:run game.spsrc answers.txt` -- for testing: runs it without a window, types the answers file in,
    and reports what it printed, its exit code and any error.
- **A note at session start** saying where sp4gl is and when it was built.

## Requirements

- Windows, with `sp4gl.exe` on the PATH (Sheerpower installs it in `C:\Sheerpower`), and Windows PowerShell (part
  of Windows) for the hooks; or
- Linux, with `sp4gl` on the PATH (the Sheerpower .deb installs it) and `/bin/sh` for the hooks.  On Linux a
  program and the console run in a terminal of your own (`sp4gl game.spsrc`); `/sheerpower:run` compiles the
  program and says so.  Claude Code may show a "hook error" line for the plugin's Windows hooks there: they cannot
  start without Windows PowerShell, and the Linux hooks do the work.
- Claude Code 2.1.296 or later.

## Install

```
/plugin marketplace add https://learnsheerpower.ttinet.com/marketplace.json
/plugin install sheerpower@sheerpower
```
