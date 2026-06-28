# Analyzing Agency MBS Market Activity — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Also consult **superpowers:writing-skills** for skill-authoring conventions (lean SKILL.md, `references/` for detail, `scripts/` for helpers, strong trigger-word description).

**Goal:** Build a Claude Code skill that produces an agency MBS (UMBS + Ginnie) trading-market-activity recap culminating in a relative-value read, using a hybrid data approach (auto-fetch free public sources; `[VERIFY]` for terminal-only data).

**Architecture:** One skill directory in this repo. A lean `SKILL.md` holds the process (when-to-use, inputs, workflow, output, quality checks) and points to two `references/` files (the verified data-source map and the relative-value definitions) plus one `scripts/` helper (`fetch_fred.sh`, because WebFetch is 403'd on FRED while `curl` works). Content is sourced verbatim from the approved spec.

**Tech Stack:** Markdown (skill + references), Bash (FRED fetch helper using `curl`). No build system. Verification is via shell commands (frontmatter parse, content greps, URL HEAD checks, `bash -n`).

## Global Constraints

- **Spec source of truth:** `docs/superpowers/specs/2026-06-27-agency-mbs-market-activity-design.md`. All prose/table content is copied verbatim from it.
- **Skill name (exact):** `analyzing-agency-mbs-market-activity`
- **Skill location (exact):** `skills/analyzing-agency-mbs-market-activity/` in this repo.
- **Frontmatter style:** match the sibling `conducting-debt-market-conditions-analysis` skill — `name`, `description`, `tags`, `metadata`. `name` must equal the directory name.
- **Hard rule baked into content:** never present the computed current-coupon spread proxy as a true OAS; there is no free ICE BofA MBS OAS series on FRED.
- **`[VERIFY]` convention:** terminal-only data (OAS, dollar-roll drops/breakevens, specified-pool pay-up grids, effective duration/convexity, loan-level analytics) is always marked `[VERIFY]`.
- **FRED access:** WebFetch returns 403 on `fred.stlouisfed.org`; use `curl 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=<ID>'` (no API key needed).
- Commit after each task.

## File Structure

```
skills/analyzing-agency-mbs-market-activity/
  SKILL.md                                  # lean process; links to references + script
  references/
    data-sources.md                         # fetchability-tagged web-resource map (Tiers 1-3)
    relative-value-reference.md             # precise RV definitions
  scripts/
    fetch_fred.sh                           # curl helper for FRED series (DGS*, MORTGAGE30US, WSHOMCB)
docs/superpowers/plans/2026-06-27-analyzing-agency-mbs-market-activity.md   # this plan
```

Responsibilities:
- **SKILL.md** — what Claude reads into context on invocation. Must stay lean; defers detail tables to `references/`.
- **references/data-sources.md** — the full source map so SKILL.md isn't bloated.
- **references/relative-value-reference.md** — RV definitions, read on demand during step 5 of the workflow.
- **scripts/fetch_fred.sh** — deterministic FRED fetch that bypasses the WebFetch 403.

---

### Task 1: Scaffold skill directory, frontmatter, and section skeleton

**Files:**
- Create: `skills/analyzing-agency-mbs-market-activity/SKILL.md`

**Interfaces:**
- Produces: a `SKILL.md` whose `name:` is `analyzing-agency-mbs-market-activity` and whose section headers later tasks fill in.

- [ ] **Step 1: Write the SKILL.md frontmatter + section skeleton**

Create `skills/analyzing-agency-mbs-market-activity/SKILL.md` with exactly:

```markdown
---
name: analyzing-agency-mbs-market-activity
description: Synthesizes UMBS / agency MBS (Fannie, Freddie, Ginnie) trading market activity — TBA prices, spreads, trading volumes, Fed activity, prepay trends — and produces a relative-value read (coupon stack, dollar roll, specified-pool pay-ups). Use when recapping the agency MBS market, timing the coupon stack, or assessing relative value across UMBS/Ginnie pass-throughs. Triggers on UMBS, agency MBS, TBA, dollar roll, current coupon, specified pool, pay-up, CPR, prepay, MBS recap, coupon stack.
tags:
  - process
  - mortgage-backed-securities
  - trading
metadata:
  author: duncan
  practice_areas:
    - Securitized Products
    - Agency MBS Trading
  document_types:
    - Market Activity Report
  skill_modes:
    - Process Management
    - Analysis
---
# Analyzing Agency MBS Market Activity

Synthesizes UMBS / agency MBS (Fannie Mae, Freddie Mac, Ginnie Mae) trading market activity and produces a relative-value read. Covers UMBS 30y/15y and Ginnie II.

## When To Use

## Inputs To Gather

## Workflow

## Data Sources

See [references/data-sources.md](references/data-sources.md) for the full, fetchability-tagged source map.

## Output

## Quality Checks

## Relative-Value Reference

See [references/relative-value-reference.md](references/relative-value-reference.md) for precise definitions of every metric used in the workflow.
```

- [ ] **Step 2: Verify the frontmatter parses and name matches the directory**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs
python3 -c "import yaml,sys; d=open('skills/analyzing-agency-mbs-market-activity/SKILL.md').read().split('---')[1]; m=yaml.safe_load(d); assert m['name']=='analyzing-agency-mbs-market-activity', m['name']; assert len(m['description'])<=1024; print('OK', m['name'])"
```
Expected: `OK analyzing-agency-mbs-market-activity`

- [ ] **Step 3: Verify all required section headers exist**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs
for h in "## When To Use" "## Inputs To Gather" "## Workflow" "## Data Sources" "## Output" "## Quality Checks" "## Relative-Value Reference"; do grep -qF "$h" skills/analyzing-agency-mbs-market-activity/SKILL.md && echo "found: $h" || { echo "MISSING: $h"; exit 1; }; done
```
Expected: seven `found:` lines, exit 0.

- [ ] **Step 4: Commit**

```bash
cd /Users/duncan/Projects/shiuhlon/umbs
git add skills/analyzing-agency-mbs-market-activity/SKILL.md
git commit -m "scaffold analyzing-agency-mbs-market-activity skill"
```

---

### Task 2: Write the core process sections in SKILL.md

**Files:**
- Modify: `skills/analyzing-agency-mbs-market-activity/SKILL.md` (fill `When To Use`, `Inputs To Gather`, `Workflow`, `Output`, `Quality Checks`)

**Interfaces:**
- Consumes: the section skeleton from Task 1.
- Produces: a 6-step Workflow whose step 2/3 reference `scripts/fetch_fred.sh` (Task 5) and `references/data-sources.md` (Task 3), plus the Output and Quality Checks sections.

- [ ] **Step 1: Fill the `## When To Use` section**

Under `## When To Use`, insert verbatim the six bullets from the spec's "When To Use" section:
```markdown
- Producing a daily/weekly agency MBS market activity recap for a desk or PM
- Assessing relative value across the UMBS coupon stack (up-in-coupon vs. down-in-coupon)
- Evaluating a TBA dollar roll vs. holding-and-financing (drop vs. breakeven / carry)
- Framing specified-pool pay-up decisions (prepay protection stories)
- Contextualizing prepay speeds (CPR/PSA) against coupon premium/discount
- Summarizing Fed agency-MBS operations / SOMA runoff impact on technicals
```

- [ ] **Step 2: Fill the `## Inputs To Gather` section**

Under `## Inputs To Gather`, insert verbatim the four bullets from the spec's "Inputs To Gather" section (frame; auto-fetched market backdrop; auto-fetched activity/technicals; terminal-only `[VERIFY]`).

- [ ] **Step 3: Fill the `## Workflow` section**

Under `## Workflow`, insert the six numbered steps from the spec's "Workflow" section verbatim (Set the frame; Pull the market backdrop; Pull activity & technicals; Compute the spread proxy; Relative-value read; Synthesize). Ensure step 2 names `scripts/fetch_fred.sh` for the FRED pulls and step 4 contains the "never present the spread proxy as a true OAS" rule.

- [ ] **Step 4: Fill the `## Output` section**

Under `## Output`, insert verbatim the six output bullets from the spec's "Output" section (Market Activity Recap; Levels table; Activity snapshot; Relative-Value read; Prepay/convexity note; `[VERIFY]` list).

- [ ] **Step 5: Fill the `## Quality Checks` section**

Under `## Quality Checks`, insert verbatim the seven quality-check bullets from the spec's "Quality Checks" section (timestamps/staleness; cite source + as-of; never call the proxy a true OAS; roll/pay-up reads `[VERIFY]`; settlement class matches program; state proxy methodology; distinguish Fed ops from market drops).

- [ ] **Step 6: Verify the process sections are complete and reference the script + OAS rule**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs
F=skills/analyzing-agency-mbs-market-activity/SKILL.md
grep -qF "scripts/fetch_fred.sh" "$F" && echo "ok: script ref"
grep -qiF "never present" "$F" && grep -qF "OAS" "$F" && echo "ok: OAS rule"
grep -c "^[0-9]\." "$F" | grep -qx 6 && echo "ok: 6 workflow steps" || echo "check step count: $(grep -c '^[0-9]\.' "$F")"
# Output + Quality Checks sections are non-empty (have bullets after the header)
awk '/^## Output/{o=1} o&&/^- /{print "ok: output bullets"; exit}' "$F"
awk '/^## Quality Checks/{q=1} q&&/^- /{print "ok: quality bullets"; exit}' "$F"
```
Expected: `ok: script ref`, `ok: OAS rule`, `ok: 6 workflow steps`, `ok: output bullets`, `ok: quality bullets`.

- [ ] **Step 7: Commit**

```bash
cd /Users/duncan/Projects/shiuhlon/umbs
git add skills/analyzing-agency-mbs-market-activity/SKILL.md
git commit -m "add process sections (when-to-use, inputs, workflow, output, quality) to agency MBS skill"
```

---

### Task 3: Write `references/data-sources.md` (verified resource map)

**Files:**
- Create: `skills/analyzing-agency-mbs-market-activity/references/data-sources.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the source map SKILL.md links to. Must contain the three tier tables and the source-caveats list.

- [ ] **Step 1: Write the data-sources reference**

Create the file with: a title, a one-line "verified 2026-06-27 / fetchability tag meaning" note, then copy verbatim from the spec's "Data Sources" section: the **Tier 1 — Auto-fetch** table, the **Tier 2 — Free but needs curl/API/login** table, the **Tier 3 — Terminal-only `[VERIFY]`** list, and the **Source caveats** bullets (no free MBS OAS; 5s/10s blend `[VERIFY]`; MND delayed/EOD null-check; CME 403; Fannie domain 403).

- [ ] **Step 2: Verify all tiers, the FRED-curl note, and the no-OAS caveat are present**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs
F=skills/analyzing-agency-mbs-market-activity/references/data-sources.md
for s in "Tier 1" "Tier 2" "Tier 3" "fredgraph.csv" "No free ICE BofA MBS OAS" "freddiemac.com/pmms" "sifma.org" "finra.org" "newyorkfed.org" "ginniemae.gov" "WSHOMCB"; do grep -qiF "$s" "$F" && echo "ok: $s" || { echo "MISSING: $s"; exit 1; }; done
```
Expected: an `ok:` line for each token, exit 0.

- [ ] **Step 3: Commit**

```bash
cd /Users/duncan/Projects/shiuhlon/umbs
git add skills/analyzing-agency-mbs-market-activity/references/data-sources.md
git commit -m "add verified data-source map reference"
```

---

### Task 4: Write `references/relative-value-reference.md`

**Files:**
- Create: `skills/analyzing-agency-mbs-market-activity/references/relative-value-reference.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the RV definitions SKILL.md links to.

- [ ] **Step 1: Write the RV reference**

Create the file with a title and copy verbatim the eight definition blocks from the spec's "Relative-Value Reference (appendix content)" section: TBA/dollar roll (drop, breakeven, implied financing, special); current coupon + CC spread; spread measures (nominal/Z/OAS); specified-pool pay-ups; prepay conventions (SMM/CPR/PSA, fast/slow); coupon stack RV (up/down-in-coupon); WAC/WALA/WAM; convexity/extension.

- [ ] **Step 2: Verify every RV concept is present**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs
F=skills/analyzing-agency-mbs-market-activity/references/relative-value-reference.md
for s in "dollar roll" "breakeven" "implied financing" "special" "current coupon" "Z-spread" "OAS" "pay-up" "SMM" "CPR" "PSA" "up-in-coupon" "WALA" "convex"; do grep -qiF "$s" "$F" && echo "ok: $s" || { echo "MISSING: $s"; exit 1; }; done
```
Expected: an `ok:` line for each, exit 0.

- [ ] **Step 3: Commit**

```bash
cd /Users/duncan/Projects/shiuhlon/umbs
git add skills/analyzing-agency-mbs-market-activity/references/relative-value-reference.md
git commit -m "add relative-value definitions reference"
```

---

### Task 5: Write and test `scripts/fetch_fred.sh`

**Files:**
- Create: `skills/analyzing-agency-mbs-market-activity/scripts/fetch_fred.sh`
- Test: `skills/analyzing-agency-mbs-market-activity/scripts/test_fetch_fred.sh`

**Interfaces:**
- Produces: `fetch_fred.sh <SERIES_ID> [<SERIES_ID> ...]` — prints, per series, the most recent non-empty `date,value` line from FRED. Exit 1 with usage if no args. Used by SKILL.md workflow step 2.

- [ ] **Step 1: Write the failing test**

Create `skills/analyzing-agency-mbs-market-activity/scripts/test_fetch_fred.sh`:
```bash
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
```

- [ ] **Step 2: Run the test to verify it fails (script missing)**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs
chmod +x skills/analyzing-agency-mbs-market-activity/scripts/test_fetch_fred.sh
bash skills/analyzing-agency-mbs-market-activity/scripts/test_fetch_fred.sh; echo "exit=$?"
```
Expected: FAIL (the usage guard runs a non-existent script) — non-zero `exit=`.

- [ ] **Step 3: Write the implementation**

Create `skills/analyzing-agency-mbs-market-activity/scripts/fetch_fred.sh`:
```bash
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
```

- [ ] **Step 4: Run the test to verify it passes**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs
chmod +x skills/analyzing-agency-mbs-market-activity/scripts/fetch_fred.sh
bash skills/analyzing-agency-mbs-market-activity/scripts/test_fetch_fred.sh; echo "exit=$?"
```
Expected: `ok: usage guard`, `ok: syntax`, then either `ok: network fetch -> DGS10,<date>,<value>` or `skip: network unavailable`, then `ALL PASS`, `exit=0`.

- [ ] **Step 5: Commit**

```bash
cd /Users/duncan/Projects/shiuhlon/umbs
git add skills/analyzing-agency-mbs-market-activity/scripts/fetch_fred.sh skills/analyzing-agency-mbs-market-activity/scripts/test_fetch_fred.sh
git commit -m "add fetch_fred curl helper with test"
```

---

### Task 6: Final wiring, URL resolution check, and install

**Files:**
- Modify: `skills/analyzing-agency-mbs-market-activity/SKILL.md` (confirm cross-links; note the FRED helper in Data Sources)

**Interfaces:**
- Consumes: all prior tasks.
- Produces: a complete, cross-linked skill, optionally installed to `~/.claude/skills/`.

- [ ] **Step 1: Confirm SKILL.md cross-links resolve to real files**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs/skills/analyzing-agency-mbs-market-activity
test -f references/data-sources.md && echo "ok: data-sources" || echo "MISSING data-sources"
test -f references/relative-value-reference.md && echo "ok: rv" || echo "MISSING rv"
test -x scripts/fetch_fred.sh && echo "ok: script executable" || echo "MISSING/not-exec script"
grep -qF "references/data-sources.md" SKILL.md && grep -qF "references/relative-value-reference.md" SKILL.md && echo "ok: links present"
```
Expected: `ok: data-sources`, `ok: rv`, `ok: script executable`, `ok: links present`.

- [ ] **Step 2: Verify Tier-1 source URLs still resolve (best-effort HEAD check)**

Run:
```bash
cd /Users/duncan/Projects/shiuhlon/umbs
for u in \
  "https://www.freddiemac.com/pmms" \
  "https://www.mortgagenewsdaily.com/mbs" \
  "https://www.sifma.org/research/statistics/us-mortgage-backed-securities-statistics" \
  "https://www.finra.org/finra-data/browse-catalog/trace-volume-reports/about-trace-monthly-volume-reports" \
  "https://www.newyorkfed.org/markets/ambs_operation_schedule" ; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 -L "$u" || echo "ERR")
  echo "$code  $u"
done
```
Expected: mostly `200` (a `403`/`ERR` from bot-blocking is acceptable for sites known to block scripted fetches — note any in the task summary; do not edit URLs unless a `404`).

- [ ] **Step 3: Review the whole skill against superpowers:writing-skills**

Read `SKILL.md` and both references end-to-end. Confirm: SKILL.md stays lean (detail lives in references), description has trigger words, no `[VERIFY]` rule is contradicted, no placeholder text. Fix anything inline.

- [ ] **Step 4: Install for cross-project use (optional, ask before running)**

Run (only if the user wants it usable outside this repo):
```bash
ln -sfn /Users/duncan/Projects/shiuhlon/umbs/skills/analyzing-agency-mbs-market-activity ~/.claude/skills/analyzing-agency-mbs-market-activity
ls -l ~/.claude/skills/analyzing-agency-mbs-market-activity
```
Expected: a symlink pointing into the repo.

- [ ] **Step 5: Commit**

```bash
cd /Users/duncan/Projects/shiuhlon/umbs
git add -A skills/analyzing-agency-mbs-market-activity
git commit -m "finalize agency MBS market-activity skill: cross-links + review" || echo "nothing to commit"
```

---

## Self-Review

**Spec coverage:**
- When To Use → Task 2 ✓
- Inputs To Gather → Task 2 ✓
- Workflow (6 steps) → Task 2 ✓
- Data Sources (Tiers 1–3 + caveats) → Task 3 ✓
- FRED curl access (WebFetch 403) → Task 5 (`fetch_fred.sh`) + Task 3 (Tier 2 note) ✓
- Output → Task 2 Step 4 ✓
- Quality Checks → Task 2 Step 5 ✓
- Relative-Value Reference → Task 4 ✓
- No-free-OAS / never-call-proxy-OAS rule → Task 2 (workflow + quality checks), Task 3 (caveat) ✓
- Out of scope → inherent (skill simply doesn't cover PL/intraday) ✓

**Placeholder scan:** No "TBD/TODO". References to spec sections point at a committed, complete artifact (not placeholders); structural greps confirm content landed.

**Type consistency:** Script contract `fetch_fred.sh <SERIES_ID>...` is consistent between Task 5 interface, implementation, test, and the Task 2 workflow reference. File paths are identical across tasks.
