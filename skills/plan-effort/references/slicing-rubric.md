# Work Effort Slicing & Planning Rubric

This rubric guides how to decompose `technical-design.md` into discrete work efforts (`WE-{NN}`).

---

## 1. Slicing Principles

### A. Vertical Slices Over Horizontal Layers
- **Anti-Pattern (Horizontal)**: 
  - WE-01: Create all database tables
  - WE-02: Build all API routes
  - WE-03: Build all UI components
  *(Fails because nothing is testable or shippable until the very end).*
- **Target Pattern (Vertical)**:
  - Phase 0 (Prerequisites): Shared baseline migrations, base configs, and feature flag registration.
  - Phase 1 (Vertical Slices): Each WE delivers an end-to-end slice (e.g. "Create User Endpoint & Persistence", "Search Filter & Query Handler").
  - Each slice is independently testable, reviewable, and mergeable.

### B. Sizing Heuristic (~1 Day Target)
- Each work effort should ideally represent roughly **one day's effort** for a focused engineer or subagent.
- **Signs an effort is too big**:
  - Touches more than 4–5 distinct files across different layers.
  - Has more than 6 acceptance criteria.
  - Merges multiple user actions or workflows into a single effort.
- **Remedy**: Split along:
  - Read path vs. Write path.
  - Core happy path vs. Complex edge case/failure handling.
  - Primary filter vs. Secondary filters.

### C. Dependency Discipline (Keep the DAG Wide)
- Dependencies must represent **true technical blockers** (e.g. WE-02 cannot compile without WE-01's schema migration).
- Do NOT add dependencies merely for arbitrary linear ordering.
- Aim for a shallow, wide dependency graph to maximize concurrent execution by parallel subagents or team members.

---

## 2. Feature Flag Policy (Post-MVP Projects)

When a project modifies an existing production service or is past initial MVP:
1. **Identify Flag**: Define a clear, namespaced flag key: `ff.<project-name>.<feature>`.
2. **Phase 0 Task**: Add an effort to register the flag in configuration / flag service.
3. **Execution Guard**: Require subsequent vertical slices to wrap new execution paths or endpoints in the flag check.
4. **Final Phase Task**: Add an effort to monitor telemetry and clean up / retire the flag.

---

## 3. Tracker Formatting Rules

- **Local Storage**:
  - Path: `docs/projects/<project-name>/efforts/WE-{NN}-{kebab-name}.md`
  - Two-digit padding: `WE-01`, `WE-02`, ..., `WE-10`.
- **GitHub Issues**:
  - Title: `[WE-{NN}] <Title>`
  - Labels: `effort:<project-name>`, `phase:<phase-slug>`, `status:planned`
  - Body: Rendered effort content (Summary, Prerequisites, Acceptance Criteria, Notes).
  - Cross-Reference: Capture issue `#<number>` and store in `implementation-plan.md`.
