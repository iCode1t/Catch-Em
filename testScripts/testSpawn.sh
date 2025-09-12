#!/usr/bin/env bash
# scripts/test_spawn.sh
# Usage:
#   ./test_spawn.sh start [cpu_count] [mem_mb]
#   ./test_spawn.sh list
#   ./test_spawn.sh stop
#
# Example: ./test_spawn.sh start 2 200  -> 2 CPU hogs + ~200MB mem hog

set -euo pipefail

TMPDIR="/tmp/catchem-test"
PIDFILE="${TMPDIR}/pids"

cmd="${1:-help}"

function ensure_tmp {
  mkdir -p "${TMPDIR}"
  : > "${PIDFILE}"
}

case "${cmd}" in
  start)
    CPU_CNT="${2:-2}"
    MEM_MB="${3:-200}"
    ensure_tmp
    echo "Starting ${CPU_CNT} CPU hog(s) and ${MEM_MB} MB memory hog..."
    # Start CPU hogs (busy loops). Each backgrounded job PID is recorded.
    for i in $(seq 1 "${CPU_CNT}"); do
      ( while :; do :; done ) & echo $! >> "${PIDFILE}"
    done

    # Start a Python memory hog that allocated MEM_MB MB then sleeps
    python3 - <<PYTHON &
import time,sys
mem=[]
MB=${MEM_MB}
try:
    for i in range(MB):
        mem.append(' ' * 1024 * 1024)   # allocate ~1MB per iter
        time.sleep(0.01)                # small throttle so you can observe allocation
    # keep process alive so you can test signals
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    pass
PYTHON
    echo $! >> "${PIDFILE}"

    echo "Started test processes (PIDs):"
    cat "${PIDFILE}"
    echo "Run './scripts/test_spawn.sh stop' to clean up."
    ;;

  list)
    if [[ -f "${PIDFILE}" ]]; then
      echo "Recorded test PIDs:"
      cat "${PIDFILE}"
    else
      echo "No pids file found (no running test processes recorded)."
    fi
    ;;

  stop)
    if [[ -f "${PIDFILE}" ]]; then
      echo "Stopping test PIDs:"
      while read -r pid; do
        if [[ -n "${pid}" ]]; then
          echo " -> killing ${pid}"
          kill "${pid}" 2>/dev/null || true
        fi
      done < "${PIDFILE}"
      rm -f "${PIDFILE}"
      echo "Done."
    else
      echo "No pids file found."
    fi
    ;;

  *)
    cat <<USAGE
Usage: $0 start [cpu_count] [mem_mb]
       $0 list
       $0 stop

start  - spawn background processes (CPU and memory) for safe testing
list   - show recorded PIDs
stop   - kill recorded PIDs
USAGE
    exit 1
    ;;
esac
