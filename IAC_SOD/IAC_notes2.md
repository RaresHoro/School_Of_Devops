# Infrastructure as Code: Modules, Roles, and Reusability in Ansible

## 🔹 Modules in Ansible

### ✅ What are Modules?
- **Modules** are standalone scripts used by Ansible to perform specific tasks.
- Think of them as building blocks that execute individual actions like installing packages, creating files, managing services, etc.

### 🛠️ Examples of Built-in Modules
- `apt`, `yum`: Install packages.
- `copy`, `template`: Manage files.
- `service`: Start/stop services.
- `user`, `group`: Manage users and groups.

### 🔁 Custom Modules
- You can also write **custom modules** in Python or any supported language if built-in ones aren’t sufficient.

---

## 🔹 Roles in Ansible

### ✅ What are Roles?
- **Roles** are a way to group tasks, variables, files, templates, and handlers in a standardized directory structure.
- They promote **organization and reusability** of your automation code.

### 📁 Typical Role Structure
```
my-role/
├── defaults/
│   └── main.yml          # Default variables
├── files/                # Static files to copy
├── handlers/
│   └── main.yml          # Handlers (e.g., restart services)
├── meta/
│   └── main.yml          # Role metadata (dependencies)
├── tasks/
│   └── main.yml          # Main list of tasks
├── templates/            # Jinja2 templates
└── vars/
    └── main.yml          # Other variables
```

### 📦 Example Use Case
To create a reusable role for installing NGINX:
- Place tasks to install and configure NGINX in `tasks/main.yml`.
- Templates like `nginx.conf.j2` in `templates/`.
- Set default variables in `defaults/main.yml`.

Then use it in your playbook:
```yaml
- hosts: web
  roles:
    - nginx
```

---

## 🔄 Reusability in IaC

### 🧱 Why is Reusability Important?
- Reduces duplication across environments (dev, staging, prod).
- Increases maintainability and consistency.
- Promotes modular design and separation of concerns.

### 🛠️ Achieving Reusability in Ansible
1. **Use Roles**: As shown above.
2. **Parameterize Variables**: Define variables so roles can be reused with different values.
3. **Modular Playbooks**: Split playbooks by function or component.
4. **Include/Import Tasks**: Dynamically include tasks based on conditions.
5. **Use Ansible Collections**: Package and distribute reusable roles, modules, and plugins.

---

## ✅ Summary Table

| Concept      | Description                                  | Reusability Benefit |
|--------------|----------------------------------------------|---------------------|
| **Module**   | Executes a single action/task                | Low                 |
| **Role**     | Structured reusable set of tasks/resources   | High                |
| **Playbook** | High-level orchestration of tasks/roles      | Medium              |

---

## 🧠 Final Notes
- Use **roles** to encapsulate infrastructure components (like `nginx`, `mysql`, `users`).
- Leverage **variables and templates** to customize behavior without changing the role logic.
- Combine roles and modules to create robust, repeatable infrastructure automation.

---

# Terraform State Drift

## 🧾 What Is Terraform State Drift?

**State drift** occurs when the actual infrastructure in your cloud environment diverges from what is recorded in Terraform’s **state file** (`terraform.tfstate`).

Terraform uses this state file to understand the current state of resources and decide what needs to be created, updated, or destroyed during `terraform apply`.

When you (or something else) modify infrastructure **outside of Terraform** — like through the cloud provider console, CLI, or other automation — **drift** happens.

---

## 🔍 Causes of Drift

Common causes include:

1. **Manual changes**:
   - A developer manually changes a security group rule or modifies a VM size in the cloud console.

2. **External systems or scripts**:
   - Other automation tools or scripts update resources independently of Terraform.

3. **Auto-scaling or managed services**:
   - Services like AWS Auto Scaling, Azure VMSS, or Kubernetes may adjust resources dynamically.

4. **State file corruption or desynchronization**:
   - When multiple users or systems interact with Terraform without locking or coordination.

---

## 🧰 How to Detect Drift

Run the following command to compare actual infrastructure with the state file:

```bash
terraform plan
```

This shows any changes between your desired (coded) state and real-world infrastructure.

For automation-friendly output:

```bash
terraform plan -detailed-exitcode
```

Exit codes:
- `0`: No changes.
- `1`: Error occurred.
- `2`: Drift detected or changes required.

---

## 🧹 How to Handle Drift

### 1. **Revert Manual Changes**
- Run `terraform apply` to reset the infrastructure to match your code.

### 2. **Adopt New State**
- If the manual change is valid, update the Terraform code accordingly or use `terraform import` to bring it under Terraform management.

