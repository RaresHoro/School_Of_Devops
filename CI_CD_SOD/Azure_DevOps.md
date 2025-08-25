# Azure DevOps: Basics, Components, and Pipelines

## 📌 Introduction

**Azure DevOps (ADO)** is a Microsoft service that provides end-to-end tools for managing the software development lifecycle (SDLC). It enables teams to plan, develop, test, deliver, and monitor applications in one integrated platform.

---

## 🧱 Basic Building Blocks

### 1. **Organization**

* The highest-level container in Azure DevOps.
* Holds projects, users, security policies, billing, and service connections.

### 2. **Projects**

* A logical container for related work.
* Each project can include repos, pipelines, boards, test plans, and artifacts.

### 3. **Repositories (Repos)**

* Git-based version control.
* Used to host application code, infrastructure-as-code, and pipeline YAML definitions.

### 4. **Boards**

* Agile project management toolset.
* Provides work items, Kanban boards, sprint planning, and reporting.

### 5. **Pipelines**

* CI/CD automation engine.
* Used to build, test, and deploy applications.
* Pipelines can be created in:

  * **Classic UI designer** (drag-and-drop)
  * **YAML (as code)** in your repo

### 6. **Artifacts**

* Package management solution.
* Store and share packages like NuGet, npm, Maven, Python, or universal packages.

### 7. **Test Plans**

* Manual and exploratory testing capabilities.
* Used for test case management and execution.

---

## ⚙️ Key Pipeline Components

* **Agent**: The machine (hosted by Microsoft or self-hosted) that executes your pipeline jobs.
* **Job**: A collection of steps that run on the same agent.
* **Step**: A task or script that runs in a job (e.g., build, test, deploy).
* **Stage**: A logical grouping of jobs, often mapped to environments (e.g., Build, Test, Prod).
* **Task**: A pre-built unit of work (like `DotNetCoreCLI@2` or `AzureCLI@2`).
* **Environment**: Represents where code is deployed (e.g., dev, test, prod) and can include approval gates.

---

## 🚀 Building a Pipeline (Example)

### Scenario

We want to build and test a simple Node.js application, and then package it into a Docker image and push it to **Azure Container Registry (ACR)**.

### Example Pipeline: `azure-pipelines.yml`

```yaml
# Trigger pipeline on commits to main branch
trigger:
  branches:
    include:
      - main

# Use Microsoft-hosted Ubuntu agent
pool:
  vmImage: 'ubuntu-latest'

variables:
  ACR_NAME: 'myregistry'              # ACR name (lowercase, no .azurecr.io)
  IMAGE_NAME: 'node-sample-app'
  IMAGE_TAG: '$(Build.BuildId)'
  REGISTRY: '$(ACR_NAME).azurecr.io'

stages:
- stage: Build
  displayName: 'Build & Test'
  jobs:
  - job: build_and_test
    steps:
    - checkout: self

    - task: NodeTool@0
      inputs:
        versionSpec: '20.x'
      displayName: 'Install Node.js'

    - script: |
        npm install
        npm test
      displayName: 'Install dependencies and run tests'

- stage: Package
  displayName: 'Build & Push Docker Image'
  dependsOn: Build
  jobs:
  - job: docker_job
    steps:
    - checkout: self

    - task: AzureCLI@2
      displayName: 'Build and Push Image to ACR'
      inputs:
        azureSubscription: 'my-service-connection'   # Service connection name
        scriptType: bash
        scriptLocation: inlineScript
        inlineScript: |
          az acr login -n $(ACR_NAME)

          echo "Building Docker image..."
          docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

          echo "Tagging & pushing..."
          docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
          docker push $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
```

---

## 📊 Explanation of the Example

1. **Trigger**: Runs the pipeline when code is pushed to `main`.
2. **Build stage**: Uses Node.js to install dependencies and run tests.
3. **Package stage**: Builds a Docker image and pushes it to Azure Container Registry.
4. **Service connection**: The pipeline uses a pre-configured service connection (`my-service-connection`) to authenticate with Azure.

---

## ✅ Best Practices

* Use **variable groups** or **Azure Key Vault** for secrets (not inline).
* Split pipelines into **stages** (Build, Test, Deploy).
* Use **Environments** for Dev/Test/Prod with approval checks.
* Enable **branch policies** to enforce PR validation.
* Keep pipeline definitions in the **repo (YAML-as-code)**.


