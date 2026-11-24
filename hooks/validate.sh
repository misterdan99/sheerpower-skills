# validate.sh -- the Linux twin of validate.ps1: Claude Code's PostToolUse hook of the sheerpower plugin.
# After Claude edits or writes a .spsrc or .spinc file, compile it with  sp4gl <file> /validate  and hand the
# compiler's errors back to Claude, as a JSON "block" decision (see hook_common.sh for why not exit 2).
# A clean compile, a file of another kind, or a machine without sp4gl says nothing.
. "$(dirname "$0")/hook_common.sh"
only_on_linux
max_report_chars=8000

hook_input=$(cat)
edited_path=$(json_field file_path)
[ -n "$edited_path" ] || exit 0
case "$edited_path" in
  /*) ;;
  *) hook_cwd=$(json_field cwd); [ -n "$hook_cwd" ] && edited_path="$hook_cwd/$edited_path" ;;
esac
extension=$(printf '%s' "${edited_path##*.}" | tr 'A-Z' 'a-z')
case "$extension" in
  spsrc|spinc) ;;
  *) exit 0 ;;
esac
[ -f "$edited_path" ] || exit 0
command -v sp4gl > /dev/null 2>&1 || exit 0

# An include file alone reports the names its including program provides as errors,
# so compile a program in the same folder that includes it, when there is one
edited_folder=$(dirname "$edited_path")
compile_path=$edited_path
include_note=''
if [ "$extension" = spinc ]; then
  include_name=$(basename "$edited_path")
  include_name=${include_name%.*}
  includer=$(grep -l -i -E "^[[:space:]]*%include.*$include_name" "$edited_folder"/*.spsrc 2> /dev/null | head -n 1)
  if [ -n "$includer" ]; then
    compile_path=$includer
    include_note="(compiled through $(basename "$includer"), which includes it)"
  else
    include_note="(an include file compiled by itself: an 'Unassigned variable' or 'Label not found' line may name something the including program provides)"
  fi
fi

use_own_cmds_file
compiler_lines=$(sp4gl "$compile_path" /validate 2>&1)
compile_status=$?
[ "$compile_status" -eq 0 ] && exit 0

edited_name=$(basename "$edited_path")
folder_pattern=$(printf '%s/' "$edited_folder" | sed 's/[][\.*^$|]/\\&/g')
found=$(printf '%s\n' "$compiler_lines" | grep -v -E '^\$info \|(Build of|Generated )' | grep -v '^[[:space:]]*$' |
  sed "s|$folder_pattern||g")
[ -n "$found" ] || found="sp4gl exited with status $compile_status and printed nothing."
report=$(printf 'sp4gl /validate found errors in %s %s\n%s\nFix these before going on; the file is compiled again after your next edit.' \
  "$edited_name" "$include_note" "$found")
if [ "${#report}" -gt "$max_report_chars" ]; then
  report="$(printf '%s' "$report" | head -c "$max_report_chars")
(more errors were cut)"
fi
printf '{"decision":"block","reason":"%s"}\n' "$(printf '%s' "$report" | json_escape)"
exit 0
