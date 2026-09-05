# ===========================================================================
# watchdog.ps1 - auto-resume the overnight build after a usage-limit pause.
#
# NOTE: this file is deliberately plain ASCII. Windows PowerShell 5.1 assumes
# ANSI unless a file carries a UTF-8 BOM, so fancy dashes and quotes turn to
# mojibake and can break parsing.
#
# WHY THIS EXISTS
#   Claude Code has no internal clock. It only runs while a turn is in
#   progress. When a usage limit is hit the turn ends, and nothing is left
#   running to notice the reset. This script is the outside timer.
#
# HOW IT WORKS
#   1. Watches logs\progress.log.
#   2. If it stops changing for -StallMinutes, treats the run as stalled.
#   3. Reads the session transcript to find the usage-limit reset time.
#   4. Sleeps until reset + buffer.
#   5. Runs the bundled CLI with --resume SESSIONID so THIS session continues
#      in place, rather than starting over from the brief.
#
# ---------------------------------------------------------------------------
# BEFORE THIS CAN WORK - ONE MANUAL STEP (only you can do it)
# ---------------------------------------------------------------------------
#   The CLI bundled inside the desktop app is NOT logged in. The desktop app
#   keeps its own auth and does not share it. Until the CLI is logged in,
#   every resume attempt fails instantly with "Not logged in".
#
#   In a normal PowerShell window, once:
#
#       $exe = Get-ChildItem "$env:APPDATA\Claude\claude-code" -Directory |
#              Sort-Object Name | Select-Object -Last 1
#       & (Join-Path $exe.FullName "claude.exe")
#
#   then type  /login , finish the browser flow, then  /exit .
#
#   Check it stuck:
#
#       & (Join-Path $exe.FullName "claude.exe") -p "say OK"
#
#   Until that prints a reply, this watchdog cannot do anything.
#
# ---------------------------------------------------------------------------
# RUN IT
#   Test first, launches nothing:
#     powershell -ExecutionPolicy Bypass -File watchdog.ps1 -SelfTest
#
#   Foreground:
#     powershell -ExecutionPolicy Bypass -File watchdog.ps1
#
#   Detached, survives closing the window:
#     Start-Process powershell -WindowStyle Hidden -ArgumentList `
#       '-ExecutionPolicy','Bypass','-File', `
#       'C:\Users\puppa\OneDrive\Desktop\Basil\Shopify\watchdog.ps1'
#
#   Stop:
#     Get-Content logs\.watchdog.pid | ForEach-Object { Stop-Process -Id $_ }
# ===========================================================================

param(
  # Session to resume. Defaults to the session that started this build.
  # List them with: Get-ChildItem "$env:USERPROFILE\.claude\projects\<slug>"
  [string]$SessionId  = "aa317420-49ed-41de-884b-15540884c072",

  [int]$StallMinutes  = 15,    # quiet time before we call it stalled
  [int]$PollSeconds   = 60,    # how often to check
  [int]$BufferSeconds = 180,   # cushion added after the reset time
  [int]$BlindRetryMin = 30,    # wait when no reset time can be parsed

  [switch]$DryRun,             # run the loop but never launch the CLI
  [switch]$SelfTest            # check everything, then exit
)

$ErrorActionPreference = 'Continue'

$Root        = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProgressLog = Join-Path $Root 'logs\progress.log'
$WatchLog    = Join-Path $Root 'logs\watchdog.log'
$PidFile     = Join-Path $Root 'logs\.watchdog.pid'
$ResumeOut   = Join-Path $Root 'logs\resume-output.log'
$ResumeErr   = Join-Path $Root 'logs\resume-error.log'
$ProjectSlug = 'C--Users-puppa-OneDrive-Desktop-Basil-Shopify'
$Transcripts = Join-Path $env:USERPROFILE ".claude\projects\$ProjectSlug"

New-Item -ItemType Directory -Force -Path (Join-Path $Root 'logs') | Out-Null

function Say([string]$m) {
  $line = "[watchdog {0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m
  Write-Host $line
  Add-Content -Path $WatchLog -Value $line -Encoding utf8
}

# --- locate the CLI that ships with the desktop app -----------------------
function Get-ClaudeExe {
  $base = Join-Path $env:APPDATA 'Claude\claude-code'
  if (-not (Test-Path $base)) { return $null }
  $newest = Get-ChildItem $base -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name | Select-Object -Last 1
  if (-not $newest) { return $null }
  $exe = Join-Path $newest.FullName 'claude.exe'
  if (Test-Path $exe) { return $exe }
  return $null
}

