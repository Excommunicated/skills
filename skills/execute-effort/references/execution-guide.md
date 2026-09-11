# Effort Execution Guide

This guide details environment setup, test runner detection, worktree handling, and tracker update procedures for `execute-effort`.

---

## 1. Worktree Lifecycle & Isolation

Working in an isolated git worktree allows multiple efforts to be developed simultaneously without branch-switching conflicts in the main working tree.

### A. Ensure `.gitignore` Protection
Before creating any worktree under `.worktrees/`, ensure `.gitignore` contains the entry:
```bash
grep -qxF ".worktrees/" .gitignore 2>/dev/null || echo -e "\n# Git worktrees for parallel efforts\n.worktrees/" >> .gitignore
```

### B. Creating a Worktree
```bash
git worktree add -b "effort/<project-name>/<effort-id>" ".worktrees/<project-name>-<effort-id>" HEAD
```

### C. Fallback (If Worktree Fails)
If worktrees fail (e.g. detached HEAD or unsupported environment):
```bash
git checkout -b "effort/<project-name>/<effort-id>"
```

### D. Worktree Cleanup (After Merge / Review)
To remove a completed worktree:
```bash
git worktree remove ".worktrees/<project-name>-<effort-id>"
git branch -d "effort/<project-name>/<effort-id>"
```

---

## 2. Test & Build Runner Auto-Detection

When verifying acceptance criteria, inspect the repository configuration to run the appropriate build and test commands:

| Stack / Ecosystem | Detection Indicator | Verification Command |
| :--- | :--- | :--- |
| **Node / TypeScript** | `package.json` | `npm test` (or `pnpm test` / `yarn test` / `bun test`), `npm run build` |
| **Python** | `pyproject.toml`, `setup.py` | `pytest` (or `poetry run pytest` / `pipenv run pytest`) |
| **Rust** | `Cargo.toml` | `cargo test`, `cargo check` |
| **Go** | `go.mod` | `go test ./...`, `go build ./...` |
| **Makefile** | `Makefile` | `make test`, `make build` |

If no test suite exists, run a local syntax check, typecheck (e.g., `tsc --noEmit`), or manual script invocation as specified in the effort's notes.

---

## 3. Commit Message Standard

Commits created by `execute-effort` must clearly document the effort and verified criteria:

```text
[{{PROJECT_NAME}}][{{EFFORT_ID}}] {{EFFORT_TITLE}}

Summary:
{{SUMMARY}}

Acceptance Criteria:
- [x] {{CRITERION_1}}
- [x] {{CRITERION_2}}
```

---

## 4. Tracker Update Contracts

### A. Local Files Tracker (`local`)
1. In `docs/projects/<project-name>/efforts/WE-{NN}-...md`:
   - Update frontmatter: `status: review_ready`
   - Check off all completed acceptance criteria checkboxes: `- [x]`
2. In `docs/projects/<project-name>/implementation-plan.md`:
   - Update the status column for `WE-{NN}` to `review_ready`

### B. GitHub Issues Tracker (`github`)
1. Add comment to the GitHub issue with verification results:
   ```bash
   gh issue comment <issue-number> --repo "<repo>" --body "Effort implemented in branch \`effort/<project-name>/<effort-id>\`. All acceptance criteria verified."
   ```
2. Update labels:
   ```bash
   gh issue edit <issue-number> --repo "<repo>" --remove-label "status:planned" --add-label "status:review-ready"
   ```
3. If requested by the engineer, create a Pull Request:
   ```bash
   git push -u origin "effort/<project-name>/<effort-id>"
   gh pr create --repo "<repo>" --title "[{{PROJECT_NAME}}][{{EFFORT_ID}}] {{EFFORT_TITLE}}" --body "Resolves #<issue-number>"
   ```
4. In `docs/projects/<project-name>/implementation-plan.md`:
   - Update the status column for `WE-{NN}` to `review_ready`.
