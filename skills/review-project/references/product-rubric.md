# Product Review Rubric

This rubric guides the stakeholder interview during `review-project`. The review focuses exclusively on product viability, clarity, scope, and alignment.

---

## 1. Core Review Dimensions

### A. Persona & Problem Alignment
- Who is the intended primary user / developer / system consuming this?
- Is the problem statement grounded in an observable pain point?
- What triggers the user to interact with this feature or system?

### B. Scope & Boundary Hardening
- Are the **In Scope** items discrete and achievable?
- Are **Non-Goals / Out of Scope** items explicitly enumerated to prevent scope creep?
- Does any in-scope item depend on an unstated prerequisite?

### C. Contradictions & Codebase Collisions
- Do any statements in `brief.md` contradict requirements in `requirements.md`?
- Does the project collide with, duplicate, or alter existing repository modules or data models identified during the repository impact scan?
- Are existing conventions in the repo respected, or does this intentionally introduce a breaking paradigm?

### D. Acceptance Criteria & Edge Cases
- Are acceptance criteria written as binary, checkable conditions (true/false, passes/fails)?
- Are error conditions, edge cases, and failure modes accounted for?
- How is success verified from an external user or consumer perspective?

---

## 2. The Technical Boundary Guard

Detailed technical design is explicitly **out of scope** for this review. It is deferred to the future child skill `tech-design`.

### What Stays in `review-project` (Product Scope):
- What the system must do from a user or caller perspective.
- Inputs, outputs, business rules, and constraints.
- Latency/performance expectations (as constraints, not implementation details).
- Integration points and existing repo surfaces affected.

### What Is Deflected to `tech-design` (Technical Scope):
- Specific database tables, column types, and migration steps.
- Code-level class hierarchies, function signatures, and design patterns.
- Specific third-party libraries or internal helper architectures.
- Low-level network protocols or message schemas.

### Deflection Protocol:
When a technical implementation question arises:
1. Acknowledge the point: *"That is an important implementation detail for `tech-design`."*
2. Capture the detail or question under an `## Open Questions for Tech Design` section in `requirements.md`.
3. Redirect the conversation: *"For this review, let's focus on [the product behavior / business rule]."*
