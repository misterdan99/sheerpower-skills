# run_now.ps1 -- the UserPromptExpansion hook for /sheerpower:run: act the moment the user presses Enter, before
# Claude's turn (asked 2026-10-14: "when they type -- /sheerpower:run -- can we give immediate feedback that
# something is happening.  It took 5 seconds for the REPL console to come up", and "remember that sheerpower compiles
# at very high speeds.  Even a 1 second compile time would be rare").
#   /sheerpower:run                   open the Sheerpower REPL console now, in the session's folder
#   /sheerpower:run <program>         compile it now (.spsrc added to a name without an extension) and, when it
#                                     builds clean, open it in its own window now; Claude only waits for the end
#   /sheerpower:run <program> <file>  the headless test run: left to Claude, which reports what it printed
# Each case leaves Claude a note (additionalContext) saying what was done.  The input is one JSON object on stdin:
# command_name, command_args, cwd.  Nothing here may fail the prompt: any problem says nothing and leaves the work to
# the run skill.
try {
    $hook_input = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch {
    exit 0
}
if (-not (Get-Command sp4gl.exe -ErrorAction SilentlyContinue)) { exit 0 }
# A Linux session (WSL, whose PATH can reach Windows PowerShell): run_now.sh answers there -- never open a Windows
# console for it
if (([string]$hook_input.cwd).StartsWith('/')) { exit 0 }

$arguments = ([string]$hook_input.command_args).Trim()
$folder = [string]$hook_input.cwd
if (-not $folder -or -not (Test-Path -LiteralPath $folder -PathType Container)) { $folder = (Get-Location).Path }
$script_folder = Join-Path (Split-Path -Parent $PSScriptRoot) 'skills\run'

function reply($message, $note) {
    $answer = @{ systemMessage = $message }
    if ($note) {
        $answer.hookSpecificOutput = @{ hookEventName = 'UserPromptExpansion'; additionalContext = $note }
    }
    $answer | ConvertTo-Json -Compress -Depth 4
    exit 0
}

# ---------------------------------------------------------------- the console
if (-not $arguments) {
    try {
        Start-Process -FilePath 'sp4gl.exe' -WorkingDirectory $folder
    } catch {
        exit 0
    }
    reply 'Opening the Sheerpower REPL console...' ('The sheerpower plugin hook has ALREADY OPENED the Sheerpower REPL ' +
        'console in ' + $folder + ' -- do not open it again.  Tell the user in one short line that it is open.')
}

# ---------------------------------------------------------------- the program, and an answers file if one was given
if ($arguments.StartsWith('"')) {
    $closing = $arguments.IndexOf('"', 1)
    if ($closing -lt 0) { exit 0 }
    $program = $arguments.Substring(1, $closing - 1)
    $rest = $arguments.Substring($closing + 1).Trim()
} else {
    $words = @($arguments -split '\s+', 2)
    $program = $words[0]
    $rest = if ($words.Count -gt 1) { $words[1].Trim() } else { '' }
}
if ($rest) {
    reply ('Running ' + $program + ' without a window, on the answers in ' + $rest + '...') $null
}

if (-not [IO.Path]::IsPathRooted($program)) { $program = Join-Path $folder $program }
if (-not (Test-Path -LiteralPath $program -PathType Leaf) -and -not [IO.Path]::GetExtension($program)) {
    $program = $program + '.spsrc'
}
if (-not (Test-Path -LiteralPath $program -PathType Leaf)) {
    reply ('There is no program ' + $program + '.') ('The sheerpower plugin hook found NO PROGRAM ' + $program +
        ' (.spsrc was tried too); nothing was opened.  Tell the user; you may list the .spsrc files in that folder ' +
        'whose names are close.')
}
$program = (Resolve-Path -LiteralPath $program).Path
$name = Split-Path -Leaf $program

$compile_text = (cmd /c ('sp4gl "' + $program + '" /validate 2>&1')) -join "`n"
if ($LASTEXITCODE -ne 0) {
    reply ($name + ' did not compile -- nothing was opened.') ('The sheerpower plugin hook compiled ' + $program +
        ': COMPILE FAILED, so no window was opened.  The compiler said:' + "`n" + $compile_text + "`n" +
        'Show the user each error (line, message, the Help>> advice) and the fix you suggest, then ASK before ' +
        'changing their file.  Do not start the program now.')
}

try {
    Start-Process -FilePath 'sp4gl.exe' -ArgumentList ('"' + $program + '"') -WorkingDirectory (Split-Path -Parent $program)
} catch {
    exit 0
}
reply ('Running ' + $name + ' in its own window...') ('The sheerpower plugin hook compiled ' + $program + ' clean and ' +
    'has ALREADY OPENED it in its own window -- do not start it again.  Run IN THE BACKGROUND (run_in_background): ' +
    'powershell -NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $script_folder 'run_window.ps1') + '" -wait "' +
    $program + '" -- it waits until that window closes and reports how the program ended.  Tell the user in one ' +
    'short line that it is running in its own window, where they type.')
