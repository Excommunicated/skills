---
name: review-effort
description: Review, verify, and merge a completed work effort from a project's implementation plan, pre-checking remote PR status to prevent integration branch divergence, running automated tests, inspecting diffs, cleaning up worktrees, and surfacing unblocked downstream efforts.
disable-model-invocation: true
---

# Review Work Effort

Inspect, verify, and merge an effort created by `execute-effort`. Pre-check remote PR status (`gh pr list --state merged / open`) to prevent branch divergence on integration branches like `develop`, evaluate code changes against acceptance criteria, run automated tests and linters in the worktree, merge or fast-forward the verified branch, clean up the worktree, update the tracker, and surface unblocked downstream efforts.

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

## 2. Remote PR Pre-Check & Worktree Resolution

1. **Remote PR Pre-Check**:
   Before inspecting local diffs or attempting merges, check GitHub CLI to determine if a PR was opened or already merged remotely for the effort branch `effort/<project-name>/<effort-id>`:
   ```bash
   # Check if PR has already been merged remotely
   gh pr list --head "effort/<project-name>/<effort-id>" --state merged --json number,title,mergedAt,baseRefName

   # Check if an open PR exists
   gh pr list --head "effort/<project-name>/<effort-id>" --state open --json number,title,url,baseRefName
   ```

   - **Case A: PR Already Merged Remotely (`--state merged`)**:
     - A pull request for this effort was opened and merged via GitHub UI or CLI prior to running `review-effort`.
     - **Divergence Prevention**: Merging locally via squash merge directly on `<base-branch>` (e.g., `develop` or `main`) would cause local `<base-branch>` to diverge from `origin/<base-branch>` by generating redundant local commits.
     - **Action**:
       1. Set `<base-branch>` to `baseRefName` from the PR JSON (default to `develop` or `main` if unset).
       2. Inform the engineer:
          > ℹ️ **Remote PR Already Merged**: PR #`<number>` (`<title>`) was already merged into `<base-branch>` on GitHub. Skipping redundant local squash merge to prevent branch divergence.
       3. Seamlessly fetch and fast-forward the base branch from origin:
          ```bash
          git checkout <base-branch>
          git fetch origin <base-branch>
          git merge --ff-only origin/<base-branch>
          ```
       4. Delete the local effort branch if present:
          ```bash
          git branch -D "effort/<project-name>/<effort-id>" 2>/dev/null || true
          ```
       5. Clean up the isolated worktree (proceed directly to **Section 5.2** and **Section 5.3** for documentation/tracker completion and **Section 6** for downstream unblocking).

   - **Case B: PR Open Remotely (`--state open`)**:
     - An active pull request (`#<number>`) is open on GitHub.
     - Set `<base-branch>` to `baseRefName` (e.g., `develop` or `main`).
     - Proceed with worktree location, two-axis verification, and subsequent squash merge via `gh pr merge <pr-number> --squash --delete-branch` followed by fast-forwarding `<base-branch>`.

   - **Case C: No Remote PR Found (Local Branch)**:
     - No PR exists remotely or GitHub CLI is unavailable.
     - Fall back to standard local verification and local branch squash merge.

2. **Locate Working Tree**:
   - Check if the worktree exists:
     ```bash
     test -d "<repo-root>/.worktrees/<project-name>-<effort-id>" && echo "WORKTREE_EXISTS"
     ```
   - Set `<target-dir>` to `.worktrees/<project-name>-<effort-id>` if present; otherwise use the current directory on branch `effort/<project-name>/<effort-id>`.

3. **Determine Base Branch**:
   - Use `baseRefName` resolved from the remote PR pre-check if available.
   - Otherwise, detect the repository integration branch: check for `develop`, falling back to `main` (or project default).

4. **Inspect Diff & Commit History**:
   ```bash
   cd "<target-dir>" && git diff <base-branch>...HEAD
   git log --oneline <base-branch>..HEAD
   ```
   - If an open PR exists, PR diff and review comments can also be inspected via:
     ```bash
     gh pr diff <pr-number>
     ```

**Completion Criterion:** Remote PR status resolved, base branch determined, worktree located, and complete diff isolated (or fast-forward completed if PR was already merged).

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

Upon engineer sign-off (or when executing post-merge sync):

1. **Perform Merge & Fast-Forward**:
   - **If PR was Already Merged Remotely (Case A)**:
     - Remote PR was already merged upstream. Ensure local base branch is fast-forwarded from origin:
       ```bash
       git checkout <base-branch>
       git fetch origin <base-branch>
       git merge --ff-only origin/<base-branch>
       git branch -D "effort/<project-name>/<effort-id>" 2>/dev/null || true
       ```
   - **If Open GitHub PR Exists (Case B)**:
     - Merge via GitHub CLI with squash and remote branch deletion:
       ```bash
       gh pr merge <pr-number> --repo "<repo>" --squash --delete-branch
       ```
     - Fast-forward the local base branch from origin to prevent local divergence:
       ```bash
       git checkout <base-branch>
       git fetch origin <base-branch>
       git merge --ff-only origin/<base-branch>
       git branch -D "effort/<project-name>/<effort-id>" 2>/dev/null || true
       ```
   - **If Local Branch (No Remote PR - Case C)**:
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
   - **If Tracker is `local`**:
     - Set status to `completed` in the effort document (`docs/projects/<project-name>/efforts/WE-{NN}-...md`).
   - **If Tracker is `github`**:
     - Synchronize issue labels:
       ```bash
       gh issue edit <issue-number> --repo "<repo>" --remove-label status:review-ready --add-label status:completed
       ```
     - Close the GitHub issue (if not already closed):
       ```bash
       gh issue close <issue-number> --repo "<repo>" --reason "completed" 2>/dev/null || true
       ```
   - In `docs/projects/<project-name>/implementation-plan.md`, update the status column to `completed`.
   - Append review and merge decisions to `docs/projects/<project-name>/decisions.md` (`[DEC-XXX]`).

**Completion Criterion:** Branch merged or fast-forwarded from origin, worktree cleanly removed, and effort marked `completed`.

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
