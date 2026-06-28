#!/usr/bin/env bash
# Test the fetch_fred helper. Network test is best-effort (skips if offline).
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$DIR/fetch_fred.sh"

# 1. usage error on no args
if "$SCRIPT" >/dev/null 2>&1; then echo "FAIL: expected non-zero exit with no args"; exit 1; fi
echo "ok: usage guard"

# 2. syntax
bash -n "$SCRIPT" || { echo "FAIL: syntax error"; exit 1; }
echo "ok: syntax"

# 3. network (best-effort): DGS10 should yield a date,value line
if curl -sf --max-time 10 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=DGS10' >/dev/null 2>&1; then
  out="$("$SCRIPT" DGS10)"
  echo "$out" | grep -Eq '[0-9]{4}-[0-9]{2}-[0-9]{2},[0-9.]+' || { echo "FAIL: no date,value in: $out"; exit 1; }
  echo "ok: network fetch -> $out"
else
  echo "skip: network unavailable"
fi
echo "ALL PASS"
