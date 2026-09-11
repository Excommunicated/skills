# Tracker Spec: GitHub Issues (`github`)

## 1. Tracker Identifier
- **Name**: `github`
- **Description**: Uses GitHub Issues as the tracking backend for project efforts via the official GitHub CLI (`gh`).

---

## 2. CLI & System Prerequisites
- **CLI Command**: `gh`
- **Detection Check**:
  ```bash
  gh --version
  ```
- **Authentication Check**:
  ```bash
  gh auth status
  ```

---

## 3. Installation & Setup Guide (If Missing or Unauthenticated)

### Installing `gh`
- **Debian / Ubuntu**:
  ```bash
  type -p curl >/dev/null || sudo apt install curl -y
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
  ```
- **macOS (Homebrew)**:
  ```bash
  brew install gh
  ```
- **Fedora / RHEL**:
  ```bash
  sudo dnf install 'dnf-command(config-manager)'
  sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install gh
  ```
- **Arch Linux**:
  ```bash
  sudo pacman -S github-cli
  ```

### Authenticating `gh`
Run interactive login:
```bash
gh auth login
```
- Select **GitHub.com**
- Protocol: **HTTPS** or **SSH**
- Authenticate Git with your credentials: **Yes**
- Choose **Login with a web browser** or paste an existing Personal Access Token (PAT).
- Required scopes: `repo` (minimum to view/create issues).

---

## 4. Initialization & `project.yml` Schema

### Auto-Detection
Detect current repository coordinates:
```bash
git remote get-url origin 2>/dev/null
```
Parse the URL to extract `<owner>/<repo>`:
- `git@github.com:owner/repo.git` -> `owner/repo`
- `https://github.com/owner/repo.git` -> `owner/repo`

Prompt the user to confirm or supply the target repository.

### `project.yml` Schema
```yaml
tracker:
  type: github
  config:
    repo: "{{GITHUB_OWNER_REPO}}" # e.g. "my-org/my-repo"
    label_prefix: "effort:{{PROJECT_NAME}}"
    auto_create_labels: true
```

---

## 5. Local Scaffolding
- Optional: Create `docs/projects/<project-name>/efforts/` as an empty staging folder or omit if tracking purely on GitHub.

---

## 6. Downstream Efforts Contract
Child skills (such as Work Effort Planner and Dispatcher) use these commands:

### Create Effort
```bash
gh issue create --repo "<repo>" \
  --title "[<project-name>] <effort-title>" \
  --body "<effort-body-markdown>" \
  --label "<label_prefix>"
```

### List Efforts
```bash
gh issue list --repo "<repo>" --label "<label_prefix>" --state all --json number,title,state,assignees
```

### Read Effort
```bash
gh issue view <issue-number> --repo "<repo>" --json title,body,state,comments
```

### Update / Close Effort
```bash
# Update state / comment
gh issue comment <issue-number> --repo "<repo>" --body "<progress-update>"
gh issue close <issue-number> --repo "<repo>" --reason "completed"
```
