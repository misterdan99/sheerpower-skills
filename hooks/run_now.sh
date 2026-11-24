# run_now.sh -- the Linux twin of run_now.ps1: the UserPromptExpansion hook for /sheerpower:run.  Linux has no
# Sheerpower window -- a program and the console run in a terminal -- so the hook opens nothing:
#   /sheerpower:run                   a note: the user types  sp4gl  in a terminal of their own
#   /sheerpower:run <program>         compile it now (.spsrc added to a name without an extension); a note: COMPILE
#                                     FAILED with the compiler's messages, or clean -- the user types  sp4gl <program>
#   /sheerpower:run <program> <file>  the headless test run: left to Claude, which reports what it printed
# The input is one JSON object on stdin: command_name, command_args, cwd.  Nothing here may fail the prompt.
. "$(dirname "$0")/hook_common.sh"
only_on_linux
command -v sp4gl > /dev/null 2>&1 || exit 0

hook_input=$(cat)
arguments=$(json_field command_args | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
folder=$(json_field cwd)
[ -n "$folder" ] && [ -d "$folder" ] || folder=$(pwd)

reply() {
  if [ -n "$2" ]; then
    printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"UserPromptExpansion","additionalContext":"%s"}}\n' \
      "$(printf '%s' "$1" | json_escape)" "$(printf '%s' "$2" | json_escape)"
  else
    printf '{"systemMessage":"%s"}\n' "$(printf '%s' "$1" | json_escape)"
  fi
  exit 0
}

# ---------------------------------------------------------------- the console
if [ -z "$arguments" ]; then
  reply 'On Linux the Sheerpower console runs in a terminal: type  sp4gl  in a terminal of your own.' \
    "The sheerpower plugin hook (LINUX): there is no Sheerpower window on Linux, so nothing was opened.  Tell the user in one short line to type  sp4gl  in a terminal of their own (in $folder) to open the REPL console."
fi

# ---------------------------------------------------------------- the program, and an answers file if one was given
case "$arguments" in
  \"*)
    program=${arguments#\"}
    program=${program%%\"*}
    rest=${arguments#\""$program"\"}
    ;;
  *)
    program=${arguments%%[[:space:]]*}
    rest=${arguments#"$program"}
    ;;
esac
rest=$(printf '%s' "$rest" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
if [ -n "$rest" ]; then
  reply "Running $program without a window, on the answers in $rest..." ''
fi

case "$program" in
  /*) ;;
  *) program="$folder/$program" ;;
esac
if [ ! -f "$program" ]; then
  case "${program##*/}" in
    *.*) ;;
    *) program="$program.spsrc" ;;
  esac
fi
if [ ! -f "$program" ]; then
  reply "There is no program $program." \
    "The sheerpower plugin hook found NO PROGRAM $program (.spsrc was tried too); nothing was run.  Tell the user; you may list the .spsrc files in that folder whose names are close."
fi
name=$(basename "$program")

use_own_cmds_file
compile_text=$(sp4gl "$program" /validate 2>&1)
if [ $? -ne 0 ]; then
  reply "$name did not compile." "The sheerpower plugin hook compiled $program: COMPILE FAILED.  The compiler said:
$compile_text
Show the user each error (line, message, the Help>> advice) and the fix you suggest, then ASK before changing their file.  Do not start the program now."
fi
reply "$name compiled clean -- on Linux it runs in a terminal of your own:  sp4gl $program" \
  "The sheerpower plugin hook (LINUX) compiled $program clean.  There is no Sheerpower window on Linux, so nothing was started: tell the user in one short line to type  sp4gl $program  in a terminal of their own, where they use it, and offer a headless test run (/sheerpower:run $name <answers file>) if they want you to try it."
