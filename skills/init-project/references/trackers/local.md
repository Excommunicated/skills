# Tracker Spec: Local Files (`local`)

## 1. Tracker Identifier
- **Name**: `local`
- **Description**: Tracks work efforts as self-contained markdown files located in `docs/projects/<project-name>/efforts/`. Ideal for offline development, local task management, or delegating tasks to local subagents.

---

## 2. CLI & System Prerequisites
- **CLI Commands**: None required. Operates directly on the filesystem.
- **Detection / Auth**: Always available.

---

## 3. Installation & Setup Guide
No external dependencies required.

---

## 4. Initialization & `project.yml` Schema

### `project.yml` Schema
```yaml
tracker:
  type: local
  config:
    efforts_dir: "efforts"
    file_prefix_digits: 3 # 001, 002, etc.
```

---

## 5. Local Scaffolding
`init-project` creates:
- Directory: `docs/projects/<project-name>/efforts/`
- Seed file: `docs/projects/<project-name>/efforts/README.md`
  ```markdown
  # Work Efforts: {{PROJECT_TITLE}}

  Work efforts for this project are tracked as markdown files in this directory.
  Naming convention: `<index>-<kebab-name>.md` (e.g., `001-setup-db.md`).
  ```

---

## 6. Downstream Efforts Contract
Child skills (such as Work Effort Planner and Dispatcher) use these conventions:

### Create Effort
Create a new file `docs/projects/<project-name>/efforts/<NNN>-<effort-name>.md` with the following structure:
```markdown
---
id: {{NNN}}
title: "{{EFFORT_TITLE}}"
status: planned # planned | in_progress | completed | blocked
created_at: "{{CREATED_AT}}"
assignee: human # human | subagent-name
---

# Effort {{NNN}}: {{EFFORT_TITLE}}

## Objective
<!-- What needs to be done and why. -->

## Implementation Steps
- [ ] Step 1
- [ ] Step 2

## Verification & Acceptance
<!-- How to confirm this effort is done. -->
- [ ] Verification criteria
```

### List Efforts
Scan `docs/projects/<project-name>/efforts/*.md` (excluding `README.md`) and parse frontmatter (`id`, `title`, `status`, `assignee`).

### Read Effort
Read the specific markdown file for full step-by-step instructions.

### Update / Close Effort
Update frontmatter `status:` (e.g. to `in_progress` or `completed`) and check off task checkboxes.
