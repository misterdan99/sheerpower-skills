---
name: help
description: Sheerpower help -- look up a Sheerpower statement, function, option or task in a catalog built from the Sheerpower tutorial and proven on the engine -- the exact form to write, what it does, a verified example with its real output, and the known traps. Use it before writing a Sheerpower statement or function you are not sure of, when the compiler refuses a form, or to find which built-in does a job. Typed with nothing after it, it lists the plugin's commands.
argument-hint: [statement, function or task]
---

# Sheerpower help

## Typed with nothing: the plugin's commands

When `$ARGUMENTS` is empty, show the user this list and stop:

| Command | What it does |
|---|---|
| `/sheerpower:help <name or task>` | the form to write, what it does, a verified example with its real output, and the known traps |
| `/sheerpower:new <program name> <what it should do>` | writes a new program in house style and compiles it clean |
| `/sheerpower:validate <file>` | compiles a program and fixes every error until it builds clean |
| `/sheerpower:run <program>` | compiles it and opens it in its own window, where you use it; Claude reports how it ended |
| `/sheerpower:run` | opens the Sheerpower REPL console: try statements, write short programs, run programs |
| `/sheerpower:run <program> <answers file>` | for testing: runs it without a window, types the answers in, reports what it printed |

Or just ask in plain words.  Every edit of a `.spsrc` or `.spinc` file is compiled for you.

## Given a name or a task: the catalog

Four files sit in `data/` beside this SKILL.md.  Every example in them was run on the engine and shows the
output it really printed; every wrong form in traps.md was compiled and shows the compiler's real message.

| File | Size | How to use it |
|---|---|---|
| `data/task_index.md` | 10 KB | READ IT WHOLE first when you know the job but not the name: "convert between text and numbers" -> `val()`, `str$()`, `sprintf$()` |
| `data/catalog_index.md` | about 160 KB | NEVER read it whole -- Grep it for `**name**` (e.g. `\*\*findrow`) or a word of the meaning |
| `data/traps.md` | about 40 KB | Grep it for the statement you are about to write: wrong forms with the compiler's message and the right form; silent traps with their real output; other languages' function names and keywords with the Sheerpower one |
| `data/examples_verified.txt` | about 750 KB | Grep `==== x0364` (the id from catalog_index.md) with about 30 lines of context: the example program, then `---- output` and what it printed |

## The steps

1. Know the job, not the name: read `data/task_index.md`, pick the names.
2. For each name: Grep `data/catalog_index.md` for the name.  A line reads
   `- **name** | form | meaning | page:line | example id | PROOF | !`.
3. If the line ends with `!`, Grep `data/traps.md` for the name before writing it.
4. To see it used: Grep `data/examples_verified.txt` for `==== <example id>` with context lines.
5. Write the code, compile it (`/validate`), and believe the compiler over any text.

When the user asked (`/sheerpower:help <name>`), answer with the form to write, what it does, how far it is proven,
a verified example with the output it printed, and any trap -- short, and only what the catalog shows.

## Trusting a line: the PROOF letters

`R` an example ran and its output is shown; `P`, `S`, `W` the maker's own tests run it on every engine
build; `s`, `N`, `C`, `X` weaker evidence; `-` the tutorial's word only.  A name with no `R`, `P`, `S` or `W`
deserves a five-line probe program, compiled and run, before you build on it.

## Grep patterns that work

- A function: `\*\*sprintf\$\(\)` -- the `$` and `(` need a backslash in a regular expression.
- A statement: `\*\*collect cluster`, `\*\*when exception`.
- A meaning: `-i "day of the week"` across `data/catalog_index.md`.
- A foreign name in traps.md: `strlen`, `substr`, `elif`, `try`, `foreach` -> the Sheerpower spelling.
