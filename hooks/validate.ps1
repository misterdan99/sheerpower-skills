# validate.ps1 -- Claude Code PostToolUse hook of the sheerpower plugin.
# After Claude edits or writes a .spsrc or .spinc file, compile it with  sp4gl <file> /validate
# and hand the compiler's errors back to Claude: exit code 2 with the errors on stderr.
# A clean compile, a file of another kind, or a machine without sp4gl says nothing (exit 0).

$ErrorActionPreference = 'Stop'
$max_report_chars = 8000

# The hook's input is one JSON object on stdin; tool_input.file_path names the file just changed
try {
  $hook_input = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch {
  exit 0
}
# A Linux session (WSL, whose PATH can reach Windows PowerShell): validate.sh does the work there
if (([string]$hook_input.cwd).StartsWith('/')) { exit 0 }
$edited_path = [string]$hook_input.tool_input.file_path
if (-not $edited_path) { exit 0 }
if (-not [IO.Path]::IsPathRooted($edited_path) -and $hook_input.cwd) {
  $edited_path = Join-Path ([string]$hook_input.cwd) $edited_path
}
$extension = [IO.Path]::GetExtension($edited_path).ToLower()
if ($extension -ne '.spsrc' -and $extension -ne '.spinc') { exit 0 }
if (-not (Test-Path -LiteralPath $edited_path -PathType Leaf)) { exit 0 }
if (-not (Get-Command sp4gl.exe -ErrorAction SilentlyContinue)) { exit 0 }

# An include file alone reports the names its including program provides as errors,
# so compile a program in the same folder that includes it, when there is one
$edited_folder = Split-Path -Parent $edited_path
$compile_path = $edited_path
$include_note = ''
if ($extension -eq '.spinc') {
  $include_name = [IO.Path]::GetFileNameWithoutExtension($edited_path)
  $include_pattern = '^\s*%include\b.*\b' + [regex]::Escape($include_name) + '\b'
  $includer = Get-ChildItem -LiteralPath $edited_folder -Filter *.spsrc -File -ErrorAction SilentlyContinue |
    Where-Object { Select-String -LiteralPath $_.FullName -Pattern $include_pattern -Quiet } |
    Select-Object -First 1
  if ($includer) {
    $compile_path = $includer.FullName
    $include_note = "(compiled through $($includer.Name), which includes it)"
  } else {
    $include_note = "(an include file compiled by itself: an 'Unassigned variable' or 'Label not found' line may name something the including program provides)"
  }
}

# A console session started without SHEERPOWER_CMDS rewrites the developer's command history file
# when it exits; /validate starts none, but name a file of the plugin's own to be sure
if (-not $env:SHEERPOWER_CMDS) {
  $data_folder = $env:CLAUDE_PLUGIN_DATA
  if (-not $data_folder) { $data_folder = $env:TEMP }
  $env:SHEERPOWER_CMDS = Join-Path $data_folder 'sp4gl_cmds_hook.txt'
}

# sp4gl writes its messages only when cmd.exe runs it; called directly it hands off and returns at once
$compiler_lines = & cmd.exe /d /c sp4gl $compile_path /validate '2>&1'
$compile_status = $LASTEXITCODE
if ($compile_status -eq 0) { exit 0 }

$edited_name = [IO.Path]::GetFileName($edited_path)
$report = New-Object System.Collections.Generic.List[string]
$report.Add(("sp4gl /validate found errors in $edited_name $include_note").Trim())
foreach ($compiler_line in $compiler_lines) {
  $text = [string]$compiler_line
  if ($text -match '^\$info \|(Build of|Generated )') { continue }
  if ($text.Trim() -eq '') { continue }
  $report.Add($text.Replace($edited_folder + '\', ''))
}
if ($report.Count -eq 1) {
  $report.Add("sp4gl exited with status $compile_status and printed nothing.")
}
$report.Add('Fix these before going on; the file is compiled again after your next edit.')
$message = $report -join "`n"
if ($message.Length -gt $max_report_chars) {
  $message = $message.Substring(0, $max_report_chars) + "`n(more errors were cut)"
}
[Console]::Error.WriteLine($message)
exit 2
