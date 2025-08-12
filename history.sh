#!/bin/bash

hist() {
  local search="" since="" limit=""
  
  # ---- help message ----
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<EOF
Usage: hist <search-term> [OPTIONS]

Search your shell history for matching commands, ignoring hist itself, and removing duplicates.

Options:
  --days N     Show commands from the last N days
  --hours N    Show commands from the last N hours
  --min N      Show commands from the last N minutes
  -n N         Limit results to the latest N unique entries
  -h, --help   Show this help message

Examples:
  hist docker
  hist apt --hours 2
  hist build --days 3 -n 5
  hist "git clone" --min 30
EOF
    return 0
  fi
  
  # ---- parse args ----
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --days)   shift; since="$(date -d "$1 days ago"  '+%Y-%m-%d %H:%M:%S')" ;;
      --hours)  shift; since="$(date -d "$1 hours ago" '+%Y-%m-%d %H:%M:%S')" ;;
      --min|--mins)
                shift; since="$(date -d "$1 minutes ago" '+%Y-%m-%d %H:%M:%S')" ;;
      -n)       shift; limit="$1" ;;
      *)        # collect search term (can have spaces)
                if [[ -z "$search" ]]; then
                  search="$1"
                else
                  search="$search $1"
                fi
                ;;
    esac
    shift
  done

  if [[ -z "$search" ]]; then
    echo "Usage: hist <search-term> [--days N | --hours N | --min N] [-n N]"
    echo "Run 'hist --help' for details."
    return 1
  fi

  # ---- fetch and filter history ----
  local list=""
  if [[ -n "$ZSH_VERSION" ]]; then
    setopt extended_history 2>/dev/null || true
    list="$(fc -l -n -t "%Y-%m-%d %H:%M:%S" 1 | awk -v s="$since" -v q="$search" '
      BEGIN{IGNORECASE=1}
      {
        ts = $1 " " $2
        has_ts = (ts ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}/)
        if (has_ts) { $1=""; $2=""; sub(/^ */, "", $0) }
        if ($0 ~ /^hist[ \t]/) next  # ignore commands starting with hist
        if (index($0, q) && (s=="" || !has_ts || ts >= s)) print $0
      }' | tac | awk '!seen[$0]++' | tac)"
  else
    local old_fmt="$HISTTIMEFORMAT"
    export HISTTIMEFORMAT="%F %T "
    list="$(history | sed 's/^ *[0-9]\+ *//' | awk -v s="$since" -v q="$search" '
      BEGIN{IGNORECASE=1}
      {
        ts = $1 " " $2
        has_ts = (ts ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}/)
        if (has_ts) { $1=""; $2=""; sub(/^ */, "", $0) }
        if ($0 ~ /^hist[ \t]/) next  # ignore commands starting with hist
        if (index($0, q) && (s=="" || !has_ts || ts >= s)) print $0
      }' | tac | awk '!seen[$0]++' | tac)"
    export HISTTIMEFORMAT="$old_fmt"
  fi

  if [[ -z "$list" ]]; then
    echo "No matching commands found."
    return 1
  fi

  # ---- limit results if -n is set ----
  if [[ -n "$limit" ]]; then
    printf '%s\n' "$list" | tail -n "$limit"
  else
    printf '%s\n' "$list"
  fi
}
