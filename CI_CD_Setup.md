# 🚀 CI/CD Setup for Finch Backend

This document describes the **CI/CD pipeline architecture** used to automate testing, building, and deployment of the **Finch Backend (Django)** project. The pipeline is implemented using **GitHub Actions**.

---

## 🔧 CI/CD Tool: GitHub Actions

* GitHub Actions is used as the CI/CD provider.
* CI and CD workflows are configured in a single YAML file (`.github/workflows/deploy.yml`).
* It integrates directly with GitHub repositories for seamless automation.

---

## 📈 Pipeline Workflow Overview

```yaml
name: Deploy to Kubernetes
```

### 🔹 Trigger Events

* On push to the `main` branch
* On pull requests targeting the `main` branch

---

## ⚖️ Environment Variables & Secrets

| Type      | Used For                                 |
| --------- | ---------------------------------------- |
| `secrets` | DockerHub credentials, database secrets  |
| `vars`    | Stripe keys, frontend URLs, Django admin |

These are injected via the `env` block:

```yaml
env:
  DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
  ...
```

---

## 🚪 Job 1: `unit_test_lint`

| Step                 | Action                                                  |
| -------------------- | ------------------------------------------------------- |
| Checkout Code        | Fetch latest commit                                     |
| Install Dependencies | Install Python packages from `requirements.txt`         |
| Run Tests            | Execute Django unit tests using `python manage.py test` |

---

## 🚪 Job 2: `deploy`

| Dependency | `needs: unit_test_lint` (runs only if tests pass) |
| ---------- | ------------------------------------------------- |

### Service Container

* A **PostgreSQL 15** database is spun up for testing during CI.

```yaml
services:
  db:
    image: postgres:15
```

### Steps:

1. **Checkout Code**
   Re-checks out the repository for deployment context.

2. **Docker Login**
   Logs into DockerHub using secrets.

3. **Build and Push Docker Image**
   Tags and pushes `finch-backend:latest` to DockerHub.

4. **Checkout Private Repo** (Optional)
   Allows deploying or syncing code from a private repo.

---

## ▶️ Triggering the Pipeline

* **Automatic**:

  * Push to `main`
  * PR to `main`
* **Manual** (via GitHub UI):

  * Go to `Actions` tab
  * Select the workflow: `Deploy to Kubernetes`
  * Click `Run workflow`

---

## 📊 Monitoring the Pipeline

1. Navigate to your GitHub repository.
2. Click the **Actions** tab.
3. Select the `Deploy to Kubernetes` workflow.
4. Click into the latest run:

   * View each job (`unit_test_lint`, `deploy`)
   * Review logs per step
   * Debug failed steps using detailed output
