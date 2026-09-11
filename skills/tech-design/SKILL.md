---
name: tech-design
description: Produce or update a detailed technical design for a project by reading codebase source, mapping requirements to code changes, and interviewing the engineer.
disable-model-invocation: true
---

# Technical Design

Generate or update a rigorous technical design specification (`technical-design.md`) for a project. Inspect real source code, resolve open technical questions, construct a complete Requirements Traceability Matrix, and interview the engineer to settle architectural trade-offs.

---

## 1. Resolve Target Project & Pre-Flight Check

1. **Determine Repository Root**:
   ```bash
   git rev-parse --show-toplevel 2>/dev/null || pwd
   ```
   Set `<repo-root>` to the returned path. Projects are located at `<repo-root>/docs/projects/`.

2. **Select Target Project**:
   - Check if `<project-name>` was passed as an invocation argument (e.g., `tech-design auth-service-v2`).
   - If missing, list available projects:
     ```bash
     ls -1 "<repo-root>/docs/projects" 2>/dev/null
     ```
     Prompt the user to select a project.

3. **Status & File Validation**:
   - Check `project.yml`:
     - If `status` is not `reviewed` (or file does not exist), issue a warning:
       > ⚠️ **Notice**: This project has not completed product review (`review-project`). Proceeding directly to technical design may leave product scope unvalidated. Do you wish to continue?
     - If the user agrees, proceed.
   - Load `<repo-root>/docs/projects/<project-name>/brief.md`, `requirements.md`, and `decisions.md` into context.

**Completion Criterion:** Target project identified, context files loaded, and pre-flight status verified.

---

## 2. Detect Run Mode (Initial vs. Update)

Check if `technical-design.md` already exists:
```bash
test -f "<repo-root>/docs/projects/<project-name>/technical-design.md" && echo "EXISTS" || echo "NEW"
```

- **If `NEW`**:
  - Proceed with full greenfield technical design workflow.
- **If `EXISTS`**:
  - Load existing `technical-design.md`.
  - Prompt the engineer:
    > "An existing `technical-design.md` was found for `{{PROJECT_NAME}}`. What is the primary focus of this update?"
    > 1. Accommodating newly added product requirements.
    > 2. Resolving unforeseen technical blockers or implementation holes.
    > 3. Refactoring or updating architecture to match recent code changes.
  - Follow the incremental update guidance in [references/tech-rubric.md](references/tech-rubric.md).

**Completion Criterion:** Run mode established as either `INITIAL` or `UPDATE`.

---

## 3. Deep Source Code Exploration

Never design against hypothetical code when real files can be inspected. Ground the design by exploring the codebase:

1. **Locate Touchpoints**:
   - Trace packages, directories, and files associated with the requirements.
   - Read existing controllers, route definitions, database models, schemas, and service layers.
2. **Review Existing Tests**:
   - Read relevant unit and integration tests to understand established assertions, mocks, and test patterns.
3. **Trace Data & Execution Flow**:
   - Trace the end-to-end path: Request / Input -> Validation -> Business Logic -> Persistence -> Response / Output.
4. **If in `UPDATE` Mode**:
   - Run `git status` or inspect recent commits/diffs to see what code has changed since the last design run.

**Completion Criterion:** Relevant source code inspected; concrete file paths identified for all candidate changes.

---

## 4. Engineer Technical Interview (Grilling Loop)

Evaluate the technical architecture against the [Technical Design Rubric](references/tech-rubric.md).

Conduct the interview in structured rounds using the grilling protocol:
- Format questions with recommended answers:
  ```markdown
  ❓ **Q1** - **<Decision Title>**: <Context, trade-offs, and constraints>

  ➡️ <Recommended technical choice>

  ---

  ❓ **Q2** - **<Decision Title>**: <Context, trade-offs, and constraints>

  ➡️ <Recommended technical choice>
  ```

### Phase 1: Clear Staged Review Questions
- Ingest all items from `## Open Questions for Tech Design` in `requirements.md`.
- Ask the engineer for decisions on each item before moving to broader architecture.

### Phase 2: Probe Architectural Decisions
- Data models & database schema migrations (nullability, indexes, constraints).
- API & interface contracts (endpoints, types, signatures, error codes).
- Error boundaries, timeouts, retry policies, and edge cases.
- Requirement-to-file mapping for the Traceability Matrix.

Continue rounds until the engineer confirms all architectural decisions are resolved.

**Completion Criterion:** All open technical questions answered and all technical trade-offs settled.

---

## 5. Generate or Update `technical-design.md`

1. **Populate `technical-design.md`**:
   - If `INITIAL`: Render from [templates/technical-design.md.tmpl](templates/technical-design.md.tmpl).
   - If `UPDATE`: Revise existing sections in-place, preserving settled sections and updating only the modified delta.
   - Ensure the document includes:
     - **Architecture & Component Overview**
     - **Data Models & Schema Changes**
     - **Interface & API Contracts**
     - **Requirements Traceability Matrix**: Every single `FR-X` and `NFR-X` from `requirements.md` must be mapped to target files and concrete code changes.
     - **Error Handling & Edge Cases**
     - **Testing & Verification Strategy**
     - **Migration & Rollout Strategy**
   - Write to `<repo-root>/docs/projects/<project-name>/technical-design.md`.

2. **Update Related Files**:
   - In `requirements.md`, mark the resolved open questions in `## Open Questions for Tech Design` as resolved or archive them.
   - In `decisions.md`, append entries for each major architectural decision (`[DEC-XXX]`).
   - In `project.yml`, update status:
     ```yaml
     status: designed
     designed_at: "<ISO-8601-timestamp>"
     ```

3. **Output Summary & Links**:
   - Print clickable file links:
     - [`technical-design.md`](file://<repo-root>/docs/projects/<project-name>/technical-design.md)
     - [`requirements.md`](file://<repo-root>/docs/projects/<project-name>/requirements.md)
     - [`decisions.md`](file://<repo-root>/docs/projects/<project-name>/decisions.md)
     - [`project.yml`](file://<repo-root>/docs/projects/<project-name>/project.yml)
   - Inform the user: *"Technical design complete. Next suggested step: plan work efforts for developers or subagents."*

**Completion Criterion:** `technical-design.md` written to disk with full Requirements Traceability Matrix; project status set to `designed`.

---

## 6. Post-Run Self-Evaluation & Evolutionary Loop

1. **Friction Analysis**:
   - Did source code exploration successfully identify all affected files?
   - Did the Requirements Traceability Matrix feel natural or cumbersome?
   - Were there technical questions the rubric failed to anticipate?
2. **Formulate Updates**:
   - Draft improvements for `SKILL.md`, `templates/technical-design.md.tmpl`, or `references/tech-rubric.md`.
3. **Prompt User**:
   - Ask the user:
     > "Would you like me to update the `tech-design` skill with any improvements based on this run?"
   - If approved, apply updates directly to `~/.agents/skills/tech-design/`.

**Completion Criterion:** Self-evaluation performed and user feedback prompted.
