# Design: `analyzing-agency-mbs-market-activity` skill

**Date:** 2026-06-27
**Status:** Approved (brainstorming complete)
**Author:** Duncan Chen (with Claude Code)

## Summary

A Claude Code skill that, when invoked, produces a point-in-time **agency MBS
trading-market-activity recap** that culminates in an actionable **relative-value
(RV) read**. Covers UMBS (Fannie Mae / Freddie Mac uniform pass-throughs) and
Ginnie Mae. It uses a **hybrid** data approach: actively fetches the free public
data it can reliably get, and falls back to guided `[VERIFY]` inputs for
terminal-only data (OAS, dollar-roll levels, specified-pool pay-ups).

This is the first of two planned skills. A separate private-label / non-agency
RMBS skill will be designed later as its own spec → plan → implementation cycle.

### Decisions locked during brainstorming
- **Market scope:** UMBS + Ginnie agency MBS only. Private-label is a separate, later skill.
- **Primary job:** Market activity recap **and** relative-value analysis in one skill.
- **Data approach:** Hybrid — auto-fetch free public data; `[VERIFY]` for terminal-only data.
- **Location:** Inside this `umbs` repo (version-controlled, packageable).

## Naming & convention

- **Skill name:** `analyzing-agency-mbs-market-activity`
- Follows the gerund-phrase convention of the sibling skills
  (`conducting-debt-market-conditions-analysis`,
  `managing-loan-trading-and-settlement`).
- Covers all three agencies even though "UMBS" technically excludes Ginnie; the
  recap spans UMBS 30y/15y and Ginnie II.

## File layout

- **Skill:** `skills/analyzing-agency-mbs-market-activity/SKILL.md` (in this repo).
- **Spec:** this file.
- Optionally install/symlink into `~/.claude/skills/` so it is usable across
  projects; that is an install step, not part of the skill source.

## Skill structure

Mirrors `conducting-debt-market-conditions-analysis`:

1. Frontmatter (`name`, `description`, `tags`, `metadata`)
2. Title + one-line summary
3. **When To Use**
4. **Inputs To Gather**
5. **Workflow**
6. **Data Sources** (the web-resource map, fetchability-tagged) — *new vs. sibling*
7. **Output**
8. **Quality Checks**
9. **Relative-Value Reference** (appendix of precise definitions) — *new vs. sibling*

### Frontmatter (draft)

