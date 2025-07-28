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