### 3. **Refactor Processes**
- Minimize external modifications and enforce Terraform as the single source of truth.

---

## 🛡️ Preventing Drift

You can’t eliminate drift entirely, but you can reduce it:

- Use **Terraform-only workflows**: Avoid manual changes.
- Apply **IAM/RBAC restrictions** to limit direct resource access.
- Use **resource locks** or **policy-as-code** (e.g., Sentinel, Open Policy Agent).
- Automate **drift detection in CI/CD** and alert when differences arise.

---

## ✅ Summary

| Aspect             | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| **What is Drift?** | Mismatch between real infrastructure and Terraform's state file            |
| **Detection**      | Use `terraform plan` or `terraform plan -detailed-exitcode`                |
| **Handling**       | Apply changes, update code, or import changes into Terraform               |
| **Prevention**     | Limit manual edits, use automation, enforce access controls                |

---

# Configuration Idempotence

## 🧾 What Is Configuration Idempotence?

**Idempotence** means that **you can apply the same configuration multiple times, and the result will always be the same** — **without causing side effects**.

In simpler terms:  
> Running your script once or running it ten times should produce the **same end state** on the target system.

This ensures predictability, stability, and safety when automating infrastructure or configuration changes.

---

## 💡 Real-World Analogy

Imagine a light switch:
- **Desired state**: The light should be **ON**.
- When you flip it ON, it changes state once.
- If it's already ON, flipping it ON again does **nothing** — the system is **idempotent**.

---

## 🛠️ Idempotence in Popular Tools

### ✅ Ansible
Tasks are designed to be idempotent:
```yaml
- name: Ensure NGINX is installed
  apt:
    name: nginx
    state: present
```
Running this task multiple times will not reinstall NGINX unless necessary.

### ✅ Terraform
Uses the state file to track infrastructure.
```bash
terraform apply
```
If nothing has changed, Terraform will respond with:
```
No changes. Infrastructure is up-to-date.
```

### ✅ Kubernetes
Using:
```bash
kubectl apply -f deployment.yaml
```
is idempotent — Kubernetes ensures the desired deployment state.

---

## ✅ Why Is Idempotence Important?

| Benefit              | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| 🔄 Safe Re-runs      | Reapply configurations confidently (CI/CD, scheduled runs, etc.)            |
| 🐛 Debugging-Friendly| No unintended side effects during testing or failure recovery               |
| 📦 Efficient Automation | Prevents re-creation or duplication of resources                         |
| 👥 Collaboration      | Teams can safely share and apply the same automation code                  |

---

## 🔥 What Happens Without Idempotence?

Non-idempotent scripts may:
- Reboot servers repeatedly.
- Reinstall software unnecessarily.
- Duplicate users, cron jobs, or firewall rules.
- Cause unpredictable side effects.

### ❌ Example of non-idempotent code:
```bash
echo "* * * * * /usr/bin/backup.sh" >> /etc/crontab
```
Running this multiple times adds the same line again — not idempotent!

---

## 💬 Key Characteristics of Idempotent Code

- Checks the **current state** before making changes.
- Applies changes **only when needed**.
- Leaves the system in the **same state** on repeated execution.
- Handles **partial states** or failures gracefully.

---

## 🧠 Summary

| Term               | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| **Idempotence**    | Re-running config code always results in the same system state              |
| **Why It Matters** | Safe automation, predictable outcomes, minimal side effects                 |
| **Best Practices** | Use state-aware tools, avoid hard-coded effects, test idempotency           |

---

# Variable Precedence in IaC Tools

## 🧾 What Is Variable Precedence?

**Variable precedence** refers to the **rules that determine which variable value is used** when multiple values for the same variable exist in different scopes or files.

> When a variable is defined in multiple places, **which one wins**?

---

## 📌 Why Does This Matter?

If you're writing infrastructure code, your variables might be defined:
- Globally
- For a specific environment
- In a role
- In a command-line override

Knowing which one takes effect helps avoid:
- ❌ Unexpected behavior  
- ❌ Configuration drift  
- ❌ Debugging nightmares

---

## 🔹 Variable Precedence in Terraform

Terraform uses a straightforward precedence model:

1. **CLI Flags** (e.g., `-var`, `-var-file`)
2. **Environment Variables** (e.g., `TF_VAR_region`)
3. **Terraform `.tfvars` files**
   - Automatically loaded: `terraform.tfvars`, `*.auto.tfvars`
4. **Default values in variable blocks**

✅ CLI variables override all others.  
❌ Defaults are used only if no other value is provided.