```yaml
name: analyzing-agency-mbs-market-activity
description: Synthesizes UMBS / agency MBS (Fannie, Freddie, Ginnie) trading market activity — TBA prices, spreads, trading volumes, Fed activity, prepay trends — and produces a relative-value read (coupon stack, dollar roll, specified-pool pay-ups). Use when recapping the agency MBS market or assessing relative value across the coupon stack.
tags:
  - process
  - mortgage-backed-securities
  - trading
```

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
   - Treasury constant-maturity yields: FRED `DGS2`, `DGS5`, `DGS7`, `DGS10`, `DGS30` (via `curl` on `fredgraph.csv?id=…` — WebFetch is 403'd on FRED)
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

Verified 2026-06-27. Fetchability tag reflects whether the skill's automated
`WebFetch` can read the resource (static HTML/file = yes; JS-app / login / 403 = no).

### Tier 1 — Auto-fetch (static, no login)
| Source | URL | Provides |
|---|---|---|
| Freddie PMMS page | `https://www.freddiemac.com/pmms` | Weekly 30y/15y avg mortgage rate |
| Freddie PMMS history | `https://www.freddiemac.com/pmms/docs/historicalweeklydata.xlsx` | Weekly rates since 1971 (.xlsx) |
| Mortgage News Daily — rates | `https://www.mortgagenewsdaily.com/mortgage-rates` | Daily MND rate index |
| Mortgage News Daily — MBS | `https://www.mortgagenewsdaily.com/mbs` | EOD UMBS coupon prices (current-coupon proxy) |
| MND — MBA applications mirror | `https://www.mortgagenewsdaily.com/data/mortgage-applications` | Weekly MBA purchase/refi index (free mirror) |
| SIFMA — settlement calendar | `https://www.sifma.org/resources/guides-playbooks/mbs-notification-and-settlement-dates` | TBA notification + settlement dates |
| SIFMA — settlement calendar file | `https://www.sifma.org/wp-content/uploads/2024/08/SIFMASettlementDatesCalendar-2026.xlsx` | 2026 calendar (.xlsx) |
| SIFMA — US MBS statistics | `https://www.sifma.org/research/statistics/us-mortgage-backed-securities-statistics` | Issuance + avg daily trading volume |
| FINRA TRACE — volume reports | `https://www.finra.org/finra-data/browse-catalog/trace-volume-reports/about-trace-monthly-volume-reports` | Monthly TBA vs. spec-pool volumes |
| FINRA TRACE — volume report catalog | `https://www.finra.org/filing-reporting/trace/content-licensing/volume-reports` | Volume report files |
| NY Fed — agency MBS schedule | `https://www.newyorkfed.org/markets/ambs_operation_schedule` | Tentative operation schedule |
| NY Fed — agency MBS results/history | `https://www.newyorkfed.org/markets/ambs/ambs_schedule` | Historical operation results |
| NY Fed — transaction summary | `https://www.newyorkfed.org/markets/ambs/transaction-summary` | Operation transaction detail |
| Ginnie Mae — GMAR | `https://www.ginniemae.gov/data_and_reports/reporting/Pages/global_market_analysis.aspx` | Monthly issuance + prepay PDF |

### Tier 2 — Free but needs `curl`/API, registration, or login
| Source | Access note |
|---|---|
| FRED (`DGS2/5/7/10/30`, `MORTGAGE30US`, `WSHOMCB`) | WebFetch 403s FRED; use `curl 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=<ID>'` (no key) or the FRED API with a free key |
| Fannie Mae Data Dynamics / PoolTalk | Free but registration + JS app; not anonymously fetchable |
| Freddie Mac Clarity | Free to participants but login + JS |
| Ginnie Mae bulk disclosure files | Free account on `bulk.ginniemae.gov` |
| Optimal Blue OBMMI | JS charts → use FRED `OBMMI*` series for numbers |

### Tier 3 — Terminal-only → mark `[VERIFY]`
OAS, effective duration/convexity (Bloomberg, LSEG Yield Book, ICE Data Services);
dollar-roll drops/breakevens/implied financing (Bloomberg, TradeWeb, dealer runs);
specified-pool pay-up grids (Bloomberg, TradeWeb, eMBS/ICE, dealer desks);
loan-level prepay/cash-flow analytics (eMBS, Intex, CoreLogic, Recursion).

### Source caveats
- **No free ICE BofA MBS OAS series exists on FRED** (release 209 covers Corporate/HY/EM only). Compute a proxy spread instead; never label it OAS.
- 5s/10s blend weights for the current-coupon spread are a dealer convention — mark `[VERIFY]`.
- MND MBS prices are delayed/EOD; live intraday is paid (MBS Live). Build a null check (occasional data-provider outage banner).
- CME UMBS TBA futures page is real but 403s scripted fetches; browser-only.
- Fannie `capitalmarkets.fanniemae.com` domain returns 403 to WebFetch across the board.

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

## Relative-Value Reference (appendix content)

Precise definitions to embed so the skill's reasoning is correct:

- **TBA / dollar roll:** forward agency pass-through (pools announced 48h pre-settle under SIFMA good-delivery); a roll = offsetting near/far TBA pair = collateralized MBS financing.
  - *Drop* = front price − back price (32nds), normally positive (front holder earns coupon + paydown).
  - *Breakeven drop* = drop equating carry given up to price give-up; `actual drop > breakeven` favors rolling.
  - *Implied financing* = MBS funding rate implied by the drop; larger drop ⇒ lower implied rate.
  - *"Special"* = implied financing below GC repo (strong demand to be long the front month).
- **Current coupon:** par-priced TBA coupon, interpolated between the two coupons bracketing par.
  - *CC spread* = CC yield − benchmark (5s/10s blend, or swaps). Blend weights are dealer convention `[VERIFY]`.
- **Spread measures:** nominal (single Treasury) < Z-spread (constant spread over the spot curve) ; OAS = spread over all simulated paths, strips the prepay option (`OAS ≈ Z-spread − option cost`; for negatively convex MBS `OAS < Z-spread`). OAS is model- and vol-dependent.
- **Specified-pool pay-ups:** premium over generic TBA (32nds) for prepay protection; stories: low loan balance ($85k–$200k caps), geographic (slow-turnover/high-tax states), high LTV, low FICO, investor/non-owner-occupied. Most valuable for premium coupons.
- **Prepay conventions:** SMM = monthly; CPR = `1 − (1 − SMM)^12`; PSA = SIFMA ramp (100% PSA → 0.2%/mo to 6% CPR at month 30, then flat). Fast speeds hurt premiums (par returned on >par bond), help discounts (faster pull-to-par).
- **Coupon stack RV:** up-in-coupon = more carry/yield, shorter duration, more negative convexity, extension/contraction risk; down-in-coupon = longer duration, better convexity, rally upside.
- **WAC/WALA/WAM:** gross WAC = wtd note rate; net/pass-through coupon = gross WAC − servicing − g-fee; WALA = wtd loan age; WAM = wtd remaining term; `WALA + WAM ≈ original term`.
- **Convexity:** MBS are negatively convex (borrower prepay option) — rates fall → prepays speed, duration shortens, capped rally; rates rise → cash flows extend, effective duration lengthens (extension risk), fuller downside.

## Out of scope (this skill)

- Private-label / non-agency RMBS (separate future skill)
- Live intraday pricing / paid-terminal data ingestion
- CMO/REMIC structuring, deal cash-flow modeling
- Trade execution, settlement mechanics (covered by `managing-loan-trading-and-settlement`)
