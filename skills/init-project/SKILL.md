---
name: init-project
description: Initialize a scoped project under docs/projects/<project-name> in the current repository.
disable-model-invocation: true
---

# Initialize Project

Scaffold a scoped project workspace under `docs/projects/<project-name>/` with metadata, brief, requirements, and an issue tracker configuration.

---

## 1. Resolve Repository Root

Determine the repository root directory:
```bash
git rev-parse --show-toplevel 2>/dev/null || pwd
```
Set `<repo-root>` to the returned path. All subsequent project paths are anchored to `<repo-root>/docs/projects/`.

**Completion Criterion:** `<repo-root>` is an absolute path to the repository root.

---

## 2. Parse Project Name and Description

1. **Project Name**:
   - Check if the project name was provided as an invocation argument (e.g., `init-project my-feature`).
   - If provided, validate that it matches kebab-case (`^[a-z0-9]+(-[a-z0-9]+)*$`). If invalid, explain the format and prompt for a valid kebab-case name.
   - If not provided as an argument, prompt the user:
     > "What is the project name? (use kebab-case, e.g., `auth-service-v2`)"
2. **One-Line Description**:
   - Prompt the user:
     > "Please provide a one-line description of the project goal:"

**Completion Criterion:** Both `<project-name>` (kebab-case) and `<project-description>` are confirmed non-empty strings.

---

## 3. Collision Check

Verify whether the project directory already exists:
```bash
test -e "<repo-root>/docs/projects/<project-name>" && echo "EXISTS" || echo "AVAILABLE"
```
- If `EXISTS`:
  1. Inform the user:
     > ⚠️ **Project already exists**: `docs/projects/<project-name>` already exists in this repository.
  2. Stop execution immediately. Do not overwrite or modify existing project files.
- If `AVAILABLE`: Proceed to Step 4.

**Completion Criterion:** Target directory confirmed not to exist.

---

## 4. Issue Tracker Selection & Backend Resolution

Prompt the user:
> "Which issue tracker would you like to use for this project?"
> 1. `github` (GitHub Issues via GitHub CLI `gh`)
> 2. `local` (Markdown files in `efforts/`)
> 3. Custom (Load a spec from `references/trackers/<choice>.md`)

Follow the designated specification in [references/trackers/](references/trackers/):

### If `github`:
1. Consult [references/trackers/github.md](references/trackers/github.md).
2. Run CLI verification:
   ```bash
   gh --version && gh auth status
   ```
3. If `gh` is missing or unauthenticated:
   - Output the installation and authentication instructions from `github.md`.
   - Wait for the user to complete setup or select an alternative tracker.
4. Detect repository coordinates:
   ```bash
   git remote get-url origin 2>/dev/null
   ```
   Parse `<owner>/<repo>`. Confirm the detected repo with the user or prompt for the slug if remote is unset.
5. Set tracker config:
   ```yaml
   tracker:
     type: github
     config:
       repo: "<owner>/<repo>"
       label_prefix: "effort:<project-name>"
   ```

### If `local`:
1. Consult [references/trackers/local.md](references/trackers/local.md).
2. Set tracker config:
   ```yaml
   tracker:
     type: local
     config:
       efforts_dir: "efforts"
   ```

### If Custom:
1. Consult [references/trackers/interface.md](references/trackers/interface.md) and load `references/trackers/<choice>.md`.
2. Follow that tracker's prerequisite checks and configuration schema.

**Completion Criterion:** Tracker type selected, prerequisites satisfied, and tracker YAML configuration block formatted.

---

## 5. Scaffold Project Files

1. Create target directories:
   ```bash
   mkdir -p "<repo-root>/docs/projects/<project-name>/efforts"
   ```
2. Render files from templates:
   - **`project.yml`**: Populate [templates/project.yml.tmpl](templates/project.yml.tmpl) with:
     - `PROJECT_NAME`: `<project-name>`
     - `PROJECT_DESCRIPTION`: `<project-description>`
     - `CREATED_AT`: Current date/time (ISO 8601, e.g. `$(date -Iseconds)`)
     - `TRACKER_TYPE` & `TRACKER_CONFIG`: Formatted YAML from Step 4.
     Write to `<repo-root>/docs/projects/<project-name>/project.yml`.
   - **`brief.md`**: Populate [templates/brief.md.tmpl](templates/brief.md.tmpl) with:
     - `PROJECT_TITLE`: Title-cased version of `<project-name>`
     - `PROJECT_DESCRIPTION`: `<project-description>`
     - `CREATED_AT`: Current date
     Write to `<repo-root>/docs/projects/<project-name>/brief.md`.
   - **`requirements.md`**: Populate [templates/requirements.md.tmpl](templates/requirements.md.tmpl) with:
     - `PROJECT_TITLE`: Title-cased version of `<project-name>`
     - `PROJECT_NAME`: `<project-name>`
     - `CREATED_AT`: Current date
     Write to `<repo-root>/docs/projects/<project-name>/requirements.md`.
3. If using `local` tracker:
   - Create `<repo-root>/docs/projects/<project-name>/efforts/README.md` following [references/trackers/local.md](references/trackers/local.md).

**Completion Criterion:** All project files exist on disk with valid content and no unresolved template variables.

---

## 6. Output Summary & Links

Display a summary of the initialized project with clickable file links:
- [`project.yml`](file://<repo-root>/docs/projects/<project-name>/project.yml)
- [`brief.md`](file://<repo-root>/docs/projects/<project-name>/brief.md)
- [`requirements.md`](file://<repo-root>/docs/projects/<project-name>/requirements.md)
- [`efforts/`](file://<repo-root>/docs/projects/<project-name>/efforts)

**Completion Criterion:** File summary printed with full URI links.

---

## 7. Self-Evaluation & Evolutionary Loop

After scaffolding is completed, review the execution:
1. **Friction Analysis**:
   - Did the user have to re-enter or clarify any inputs?
   - Did tracker prerequisite checks fail or require unexpected troubleshooting?
   - Were any template sections lacking context for this project?
2. **Formulate Updates**:
   - If any friction occurred, draft specific improvements for `SKILL.md`, templates, or tracker specs.
3. **Prompt User**:
   - Ask the user:
     > "Would you like me to update the `init-project` skill with any improvements based on this run?"
   - If the user approves, apply the changes to `~/.agents/skills/init-project/`.

**Completion Criterion:** Friction reviewed and feedback prompt presented to user.