### Example:
```hcl
variable "region" {
  default = "us-east-1"
}
```

If you run:
```bash
terraform apply -var="region=us-west-1"
```

Terraform will use `"us-west-1"`.

---

## 🔸 Variable Precedence in Ansible

Ansible has a more layered precedence system. Here's a simplified **highest to lowest** order:

| Priority | Source                                            |
|----------|---------------------------------------------------|
| 🔝 1     | Extra vars (`-e "var=value"`) on CLI              |
| 2        | Task-level `vars`                                 |
| 3        | Block-level `vars`                                |
| 4        | Role `vars/main.yml`                              |
| 5        | Inventory group and host variables                |
| 6        | Playbook `vars` and `vars_files`                  |
| 7        | Facts gathered from systems                       |
| 8        | Registered variables                              |
| 9        | `set_fact` or environment variables               |
| 🔚 10     | Role defaults (`defaults/main.yml`)               |

### Example:
If the same variable is:
- Defined as a role default
- Also exists in host vars
- And is passed via `-e` on CLI

➡️ The **CLI variable** will win.

---

## 🔍 Gotchas and Tips

- **Terraform** won’t warn about overrides — review carefully.
- **Ansible** can be confusing — variable inspection tools like `ansible-playbook --check -vvv` help.
- Always **document variables** to reduce conflicts.
- Avoid using the same variable name in multiple scopes unless necessary.

---

## 🧠 Summary

| Tool       | Highest Precedence             | Lowest Precedence              |
|------------|--------------------------------|--------------------------------|
| Terraform  | CLI vars (`-var`)              | Default in `variable {}`       |
| Ansible    | Extra vars (`-e`)              | Role defaults                  |

Understanding variable precedence ensures **predictable, consistent, and safe deployments**.

---

# Multi-environment Strategies in Infrastructure as Code

## 🧾 What Are Multi-environment Strategies?

A **multi-environment strategy** defines how you structure, manage, and deploy different **isolated environments** for your application or infrastructure.

Common environments:
- `dev`: Development or experimentation
- `test` / `qa`: Automated testing
- `staging`: Production-like environment for validation
- `prod`: Live system used by end-users

Each environment can have different settings, resources, or workflows, but maintain similar architecture.

---

## 🎯 Why Use Multi-environment Strategies?

| Benefit            | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| ✅ Safe Testing     | Test infrastructure changes before applying to production                 |
| ✅ Isolation        | Prevent dev issues from impacting production                              |
| ✅ Config Control   | Define custom settings, credentials, or permissions per environment       |
| ✅ Compliance       | Ensure auditing and change management are enforced                        |
| ✅ Automation Ready | Streamline CI/CD pipelines and deployment stages                          |

---

## 🧰 How to Implement Multi-environment Strategies

### 🔸 Terraform

#### 📁 Folder-based Environment Structure
```bash
infra/
├── modules/
│   └── network/
│       └── main.tf
├── envs/
│   ├── dev/
│   │   └── main.tfvars
│   ├── staging/
│   │   └── main.tfvars
│   └── prod/
│       └── main.tfvars
```

Each environment can have:
- Its own `.tfvars` for variables
- Separate backends/state files

#### ✅ Best Practices
- Use remote backends with environment-specific state
- Use consistent module versions across environments
- Separate credentials and access control per environment

---

### 🔸 Ansible

#### 📁 Inventory-based Environment Structure
```bash
inventories/
├── dev/
│   └── hosts.yml
├── staging/
│   └── hosts.yml
└── prod/
    └── hosts.yml

group_vars/
├── dev.yml
├── staging.yml
└── prod.yml
```

- Different inventories define which hosts belong to each environment
- Variables specific to each environment stored in `group_vars` or `host_vars`

#### ✅ Best Practices
- Avoid sharing secrets between environments
- Use dynamic inventory for cloud-managed infrastructure
- Isolate Ansible Vault files per environment

---

### 🔸 Kubernetes (Helm / Kustomize)

Use **namespaces** or **separate clusters** for different environments.

#### Helm Example:
```bash
helm install myapp-dev ./chart -f values-dev.yaml
helm install myapp-prod ./chart -f values-prod.yaml
```


---

## 🧩 Common Patterns

### 1. **Per-Environment Repositories**
- One Git repo per environment (e.g., `infra-dev`, `infra-prod`)
- High isolation, but can lead to duplication

### 2. **Branch-per-Environment**
- Git branches: `main`, `staging`, `dev`
- CI/CD promotes changes through branches

