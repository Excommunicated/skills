---
name: complete-project
description: Finalize and close out a completed project, verifying all work efforts, auditing feature flag status, cleaning up lingering worktrees, and generating a summary and release notes.
disable-model-invocation: true
---

# Complete Project

Perform the final audit and formal closure of a project. Reconcile delivered work efforts against initial requirements, evaluate feature flags for retirement or monitoring, clean up lingering worktrees and branches, generate release documentation (`summary.md`), and update project status to `completed`.

---

## 1. Resolve Target Project & Ingest Artifacts

1. **Resolve Repository Root**:
   ```bash
   git rev-parse --show-toplevel 2>/dev/null || pwd
   ```
   Set `<repo-root>` to the returned path.

2. **Select Target Project**:
   - Check if `<project-name>` was passed as an argument (e.g., `complete-project auth-service-v2`).
   - If missing:
     - Scan `<repo-root>/docs/projects/` for projects where `status != completed` in `project.yml`.
     - Present the list and prompt the user to select one.

3. **Load Project Artifacts**:
   - Load `<repo-root>/docs/projects/<project-name>/project.yml`.
   - Load `brief.md`, `requirements.md`, `technical-design.md`, `decisions.md`, and `implementation-plan.md`.

**Completion Criterion:** Target project selected and all project documentation loaded into context.

---

## 2. Work Efforts & Scope Reconciliation Audit

Consult [references/completion-checklist.md](references/completion-checklist.md):

1. **Inspect Work Efforts**:
   - Scan the Work Efforts Master Index in `implementation-plan.md`.
   - Categorize efforts into `completed` vs. incomplete (`planned`, `in_progress`, `review_ready`, `changes_requested`).
2. **If Incomplete Efforts Remain**:
   - Display the incomplete efforts to the engineer.
   - Offer two paths:
     1. **Abort**: Stop `complete-project` so remaining efforts can be worked on via `execute-effort` / `review-effort`.
     2. **Formally Defer / Abandon**:
        - Prompt for the rationale (e.g. descoped for MVP, moved to future milestone).
        - Update effort status in `implementation-plan.md` to `deferred` or `abandoned`.
        - Log a formal entry in `decisions.md`:
          ```markdown
          ## [DEC-XXX] Defer Remaining Work Efforts for Project Completion
          - **Date**: YYYY-MM-DD
          - **Participants**: Engineer
          - **Decision**: Deferred efforts WE-XX, WE-YY.
          - **Rationale**: <Engineer's rationale>
          - **Impact**: Scope closed for this release.
          ```

**Completion Criterion:** 100% of efforts are accounted for as either `completed`, `deferred`, or `abandoned`.

---

## 3. Feature Flag Audit

If `implementation-plan.md` lists feature flags:

1. Present each flag to the engineer and prompt for its disposition:
   - **Option A (Canary / Active Monitoring)**: Keep flag active; document production monitoring timeline and rollout steps.
   - **Option B (Enabled by Default)**: Update configuration so the flag defaults to `true`.
   - **Option C (Immediate Retirement)**: Remove flag conditional from source code and delete fallback branches.
2. Record the chosen disposition for each flag to be included in `summary.md`.

**Completion Criterion:** Every feature flag audited and next operational steps documented.

---

## 4. Workspace & Branch Hygiene

Clean up dangling worktrees and local branches associated with this project:

1. **Prune Project Worktrees**:
   ```bash
   for wt in $(git worktree list | grep "\.worktrees/<project-name>-" | awk '{print $1}'); do
     echo "Removing worktree: $wt"
     git worktree remove "$wt" 2>/dev/null || true
   done
   git worktree prune
   ```
2. **Prune Merged Branches**:
   ```bash
   git branch --list "effort/<project-name>/*" | while read -r branch; do
     git branch -d "$branch" 2>/dev/null || true
   done
   ```

**Completion Criterion:** No lingering worktrees or stale effort branches remain for this project.

---

## 5. Generate `summary.md`

Render [templates/summary.md.tmpl](templates/summary.md.tmpl) to `<repo-root>/docs/projects/<project-name>/summary.md`:

1. **Executive Summary**: High-level narrative of what was achieved and why.
2. **Requirements Delivery Matrix**: Table mapping original requirements from `requirements.md` to their delivered status.
3. **Work Efforts Delivery Recap**: Final status of all planned, delivered, and deferred efforts.
4. **Feature Flags & Operational Hand-Off**: Action items for production monitoring or future flag cleanup.
5. **Architectural & Scope Decisions Recap**: Key `[DEC-XXX]` entries from `decisions.md`.
6. **Changelog Snippet**: Release notes formatted for inclusion in `CHANGELOG.md` or git release tags.

**Completion Criterion:** `summary.md` written to disk with complete retrospective and release notes.

---

## 6. Update Project Status & Wrap Up

1. In `<repo-root>/docs/projects/<project-name>/project.yml`, update:
   ```yaml
   status: completed
   completed_at: "<ISO-8601-timestamp>"
   ```
2. Print a final summary with clickable links:
   - [`summary.md`](file://<repo-root>/docs/projects/<project-name>/summary.md)
   - [`project.yml`](file://<repo-root>/docs/projects/<project-name>/project.yml)
   - [`implementation-plan.md`](file://<repo-root>/docs/projects/<project-name>/implementation-plan.md)
   - [`decisions.md`](file://<repo-root>/docs/projects/<project-name>/decisions.md)
3. Announce: *"🎉 Project `<project-name>` is formally completed and closed."*

**Completion Criterion:** `project.yml` updated to `completed` and final summary presented.

---

## 7. Post-Run Self-Evaluation & Evolutionary Loop

1. **Friction Analysis**:
   - Did the scope reconciliation audit handle edge cases cleanly?
   - Was the feature flag audit clear?
   - Did workspace cleanup identify all lingering branches?
2. **Formulate Updates**:
   - Propose candidate improvements to `SKILL.md` or `templates/summary.md.tmpl`.
3. **Prompt User**:
   - Ask the user:
     > "Would you like me to update the `complete-project` skill with any improvements based on this run?"
   - If approved, apply updates directly to `~/.agents/skills/complete-project/`.

**Completion Criterion:** Self-evaluation performed and user feedback prompted.
