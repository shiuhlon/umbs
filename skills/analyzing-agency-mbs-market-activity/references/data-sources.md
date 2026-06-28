# Data Sources

Verified 2026-06-27. Fetchability tag reflects whether the skill's automated `WebFetch` can read the resource (static HTML/file = yes; JS-app / login / 403 = no).

## Tier 1 — Auto-fetch (static, no login)

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

## Tier 2 — Free but needs `curl`/API, registration, or login

| Source | Access note |
|---|---|
| FRED (`DGS2/5/7/10/30`, `MORTGAGE30US`, `WSHOMCB`) | WebFetch 403s FRED; use `curl 'https://fred.stlouisfed.org/graph/fredgraph.csv?id=<ID>'` (no key) or the FRED API with a free key |
| Fannie Mae Data Dynamics / PoolTalk | Free but registration + JS app; not anonymously fetchable |
| Freddie Mac Clarity | Free to participants but login + JS |
| Ginnie Mae bulk disclosure files | Free account on `bulk.ginniemae.gov` |
| Optimal Blue OBMMI | JS charts → use FRED `OBMMI*` series for numbers |

## Tier 3 — Terminal-only → mark `[VERIFY]`

OAS, effective duration/convexity (Bloomberg, LSEG Yield Book, ICE Data Services); dollar-roll drops/breakevens/implied financing (Bloomberg, TradeWeb, dealer runs); specified-pool pay-up grids (Bloomberg, TradeWeb, eMBS/ICE, dealer desks); loan-level prepay/cash-flow analytics (eMBS, Intex, CoreLogic, Recursion).

## Source caveats

- **No free ICE BofA MBS OAS series exists on FRED** (release 209 covers Corporate/HY/EM only). Compute a proxy spread instead; never label it OAS.
- 5s/10s blend weights for the current-coupon spread are a dealer convention — mark `[VERIFY]`.
- MND MBS prices are delayed/EOD; live intraday is paid (MBS Live). Build a null check (occasional data-provider outage banner).
- CME UMBS TBA futures page is real but 403s scripted fetches; browser-only.
- Fannie `capitalmarkets.fanniemae.com` domain returns 403 to WebFetch across the board.
