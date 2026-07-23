# Option B — Release Branch + Cherry‑Pick
This branch demonstrates the second production promotion prototype for the `data-platform-release-branch-cab` reference implementation.

## Rule
`main` takes every merged change.  
A curated `release/*` branch takes only the CAB‑approved ones.

---
## How it works

1. Developers open PRs and merge into this branch freely — no CAB gate at merge time.This branch is the **firehose**: it reflects everything that's been peer‑reviewed and merged, whether or  not CAB has approved it yet.
2. Every merge auto‑deploys to QA, so QA always shows the **full integrated state** of in‑flight work.
3. When it's time for a PROD release, CAB reviews the batch of changes merged since the last release.
4. A release manager cuts a new `release/YYYY-MM-DD` branch off the last PROD commit, then cherry‑picks only the **CAB‑approved commits** onto it — skipping anything rejected.
5. Pushing the `release/*` branch triggers the PROD deploy (gated behind the `production` environment approval, with the CHG# captured in the workflow run for the audit trail).

---

## Why this is different from Option A

- In **Option A**, nothing reaches `main` or QA until CAB approves it — the gate sits before both.  
- In **Option B**, the gate sits only before **PROD**.

`main` and QA move continuously; the release branch is what's actually CAB‑scoped.

