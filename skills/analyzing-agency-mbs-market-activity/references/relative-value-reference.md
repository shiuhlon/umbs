# Relative-Value Reference

Precise definitions to support agency MBS relative-value analysis:

- **TBA / dollar roll:** forward agency pass-through (pools announced 48h pre-settle under SIFMA good-delivery); a roll = offsetting near/far TBA pair = collateralized MBS financing.
  - *Drop* = front price − back price (32nds), normally positive (front holder earns coupon + paydown).
  - *Breakeven drop* = drop equating carry given up to price give-up; `actual drop > breakeven` favors rolling.
  - *Implied financing* = MBS funding rate implied by the drop; larger drop ⇒ lower implied rate.
  - *"Special"* = implied financing below GC repo (strong demand to be long the front month).
- **Current coupon:** par-priced TBA coupon, interpolated between the two coupons bracketing par.
  - *CC spread* = CC yield − benchmark (5s/10s blend, or swaps). Blend weights are dealer convention `[VERIFY]`.
- **Spread measures:** nominal (single Treasury) vs. Z-spread (constant spread over the spot curve) — typically nominal < Z-spread on a normal/upward-sloping curve, but the ordering can reverse on an inverted curve; OAS = spread over all simulated paths, strips the prepay option (`OAS ≈ Z-spread − option cost`; for negatively convex MBS `OAS < Z-spread`). OAS is model- and vol-dependent.
- **Specified-pool pay-ups:** premium over generic TBA (32nds) for prepay protection; stories: low loan balance ($85k–$200k caps), geographic (slow-turnover/high-tax states), high LTV, low FICO, investor/non-owner-occupied. Most valuable for premium coupons.
- **Prepay conventions:** SMM = monthly; CPR = `1 − (1 − SMM)^12`; PSA = SIFMA ramp (100% PSA → 0.2%/mo to 6% CPR at month 30, then flat). Fast speeds hurt premiums (par returned on >par bond), help discounts (faster pull-to-par).
- **Coupon stack RV:** up-in-coupon = more carry/yield, shorter duration, more negative convexity, extension/contraction risk; down-in-coupon = longer duration, better convexity, rally upside.
- **WAC/WALA/WAM:** gross WAC = wtd note rate; net/pass-through coupon = gross WAC − servicing − g-fee; WALA = wtd loan age; WAM = wtd remaining term; `WALA + WAM ≈ original term`.
- **Convexity:** MBS are negatively convex (borrower prepay option) — rates fall → prepays speed, duration shortens, capped rally; rates rise → cash flows extend, effective duration lengthens (extension risk), fuller downside.
