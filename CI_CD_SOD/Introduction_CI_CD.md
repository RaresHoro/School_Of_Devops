# Introduction to CI/CD - Automation with Pipelines

## 1. What is CI/CD?

CI/CD stands for **Continuous Integration (CI)** and **Continuous Delivery/Deployment (CD)**.

- **Continuous Integration (CI):**
  - Developers frequently merge their code into a shared repository.
  - Automated builds and tests run to detect bugs early.
  - Goal: Catch issues quickly and keep the main codebase stable.

- **Continuous Delivery (CD):**
  - Ensures that code is always in a deployable state.
  - After tests pass, code is packaged and deployed to staging environments.
  - Deployment to production is still a **manual decision**.

- **Continuous Deployment (CD – automatic):**
  - Every change that passes tests is **automatically deployed** to production.

---

## 2. What are Pipelines?

A **pipeline** is an automated workflow that defines the sequence of steps your code goes through, from commit to deployment.

### Typical pipeline stages

1. **Source (SCM)**
   - Triggered by a commit or pull request (e.g., GitHub, Azure Repos).
2. **Build**
   - Compile code, install dependencies, create artifacts.
3. **Test**
   - Run unit tests, integration tests, and security scans.
4. **Deploy**
   - Release to environments (DEV → TEST → STG → PROD).

---

## 3. Benefits of CI/CD Pipelines

- **Faster feedback**: Bugs caught early.
- **Consistency**: Same automated steps for every change.
- **Reliability**: Less human error.
- **Speed**: Faster delivery of features.
- **Scalability**: Works well for teams and enterprises.

---

## 4. Example Flow

1. Developer pushes code to repository.
2. Pipeline starts automatically.
3. Build and tests run.
4. If successful, deployment to environment happens.

---

## 5. Azure DevOps Example Pipeline (YAML)

A **simple CI/CD pipeline** for a Node.js app in Azure DevOps:

```yaml
# azure-pipelines.yml
trigger:
  - main   # Runs pipeline on every commit to main branch

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '18.x'
    displayName: 'Install Node.js'

  - script: |
      npm install
      npm run build
    displayName: 'Install dependencies and build'

  - script: |
      npm test
    displayName: 'Run tests'

  - task: AzureWebApp@1
    inputs:
      azureSubscription: 'MyServiceConnection'   # Define service connection
      appName: 'my-webapp'
      package: '$(System.DefaultWorkingDirectory)/**/*.zip'
    displayName: 'Deploy to Azure Web App'
````

---

```''

👉 This pipeline will:
1. Trigger on every commit to `main`.
2. Install Node.js, dependencies, and build the project.
3. Run tests.
4. Deploy the app to an **Azure Web App**.

```
