# hook_common.sh -- shared by the sheerpower plugin's Linux hooks (validate.sh, session_start.sh, run_now.sh).
# hooks.json runs each hook as  echo "$(sh "<plugin>/hooks/<name>.sh")"  so one entry works everywhere: sh -c runs it
# on Linux; on Windows, Git Bash runs it and it stops at once (the .ps1 hooks do the work there), and Windows
# PowerShell, when Git Bash is missing, finds no sh and exits 0.  The wrapper hides the exit code, so a hook answers
# Claude Code with JSON on stdout and exits 0.

# Only on Linux; anywhere else the PowerShell hooks do the work
only_on_linux() {
  case "$(uname -s 2>/dev/null)" in
    Linux) ;;
    *) exit 0 ;;
  esac
}

# json_field <key>: the unescaped string value of "<key>": "..." in $hook_input (one key per hook input)
json_field() {
  printf '%s' "$hook_input" | tr '\n' ' ' |
    sed -n -E 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' | head -n 1 |
    sed -e 's/\\"/"/g' -e 's/\\\//\//g' -e 's/\\\\/\\/g'
}

# json_escape: stdin as the body of a JSON string (no quotes around it).  Only \u escapes: dash's echo -- the wrapper's
# echo on Ubuntu and Debian -- turns \n, \t and \\ into the characters themselves, but leaves \u alone
json_escape() {
  tr -d '\r' | tr '\t' ' ' | tr -d '\000-\010\013\014\016-\037' |
    sed -e 's/\\/\\u005c/g' -e 's/"/\\u0022/g' |
    awk 'NR > 1 { printf "\\u000a" } { printf "%s", $0 }'
}

# A console session started without SHEERPOWER_CMDS rewrites the developer's command history file when it exits;
# /validate starts none, but name a file of the plugin's own to be sure
use_own_cmds_file() {
  if [ -z "$SHEERPOWER_CMDS" ]; then
    data_folder=${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}}
    mkdir -p "$data_folder" 2>/dev/null
    SHEERPOWER_CMDS="$data_folder/sp4gl_cmds_hook.txt"
    export SHEERPOWER_CMDS
  fi
}