# --- is that CLI actually logged in? --------------------------------------
# Cheapest reliable probe: a one-word headless prompt. Returns $true/$false.
function Test-ClaudeLogin {
  $exe = Get-ClaudeExe
  if (-not $exe) { return $false }
  try {
    $out = & $exe -p "Reply with exactly: WATCHDOG_OK" 2>&1 | Out-String
  } catch {
    return $false
  }
  if ($out -match 'WATCHDOG_OK') { return $true }
  if ($out -match 'Not logged in|/login')  { return $false }
  return $false
}

# --- how long since progress.log last changed -----------------------------
function Get-LogAgeSeconds {
  if (-not (Test-Path $ProgressLog)) { return [int]::MaxValue }
  return [int]((Get-Date) - (Get-Item $ProgressLog).LastWriteTime).TotalSeconds
}

# --- sanity check on a parsed reset time ----------------------------------
# A limit reset is always soon: never more than a day out, and never far in
# the past. Anything else came from a stale line in the transcript and should
# be ignored rather than acted on.
function Test-PlausibleReset([DateTime]$t) {
  if ($null -eq $t) { return $false }
  $delta = ($t - (Get-Date)).TotalHours
  return ($delta -gt -2 -and $delta -lt 26)
}

# --- dig a usage-limit reset time out of the newest transcript ------------
# Handles both shapes the CLI writes:
#   "Claude usage limit reached|1764950400"   (unix seconds)
#   "...limit will reset at 3:00pm"
function Get-ResetTime {
  if (-not (Test-Path $Transcripts)) { return $null }
  $f = Get-ChildItem $Transcripts -Filter *.jsonl -ErrorAction SilentlyContinue |
       Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-4) } |
       Sort-Object LastWriteTime | Select-Object -Last 1
  if (-not $f) { return $null }

  # these transcripts get large, so only read the tail
  $text = ''
  try {
    $fs = [IO.File]::Open($f.FullName, 'Open', 'Read', 'ReadWrite')
    try {
      $take = [int][Math]::Min(300KB, $fs.Length)
      $fs.Seek(-$take, 'End') | Out-Null
      $buf = New-Object byte[] $take
      $fs.Read($buf, 0, $take) | Out-Null
      $text = [Text.Encoding]::UTF8.GetString($buf)
    } finally { $fs.Dispose() }
  } catch { return $null }

  # shape 1 - explicit unix timestamp
  $m = [regex]::Matches($text, 'usage limit reached\|(\d{10})')
  if ($m.Count -gt 0) {
    $epoch = [long]$m[$m.Count - 1].Groups[1].Value
    $t = [DateTimeOffset]::FromUnixTimeSeconds($epoch).LocalDateTime
    # A transcript tail can still hold a limit message from days ago. Only
    # trust a reset that is plausibly current, otherwise fall through.
    if (Test-PlausibleReset $t) { return $t }
  }

  # shape 2 - a human clock time near a reset message
  $pattern = '(?i)(?:limit[^"]{0,80}?reset|reset[^"]{0,20}?at|try again after)\D{0,10}(\d{1,2})(?::(\d{2}))?\s*(am|pm)?'
  $m = [regex]::Matches($text, $pattern)
  if ($m.Count -gt 0) {
    $g  = $m[$m.Count - 1].Groups
    $hh = [int]$g[1].Value
    $mm = 0
    if ($g[2].Success) { $mm = [int]$g[2].Value }
    $ap = $g[3].Value.ToLower()
    if ($ap -eq 'pm' -and $hh -lt 12) { $hh = $hh + 12 }
    if ($ap -eq 'am' -and $hh -eq 12) { $hh = 0 }
    if ($hh -gt 23 -or $mm -gt 59) { return $null }
    $t = (Get-Date).Date.AddHours($hh).AddMinutes($mm)
    if ($t -le (Get-Date)) { $t = $t.AddDays(1) }   # already past means tomorrow
    if (Test-PlausibleReset $t) { return $t }
  }
  return $null
}

# --- the instruction handed to the resumed session ------------------------
$ResumePrompt = @'
Resume the Shopify build. Re-read Shopify/PROJECT_BRIEF.md and
Shopify/logs/progress.log first, work out the first item that is not yet
finished, and carry on from exactly there. Do not restart completed work and
do not ask any questions. Append every meaningful step to
Shopify/logs/progress.log as you go.
'@

