---
name: review-project
description: Conduct a product-focused review of a project's brief and requirements, surfacing contradictions and logging decisions.
disable-model-invocation: true
---

# Review Project

Conduct an interactive, product-focused review of an existing project's `brief.md` and `requirements.md`. Build shared understanding, assess codebase impact, surface contradictions, resolve ambiguities, log decisions, and stage open technical questions for `tech-design`.

---

## 1. Resolve Target Project

1. **Locate Repository Root**:
   ```bash
   git rev-parse --show-toplevel 2>/dev/null || pwd
   ```
   Anchor project root to `<repo-root>/docs/projects/`.

2. **Identify Target Project**:
   - Check if `<project-name>` was passed as an invocation argument (e.g., `review-project auth-service-v2`).
   - If not passed, list existing projects:
     ```bash
     ls -1 "<repo-root>/docs/projects" 2>/dev/null
     ```
     Display the list to the user and prompt them to select one.

3. **Verify File Prerequisites**:
   - Check for existence of:
     - `<repo-root>/docs/projects/<project-name>/brief.md`
     - `<repo-root>/docs/projects/<project-name>/requirements.md`
   - If either file is missing or empty, notify the user and offer to seed initial templates from `init-project` before continuing.

**Completion Criterion:** Target project identified and both `brief.md` and `requirements.md` are loaded into context.

---

## 2. Codebase Impact Scan ("What it affects")

Before interviewing the stakeholder, ground the review in the reality of the repository:

1. Extract core domain concepts, entities, services, and APIs mentioned in `brief.md` and `requirements.md`.
2. Perform targeted repository searches (using file search and ripgrep) to discover:
   - Existing modules or services implementing similar functionality.
   - Schemas, models, or configurations that will be touched.
   - Existing tests, documentation, or CLI commands affected.
3. Synthesize an **Impact & Collision Map**:
   - Which directories/files will this project likely modify?
   - Are there overlapping features or potential breaking changes with existing code?

**Completion Criterion:** Impact & Collision Map formulated to inform interview questions.

---

## 3. Product-Focused Stakeholder Interview (Grilling Loop)

Evaluate the project against the [Product Review Rubric](references/product-rubric.md).

Conduct the interview in **rounds** using the design tree protocol:
- Identify gaps, vague wording, missing non-goals, unstated assumptions, and contradictions surfaced by the codebase impact scan.
- Group all open frontier questions into a single round formatted as:
  ```markdown
  ❓ **Q1** - **<Question Title>**: <Body and context>

  ➡️ <Your recommended answer>

  ---

  ❓ **Q2** - **<Question Title>**: <Body and context>

  ➡️ <Your recommended answer>
  ```
- Wait for user answers before proceeding to the next round.
- **Enforce the Technical Boundary Guard**:
  - Detailed architecture, database schemas, function signatures, and implementation mechanics belong in `tech-design`.
  - When technical topics arise, deflect them: acknowledge the point, record it into an *"Open Questions for Tech Design"* staging list, and refocus on product behavior and acceptance criteria.
- Continue rounds until the frontier is empty and the user confirms mutual alignment.

**Completion Criterion:** User confirms shared understanding and no unresolved product ambiguities remain on the frontier.

---

## 4. Record Settled Decisions & Update Project Artifacts

1. **Update `brief.md`**:
   - Update in-place to reflect clarified problem statement, tightened scope boundaries, and explicit non-goals.
2. **Update `requirements.md`**:
   - Update in-place with sharp, binary acceptance criteria and edge cases.
   - Add/update the `## Open Questions for Tech Design` section with all technical points captured during the interview.
3. **Log Decisions in `decisions.md`**:
   - In `<repo-root>/docs/projects/<project-name>/decisions.md` (creating it from [templates/decisions.md.tmpl](templates/decisions.md.tmpl) if it doesn't exist), append an entry for each major decision reached:
     ```markdown
     ## [DEC-XXX] <Decision Title>
     - **Date**: YYYY-MM-DD
     - **Participants**: <Names/Roles>
     - **Decision**: <Clear decision statement>
     - **Rationale**: <Why this path was chosen over alternatives>
     - **Impact**: <Affected requirements, scope, or repo surfaces>
     ```
4. **Update `project.yml`**:
   - Update status fields:
     ```yaml
     status: reviewed
     reviewed_at: "<ISO-8601-timestamp>"
     ```
5. **Print Summary & Hand-off**:
   - Output links to all modified files:
     - [`brief.md`](file://<repo-root>/docs/projects/<project-name>/brief.md)
     - [`requirements.md`](file://<repo-root>/docs/projects/<project-name>/requirements.md)
     - [`decisions.md`](file://<repo-root>/docs/projects/<project-name>/decisions.md)
     - [`project.yml`](file://<repo-root>/docs/projects/<project-name>/project.yml)
   - Inform the user: *"Product review complete. Next suggested step: run `tech-design <project-name>` to begin detailed technical architecture."*

**Completion Criterion:** Project files updated on disk, decisions logged, and status updated to `reviewed`.

---

## 5. Post-Run Self-Evaluation & Evolutionary Loop

1. **Friction Analysis**:
   - Did the impact scan identify the right areas of the repo?
   - Did any questions drift too deep into technical implementation before being deflected?
   - Was any part of the decision log or rubric awkward to apply?
2. **Formulate Improvements**:
   - Draft candidate refinements to `SKILL.md`, `templates/decisions.md.tmpl`, or `references/product-rubric.md`.
3. **Prompt User**:
   - Ask the user:
     > "Would you like me to update the `review-project` skill with any improvements based on this review?"
   - If the user approves, apply the updates directly to `~/.agents/skills/review-project/`.

**Completion Criterion:** Self-evaluation performed and user feedback prompted.
