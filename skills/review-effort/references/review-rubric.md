# Work Effort Review Rubric

This rubric guides the verification, diff inspection, and merge procedures during `review-effort`.

---

## 1. Two-Axis Review Framework

### Axis A: Spec & Requirements Traceability
1. **Acceptance Criteria Verification**:
   - Step through each checkbox in the work effort document.
   - Confirm that the concrete code changes in the git diff fulfill the criterion completely.
2. **Scope Confinement (No Phantom Code)**:
   - Confirm that the diff only touches files relevant to this effort.
   - Ensure changes align with the contracts, schemas, and endpoints defined in `technical-design.md`.
   - Reject unprompted refactorings or cosmetic changes to unrelated files.

### Axis B: Code Quality, Safety & Health
1. **Automated Verification**:
   - Run project builds, type checks, and test suites within the worktree.
   - Verify that all new unit or integration tests pass, and no regression occurs in existing tests.
   - In sandboxed environments that block local loopback socket binding (`127.0.0.1` / `httptest.NewServer`), run loopback listener tests outside the sandbox or explicitly report any skipped tests in the verification summary.
2. **Code Cleanliness & Hygiene**:
   - No leftover debug artifacts (`console.log`, `print()`, debugger breakpoints, `TODO` markers).
   - No commented-out code blocks.
   - No committed secrets, API keys, credentials, or `.env` files.
   - Code adheres to existing repository style and lint standards.

---

## 2. Findings & Remediation Protocol

When a defect or gap is identified during review:

1. **Document the Issue**:
   - Provide the file, line number, and clear description of the defect.
2. **Determine Remediation Path**:
   - **Immediate In-Session Fix**: If the issue is minor (e.g. fixing a typo, adding a missing assertion, removing a debug log), apply the fix in the worktree, re-run tests, and proceed with approval.
   - **Request Changes**: If the issue requires architectural redesign or extensive rework, set effort status to `changes_requested` in the tracker and `implementation-plan.md`, documenting the required changes for `execute-effort`.

---

## 3. Remote PR Pre-Check, Merge & Worktree Cleanup Operations

### A. Remote PR Pre-Check
Before squash merging locally, query GitHub CLI for PR status:
```bash
# Check if PR is already merged remotely
gh pr list --head "effort/<project-name>/<effort-id>" --state merged --json number,title,mergedAt,baseRefName

# Check if an open PR exists
gh pr list --head "effort/<project-name>/<effort-id>" --state open --json number,title,url,baseRefName
```

### B. Merge & Fast-Forward Operations
- **Pre-Check: PR Already Merged Remotely**:
  If the PR was already merged upstream via GitHub UI or CLI, **do not** perform a local squash merge (which would cause local `<base-branch>` to diverge from `origin/<base-branch>`). Seamlessly fetch and fast-forward:
  ```bash
  git checkout <base-branch>
  git fetch origin <base-branch>
  git merge --ff-only origin/<base-branch>
  git branch -D "effort/<project-name>/<effort-id>" 2>/dev/null || true
  ```
- **Pre-Check: Open GitHub PR**:
  Merge the PR via GitHub CLI, then fast-forward the local base branch:
  ```bash
  gh pr merge <pr-number> --repo "<repo>" --squash --delete-branch
  git checkout <base-branch>
  git fetch origin <base-branch>
  git merge --ff-only origin/<base-branch>
  git branch -D "effort/<project-name>/<effort-id>" 2>/dev/null || true
  ```
- **Local Branch Merge (No Remote PR)**:
  ```bash
  git checkout <base-branch>
  git pull origin <base-branch> 2>/dev/null || true
  git merge --squash "effort/<project-name>/<effort-id>"
  git commit -m "[<project-name>][<effort-id>] Merge: <Effort Title>"
  ```

### C. Worktree Cleanup
After a successful merge or fast-forward, remove the isolated worktree using `--force` so gitignored build outputs created inside the worktree (e.g., `bin/`, `frontend/dist/`, `frontend/node_modules/`) do not block removal or prevent `git branch -D`:
```bash
git worktree remove --force ".worktrees/<project-name>-<effort-id>"
git worktree prune
if git show-ref --verify --quiet "refs/heads/effort/<project-name>/<effort-id>"; then
  git branch -D "effort/<project-name>/<effort-id>"
fi
```

---

## 4. Downstream Unblocking Analysis

Once an effort is marked `completed`:
1. Parse the Work Efforts Master Index in `docs/projects/<project-name>/implementation-plan.md`.
2. For each effort with status `planned`:
   - Check its listed `Prerequisites`.
   - If all listed prerequisites are now `completed`, mark the effort as **Ready for Execution**.
3. Display the list of ready efforts to the engineer.
