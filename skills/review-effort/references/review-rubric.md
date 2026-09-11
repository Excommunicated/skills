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

## 3. Merge & Worktree Cleanup Operations

### A. Merge Operations
- **GitHub PR**:
  ```bash
  gh pr merge <pr-number> --repo "<repo>" --squash --delete-branch
  ```
- **Local Branch Merge**:
  ```bash
  git checkout <base-branch>
  git pull origin <base-branch> 2>/dev/null || true
  git merge --squash "effort/<project-name>/<effort-id>"
  git commit -m "[<project-name>][<effort-id>] Merge: <Effort Title>"
  git branch -D "effort/<project-name>/<effort-id>"
  ```

### B. Worktree Cleanup
After a successful merge, remove the isolated worktree:
```bash
git worktree remove ".worktrees/<project-name>-<effort-id>"
git worktree prune
```

---

## 4. Downstream Unblocking Analysis

Once an effort is marked `completed`:
1. Parse the Work Efforts Master Index in `docs/projects/<project-name>/implementation-plan.md`.
2. For each effort with status `planned`:
   - Check its listed `Prerequisites`.
   - If all listed prerequisites are now `completed`, mark the effort as **Ready for Execution**.
3. Display the list of ready efforts to the engineer.
