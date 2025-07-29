# 🤖 Service Principal (Non-Human User)

## What Is a Service Principal?

A **Service Principal** is a **non-human identity** used in Azure to authenticate and authorize applications, scripts, or automation tools (like Terraform, GitHub Actions, or DevOps pipelines) to interact with Azure resources.

Think of it as a **"bot account"** for your app or pipeline that logs into Azure on its behalf.

---

## 🧱 Why Service Principals Matter

### ✅ Secure, Scalable Access
- Allows fine-grained, scoped, and time-limited access.
- Avoids credential sprawl and hardcoded secrets.

### ✅ Non-Interactive Use
- Designed for automation, not human login.
- Used with Azure CLI, SDKs, Terraform, CI/CD, and more.

---

## 🔐 How Service Principals Work

Each Service Principal is backed by:
- An **Azure AD App Registration**
- A **secret or certificate**
- An assigned **role** for RBAC access

---

## 🛠️ Example: Azure CLI Login in a Pipeline

```bash
az login --service-principal \
  --username <appId> \
  --password <secret> \
  --tenant <tenantId>
```

Allows non-human login for CI/CD or scripting.

---

## 🎯 Typical Roles and Permissions

| Role Name    | Description                          |
|--------------|--------------------------------------|
| Reader       | Read-only access                     |
| Contributor  | Read + write (no RBAC changes)       |
| Owner        | Full control, including RBAC         |
| Custom Role  | Tailored to specific needs           |

---

## 🧠 Best Practices

