# Technical Design Rubric

This rubric guides the technical exploration and engineer interview during `tech-design`.

---

## 1. Core Technical Dimensions

### A. Codebase Grounding
- Never guess at architecture: inspect the real source code, package configurations, and imports.
- Re-use existing patterns, utilities, and abstractions unless there is an explicit architectural reason to deviate.
- Identify existing code that can be retired or replaced rather than adding redundant layers.

### B. Data Models & Integrity
- Are schema changes backward-compatible with existing data and running instances?
- Are column types, nullability, defaults, and foreign key cascades explicitly defined?
- Are index additions or data migrations necessary to maintain query performance?

### C. Contract Rigor
- Are API endpoints, method signatures, and DTO types strictly defined?
- Are request validation rules and response error payloads documented?
- Is idempotency required and handled for mutation endpoints?

### D. Requirements Traceability
- **The Traceability Standard**: Every `FR-X` and `NFR-X` from `requirements.md` must have at least one corresponding entry in the Requirements Traceability Matrix.
- Each entry must identify specific target files (e.g. `src/services/auth.ts`) and describe the concrete code change.
- No phantom requirements: do not add implementation work that does not tie back to a product requirement or explicit technical constraint.

### E. Failure Modes & Observability
- How does the system behave when a downstream service, database, or network call fails?
- Are error messages informative without leaking sensitive internal details?
- Are structured logs or metrics needed to observe this feature in production?

---

## 2. Incremental Update Heuristics (Re-running `tech-design`)

When updating an existing `technical-design.md`:
1. **Identify the Trigger**:
   - New requirement added in `requirements.md`?
   - Implementation hit an unforeseen obstacle or edge case?
   - Upstream dependency or schema changed?
2. **Isolate the Delta**:
   - Pinpoint only the sections of `technical-design.md` affected by the change.
   - Update the Requirements Traceability Matrix to reflect new or modified file targets.
   - Preserve already settled and unaffected sections.
3. **Log the Shift**:
   - Record an entry in `decisions.md` explaining why the technical architecture shifted.
