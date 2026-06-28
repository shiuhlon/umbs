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

- Producing a daily/weekly agency MBS market activity recap for a desk or PM
- Assessing relative value across the UMBS coupon stack (up-in-coupon vs. down-in-coupon)
- Evaluating a TBA dollar roll vs. holding-and-financing (drop vs. breakeven / carry)
- Framing specified-pool pay-up decisions (prepay protection stories)
- Contextualizing prepay speeds (CPR/PSA) against coupon premium/discount
- Summarizing Fed agency-MBS operations / SOMA runoff impact on technicals

## Inputs To Gather

- **Frame:** as-of date, settlement month + class, programs in focus (UMBS 30y, UMBS 15y, GNII 30y), coupon stack of interest
- **Auto-fetched market backdrop:** Treasury curve, primary mortgage rate, EOD UMBS coupon prices
- **Auto-fetched activity/technicals:** TBA settlement calendar, issuance/volume stats, TRACE volumes, Fed ops + SOMA holdings, Ginnie issuance/prepay headlines
- **Terminal-only (`[VERIFY]`):** OAS, effective duration/convexity, dollar-roll drops/breakevens/implied financing, specified-pool pay-up grids, loan-level prepay analytics

## Workflow

1. **Set the frame** — Confirm as-of date, settlement month/class, programs, and the coupon stack in focus.

2. **Pull the market backdrop (auto-fetch)**
   - Treasury constant-maturity yields: FRED `DGS2`, `DGS5`, `DGS7`, `DGS10`, `DGS30` via `scripts/fetch_fred.sh`
   - Primary mortgage rate: Freddie PMMS page / historical `.xlsx`, or Mortgage News Daily 30y index
   - Current-coupon proxy: Mortgage News Daily **MBS dashboard** EOD UMBS coupon prices

3. **Pull activity & technicals (auto-fetch)**
   - SIFMA TBA settlement calendar (Class A/B/C/D notification + settlement dates) and US MBS issuance/trading-volume statistics
   - FINRA TRACE monthly volume report (TBA vs. specified-pool agency pass-through volumes)
   - NY Fed agency-MBS operation schedule + results + transaction summary; SOMA agency-MBS holdings (FRED `WSHOMCB`)
   - Ginnie Mae Global Markets Analysis Report (GMAR) for issuance + prepay headlines

4. **Compute the spread proxy**
   - Current-coupon spread = interpolated par-coupon yield − a 5s/10s Treasury blend (blend weights are a dealer convention; mark `[VERIFY]`)
   - Nominal spread = current-coupon yield − 10y Treasury
   - **There is no free ICE BofA MBS OAS series on FRED.** Never present the computed spread proxy as a true OAS. True OAS is `[VERIFY]` from a terminal.

5. **Relative-value read**
   - Coupon-stack RV: up-in-coupon (more carry/yield, shorter duration, more negative convexity) vs. down-in-coupon (longer duration, better convexity, rally upside)
   - Dollar roll vs. carry: drop, breakeven, implied financing; flag when the roll trades "special"
   - Specified-pool pay-ups: which prepay-protection stories (low loan balance, geographic, high LTV, low FICO, investor) and why they matter for premium coupons
   - Prepay context: CPR/SMM/PSA; fast hurts premiums, fast helps discounts
   - Convexity / extension risk note

6. **Synthesize** — Recap narrative + RV calls, each with explicit conditions for reassessment.

## Data Sources

See [references/data-sources.md](references/data-sources.md) for the full, fetchability-tagged source map.

## Output

- **Market Activity Recap** (1–2 paragraphs): rates/curve, current-coupon proxy + spread, supply/demand, Fed, prepay headlines
- **Levels table**: Treasury curve points, current-coupon proxy yield, UMBS coupon prices, computed spreads (each timestamped + sourced)
- **Activity snapshot**: TRACE TBA/spec volumes, SIFMA issuance, Fed operation + SOMA Δ
- **Relative-Value read**: coupon-stack call, dollar-roll vs. carry, specified-pool pay-up framing — each with conditions
- **Prepay / convexity note**
- **`[VERIFY]` list**: terminal-only inputs the user should confirm (OAS, roll drops, pay-up grids)

## Quality Checks

- Every data point is timestamped with an as-of; flag anything older than 2 business days as stale
- Each number cites its source and as-of
- Never present the computed current-coupon spread proxy as a true OAS
- Roll and pay-up reads are marked `[VERIFY]` unless an actual terminal level is supplied
- Settlement class must match the program discussed (UMBS 30y = Class A, etc.)
- Spread proxy methodology (blend weights, benchmark) is stated explicitly
- Distinguish the Fed's own operation results from market-level dollar-roll drops (NY Fed publishes only its operations, not market drops)

## Relative-Value Reference

See [references/relative-value-reference.md](references/relative-value-reference.md) for precise definitions of every metric used in the workflow.