- Use **least privilege** (don't assign Owner unless required)
- Prefer **short-lived secrets or certificates**
- Use **Managed Identity** if supported by the resource
- Store secrets securely (e.g., **Azure Key Vault**)
- Prefer **federated identities** (e.g., GitHub OIDC) when possible

---

## 🔁 Related Azure Concepts

| Concept           | Description                                                     |
|-------------------|-----------------------------------------------------------------|
| Managed Identity  | Azure-managed Service Principal tied to a resource              |
| App Registration  | Identity definition in Azure AD                                |
| RBAC              | Role-Based Access Control — defines what the SP can do         |
| Key Vault         | Ideal place to store SP secrets or certificates securely        |

---

## 💡 Summary

> A **Service Principal** is the go-to identity mechanism in Azure for **apps, pipelines, and automation tools** to access resources securely.

It’s foundational for:
- DevOps pipelines (Azure DevOps, GitHub Actions)
- Terraform and Bicep deployments
- Application-to-Azure communication
- Programmatic Azure management

---

# 🔐 Principle of Least Privilege (PoLP)

## ✅ What Is the Principle of Least Privilege?

The **Principle of Least Privilege** (PoLP) states that **any user, application, service, or process should be granted only the minimum permissions necessary to perform its intended task — nothing more**.

It's a fundamental security concept used to reduce the attack surface and limit the potential damage from mistakes or malicious activity.

---

## 🔍 Why It Matters in Azure

In Azure, permissions are granted using **Role-Based Access Control (RBAC)**. These permissions can be assigned at various scopes such as subscription, resource group, or specific resources.

Without applying least privilege:
- Users may get **Owner** access when they only need **Reader**.
- Service Principals might have **wide permissions** across the subscription when they only need access to one resource.
- Misconfigured automation or compromised accounts could impact **all** resources.

### Benefits:
- Minimizes **unauthorized access**
- Reduces **blast radius** in case of compromise
- Helps achieve **compliance** and better **auditability**

---

## 🛠️ How to Implement Least Privilege in Azure

### 1. Assign Roles at the Smallest Necessary Scope
- Prefer **resource** or **resource group** scope instead of **subscription-wide** access.

### 2. Use Built-in Roles First
- Azure has predefined roles like:
  - `Reader`
  - `Contributor`
  - `Virtual Machine Contributor`
- Avoid `Owner` unless absolutely necessary.

### 3. Create Custom Roles If Needed
- When built-in roles don't fit, define a **custom role** with the exact required actions.
- Example: `Microsoft.Compute/virtualMachines/read`

### 4. Review and Audit Access Regularly
- Use **Azure Policy** and **Access Reviews** via Azure AD.
- Remove inactive users, groups, or Service Principals.

### 5. Use Time-Bound Access
- Enable **Just-In-Time (JIT) access** using **Azure AD Privileged Identity Management (PIM)**.
- Ideal for high-privilege roles like `Owner` or `User Access Administrator`.

### 6. Avoid Overprivileged Service Principals
- Limit Service Principal access to only the scope it needs (e.g., a single resource group).
- Prefer **Managed Identities** when possible.

---

## 🔄 Real-World Example

> A developer only needs to deploy and manage App Services.

### ✅ Recommended:
Assign them the `Website Contributor` or `Web Plan Contributor` role **at the resource group level**.

### ❌ Not Recommended:
Granting `Owner` role at the **subscription level** exposes unnecessary risk and broad control over unrelated resources.

---

## 🧠 Summary

The **Principle of Least Privilege** is a core security best practice:

- Grant **only the access required** — no more.
- Regularly **audit and prune** unused or excessive permissions.
- Helps secure automation (Service Principals), users, and systems.
- Essential for **security, compliance, and operational integrity**.

By applying PoLP, you make your Azure environment more resilient, secure, and controlled.

---
# 🌐 NAT vs Public IP in Azure

Understanding the difference between **NAT (Network Address Translation)** and **Public IP Addresses** is essential for designing secure and efficient network architectures in Azure.

---

## 🔸 Public IP Address

A **Public IP** is a globally routable IP address assigned to a resource that allows **inbound and outbound communication with the internet**.

### ✅ Characteristics:
- Globally unique
- Can be **static** or **dynamic**
- Assigned directly to a VM, Load Balancer, App Gateway, etc.
- Enables **direct access** (e.g., SSH, RDP, HTTP)

### 📌 Example Use Cases:
- Assigning a public IP to a VM for SSH access
- Hosting a public-facing website on a load balancer

---

## 🔸 Network Address Translation (NAT)

**NAT** allows multiple private resources (e.g., VMs in a subnet) to **share one or more public IPs** for **outbound-only communication** to the internet.

### ✅ Characteristics:
- **Outbound internet access only** (no direct inbound access)
- Hides internal private IPs from external exposure
- Can be scaled using **Azure NAT Gateway**
- More secure by reducing exposed surface

### 🧱 Common NAT Forms in Azure:
- **SNAT** – Source NAT for outbound connectivity
- **DNAT** – Destination NAT for routing inbound connections via load balancer rules
- **NAT Gateway** – Managed outbound NAT service for subnets

---

## 🔍 Key Differences

| Feature                  | Public IP                          | NAT (e.g., NAT Gateway or SNAT)        |
|--------------------------|------------------------------------|----------------------------------------|
| Inbound Access           | ✅ Yes                             | ❌ No (unless via DNAT or LB rule)     |
| Outbound Access          | ✅ Yes                             | ✅ Yes                                 |
| Exposure to Internet     | Direct                             | Indirect (internal IP is hidden)       |
| IP Usage                 | One IP per resource (usually)      | One IP shared by many                  |
| Security Implication     | Requires securing exposed endpoint | Minimizes exposure                     |
| Use Case                 | Remote login, public-facing apps   | Outbound traffic from private subnets  |

---

## 🧠 When to Use What?

- **Use a Public IP when**:
  - You need **direct access** to a resource from the internet
  - You're hosting **public APIs**, websites, or need **remote login**

- **Use NAT when**:
  - You want to **enable outbound-only access** for VMs
  - You need to **secure internal resources** without exposing them publicly
  - You want **centralized control** over outbound IPs using NAT Gateway

---

## ✅ Summary

- **Public IP**: Direct, full internet access (both inbound and outbound), more exposed.
- **NAT**: Enables outbound access for private resources with **no direct inbound**, ideal for secure environments.

Both are essential tools in Azure networking—choose based on access needs and security posture.

## Setting up NAT in Azure

```bash
# Set common variables
RG_NAME="rg"
LOCATION="westeurope"
VNET_NAME="vnet-rares"
SUBNET_NAME="subnet1"
VM_NAME="vm-rares-nat"
ADMIN_USER="azureuser"
SSH_KEY_PATH="~/.ssh/id_rsa.pub"

# NAT resources
NAT_NAME="nat-rares"
NAT_PIP_NAME="nat-rares-pip"

# Network names
NIC_NAME="nic-rares-nat"
NSG_NAME="nsg-rares"

# VM and networking setup
ADDRESS_PREFIX="10.10.0.0/16"
SUBNET_PREFIX="10.10.1.0/24"
IMAGE="UbuntuLTS"
SIZE="Standard_B1s"

# ---------------------------
# 1. Create Resource Group
# ---------------------------
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION"

# ---------------------------
# 2. Create VNet + Subnet
# ---------------------------
az network vnet create \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --name "$VNET_NAME" \
  --address-prefix "$ADDRESS_PREFIX" \
  --subnet-name "$SUBNET_NAME" \
  --subnet-prefix "$SUBNET_PREFIX"

# ---------------------------
# 3. Create NSG for internal access
# ---------------------------
az network nsg create \
  --resource-group "$RG_NAME" \
  --name "$NSG_NAME" \
  --location "$LOCATION"

# Allow SSH internally (for testing with private IP if needed)
az network nsg rule create \
  --resource-group "$RG_NAME" \
  --nsg-name "$NSG_NAME" \
  --name AllowSSHInternal \
  --priority 1000 \
  --direction Inbound \
  --protocol Tcp \
  --access Allow \
  --source-address-prefixes VirtualNetwork \
  --destination-port-range 22 \
  --destination-address-prefixes VirtualNetwork

# ---------------------------
# 4. Create Public IP for NAT
# ---------------------------
az network public-ip create \
  --resource-group "$RG_NAME" \
  --name "$NAT_PIP_NAME" \
  --sku Standard \
  --allocation-method Static

# ---------------------------
# 5. Create NAT Gateway
# ---------------------------
az network nat gateway create \
  --resource-group "$RG_NAME" \
  --name "$NAT_NAME" \
  --location "$LOCATION" \
  --public-ip-addresses "$NAT_PIP_NAME" \
  --sku Standard

# ---------------------------
# 6. Associate NAT Gateway with Subnet
# ---------------------------
az network vnet subnet update \
  --resource-group "$RG_NAME" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_NAME" \
  --nat-gateway "$NAT_NAME" \
  --network-security-group "$NSG_NAME"

# ---------------------------
# 7. Create NIC (No Public IP)
# ---------------------------
az network nic create \
  --resource-group "$RG_NAME" \
  --name "$NIC_NAME" \
  --vnet-name "$VNET_NAME" \
  --subnet "$SUBNET_NAME" \
  --network-security-group "$NSG_NAME"

# ---------------------------
# 8. Create Linux VM (private only)
# ---------------------------
az vm create \
  --resource-group "$RG_NAME" \
  --name "$VM_NAME" \
  --image "$IMAGE" \
  --size "$SIZE" \
  --admin-username "$ADMIN_USER" \
  --ssh-key-values "$SSH_KEY_PATH" \
  --nics "$NIC_NAME" \
  --public-ip-address "" \
  --storage-sku Standard_LRS \
  --tags Owner="Owner"

# ---------------------------
# 9. Test
# ---------------------------
echo "NAT-based VM created with outbound internet access but no public IP."
echo "To test, use a jump box or Bastion to connect, then run:"
echo "curl https://ifconfig.me"
```
---

# 🌐 Azure Backbone vs VPN vs ExpressRoute

## 📖 What Is the Azure Backbone?

The **Azure Backbone** is Microsoft’s **private, high-speed, global fiber network** that connects all Azure regions, data centers, and edge nodes around the world. It is the infrastructure that powers services like Azure, Microsoft 365, Bing, and Xbox Live.

Once your traffic enters Azure (via VPN, ExpressRoute, or a public endpoint), it travels across this **secure, low-latency network** — not the public internet.

---

## 🔍 Key Features of Azure Backbone

- **Private and Secure**: Isolated from public internet
- **High Performance**: Ultra-low latency and high bandwidth
- **Global Reach**: Spanning across continents and Azure regions
- **Encrypted by Default**: Data in transit is encrypted end-to-end
- **Built-in Redundancy**: Auto-routing and failover for resilience

---

## 🧾 What Is a VPN?

A **VPN (Virtual Private Network)** securely connects your **on-premises network** to Azure over the **public internet**.

### Characteristics:
- Uses **IPSec encryption**
- Traffic travels over **the internet**, but securely
- Cost-effective and quick to set up
- Ideal for light or test workloads

---

## 🧾 What Is ExpressRoute?

**ExpressRoute** is a **dedicated private connection** between your data center and Azure.

### Characteristics:
- **Does not use the public internet**
- Delivered via Microsoft partners (telecom providers)
- Offers **high speed**, **low latency**, and **SLA-backed uptime**
- Suitable for **production and mission-critical applications**

---

## 🔄 Comparison Table

| Feature                    | **VPN Gateway**                | **ExpressRoute**                     | **Azure Backbone**                      |
|----------------------------|--------------------------------|---------------------------------------|------------------------------------------|
| Connects To               | On-prem to Azure              | On-prem to Azure                     | Inside Azure (region to region/service) |
| Runs Over                 | Public internet                | Private telecom circuit              | Microsoft-owned private fiber           |
| Security                  | Encrypted (IPSec)              | Private, no public exposure          | Encrypted in transit                     |
| Speed/Bandwidth           | Moderate (up to 1 Gbps)        | High (up to 10–100 Gbps)             | Very high (used internally by Azure)    |
| Latency                   | Varies (internet-based)        | Low and predictable                  | Very low and optimized                   |
| Reliability               | Internet-dependent             | SLA-backed                           | Microsoft-controlled                     |
| Setup Time                | Minutes to a few hours         | Days to weeks (requires ISP)         | Automatically used within Azure         |
| Cost                      | Low to moderate                | High (depends on provider + usage)   | Included in Azure service usage         |

---

## 🧠 When to Use What?

### Use **VPN** when:
- You want a **quick and simple** setup
- Moderate performance is acceptable
- You're experimenting or in early-stage development

### Use **ExpressRoute** when:
- You need **guaranteed bandwidth and uptime**
- You're handling **sensitive or high-throughput workloads**
- You must **bypass the internet entirely**

### Azure Backbone is used:
- **Automatically** when Azure services talk to each other
- For **cross-region replication**, **PaaS traffic**, **VNet Peering**, etc.
- By services like **Azure Front Door**, **Private Link**, and **Service Endpoints**

Once your traffic enters Azure, **the Azure Backbone handles it securely and efficiently across Microsoft’s global infrastructure**.

---

## ✅ Summary

- **VPN**: Encrypted tunnel over internet – fast and easy
- **ExpressRoute**: Private connection – high performance and reliability
- **Azure Backbone**: Microsoft’s global, private highway – used inside Azure automatically

Each plays a unique role in building secure and performant Azure architectures.
---

# 💸 Understanding Azure Egress Cost

## 📘 What Is Egress?

**Egress** refers to data **leaving** Azure — typically when it's transferred to:
- The **public internet**
- Another **Azure region**
- A different **availability zone** (in some cases)

In contrast, **ingress** (data coming into Azure) is generally **free**.

---

## 📦 Common Egress Scenarios

| Scenario                                 | Egress Charges? |
|------------------------------------------|------------------|
| Downloading files from Blob to the internet | ✅ Yes         |
| Serving web traffic to external users       | ✅ Yes         |
| Replicating data between regions            | ✅ Yes         |
| Traffic within the same VNet                | ❌ No          |
| Accessing Azure services via Private Link   | ❌ Often free  |

---

## 💰 Typical Azure Egress Pricing (to Internet)

| Data Volume (per month) | Estimated Price per GB |
|-------------------------|------------------------|
| First 5 GB              | Free                   |
| 5 GB – 5 TB             | ~$0.087 per GB         |
| 5 TB – 10 TB            | ~$0.083 per GB         |
| >10 TB                  | Lower (volume discount) |

> 📌 Pricing can vary slightly by region and is subject to change. Always refer to the official [Azure Bandwidth Pricing](https://azure.microsoft.com/en-us/pricing/details/bandwidth/) page.

---

## 🧠 Tips to Reduce Egress Costs

1. **Keep Resources in the Same Region**
   - Co-locate services (App + DB) to avoid cross-region charges.

2. **Use Private Link or Service Endpoints**
   - Routes traffic over the Azure backbone rather than the internet.

3. **Enable Compression**
   - Reduce transferred data volumes (gzip, Brotli, etc.).

4. **Use CDN or Edge Caching**
   - Offload static content delivery and reduce origin egress.

5. **Batch or Aggregate Data Transfers**
   - Fewer large transfers are often more efficient than many small ones.

6. **Monitor and Budget**
   - Use Azure Cost Management to track and alert on data egress usage.

---

## ✅ Summary

| Direction         | Cost      |
|-------------------|-----------|
| Ingress (into Azure) | ✅ Free   |
| Egress (to internet) | 💸 Billed |
| VNet-to-VNet (same region) | ❌ Free   |
| Cross-region traffic | 💸 Yes    |

Egress cost can add up significantly, especially in data-heavy or customer-facing applications. Understanding and designing for it early helps optimize both performance and cost.

---
# 🔐 SSL/TLS, Certificate Authorities, and Let's Encrypt

## 🔒 What Is SSL/TLS?

**SSL (Secure Sockets Layer)** and **TLS (Transport Layer Security)** are cryptographic protocols used to secure communication over networks — especially the internet. 

TLS is the modern, secure successor to SSL. Although SSL is deprecated, the term "SSL" is still commonly used when people mean "SSL/TLS".

### ✅ What They Do:
- **Encrypt** the data in transit to protect it from interception.
- **Authenticate** the identity of the server to prevent impersonation.
- **Ensure data integrity**, making sure data is not tampered with during transmission.

Every time you visit an HTTPS website, TLS is used to keep the connection secure.

---

## 🏢 What Is a Certificate Authority (CA)?

A **Certificate Authority (CA)** is a trusted organization responsible for issuing **digital certificates**. These certificates validate the identity of websites or other services on the internet.

### 🔐 How It Works:
- The CA verifies the ownership and identity of a domain or organization.
- It then issues a **digitally signed certificate** that browsers and systems can trust.
- Your browser uses its list of **trusted root CAs** to verify the certificate chain.

If a certificate is **signed by a trusted CA**, the connection is considered secure.

### 🔎 Examples of Certificate Authorities:
- DigiCert
- GlobalSign
- Sectigo
- Let’s Encrypt

---

## 🎁 What Is Let's Encrypt?

**Let’s Encrypt** is a **free, automated, and open Certificate Authority** created by the Internet Security Research Group (ISRG). It aims to make HTTPS universal and accessible to everyone.

### 🔧 Key Features:
- **Free SSL/TLS certificates** for any domain.
- Fully **automated issuance and renewal** via tools like Certbot.
- **Trusted by all major browsers and platforms**.
- Certificates are valid for **90 days**, encouraging automation and security hygiene.

Let’s Encrypt has drastically simplified the process of enabling HTTPS, contributing to the global push for a more secure web.

---

## 🧠 Summary

| Term             | Description |
|------------------|-------------|
| **SSL/TLS**      | Encryption protocols that secure data in transit |
| **Certificate**  | A digital document proving a server's identity |
| **CA**           | A trusted entity that issues and signs certificates |
| **Let’s Encrypt**| A free, automated CA that simplifies HTTPS adoption |

SSL/TLS ensures that online communications are encrypted and trustworthy, while CAs — including Let’s Encrypt — make that trust possible by issuing and validating certificates.

---
# 🛡️ CVE & GHSA – Vulnerability Identifiers

## 📘 What Are Vulnerability Identifiers?

Vulnerability identifiers are unique labels assigned to known security issues in software. They help developers, security teams, and tools:
- Reference specific vulnerabilities
- Track their status and severity
- Coordinate fixes across platforms

Two of the most common identifiers are:
- **CVE** – Common Vulnerabilities and Exposures
- **GHSA** – GitHub Security Advisory

---

## 🐞 CVE – Common Vulnerabilities and Exposures

### ✅ What Is CVE?

**CVE** is an internationally recognized system for cataloging publicly known cybersecurity vulnerabilities.

### 🔧 Managed By:
- **MITRE Corporation**, sponsored by the U.S. Department of Homeland Security
- Official site: [https://cve.org](https://cve.org)

### 🔢 Format:
```
CVE-YYYY-NNNNN
```
Example:
```
CVE-2023-12345
```

### 🎯 Purpose:
- Provide a **universal identifier** for vulnerabilities
- Allow tools and teams to **correlate and communicate** about issues
- Enable consistent **vulnerability management** across systems

### 📍 Where You’ll See It:
- Operating system package issues (Ubuntu, RHEL, etc.)
- Web servers (e.g., Apache, Nginx)
- Libraries and frameworks (e.g., OpenSSL, Log4j)

---

## 🛠️ GHSA – GitHub Security Advisory

### ✅ What Is GHSA?

**GHSA** is GitHub’s platform-specific system for documenting and tracking vulnerabilities in **open source repositories hosted on GitHub**.

### 🔧 Managed By:
- GitHub Security Team and open source maintainers
- Publicly listed at: [https://github.com/advisories](https://github.com/advisories)

### 🔢 Format:
```
GHSA-xxxx-xxxx-xxxx
```
Example:
```
GHSA-7rjr-3q55-vv33
```

### 🎯 Purpose:
- Track vulnerabilities **within GitHub-hosted projects**
- Power automated alerts (e.g., Dependabot)
- Help maintainers and contributors **resolve and disclose issues responsibly**

### 📍 Where You’ll See It:
- Node.js (npm), Python (PyPI), Ruby (Gems), Go modules
- GitHub Actions and workflow vulnerabilities
- GitHub Security Tab, Pull Request checks, and Dependency Graph

---

## 🔍 CVE vs GHSA – Key Differences

| Feature            | **CVE**                            | **GHSA**                                  |
|--------------------|-------------------------------------|--------------------------------------------|
| Managed By         | MITRE (independent registry)        | GitHub Security Team                        |
| Scope              | All software & hardware             | GitHub-hosted open source only             |
| Format             | CVE-YYYY-NNNNN                      | GHSA-xxxx-xxxx-xxxx                         |
| Integration        | OS vendors, global tools, scanners  | GitHub repos, Dependabot, GitHub API       |
| Usage              | Enterprise, security vendors        | Developers, open source maintainers        |

---

## 🧠 Why This Matters

Vulnerability identifiers are critical for:
- **Coordinated vulnerability disclosure**
- **Automated patching and alerts**
- **Compliance and reporting**
- **Clarity across security tools and platforms**

They are foundational to secure software development and effective vulnerability management.

---

## 🔗 Useful Links

- [CVE.org](https://cve.org)
- [GitHub Advisory Database](https://github.com/advisories)
- [National Vulnerability Database (NVD)](https://nvd.nist.gov/)

---
# 📦 Storage Lifecycle Rules

## 📘 What Are Storage Lifecycle Rules?

**Storage Lifecycle Rules** are automated policies that manage the **retention, movement, and deletion** of stored data over time.

They help control:
- **Where** your data resides (e.g., Hot vs. Cool vs. Archive tiers)
- **How long** data is retained
- **When** data is deleted

> The primary goal is to **optimize cost and performance** automatically.

---

## 🔁 How Lifecycle Rules Work

A typical lifecycle flow might look like this:

- **Days 0–30**: Store files in the **Hot/Standard** tier for frequent access.
- **Days 31–90**: Move less-accessed files to the **Cool/Archive** tier.
- **Day 91+**: Automatically **delete** files no longer needed.

These actions are automated based on object age, access patterns, and naming.

---

## 🧠 Why Use Lifecycle Rules?

- 💰 **Cost Savings**: Shift data to lower-cost storage tiers
- ⚙️ **Automation**: No need for manual cleanup
- 📜 **Compliance**: Enforce data retention or deletion policies
- 🧹 **Efficiency**: Keep your storage lean and manageable

---

## 🔄 Example Lifecycle Actions

| Action                  | Common Use Case                     |
|--------------------------|--------------------------------------|
| Move to Cool/Archive     | Archive logs or images after 30 days |
| Delete blobs             | Remove old temp files after 90 days  |
| Tier-down blob storage   | Reduce cost for infrequently used data |
| Retain indefinitely      | Keep legal documents untouched       |

---

## 🏗️ Lifecycle Rules in Azure Blob Storage

Azure supports lifecycle rules specifically for **Blob Storage**. You can:

- Apply rules to **containers**, **prefixes**, or **specific blob types**
- Use filters like:
  - **Last modified date**
  - **Blob name patterns**
  - **Access tiers**

### Supported Actions in Azure:

- Move to **Cool tier**
- Move to **Archive tier**
- **Delete blobs**
- **Delete snapshots**
- **Delete blob versions**

---

## 📅 Common Use Cases

- **Application Logs**: Keep for 30 days in Hot, archive afterward, delete at 90 days.
- **Backups**: Archive after 7 days, delete after 90 days.
- **Media Content**: Gradually move to colder tiers as it ages.
- **Data Retention**: Automatically delete PII or sensitive data after compliance deadlines.

---

## 🧠 Things to Keep in Mind

- Lifecycle rules are **bulk operations** — they apply automatically to all matching objects.
- Archive tier is the **cheapest**, but also the **slowest to access** (rehydration required).
- Some transitions may **incur costs** if accessed later.
- Ensure rules don’t **conflict** or cause unexpected deletion (e.g., delete before transition).

---

## ✅ Summary

Storage Lifecycle Rules are a powerful, cost-effective way to:
- Automate storage management
- Ensure compliance with data retention policies
- Optimize cloud spending

They're widely supported across cloud platforms like **Azure Blob Storage**, **AWS S3**, and **Google Cloud Storage** — and are highly recommended for long-lived or high-volume storage scenarios.

---

# 💰 Resource Tagging (Follow the Money)

## 📘 What Is Resource Tagging?

**Resource tagging** is the process of attaching **key-value metadata** to cloud resources to help with organization, automation, governance, and especially **cost management**.

Tags are simple labels, such as:

```
Environment=Prod
Owner=rares.horodinca@endava.com
Project=AI-Initiative
```

They help you **track, search, group, and manage** cloud resources effectively.

---

## 💡 “Follow the Money” – Why Tagging Is Critical

In cloud platforms like Azure, it's easy to create resources and lose track of **who owns them, why they exist, or how much they're costing**.

Tagging allows you to **follow the money** by tying usage and billing to:
- Specific people or teams
- Departments or cost centers
- Projects or environments
- Business justification

---

## 🧱 Example Tags and Their Purpose

| Tag Key       | Value Examples                  | Purpose                            |
|---------------|----------------------------------|------------------------------------|
| `Owner`       | `rares.horodinca@endava.com`     | Identifies the responsible person  |
| `Project`     | `CRM-Platform`, `DataLake-2025` | Groups resources by initiative     |
| `Environment` | `Dev`, `Test`, `Prod`           | Indicates lifecycle stage          |
| `CostCenter`  | `IT-OPS`, `FIN-DEV`             | Maps usage to financial units      |
| `Stage`       | `Build`, `Staging`, `Live`      | Tracks deployment context          |
| `Expiration`  | `2025-09-01`                    | Helps with automated cleanup       |

---

## 📊 Tags for Cost Management

Tags are fully integrated with **Azure Cost Management + Billing**. You can:

- **Filter usage and cost reports** by tag values
- **Create budgets and alerts** per project or owner
- **Visualize spend** by department or function
- Enable **chargebacks and showbacks** internally

This allows teams to **own their consumption** and stay accountable.

---

## 🧠 Best Practices for Tagging

1. **Standardize your tag keys**
   - Use lowercase, no spaces or special characters
   - Be consistent across teams and resource types

2. **Automate tagging with policies**
   - Use Azure Policy to enforce required tags
   - Auto-populate default values where needed

3. **Include tags in templates and scripts**
   - Bicep, ARM, Terraform, CLI — tag everything by default

4. **Audit tagging regularly**
   - Use Azure Resource Graph or reporting tools to find missing or inconsistent tags

---

## ⚠️ Common Mistakes to Avoid

- ❌ Inconsistent tag keys (`project` vs `Project`)
- ❌ Leaving values blank (`Owner=` with no value)
- ❌ Only tagging top-level resources (misses attached disks, IPs, etc.)
- ❌ Ignoring tags in cost reporting

---

## ✅ Summary

| Benefit             | Description                                       |
|---------------------|---------------------------------------------------|
| Cost Tracking        | Assign costs by team, project, or department     |
| Governance           | Identify resource owners and purpose             |
| Automation           | Enable rules, alerts, and cleanup by tag         |
| Compliance           | Enforce tagging policies with Azure Policy       |


> 🎯 **Tag it, track it, trim it. That’s how you follow the money.**

---

# ⚙️ High Availability (HA) — Applications and Clusters

## 📘 What Is High Availability?

**High Availability (HA)** refers to the design and implementation of systems in a way that ensures **minimal downtime** and **continuous operation** even in the event of component failures.

The goal is to keep services accessible and responsive — especially critical in cloud-native environments.

---

## 🧩 HA in Applications vs HA in Clusters

### 🧩 High Availability in Applications

High availability in applications means ensuring that the **end-user experience is uninterrupted**, even if parts of the backend fail.

#### ✅ Strategies:
- **Load Balancers** to distribute traffic across multiple instances
- **Auto-scaling and auto-healing** to replace unhealthy components
- **Retry logic** within the application code
- **Redundancy**: Deploy multiple copies of each service

### 🧱 High Availability in Clusters

A **cluster** is a group of servers (nodes) that work together to host workloads. In a cluster:

- HA ensures that the **system keeps running** even if one or more nodes go down
- Critical services (databases, containers, APIs) remain accessible

#### ✅ Common Examples:
- **Kubernetes clusters**
- **Database clusters** (SQL Always On, MongoDB Replica Sets)
- **Azure VM Scale Sets**

---

## 🔄 HA Techniques Across Components

| Component        | HA Technique                                             |
|------------------|----------------------------------------------------------|
| Web Applications | Load balancing, multi-instance deployment                |
| Databases        | Replication, failover clusters, geo-redundancy           |
| Virtual Machines | Availability sets/zones, health probes, auto-restart    |
| Containers       | Kubernetes replica sets, self-healing nodes              |
| Storage          | LRS, ZRS, GRS redundancy                                 |
| Networking       | Redundant gateways, Traffic Manager, Azure Front Door   |

---

## 🏗️ High Availability in Azure

Azure provides native tools and services to support high availability:

- **Availability Sets**: Protect VMs from host-level failures
- **Availability Zones**: Protect VMs/apps from datacenter outages
- **Azure Load Balancer**: Distribute traffic across backend pools
- **Azure Front Door**: Global HTTP load balancing and failover
- **Azure Kubernetes Service (AKS)**: Node auto-healing, multi-zone deployments
- **SQL Database Auto-Failover**: Resilient, managed database HA

### 📊 Azure SLA Tiers

| Deployment Type              | Typical SLA          |
|------------------------------|----------------------|
| Single VM (Premium SSD)      | 99.9%                |
| Availability Set             | 99.95%               |
| Availability Zones           | 99.99%               |

---

## 📅 HA vs Disaster Recovery (DR)

| Aspect             | High Availability (HA)                 | Disaster Recovery (DR)                 |
|--------------------|----------------------------------------|----------------------------------------|
| Focus              | Continuous service                     | Service restoration after outage       |
| Recovery Time      | Seconds to minutes                     | Minutes to hours                       |
| Tools              | Load balancers, zones, clustering      | Backups, geo-replication, failover     |

- **HA** is about **avoiding downtime**
- **DR** is about **recovering from downtime**

---

## ✅ Summary

High Availability is all about **designing for failure**:
- Ensure **no single point of failure**
- Use **redundancy, distribution, and automation**
- Rely on **cloud-native HA tools and patterns**

---

# 🚨 P0, P1, P2 — Priority Levels in Incident and Task Management

## 📘 What Are P0, P1, P2?

**P0**, **P1**, **P2** (and sometimes **P3**, **P4**) are commonly used priority levels to indicate the **urgency and impact** of a task, bug, or incident.

These labels help teams triage, communicate, and respond consistently to issues based on their criticality.

---

## 📊 Priority Level Definitions

| Priority | Label        | Description                                                                 |
|----------|--------------|-----------------------------------------------------------------------------|
| **P0**   | 🔥 Critical   | Full system outage, data loss, or security breach. Requires immediate response. |
| **P1**   | 🚨 High       | Major functionality broken; workaround exists. Urgent but not catastrophic. |
| **P2**   | ⚠️ Medium     | Non-blocking bugs or feature gaps. Can be scheduled into upcoming sprints. |
| **P3+** | ✅ Low         | Cosmetic issues, enhancements, or technical debt. Not time-sensitive.       |

---

## 🔥 P0 — Critical Priority

### Examples:
- Entire system or key service is down
- Production deployment failure
- Security incident or data breach
- Users cannot log in or access critical features

### Response:
- **Immediate escalation**
- **24/7 on-call rotation may be triggered**
- Stakeholder communication initiated
- Typically tracked in a **"war room"** setting

---

## 🚨 P1 — High Priority

### Examples:
- Broken features with a workaround
- Performance degradation under load
- Affecting a specific customer segment

### Response:
- Acknowledged and assigned quickly (e.g., within hours)
- Fix planned within **days**, not weeks
- Impact tracked closely

---

## ⚠️ P2 — Medium Priority

### Examples:
- Minor bugs with low user impact
- Missing or inconsistent behavior
- UI misalignment

### Response:
- Logged and triaged
- Typically scheduled in an upcoming sprint
- May be deferred if higher priority work exists

---

## ✅ P3 / P4 — Low Priority

### Examples:
- Cosmetic issues
- Nice-to-have feature requests
- Outdated documentation
- Known tech debt

These are typically logged for future backlog grooming or enhancement cycles.

---

## 🧠 Why Prioritization Matters

Using a clear priority system helps teams:

- Focus on what truly matters
- Respond to incidents quickly and effectively
- Communicate urgency and expectations
- Support SLA commitments and incident management workflows

---

## 🔍 Priority vs Severity

| Term       | What it Describes                  |
|------------|-------------------------------------|
| **Severity** | The **impact** of the issue (e.g., all users affected) |
| **Priority** | The **urgency** of the response or fix                  |

> A minor bug may be *low severity* but *high priority* if it affects a key customer presentation tomorrow.

---

## ✅ Summary

- **P0** = Stop everything, fix immediately
- **P1** = High importance, fix ASAP with a plan
- **P2** = Moderate impact, scheduled appropriately
- **P3+** = Minor issues, track and resolve as resources allow



