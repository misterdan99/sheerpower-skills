# session_start.sh -- the Linux twin of session_start.ps1: Claude Code's SessionStart hook of the sheerpower plugin.
# Tells Claude, in a few lines added to its context, whether sp4gl is on this machine, how to call it on Linux, and
# which of the plugin's skills to load before it writes Sheerpower code.
. "$(dirname "$0")/hook_common.sh"
only_on_linux

# The engine this plugin's knowledge was proven on
proven_engine='V011.032.14'
proven_engine_date='2026-11-23'

sp4gl_path=$(command -v sp4gl 2> /dev/null)
if [ -z "$sp4gl_path" ]; then
  echo 'Sheerpower plugin: sp4gl is not on the PATH, so Sheerpower programs cannot be compiled or run here. Before writing Sheerpower code (.spsrc, .spinc), load the sheerpower:language skill.'
  exit 0
fi
engine_file=$(readlink -f "$sp4gl_path" 2> /dev/null)
[ -n "$engine_file" ] || engine_file=$sp4gl_path
engine_date=$(date -r "$engine_file" +%Y-%m-%d 2> /dev/null)
echo "Sheerpower plugin: sp4gl is $sp4gl_path, dated $engine_date. This is Linux: call sp4gl directly (no cmd /c) -- sp4gl <file> /validate 2>&1 to compile, sp4gl <file> /headless < /dev/null 2>&1 to test. Before writing, changing or reviewing Sheerpower code (.spsrc, .spinc), load the sheerpower:language skill, and look names up with sheerpower:help. Every edit of a .spsrc or .spinc file is compiled for you; errors come back as hook feedback."
if [ -n "$engine_date" ] && [ "$engine_date" != "$proven_engine_date" ]; then
  earlier=$(printf '%s\n%s\n' "$engine_date" "$proven_engine_date" | sort | head -n 1)
  if [ "$earlier" = "$engine_date" ]; then
    echo "This sp4gl is older than the $proven_engine engine of $proven_engine_date the plugin was proven on, so a feature the skills describe may be missing here; the compiler has the last word."
  fi
fi
exit 0
