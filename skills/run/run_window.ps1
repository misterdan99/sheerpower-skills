# run_window.ps1 -- compile a Sheerpower program and run it in its own console window for the user, wait until that
# window closes, then say how the program ended.  With no program, open the Sheerpower console and return at once.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File run_window.ps1 [<program>]
#   powershell -NoProfile -ExecutionPolicy Bypass -File run_window.ps1 -wait <program>
#
# A program named without an extension gets .spsrc (asked 2026-10-14: "do 1 and 2, and ask before fixing
# errors" -- 1: c:\sheerpower\samples\fib is fib.spsrc; 2: compile and start in one step).  -wait: the plugin's run
# hook has already compiled the program and opened its window -- only wait for that window to close.  Prints one of:
#   NOT FOUND           no such program (exit 3)
#   COMPILE FAILED      the compiler's messages follow; no window was opened (exit 2)
#   ENDED               the window closed and no error file was written (exit 0)
#   ENDED WITH AN ERROR the error file's first lines follow (exit 1)
# sp4gl started in a window may hand the window to a second sp4gl process, so the wait is for every sp4gl started
# since then whose command line names the program.
param([string]$program, [switch]$wait)

if (-not $program) {
    Start-Process -FilePath 'sp4gl.exe' -WorkingDirectory (Get-Location).Path
    'CONSOLE OPENED in ' + (Get-Location).Path
    exit 0
}

$program = $program.Trim('"', "'", ' ')
if (-not (Test-Path -LiteralPath $program -PathType Leaf) -and -not [IO.Path]::GetExtension($program)) {
    $program = $program + '.spsrc'
}
if (-not (Test-Path -LiteralPath $program -PathType Leaf)) {
    'NOT FOUND -- no program ' + $program
    exit 3
}
$program = (Resolve-Path -LiteralPath $program).Path
$folder = Split-Path -Parent $program
$base_name = [IO.Path]::GetFileNameWithoutExtension($program)
$wanted = $program.ToLower()

function window_processes($since) {
    @(Get-CimInstance Win32_Process -Filter "Name='sp4gl.exe'" | Where-Object {
        $_.CommandLine -and $_.CommandLine.ToLower().Contains($wanted) -and $_.CommandLine -notmatch '/validate' -and
        (-not $since -or $_.CreationDate -ge $since) })
}

if ($wait) {
    # the hook opened the window a moment ago: wait while any sp4gl names the program (a program that already ended
    # leaves none), then look for an error file written since it started
    $open = window_processes $null
    if ($open.Count -gt 0) {
        $started = ($open | Sort-Object CreationDate | Select-Object -First 1).CreationDate.AddSeconds(-1)
    } else {
        $started = (Get-Date).AddSeconds(-60)
    }
    'WAITING for ' + $program
    while ((window_processes $started).Count -gt 0) { Start-Sleep -Milliseconds 500 }
} else {
    # compile first: a program that does not build opens no window
    $compile_text = cmd /c ('sp4gl "' + $program + '" /validate 2>&1')
    if ($LASTEXITCODE -ne 0) {
        'COMPILE FAILED -- ' + $program + ' (no window was opened)'
        $compile_text
        exit 2
    }
    'COMPILED CLEAN -- ' + $program

    $started = (Get-Date).AddSeconds(-1)
    $launched = Start-Process -FilePath 'sp4gl.exe' -ArgumentList ('"' + $program + '"') -WorkingDirectory $folder -PassThru
    'STARTED in its own window'
    # wait while the sp4gl started here runs, and while any other sp4gl started since then names the program
    while (-not $launched.HasExited -or (window_processes $started).Count -gt 0) { Start-Sleep -Milliseconds 500 }
}

$error_file = Get-ChildItem -LiteralPath $folder -Filter ($base_name + '_error_*.txt') -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $started } | Sort-Object LastWriteTime | Select-Object -Last 1
if ($error_file) {
    'ENDED WITH AN ERROR -- the error file: ' + $error_file.FullName
    Get-Content -LiteralPath $error_file.FullName -TotalCount 40
    exit 1
}
'ENDED -- the window closed and no error file was written'
exit 0
