#!/usr/bin/env bash
# Fetch the latest observation for one or more FRED series via curl.
# WebFetch is 403'd on fred.stlouisfed.org; the fredgraph.csv endpoint works with no API key.
# Usage: fetch_fred.sh <SERIES_ID> [<SERIES_ID> ...]
#   e.g. fetch_fred.sh DGS2 DGS5 DGS10 DGS30 MORTGAGE30US WSHOMCB
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $(basename "$0") <SERIES_ID> [<SERIES_ID> ...]" >&2
  echo "  e.g. $(basename "$0") DGS10 MORTGAGE30US WSHOMCB" >&2
  exit 1
fi

for id in "$@"; do
  url="https://fred.stlouisfed.org/graph/fredgraph.csv?id=${id}"
  csv="$(curl -sf --max-time 20 "$url")" || { echo "${id}: ERROR fetching $url" >&2; continue; }
  # Last data row whose value column is not a missing-value marker ("." or empty).
  latest="$(printf '%s\n' "$csv" | tail -n +2 | awk -F, 'NF>=2 && $2!="" && $2!="." {d=$1; v=$2} END{if(d!="") print d","v}')"
  if [ -n "$latest" ]; then
    echo "${id},${latest}"
  else
    echo "${id}: no observations" >&2
  fi
done
