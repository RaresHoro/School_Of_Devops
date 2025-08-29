# GitHub Actions – Comprehensive Guide to CI/CD Automation

---

## 1. Introduction to GitHub Actions

GitHub Actions is a **native CI/CD platform built into GitHub** that automates building, testing, and deploying directly from your repository.

### Why GitHub Actions?

* Launched in 2019 → deeply integrated with GitHub.
* No third-party integration needed → **triggers directly on GitHub events** (push, PR, issue, release).
* Huge **Marketplace** of reusable actions.
* Supports **Linux, macOS, Windows** runners.
* **Free minutes** included for public repos.

### Key Concepts

* **Workflows** → YAML-defined automation triggered by GitHub events.
* **Jobs** → A collection of steps that run on the same runner.
* **Steps** → Individual actions or shell commands.
* **Runners** → Machines where jobs execute (GitHub-hosted or self-hosted).
* **Actions** → Reusable tasks from GitHub Marketplace.
* **Environments** → Named targets (e.g., staging, prod) with approval gates.
* **Secrets** → Encrypted environment variables stored in GitHub.

---

## 2. Connecting GitHub Actions to Your Repo

No external linking is required — it’s built into GitHub.

### Setup

1. In your repository → **Actions** tab.
2. Pick a starter workflow or create a `.github/workflows/<name>.yml` file.
3. Push it → GitHub automatically runs it on future triggers.
4. Workflow results appear in the **Actions** tab and on **commits/PRs**.

### Best Practices

* Store workflows under `.github/workflows/`.
* Use branch filters to control triggers.
* Use GitHub **Environments** for deploy jobs with manual approvals.
* Store sensitive values in **Settings → Secrets and variables → Actions**.

---

## 3. Runners, Actions, and Secrets

### Runners

* **GitHub-hosted**: ephemeral Ubuntu, Windows, macOS machines.
* **Self-hosted**: run on your own infra for custom environments.

### Actions

* Reusable logic units (published in the Marketplace).
* Examples:

  * `actions/checkout` → clone repo.
  * `actions/setup-node` → setup Node.js.
  * `docker/build-push-action` → build/push Docker images.
  * `github/codeql-action` → security scanning.

### Secrets

* Store secrets at repo/org level.
* Example:

  * `DOCKERHUB_USERNAME`
  * `DOCKERHUB_TOKEN`
* Accessed in workflows via `${{ secrets.DOCKERHUB_TOKEN }}`.

---

## 4. Writing Your First GitHub Actions Workflow

### Basic Example

```yaml
# .github/workflows/ci.yml
name: Node CI

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test
```

---

### Best Practices

* **Name workflows clearly** (`ci.yml`, `deploy.yml`).
* Use **`on:` triggers** for PRs, pushes, schedules, releases.
* Use **matrix builds** to test across versions (e.g., Node 18, 20).
* Store sensitive values as **Secrets**.
* Reuse Marketplace actions (don’t reinvent the wheel).

---

## 5. Setting up CI for a Sample Node.js App

### Example Workflow

1. Developer pushes or opens a PR.
2. GitHub Actions triggers workflow.
3. Pipeline stages:

   * **Install**: Restore npm cache, install deps.
   * **Unit Tests**: Run `npm test`.
   * **Linting**: Run ESLint.
   * **Build**: Run `npm run build`.
   * **Deploy**: Run only on `main` branch merge.

### Example Config

```yaml
name: Node CI Pipeline

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  install:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Restore cache
        uses: actions/cache@v4
        with:
          path: ~/.npm
          key: npm-${{ hashFiles('package-lock.json') }}
      - run: npm ci

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npx eslint .

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm test

  deploy:
    runs-on: ubuntu-latest
    needs: [install, lint, test]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - run: echo "Deploying app..."
```

---

## 6. Scaling with Workflows and Matrix Builds

* **Matrix builds**: run across versions/platforms

  ```yaml
  strategy:
    matrix:
      node: [18, 20]
      os: [ubuntu-latest, windows-latest]
  ```
* **Needs**: define job dependencies.
* **Reusable workflows**: call one workflow from another across repos.
* **Concurrency**: cancel in-progress runs on the same branch.

---

## 7. Reusable Config with Composite Actions

* Write your own actions (YAML + shell/JS).
* Store in `.github/actions/` or publish to Marketplace.
* Example: `ci-setup` action that installs Node and restores cache.

---

## 8. GitHub Actions + Pull Request Checks ✅

GitHub Actions integrates natively with GitHub PRs.

### How It Works

1. Developer opens/updates a PR.
2. Workflows with `on: pull_request` trigger.
3. GitHub shows results (✅ pass / ❌ fail) directly on the PR.
4. You can enforce required checks via branch protection.

---

### Enabling PR Checks

1. Repo → **Settings → Branches → Branch protection rules**.
2. Add rule for `main`.
3. Enable **Require status checks to pass before merging**.
4. Select workflows/jobs (e.g., `Node CI / test`).
5. Save.

Now merges are blocked until Actions workflows succeed.

---

### Example: Minimal PR Check Workflow

```yaml
# .github/workflows/pr-checks.yml
name: PR Checks

on:
  pull_request:

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm run lint
      - run: npm test
```

This workflow runs on every PR and shows up in the PR checks.

---

### Best Practices for PR Checks

* **Fast feedback**: keep checks <5 minutes.
* Run **lint + unit tests**, leave long deploys for post-merge.
* Add **matrix builds** for compatibility testing.
* Use **required checks** to enforce quality gates.
* Combine with **CodeQL** or security scans for extra protection.

---

# Final Thoughts

* GitHub Actions is **native CI/CD for GitHub repos**.
* Zero setup: just add `.github/workflows/*.yml`.
* Tight integration with GitHub PRs and branch protections.
* Supports Linux/macOS/Windows runners.
* Marketplace actions cover common tasks.
* Secrets & environments make deployments safe.
* **PR checks ensure quality gates** before code merges.

**GitHub Actions shines for GitHub-native teams**: it’s simple, flexible, and deeply integrated with the developer workflow.

