
# Jenkins - Comprehensive Guide to CI/CD Automation

---

## 1. Introduction to Jenkins

Jenkins is an **open-source automation server** that helps developers integrate and deliver software quickly and reliably.

### Why Jenkins?

- First released in 2011 (as a fork of Hudson).
- Used by startups and enterprises alike.
- Has a **large ecosystem** with over **1,800 plugins**.
- Highly **extensible**: integrates with almost every tool in the DevOps ecosystem.

### Key Concepts

- **Jobs**: Units of work (e.g., build, test, deploy).
- **Builds**: Executions of jobs.
- **Pipelines**: A series of jobs connected into an automated workflow.
- **Nodes (Agents/Slaves)**: Machines that execute jobs under Jenkins’ control.

---

## 2. Setting up Jenkins with Docker

### Why Docker?

- Isolates Jenkins from host dependencies.
- Easy to replicate across environments.
- Quickly reset Jenkins for testing configurations.

### Basic Setup

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
````

  **8080** → Web UI.\
  **50000** → Communication with Jenkins agents.\
  **jenkins\_home** → Persistent data (jobs, plugins, configs).\

### Best Practices

  Mount `jenkins_home` on external storage for backups.\
  Use **reverse proxy + HTTPS** (Nginx/Traefik + Let’s Encrypt)\
  Run Jenkins as a non-root user in production.\

---

## 3. Managing Slaves (Agents) and Plugins

Jenkins supports **distributed builds** through agents.

### Master vs Agent:

 **Master (Controller)**:

  * Provides the web UI.
  * Orchestrates jobs.
  * Stores build metadata.

  **Agent (Slave)**:

  * Executes the actual build/test jobs.
  * Can run on Linux, Windows, or inside containers.

### Connecting Agents:

* **SSH**: Most common, secure.
* **JNLP (Java Web Start)**: Useful for firewall-restricted environments.
* **Cloud Agents**: Provisioned on-demand (Kubernetes, AWS, Azure, GCP).

### Why Agents Matter:

* Scale horizontally → run jobs in parallel.
* Specialized environments (e.g., one agent with Java 17, another with Python 3.12).

### Plugins:

* Extend Jenkins capabilities.
* Examples:

  * **SCM Plugins** (Git, GitHub, Bitbucket, GitLab).
  * **Build Tool Plugins** (Maven, Gradle, NodeJS).
  * **UI/Monitoring Plugins** (Blue Ocean, Build Monitor).
  * **Cloud Plugins** (Kubernetes, EC2, Azure VM).

**⚠️ Warning:** Too many plugins = unstable Jenkins. Always audit and update carefully.

---

## 4. Writing Your First Pipeline

Jenkins Pipelines = **Pipeline-as-Code** using Groovy.

### Pipeline Types:

1. **Declarative** (Recommended)

   * Structured, easy to read.
   * Example:

     ```groovy
     pipeline {
         agent any
         stages {
             stage('Build') {
                 steps {
                     sh 'mvn clean install'
                 }
             }
             stage('Test') {
                 steps {
                     sh 'mvn test'
                 }
             }
             stage('Deploy') {
                 steps {
                     echo 'Deploying...'
                 }
             }
         }
     }
     ```

2. **Scripted**

   * Full control via Groovy scripting.
   * Example:

     ```groovy
     node {
         stage('Build') {
             sh 'mvn clean install'
         }
         stage('Test') {
             sh 'mvn test'
         }
     }
     ```

### Best Practices:

* Always **store Jenkinsfile in repo** (version-controlled).
* Split jobs into multiple **stages** (build, test, deploy).
* Use **parameters** for flexible pipelines (e.g., deploy branch X to environment Y).
* Use **post actions** to handle failures (notifications, cleanups).

---

## 5. Setting up CI for a Sample Java App

### Example Workflow

1. Developer pushes to GitHub.
2. Jenkins triggers pipeline (via **webhook**).
3. Pipeline stages:

   * **Build**: `mvn clean package`
   * **Unit Tests**: `mvn test`
   * **Static Analysis**: SonarQube scan
   * **Artifact Archive**: Store `.jar` or `.war` in Nexus/Artifactory
   * **Deploy to Staging**: Run `kubectl apply` or push to Azure WebApp

### Tools Integrated

* **SCM**: GitHub, GitLab.
* **Build Tools**: Maven, Gradle.
* **Artifact Repos**: Nexus, JFrog Artifactory.
* **Cloud Deployments**: Azure, AWS, GCP.

---

## 6. Cloud for Dynamic Slave Provisioning

Instead of static agents, Jenkins can use **ephemeral agents**.


* Elastic scaling → agents created only when needed.
* Saves money on cloud infra.
* Fresh environment for each build (no leftover state).

### Popular Options:

* **Kubernetes Plugin**:

  * Each build runs in a container.
  * Define pod templates with required tools.
  * Most modern Jenkins installations run this way.

* **AWS EC2 Plugin**:

  * Launch EC2 instances as Jenkins agents.
  * Supports spot instances (cheap builds).

* **Azure VM Agents**:

  * Jenkins spins up Azure VMs on demand.
  * Useful in MS-focused environments.

---

## 7. Shared Pipeline Library

Large organizations often need to **standardize pipelines**.

### How it Works:

* A **shared library repo** stores reusable Groovy code.
* Jenkins loads this repo automatically.
* Developers call shared functions instead of duplicating pipeline logic.

### Structure:

```
(root)
 ├── vars/
 │    └── buildApp.groovy
 └── src/
      └── org/company/jenkins/Utils.groovy
```

### Example:

**Library Function (`vars/buildApp.groovy`):**

```groovy
def call() {
    stage('Build App') {
        sh 'mvn clean install'
    }
}
```

**Jenkinsfile:**

```groovy
@Library('my-shared-library') _
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                buildApp()
            }
        }
    }
}
```

### Benefits:

* **DRY Principle** → Avoid repeating pipeline logic.
* **Consistency** → All teams follow the same standards.
* **Maintainability** → Update once, apply everywhere.

---

# Final Thoughts

* Jenkins is a mature, flexible, and extensible CI/CD tool.
* Docker simplifies deployment and management.
* Agents (static or cloud-based) allow scaling and specialization.
* Pipelines make automation reproducible and version-controlled.
* Shared libraries bring enterprise-level standardization.

**Jenkins shines in enterprises with complex workflows** but requires careful management (plugins, scaling, security) to avoid “Jenkins sprawl.”

---

