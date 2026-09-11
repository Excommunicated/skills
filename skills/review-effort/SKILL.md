---
name: review-effort
description: Review, verify, and merge a completed work effort from a project's implementation plan, running automated tests, inspecting diffs, cleaning up worktrees, and surfacing unblocked downstream efforts.
disable-model-invocation: true
---

# Review Work Effort

Inspect, verify, and merge an effort created by `execute-effort`. Evaluate code changes against acceptance criteria, run automated tests and linters in the worktree, merge the verified branch, clean up the worktree, update the tracker, and surface unblocked downstream efforts.

---

## 1. Resolve Target Project & Effort ID

1. **Resolve Repository Root**:
   ```bash
   git rev-parse --show-toplevel 2>/dev/null || pwd
   ```
   Set `<repo-root>` to the returned path.

2. **Identify Effort**:
   - Check if `<project-name>` and `<effort-id>` were passed as arguments (e.g., `review-effort auth-service WE-02`).
   - If missing:
     - Inspect `<repo-root>/docs/projects/<project-name>/implementation-plan.md`.
     - Find all efforts currently marked `review_ready`.
     - Display the list and prompt the engineer to select an effort.

3. **Load Context**:
   - Load the effort definition (from `efforts/` or GitHub issue) to retrieve the acceptance criteria checklist.
   - Load `technical-design.md` to reference the Requirements Traceability Matrix and architectural contracts.

**Completion Criterion:** Target effort loaded and acceptance criteria checklist staged for evaluation.

---

## 2. Locate Worktree & Generate Diff

1. **Locate Working Tree**:
   - Check if the worktree exists:
     ```bash
     test -d "<repo-root>/.worktrees/<project-name>-<effort-id>" && echo "WORKTREE_EXISTS"
     ```
   - Set `<target-dir>` to `.worktrees/<project-name>-<effort-id>` if present; otherwise use the current directory on branch `effort/<project-name>/<effort-id>`.
2. **Determine Base Branch**:
   - Typically `main` (or the project's integration branch).
3. **Inspect Diff & Commit History**:
   ```bash
   cd "<target-dir>" && git diff <base-branch>...HEAD
   git log --oneline <base-branch>..HEAD
   ```

**Completion Criterion:** Worktree located and complete diff against base branch isolated.

---

## 3. Two-Axis Verification

Follow [references/review-rubric.md](references/review-rubric.md):

### Axis A: Spec & Traceability Check
- Verify that every acceptance criterion in the work effort is explicitly fulfilled in the diff.
- Confirm changes adhere to `technical-design.md` and introduce no out-of-scope modifications or phantom code.

### Axis B: Automated Test & Quality Check
- Within `<target-dir>`, execute the automated test and build commands (e.g., `npm test`, `pytest`, `cargo test`, `make test`).
- Check code hygiene:
  - Zero debug print statements (`console.log`, `print()`, breakpoints).
  - No committed secrets or `.env` files.
  - No commented-out code blocks.

**Completion Criterion:** All acceptance criteria verified against the diff, and automated builds/tests pass cleanly.

---

## 4. Findings & Remediation Handling

If any test fails, code hygiene violates standards, or criteria remain unfulfilled:
1. Present the findings clearly to the engineer with file paths and line numbers.
2. Offer the engineer a choice:
   - **Fix Now**: Apply the patch directly inside the worktree and re-run automated verification.
   - **Request Changes**: Update the effort status to `changes_requested` in the tracker and `implementation-plan.md`, documenting the requested changes so `execute-effort` can address them.
3. If changes are requested, halt execution and exit cleanly.

**Completion Criterion:** Code passes all checks or is flagged as `changes_requested`.

---

## 5. Approval, Merge & Cleanup

Upon engineer sign-off:

1. **Perform Merge**:
   - **If GitHub Tracker / PR exists**:
     ```bash
     gh pr merge --repo "<repo>" --squash --delete-branch
     ```
   - **If Local Branch**:
     ```bash
     git checkout <base-branch>
     git pull origin <base-branch> 2>/dev/null || true
     git merge --squash "effort/<project-name>/<effort-id>"
     git commit -m "[<project-name>][<effort-id>] Merge: <Effort Title>"
     git branch -D "effort/<project-name>/<effort-id>"
     ```
2. **Remove Isolated Worktree**:
   ```bash
   git worktree remove ".worktrees/<project-name>-<effort-id>" 2>/dev/null || true
   git worktree prune
   ```
3. **Update Documentation & Tracker**:
   - Set status to `completed` in the effort document (`efforts/` or close GitHub issue).
   - In `docs/projects/<project-name>/implementation-plan.md`, update the status column to `completed`.
   - Append review and merge decisions to `docs/projects/<project-name>/decisions.md` (`[DEC-XXX]`).

**Completion Criterion:** Branch merged, worktree cleanly removed, and effort marked `completed`.

---

## 6. Downstream Unblocking Analysis

1. Scan `<repo-root>/docs/projects/<project-name>/implementation-plan.md`.
2. Evaluate all remaining efforts with status `planned`.
3. Check their listed prerequisites:
   - If all prerequisites are now marked `completed`, identify the effort as **Ready for Execution**.
4. Display the unblocked efforts to the engineer:
   > 🚀 **Unblocked Work Efforts**:
   > - `WE-XX`: `<Title>`
   > - `WE-YY`: `<Title>`
   > 
   > Next suggested command: `execute-effort <project-name> <effort-id>`

**Completion Criterion:** Newly unblocked efforts surfaced to the user.

---

## 7. Post-Run Self-Evaluation & Evolutionary Loop

1. **Friction Analysis**:
   - Did diff generation or automated test execution encounter quirks?
   - Was worktree cleanup smooth?
   - Did the unblocking calculation correctly resolve prerequisites?
2. **Formulate Updates**:
   - Propose candidate improvements to `SKILL.md` or `references/review-rubric.md`.
3. **Prompt User**:
   - Ask the user:
     > "Would you like me to update the `review-effort` skill with any improvements based on this run?"
   - If approved, apply updates directly to `~/.agents/skills/review-effort/`.

**Completion Criterion:** Self-evaluation performed and user feedback prompted.
