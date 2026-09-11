---
name: execute-effort
description: Implement a single work effort from a project's implementation plan, working in an isolated git worktree, verifying acceptance criteria with builds and tests, and preparing a review-ready branch.
disable-model-invocation: true
---

# Execute Work Effort

Implement a single work effort (`WE-{NN}`) from a project's `implementation-plan.md`. Isolate development in a dedicated git worktree, implement changes against acceptance criteria, execute builds and test suites to verify correctness, create a clean review-ready commit, and update tracker status.

---

## 1. Resolve Target Project & Effort ID

1. **Resolve Repository Root**:
   ```bash
   git rev-parse --show-toplevel 2>/dev/null || pwd
   ```
   Set `<repo-root>` to the returned path. Projects are located at `<repo-root>/docs/projects/`.

2. **Parse Arguments**:
   - Argument 1: `<project-name>` (e.g. `auth-service-v2`)
   - Argument 2: `<effort-id>` (e.g. `WE-02`)
   - **If `<project-name>` is missing**: List existing projects from `docs/projects/` and prompt the user.
   - **If `<effort-id>` is missing**:
     - Read `<repo-root>/docs/projects/<project-name>/implementation-plan.md`.
     - Find all efforts whose prerequisites are fully satisfied and whose status is `planned`.
     - Display these ready efforts and prompt the user to pick one.

3. **Prerequisite Gating**:
   - Check the selected effort's prerequisites in `implementation-plan.md`.
   - If any prerequisite is not marked `completed` or `review_ready`, issue a warning:
     > ⚠️ **Warning**: Prerequisite effort `<prereq-id>` has not been marked completed. Proceeding may cause merge conflicts or missing dependencies. Do you want to proceed anyway?
   - If the user confirms, continue.

**Completion Criterion:** Target project and effort identified, and prerequisite status confirmed.

---

## 2. Load Effort & Architecture Context

1. **Load Effort Definition**:
   - **Local Tracker**: Read `<repo-root>/docs/projects/<project-name>/efforts/{{EFFORT_FILE}}`.
   - **GitHub Tracker**: Read issue details via `gh issue view <issue-number>`.
   - Ingest the Summary, Acceptance Criteria, and Implementation Notes.
2. **Load Architectural Context**:
   - Ingest `<repo-root>/docs/projects/<project-name>/technical-design.md`.
   - Review the Requirements Traceability Matrix and target files relevant to this effort.

**Completion Criterion:** Effort checklist, acceptance criteria, and target files loaded into context.

---

## 3. Isolated Workspace Setup via Git Worktree

Consult [references/execution-guide.md](references/execution-guide.md):

1. **Ensure `.gitignore` Safety**:
   ```bash
   grep -qxF ".worktrees/" .gitignore 2>/dev/null || echo -e "\n# Git worktrees for parallel efforts\n.worktrees/" >> .gitignore
   ```
2. **Create Git Worktree**:
   ```bash
   git worktree add -b "effort/<project-name>/<effort-id>" ".worktrees/<project-name>-<effort-id>" HEAD
   ```
   - **Fallback**: If worktree creation fails (e.g. detached HEAD or unsupported state), create and checkout a local branch in the current tree:
     ```bash
     git checkout -b "effort/<project-name>/<effort-id>"
     ```
3. Set working directory `<work-dir>` to the worktree path (or repo root if using fallback branch).

**Completion Criterion:** Worktree created and active branch set to `effort/<project-name>/<effort-id>`.

---

## 4. Implementation & Verification Loop

Within `<work-dir>`:

1. **Execute Changes**:
   - Modify or create target files as specified in the effort notes and `technical-design.md`.
   - Follow existing project conventions, formatting, and abstractions.
2. **Build & Test Verification**:
   - Auto-detect test/build tools using [references/execution-guide.md](references/execution-guide.md).
   - Run the appropriate test and build commands (e.g., `npm test`, `pytest`, `cargo test`, `make build`).
   - Add new tests if required to cover the new functionality.
   - Verify that all acceptance criteria checkboxes pass.

**Completion Criterion:** All code changes implemented and all automated builds and tests pass cleanly.

---

## 5. Commit Changes

1. Stage modified source files:
   ```bash
   git add <target-files>
   ```
2. Create a clean, descriptive commit following [references/execution-guide.md](references/execution-guide.md):
   ```bash
   git commit -m "[<project-name>][<effort-id>] <Effort Title>

   Summary:
   <Summary of changes>

   Acceptance Criteria:
   - [x] Criterion 1
   - [x] Criterion 2"
   ```

**Completion Criterion:** Changes committed to git branch with structured commit message.

---

## 6. Update Documentation & Tracker

1. **Update Effort Document**:
   - **Local Tracker**: In `docs/projects/<project-name>/efforts/WE-{NN}-...md`:
     - Set frontmatter: `status: review_ready`.
     - Check off all completed acceptance criteria checkboxes: `- [x]`.
   - **GitHub Tracker**:
     - Post a comment on the GitHub issue with verification summary.
     - Update issue labels: remove `status:planned`, add `status:review-ready`.
     - If requested, push the branch and open a PR:
       ```bash
       git push -u origin "effort/<project-name>/<effort-id>"
       gh pr create --title "[<project-name>][<effort-id>] <Effort Title>" --body "Resolves #<issue-number>"
       ```
2. **Update Implementation Plan**:
   - In `<repo-root>/docs/projects/<project-name>/implementation-plan.md`, update the status cell for `<effort-id>` to `review_ready`.
3. **Display Completion Summary**:
   - Output:
     - Branch: `effort/<project-name>/<effort-id>`
     - Worktree Path: [`.worktrees/<project-name>-<effort-id>`](file://.worktrees)
     - Modified Files list with clickable links.
     - Notice: *"Effort complete and ready for engineer review or PR merge."*

**Completion Criterion:** Tracker and documentation updated to reflect `review_ready` status.

---

## 7. Post-Run Self-Evaluation & Evolutionary Loop

1. **Friction Analysis**:
   - Did test runner detection work smoothly?
   - Were worktrees easy to manage?
   - Did any acceptance criteria feel vague during coding?
2. **Formulate Updates**:
   - Propose candidate improvements to `SKILL.md` or `references/execution-guide.md`.
3. **Prompt User**:
   - Ask the user:
     > "Would you like me to update the `execute-effort` skill with any improvements based on this run?"
   - If approved, apply updates directly to `~/.agents/skills/execute-effort/`.

**Completion Criterion:** Self-evaluation performed and user feedback prompted.
