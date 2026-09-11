# Project Completion Checklist & Reference

This reference guides the final audit, feature flag evaluation, workspace cleanup, and release documentation during `complete-project`.

---

## 1. Work Efforts Reconciliation

Before closing a project:
1. Parse `docs/projects/<project-name>/implementation-plan.md`.
2. Inspect the status of every listed effort:
   - **All `completed`**: Project is ready for full closure.
   - **Incomplete efforts exist (`planned`, `in_progress`, `review_ready`, `changes_requested`)**:
     - Prompt the engineer:
       - **Finish Efforts**: Abort `complete-project` so unfinished work can be completed via `execute-effort` / `review-effort`.
       - **Formally Defer/Abandon**: If scope was intentionally dropped, update the effort's status in `implementation-plan.md` to `deferred` or `abandoned`, and log an entry in `decisions.md` explaining the business or technical reason.

---

## 2. Requirements Delivery Verification

Cross-reference `requirements.md` with the delivered code:
- Ensure all `FR-X` and `NFR-X` requirements marked as in-scope have been accounted for.
- Note any requirements that were descoped or deferred during technical design or execution.

---

## 3. Feature Flag Operational Lifecycle

If feature flags were registered for this project:

| Decision Path | Actions Required |
| :--- | :--- |
| **Canary / Active Monitoring** | Leave flag in place. Document rollout timeline, monitoring dashboard, and target retirement date in `summary.md`. |
| **Enabled by Default** | Toggle default value to `true` in configuration. Schedule flag removal for a future maintenance effort. |
| **Immediate Retirement** | Remove flag conditionals from code, remove configuration key, delete dead fallback branch, and verify tests pass. |

---

## 4. Repository & Worktree Cleanup

Ensure no dangling branches or worktrees clutter the repo:

1. **List Worktrees**:
   ```bash
   git worktree list
   ```
2. **Remove Project Worktrees**:
   ```bash
   for wt in $(git worktree list | grep "\.worktrees/<project-name>-" | awk '{print $1}'); do
     git worktree remove "$wt" 2>/dev/null || true
   done
   git worktree prune
   ```
3. **Delete Merged Effort Branches**:
   ```bash
   git branch --list "effort/<project-name>/*" | while read -r branch; do
     git branch -d "$branch" 2>/dev/null || true
   done
   ```

---

## 5. Project Metadata Closure

1. In `<repo-root>/docs/projects/<project-name>/project.yml`:
   - Set `status: completed`
   - Set `completed_at: "<ISO-8601-timestamp>"`
2. Write `<repo-root>/docs/projects/<project-name>/summary.md`.
