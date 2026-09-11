---
name: plan-effort
description: Decompose a project's technical design into vertical, independently shippable work efforts (WE-{NN}) with dependencies, feature flags, and an implementation plan hub.
disable-model-invocation: true
---

# Plan Work Efforts

Decompose a project's `technical-design.md` into vertically sliced, independently shippable work efforts (`WE-{NN}`). Map technical dependencies into a clean DAG, identify feature flags for post-MVP safety, establish a local `implementation-plan.md` tracking hub, and batch-create efforts in the configured issue tracker (`github` or `local`).

---

## 1. Resolve Target Project & Pre-Flight Check

1. **Determine Repository Root**:
   ```bash
   git rev-parse --show-toplevel 2>/dev/null || pwd
   ```
   Set `<repo-root>` to the returned path. Projects are located at `<repo-root>/docs/projects/`.

2. **Select Target Project**:
   - Check if `<project-name>` was passed as an invocation argument (e.g., `plan-effort auth-service-v2`).
   - If missing, list available projects:
     ```bash
     ls -1 "<repo-root>/docs/projects" 2>/dev/null
     ```
     Prompt the user to select one.

3. **Validate Prerequisites**:
   - Verify `<repo-root>/docs/projects/<project-name>/technical-design.md` exists. If missing, warn:
     > ⚠️ **Prerequisite missing**: `technical-design.md` was not found. Please run `tech-design <project-name>` before planning work efforts.
   - Read `<repo-root>/docs/projects/<project-name>/project.yml` to extract the tracker configuration (`tracker.type`, `tracker.config`).
   - Load `brief.md`, `requirements.md`, `decisions.md`, and `technical-design.md` into context.

**Completion Criterion:** Target project identified, tracker settings confirmed, and design documents loaded.

---

## 2. Check Run Mode (Greenfield vs. Incremental Sync)

Check if `implementation-plan.md` already exists:
```bash
test -f "<repo-root>/docs/projects/<project-name>/implementation-plan.md" && echo "EXISTS" || echo "NEW"
```
- **If `EXISTS`**:
  - Load existing `implementation-plan.md`.
  - Scan existing efforts to note what is already `completed`, `in_progress`, or `planned`.
  - Incremental mode: Add new efforts with sequential numbering (e.g., `WE-05+`) without modifying completed efforts.
- **If `NEW`**:
  - Greenfield mode: Plan the complete project lifecycle starting from `WE-01`.

**Completion Criterion:** Run mode established as `NEW` or `INCREMENTAL`.

---

## 3. Deconstruct Technical Design into Vertical Slices

Consult [references/slicing-rubric.md](references/slicing-rubric.md):

1. **Audit Traceability**:
   - Cross-reference the Requirements Traceability Matrix from `technical-design.md`.
   - Ensure every `FR-X` and `NFR-X` is accounted for across the planned efforts.
2. **Feature Flag Check**:
   - If the project modifies a live production service or is past initial MVP, prompt the engineer:
     > "Does this project require feature flag gating in production?"
   - If yes:
     - Define the flag key (e.g., `ff.<project-name>.<feature>`).
     - Allocate a Phase 0 effort to register and stub the flag.
     - Ensure subsequent efforts wrap their entry points in the flag check.
3. **Decompose into Vertical Slices (~1 Day Sizing)**:
   - **Phase 0: Prerequisites & Scaffolding** (Schema setup, shared types, base config, feature flags).
   - **Phase 1+: Vertical Feature Slices** (End-to-end functionality, independently testable and shippable).
   - **Final Phase: Hardening & Verification** (End-to-end integration tests, telemetry, rollout, flag retirement).
4. **Construct Dependency Graph**:
   - Establish strict prerequisite relationships between efforts.
   - Keep the graph wide and shallow to maximize parallel agent/developer execution.

**Completion Criterion:** Work efforts formulated with clear summaries, prerequisites, acceptance criteria, and technical notes.

---

## 4. Engineer Review & Confirmation Gate

Before creating issues in the tracker, present the draft plan to the engineer:
1. **Display Summary Table**:
   - Show ID (`WE-{NN}`), Title, Phase, and Prerequisites.
2. **Display Mermaid DAG**:
   ```mermaid
   flowchart TD
     ...
   ```
3. **Review Detailed Slices**:
   - Show acceptance criteria and target files for each effort.
4. **Interactive Adjustment**:
   - Adjust effort boundaries, split oversized tasks, or re-wire dependencies based on engineer feedback.
5. **Obtain Approval**:
   - Ask the engineer: *"Are you ready to create these work efforts in the `<tracker-type>` issue tracker?"*

**Completion Criterion:** Explicit engineer approval confirmed before any external tracker writes.

---

## 5. Tracker Dispatch & Artifact Generation

Follow the tracker spec configured in `project.yml`:

### A. If Tracker is `local`:
1. Ensure `<repo-root>/docs/projects/<project-name>/efforts/` exists.
2. For each effort, render [templates/effort.md.tmpl](templates/effort.md.tmpl):
   - Path: `<repo-root>/docs/projects/<project-name>/efforts/WE-{NN}-{kebab-title}.md`
   - Fill frontmatter: `id`, `title`, `status: planned`, `phase`, `prerequisites`, `created_at`.
   - Fill body: Summary, Prerequisites, Acceptance Criteria, Implementation Notes.
3. Use relative link `[WE-{NN}](efforts/WE-{NN}-{kebab-title}.md)` as the Tracker Ref in `implementation-plan.md`.

### B. If Tracker is `github`:
1. Verify `gh` authentication:
   ```bash
   gh auth status
   ```
2. For each effort, create a GitHub Issue:
   ```bash
   gh issue create --repo "<repo>" \
     --title "[WE-{NN}] <Title>" \
     --body "<Rendered-Effort-Markdown>" \
     --label "effort:<project-name>,status:planned"
   ```
3. Capture the returned issue URL and number (`#<number>`) and record it as the Tracker Ref in `implementation-plan.md`.

### C. Write `implementation-plan.md`:
- Render [templates/implementation-plan.md.tmpl](templates/implementation-plan.md.tmpl) to `<repo-root>/docs/projects/<project-name>/implementation-plan.md`.
- Populate Overview, Feature Flags, Work Efforts Master Index table, and Mermaid Dependency Graph.

### D. Update Project Metadata:
- Append sequencing and planning decisions to `decisions.md` (`[DEC-XXX]`).
- Update `project.yml`: set `efforts_count: <N>`.

### E. Print Links:
- Output clickable links to [`implementation-plan.md`](file://<repo-root>/docs/projects/<project-name>/implementation-plan.md) and all generated work effort files or GitHub issues.

**Completion Criterion:** Work efforts created in tracker; `implementation-plan.md` written to disk.

---

## 6. Post-Run Self-Evaluation & Evolutionary Loop

1. **Friction Analysis**:
   - Did effort slicing hit the ~1 day target naturally?
   - Did tracker issue creation encounter any CLI or formatting hurdles?
   - Was the dependency graph clear and acyclic?
2. **Formulate Updates**:
   - Propose candidate improvements to `SKILL.md`, `templates/`, or `references/slicing-rubric.md`.
3. **Prompt User**:
   - Ask the user:
     > "Would you like me to update the `plan-effort` skill with any improvements based on this run?"
   - If approved, apply updates directly to `~/.agents/skills/plan-effort/`.

**Completion Criterion:** Self-evaluation performed and user feedback prompted.