function Invoke-Resume {
  $exe = Get-ClaudeExe
  if (-not $exe) {
    Say "ERROR: claude.exe not found under %APPDATA%\Claude\claude-code"
    return
  }
  if ($DryRun) {
    Say "DRY RUN - would run: $exe --resume $SessionId -p [resume prompt] --dangerously-skip-permissions"
    return
  }

  Say "resuming session $SessionId"
  Say "using $exe"
  try {
    Push-Location $Root
    $cliArgs = @('--resume', $SessionId, '-p', $ResumePrompt, '--dangerously-skip-permissions')
    $proc = Start-Process -FilePath $exe -ArgumentList $cliArgs -PassThru -NoNewWindow `
              -RedirectStandardOutput $ResumeOut -RedirectStandardError $ResumeErr
    Say ("launched (pid {0}). output -> logs\resume-output.log" -f $proc.Id)
  } catch {
    Say ("ERROR launching resume: {0}" -f $_.Exception.Message)
  } finally {
    Pop-Location
  }
}

# ===========================================================================
# SELF TEST
# ===========================================================================
if ($SelfTest) {
  Say "=== self test ==="

  $exe = Get-ClaudeExe
  if ($exe) { Say "OK   cli found: $exe" }
  else      { Say "FAIL cli not found under %APPDATA%\Claude\claude-code" }

  $tp = Join-Path $Transcripts "$SessionId.jsonl"
  if (Test-Path $tp) { Say "OK   session transcript exists: $SessionId" }
  else {
    Say "FAIL no transcript for session $SessionId"
    Say "     available sessions:"
    Get-ChildItem $Transcripts -Filter *.jsonl -ErrorAction SilentlyContinue |
      Sort-Object LastWriteTime |
      ForEach-Object { Say ("       {0}  (modified {1})" -f $_.BaseName, $_.LastWriteTime) }
  }

  if (Test-Path $ProgressLog) { Say ("OK   progress.log age: {0}s" -f (Get-LogAgeSeconds)) }
  else                        { Say "FAIL progress.log not found at $ProgressLog" }

  $r = Get-ResetTime
  if ($r) { Say "OK   parsed a reset time from the transcript: $r" }
  else    { Say "note no reset time in the recent transcript tail (normal when not rate limited)" }

  Say "checking CLI login (this makes one tiny request)..."
  if (Test-ClaudeLogin) {
    Say "OK   cli is logged in - auto-resume will work"
  } else {
    Say "FAIL cli is NOT logged in - auto-resume cannot work yet"
    Say "     fix: run the CLI once in a terminal and use /login (see header of this file)"
  }

  Say "=== end self test ==="
  exit 0
}

# ===========================================================================
# MAIN LOOP
# ===========================================================================
$PID | Out-File -FilePath $PidFile -Encoding ascii

Say "started (pid $PID)"
$exe = Get-ClaudeExe
if ($exe) { Say "cli: $exe" } else { Say "WARNING: claude.exe not found - resume will fail" }
Say "session: $SessionId"
Say "watching: $ProgressLog (stall after $StallMinutes min, poll every $PollSeconds s)"
if ($DryRun) { Say "DRY RUN mode - will not launch anything" }

if (-not (Test-Path (Join-Path $Transcripts "$SessionId.jsonl"))) {
  Say "WARNING: no transcript for that session id. Run with -SelfTest to list valid ids."
}

$lastResume = [DateTime]::MinValue

while ($true) {
  $age = Get-LogAgeSeconds

  if ($age -lt ($StallMinutes * 60)) {
    Start-Sleep -Seconds $PollSeconds        # progress is happening; stay quiet
    continue
  }

  Say ("progress.log unchanged for {0} min - looks stalled" -f [int]($age / 60))

  if (((Get-Date) - $lastResume).TotalMinutes -lt 20) {
    Say "resumed recently, holding off"
    Start-Sleep -Seconds $PollSeconds
    continue
  }

  $reset = Get-ResetTime
  if ($reset) {
    $wait = [int](($reset - (Get-Date)).TotalSeconds) + $BufferSeconds
    if ($wait -gt 0) {
      Say ("usage limit resets at {0}; sleeping {1} min (incl. {2}s buffer)" -f `
           $reset.ToString('yyyy-MM-dd HH:mm:ss'), [int]($wait / 60), $BufferSeconds)
      Start-Sleep -Seconds $wait
    } else {
      Say "reset time already passed - resuming now"
    }
  } else {
    Say "no reset time in the transcript; blind retry in $BlindRetryMin min"
    Start-Sleep -Seconds ($BlindRetryMin * 60)
  }

  Invoke-Resume
  $lastResume = Get-Date
  Start-Sleep -Seconds $PollSeconds
}
