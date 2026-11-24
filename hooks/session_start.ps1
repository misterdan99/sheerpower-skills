# session_start.ps1 -- Claude Code SessionStart hook of the sheerpower plugin.
# Tells Claude, in two lines added to its context, whether sp4gl is on this machine and which of
# the plugin's skills to load before it writes Sheerpower code.

# A Linux session (WSL, whose PATH can reach Windows PowerShell): session_start.sh does the work there
try {
  $hook_input = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch {
  $hook_input = $null
}
if ($hook_input -and ([string]$hook_input.cwd).StartsWith('/')) { exit 0 }

# The engine this plugin's knowledge was proven on
$proven_engine = 'V011.032.14'
$proven_engine_date = [datetime]'2026-11-23'

$sp4gl = Get-Command sp4gl.exe -ErrorAction SilentlyContinue
if (-not $sp4gl) {
  Write-Output 'Sheerpower plugin: sp4gl.exe is not on the PATH, so Sheerpower programs cannot be compiled or run here. Before writing Sheerpower code (.spsrc, .spinc), load the sheerpower:language skill.'
  exit 0
}

$engine_date = (Get-Item -LiteralPath $sp4gl.Source).LastWriteTime
Write-Output ("Sheerpower plugin: sp4gl is {0}, dated {1:yyyy-MM-dd}. Before writing, changing or reviewing Sheerpower code (.spsrc, .spinc), load the sheerpower:language skill, and look names up with sheerpower:help. Every edit of a .spsrc or .spinc file is compiled for you; errors come back as hook feedback." -f $sp4gl.Source, $engine_date)
if ($engine_date -lt $proven_engine_date) {
  Write-Output ("This sp4gl is older than the {0} engine of {1:yyyy-MM-dd} the plugin was proven on, so a feature the skills describe may be missing here; the compiler has the last word." -f $proven_engine, $proven_engine_date)
}
exit 0
