# Private-VM + Bastion Pattern on Azure

Network-isolated workload, accessible only through a jump host

---

## 1  Create the resource group

```bash
az group create -n aks-light-rg -l northeurope
```

---

## 2  Build the virtual network

| Object           | CIDR           | Purpose          |
| ---------------- | -------------- | ---------------- |
| **vnet-demo**    | `10.10.0.0/16` | hub VNet         |
| **snet-hidden**  | `10.10.1.0/27` | private workload |
| **snet-bastion** | `10.10.2.0/27` | bastion subnet   |

```bash
az network vnet create \
  -g aks-light-rg -n vnet-demo -l northeurope \
  --address-prefix 10.10.0.0/16 \
  --subnet-name snet-hidden --subnet-prefix 10.10.1.0/27

az network vnet subnet create \
  -g aks-light-rg --vnet-name vnet-demo \
  -n snet-bastion --address-prefix 10.10.2.0/27
```

---

## 3  Create Network Security Groups

### 3.1 NSG for *vm-hidden*

```bash
az network nsg create -g aks-light-rg -n vmhidden-nsg -l northeurope

az network nsg rule create -g aks-light-rg \
  -n Allow-VNet \
  --nsg-name vmhidden-nsg \
  --priority 100 --direction Inbound --access Allow \
  --protocol Tcp \
  --source-address-prefixes VirtualNetwork \
  --destination-port-ranges 22 80 8080
```

### 3.2 NSG for *bastion*

```bash
az network nsg create -g aks-light-rg -n bastion-nsg -l northeurope

# Replace X.X.X.X with your real public IP
az network nsg rule create -g aks-light-rg \
  -n Allow-MyIP-SSH \
  --nsg-name bastion-nsg \
  --priority 100 --direction Inbound --access Allow \
  --protocol Tcp \
  --source-address-prefixes X.X.X.X/32 \
  --destination-port-ranges 22
```

---

## 4  Deploy **vm-hidden** (no public IP)

```bash
az vm create \
  -g aks-light-rg -n vm-hidden \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --vnet-name vnet-demo --subnet snet-hidden \
  --nsg vmhidden-nsg \
  --public-ip-address "" \
  --admin-username azureuser \
  --generate-ssh-keys
```

---

## 5  Create a public IP for bastion

```bash
az network public-ip create \
  -g aks-light-rg -n bastion-pip \
  --sku Standard --allocation-method Static
```

---

## 6  Deploy **vm-bastion** (jump host)

```bash
az vm create \
  -g aks-light-rg -n vm-bastion \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --vnet-name vnet-demo --subnet snet-bastion \
  --nsg bastion-nsg \
  --public-ip-address bastion-pip \
  --admin-username azureuser \
  --generate-ssh-keys
```

---

## 7  Authorize the same SSH key on **vm-hidden**

```bash
az vm user update \
  -g aks-light-rg -n vm-hidden \
  --username azureuser \
  --ssh-key-value "$(cat ~/.ssh/id_ed25519.pub)"
```

---

## 8  Test the architecture

### 8.1 SSH into bastion

```bash
ssh -i ~/.ssh/id_ed25519 azureuser@<bastion-public-ip>
```

### 8.2 From bastion, SSH into hidden VM

```bash
ssh -i ~/.ssh/id_ed25519 azureuser@10.10.1.4
```

### 8.3 Start a simple web server on hidden VM

```bash
python3 -m http.server 8080
```

### 8.4 Curl the hidden service from bastion

```bash
curl http://10.10.1.4:8080
```

Expected: directory listing HTML.

### 8.5 Confirm external traffic is blocked

*SSH or curl from any Internet host to vm-hidden should fail (no public IP).*

---

## 9  Optional hardening

* Replace the Python test server with Nginx or your real application.
* Enable Azure Defender, NSG flow logs, and monitoring.
* Swap the VM jump host for **Azure Bastion** PaaS to eliminate public IP exposure.

