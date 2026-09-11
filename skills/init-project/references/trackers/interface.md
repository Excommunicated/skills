# Tracker Backend Interface Specification

This document defines the standard contract that all issue tracker backends must implement. `init-project` uses this specification to initialize tracker configurations, and downstream skills (such as work effort planners and dispatchers) use it to create and manage tasks.

---

## Required Spec Structure

Every tracker backend specification file in `references/trackers/<tracker_name>.md` must define the following sections:

### 1. Tracker Identifier
- **Name**: Unique string identifier (e.g., `github`, `local`, `linear`, `jira`).
- **Description**: Summary of the tracker backend.

### 2. CLI & System Prerequisites
- **Commands**: Array of CLI commands or environment variables needed (e.g., `gh`, `curl`, `node`).
- **Detection Check**: Exact command to verify if the tool is installed (e.g., `gh --version`).
- **Authentication Check**: Exact command to verify credentials/tokens (e.g., `gh auth status`).

### 3. Installation & Setup Guide
Step-by-step instructions to display to the user if the CLI tool or authentication check fails:
- Package manager commands for common platforms (Linux apt/dnf, macOS brew, Windows).
- Authentication workflow (interactive login, token generation, required scopes/permissions).

### 4. Initialization & `project.yml` Schema
- **Init Prompts**: Questions to prompt the user during `init-project` (e.g., repo slug, project board, token name).
- **Auto-Detection**: Shell commands to infer defaults (e.g., `git remote get-url origin`).
- **Schema**: Exact YAML structure written under `tracker:` in `project.yml`.
  ```yaml
  tracker:
    type: <tracker_name>
    config:
      # tracker-specific configuration key-values
  ```

### 5. Local Scaffolding
- Specify whether local directories or files must be created at initialization (e.g., creating `efforts/`).

### 6. Downstream Efforts Contract
A standardized mapping that future child skills (e.g., Work Effort Planner) can consume:
- **Create Effort**: Command, API call, or file creation template to open a new effort.
- **List Efforts**: Command or filesystem scan to retrieve existing efforts.
- **Read Effort**: Command or file path to read effort details and status.
- **Update / Close Effort**: Command or edit rule to change effort state (e.g., `in_progress`, `completed`).

---

## Adding a New Tracker Backend

To add support for a new issue tracker (e.g., `linear`, `jira`, `gitlab`):
1. Create `references/trackers/<tracker_name>.md`.
2. Follow the required sections above.
3. Once the file is present, `init-project` and downstream planning skills can reference it immediately without altering core workflow logic.
