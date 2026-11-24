---
name: validate
description: Compile a Sheerpower program with sp4gl /validate and fix every error until it builds clean.
argument-hint: [program.spsrc]
---

# Validate a Sheerpower program

1. The file: `$ARGUMENTS`, or the .spsrc file this conversation is working on.  For a .spinc include file,
   compile the program that includes it (an include alone reports the names its program provides as errors).
2. Compile: on Windows, PowerShell `cmd /c "sp4gl <file> /validate 2>&1"`, Bash `cmd //c "sp4gl <file> /validate
   2>&1"`; on Linux, `sp4gl <file> /validate 2>&1`.
   Exit code 0 = clean, 1 = errors.
3. Each error is `$error |file |line |column | message`, usually followed by `$info | Help>>` or `Fix>>`
   with the right form.  Fix the FIRST error first (later ones often follow from it); load
   **sheerpower:language** and check **sheerpower:help** rather than guessing.
4. Compile again until clean.  Report what was wrong and what changed.