### 3. **Monorepo with Directory-per-Environment**
- All environments stored in one repo
```bash
envs/
├── dev/
├── staging/
└── prod/
```
- Easier to share modules, templates, and configuration

---

## 🔒 Security and Secrets Management

- Use separate IAM roles, service principals, or credentials per environment
- Manage secrets with tools like:
  - 🔐 HashiCorp Vault
  - 🔐 AWS Secrets Manager
  - 🔐 Azure Key Vault
  - 🔐 Ansible Vault

---

## 🧠 Summary

| Topic                     | Recommendation                                                |
|---------------------------|----------------------------------------------------------------|
| **Isolation**             | Keep environments independent and avoid shared state          |
| **Configuration**         | Use `tfvars`, inventory files, or `values.yaml` per env       |
| **Tooling**               | Workspaces, directories, or Git branches                      |
| **Security**              | Use environment-specific credentials and encrypted secrets    |
| **Testing & Promotion**   | Promote validated changes from dev → staging → prod           |

---

# 🔐 Secrets Management in DevOps and IaC

## 🧾 What Is Secrets Management?

**Secrets management** is the secure handling of sensitive data such as:

- API keys  
- Database passwords  
- TLS/SSL certificates  
- Private SSH keys  
- Cloud access tokens  
- Encryption keys  
- Connection strings  

These secrets must be **stored, accessed, and distributed securely**, especially in automation pipelines and Infrastructure as Code (IaC) workflows.

---

## ⚠️ Why Is Secrets Management Important?

| Risk                | Description                                                               |
|---------------------|---------------------------------------------------------------------------|
| 🚨 Data Breach       | Hardcoded secrets in code repositories can be leaked or stolen            |
| 🐛 Misconfigurations | Improperly shared or expired secrets can break environments               |
| 📜 Compliance        | Violates standards like SOC2, ISO, GDPR, HIPAA                            |
| 🔍 Auditing          | You need to track **who accessed what and when**                          |

---

## 🧰 Tools for Secrets Management

### ✅ HashiCorp Vault
- Enterprise-grade tool with access control, secret leasing, and auditing.
- Supports dynamic secrets and automatic revocation.
- Integrates with Terraform, Kubernetes, CI/CD tools.

### ✅ AWS Secrets Manager / Parameter Store
- Managed storage for secrets with auto-rotation and IAM control.
- Native integration with AWS Lambda, ECS, EC2.

### ✅ Azure Key Vault
- Centralized key and secret storage.
- Role-based access and managed identity integration.
- Works with Azure DevOps and pipelines.

### ✅ Google Cloud Secret Manager
- Secure, versioned secret storage with IAM.
- Full audit logging support.

### ✅ Ansible Vault
- Encrypt sensitive files and variables.
- Example:
  ```bash
  ansible-vault encrypt secrets.yml
  ```

### ✅ SOPS (Secrets OPerationS)
- Encrypt YAML/JSON files using KMS, PGP, or age.
- GitOps and Kubernetes-friendly.
- Compatible with Helm, Kustomize, Terraform.

---

## ✅ Best Practices for Secrets Management

### ❌ Don’t:
- Hardcode secrets into source code or Git repositories.
- Use unencrypted `.env` or YAML files.
- Share secrets over unsecured channels (email, chat, tickets).

### ✅ Do:
- Store secrets in **encrypted and access-controlled** systems.
- Rotate secrets **regularly** — automate when possible.
- Use **least privilege** access models.
- Integrate secrets securely into CI/CD pipelines.
- Monitor and audit secret usage.
- Separate secrets per environment (`dev`, `staging`, `prod`).

---

## 🔄 Secrets in IaC Workflows

| Tool         | Best Practices                                                            |
|--------------|---------------------------------------------------------------------------|
| **Terraform**| Avoid plain `.tfvars`; prefer environment variables or Vault              |
| **Ansible**  | Use `ansible-vault` to encrypt secrets                                    |
| **Kubernetes**| Use `Secrets`, Sealed Secrets, or Vault integration                      |
| **CI/CD**    | Store in built-in secrets store (e.g., GitHub Secrets, GitLab Variables)  |

---

## 🧠 Summary

| Aspect             | Recommendation                                                          |
|--------------------|---------------------------------------------------------------------------|
| **What to protect**| API keys, credentials, tokens, certificates, encryption keys             |
| **How to protect** | Managed secret storage, encrypted at rest/in-transit, access-controlled  |
| **Who accesses**   | Only services/users with explicit permission                             |
| **When to rotate** | Regularly, or after each deployment if possible                          |
| **Where to store** | Avoid Git or plaintext files; use secure, centralized tools              |
