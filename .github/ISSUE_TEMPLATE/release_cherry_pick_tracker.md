
# Release Cherry-Pick Tracker

**Name:** Release Cherry-Pick Tracker  
**About:** Track which commits are approved, shipped, or skipped for a release branch  
**Title:** Release YYYY-MM-DD — Cherry-Pick Tracker  
**Labels:** release-tracking  
**Assignees:** 

## Release Branch
release/YYYY-MM-DD  
Cut from: release/<previous-release-date>

## Commits Under Consideration
Commit Hash | CHG # | Status | Notes
----------- | ------ | ------ | -----
<hash> | CHG____ | Proposed / Approved / Skipped / Shipped | 

### Status definitions:
- **Proposed** — merged to main, awaiting CAB decision
- **Approved** — CAB approved, not yet cherry-picked
- **Skipped** — CAB reviewed and declined, OR intentionally held back this release (explain in Notes)
- **Shipped** — cherry-picked onto this release branch and deployed to PROD

## Skip Reasons
If any commit is Skipped, one line here explaining why — so nobody has to guess later.

## Release Manager
Who is cutting this release and doing the cherry-picks.

## Deploy Checklist
- Release branch cut from previous release branch tip
- All Approved commits cherry-picked via PR against this release branch (not direct push)
- Each cherry-pick PR reviewed before merge
- PROD deploy approved
- prod-current tag moved to this branch’s tip
- This issue closed with final status of every commit
