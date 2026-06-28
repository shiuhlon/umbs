# umbs

Claude Code **skills** for UMBS / agency MBS trading-market-activity analysis.

## Skills

| Skill | What it does |
|-------|--------------|
| [`analyzing-agency-mbs-market-activity`](skills/analyzing-agency-mbs-market-activity/SKILL.md) | Produces an agency MBS (UMBS Fannie/Freddie + Ginnie) market-activity recap that culminates in a relative-value read (coupon stack, dollar roll, specified-pool pay-ups). Hybrid data approach: auto-fetches free public sources (SIFMA, FINRA TRACE, NY Fed, GSE prepay tools, FRED) and marks terminal-only data (OAS, roll levels, pay-up grids) `[VERIFY]`. |

> A private-label / non-agency RMBS skill is planned as a separate addition.

## Install

These skills install with [`skills`](https://github.com/vercel-labs/skills) (the [skills.sh](https://www.skills.sh) CLI) via `npx` — no global install needed.

```bash
# Install all skills from this repo into the current project
npx skills add shiuhlon/umbs

# Preview what's in the repo first
npx skills add shiuhlon/umbs --list

# Install just the agency MBS skill
npx skills add shiuhlon/umbs --skill analyzing-agency-mbs-market-activity

# Install globally (all projects), targeting Claude Code, no prompts
npx skills add shiuhlon/umbs -g -a claude-code -y
```

Flags: `--list` shows available skills, `--skill <name>` selects one (repeatable; `'*'` for all), `-g` installs globally instead of project-local, `-a <agent>` targets an agent (`claude-code`, `cursor`, `opencode`, …), `-y` skips confirmation prompts.

## Use

Claude Code discovers installed `SKILL.md` files at the start of a session. Once installed, invoke the skill by asking for an agency MBS market recap / relative-value read, or with `/analyzing-agency-mbs-market-activity`.

The skill ships a helper for the one source Claude Code's web fetch can't read (FRED 403s automated fetches):

```bash
skills/analyzing-agency-mbs-market-activity/scripts/fetch_fred.sh DGS2 DGS5 DGS7 DGS10 DGS30 MORTGAGE30US WSHOMCB
```
