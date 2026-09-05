#!/usr/bin/env bash
# ===========================================================================
# watchdog.sh - thin wrapper around watchdog.ps1
#
# The real implementation lives in watchdog.ps1. This machine is Windows, and
# the working parts of the job (finding the bundled claude.exe, reading
# session transcripts, launching a detached process that survives the parent
# shell) are all far more reliable in PowerShell than in Git Bash.
#
# An earlier version of this file called a bare `claude` command. That was
# wrong: the CLI is not on PATH here. It ships inside the desktop app at
#   %APPDATA%\Claude\claude-code\<version>\claude.exe
# watchdog.ps1 resolves that path itself.
#
#   Check everything is wired up (launches nothing):
#       bash watchdog.sh --selftest
#
#   Start it:
#       bash watchdog.sh
#
#   Stop it:
#       bash watchdog.sh --stop
# ===========================================================================
set -u

ROOT="$(cd "$(dirname "$0")" && pwd)"
WIN_ROOT="$(cd "$ROOT" && pwd -W 2>/dev/null | sed 's|/|\\|g')"
[ -n "${WIN_ROOT:-}" ] || WIN_ROOT="$ROOT"
PS1_FILE="$WIN_ROOT\\watchdog.ps1"
PIDFILE="$ROOT/logs/.watchdog.pid"

case "${1:-}" in
  --stop)
    if [ -f "$PIDFILE" ]; then
      pid=$(tr -d '\r\n ' < "$PIDFILE")
      powershell -NoProfile -Command "Stop-Process -Id $pid -ErrorAction SilentlyContinue" \
        && echo "stopped watchdog (pid $pid)"
      rm -f "$PIDFILE"
    else
      echo "no pidfile - watchdog does not appear to be running"
    fi
    ;;
  --selftest)
    powershell -ExecutionPolicy Bypass -NoProfile -File "$PS1_FILE" -SelfTest
    ;;
  --dryrun)
    powershell -ExecutionPolicy Bypass -NoProfile -File "$PS1_FILE" -DryRun
    ;;
  *)
    powershell -ExecutionPolicy Bypass -NoProfile -File "$PS1_FILE" "$@"
    ;;
esac
