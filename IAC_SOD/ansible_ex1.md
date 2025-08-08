
---

# 🛠️ Ansible Lab Setup (Controller + 2 Nodes)

## ☁️ VM Setup

1. **Provision 3 VMs** (either on AWS, local VirtualBox, or any cloud):

   * `controller` (Ansible master)
   * `web1`
   * `web2`

2. **Ensure SSH connectivity**:

   * All VMs accessible via public IP (or private IP if on same VPC)
   * Security groups/firewalls allow SSH (port 22) from controller to web1 and web2

---

## 📁 Inventory Files

### ✅ `inventory.ini`

```ini
[web]
web1 ansible_host=13.50.200.123
web2 ansible_host=13.50.200.124
```

### ✅ `inventory.yml`

```yaml
all:
  children:
    web:
      hosts:
        web1:
          ansible_host: 13.50.200.123
        web2:
          ansible_host: 13.50.200.124
```

---

## 🔐 SSH Key Pair Creation

On the **controller**:

```bash
ssh-keygen -t rsa -b 4096 -C "ansible@controller"
```

* Private key: `/home/ansible/.ssh/id_rsa`
* Public key: `/home/ansible/.ssh/id_rsa.pub`

---

## ⚙️ `ansible.cfg` Setup

```ini
[defaults]
inventory = ./inventory.ini       # or inventory.yml
remote_user = ansible
host_key_checking = False
```

---

## 🔐 Distribute SSH Key to Nodes

On `web1` and `web2`, logged in as `ubuntu`:

```bash
sudo useradd -m -s /bin/bash ansible
sudo mkdir -p /home/ansible/.ssh
sudo nano /home/ansible/.ssh/authorized_keys   # Paste contents of id_rsa.pub
sudo chmod 700 /home/ansible/.ssh
sudo chmod 600 /home/ansible/.ssh/authorized_keys
sudo chown -R ansible:ansible /home/ansible/.ssh
```

---

## ✅ Test Ad Hoc Ping Command

```bash
ansible all -m ping
```

Expected:

```yaml
web1 | SUCCESS => { "ping": "pong" }
web2 | SUCCESS => { "ping": "pong" }
```

---

## 📜 Playbook: `setup_ansible_user.yml`

```yaml
---
- name: Configure ansible user access
  hosts: web
  become: true

  vars:
    ssh_public_key: "{{ lookup('file', '/home/ansible/.ssh/id_rsa.pub') }}"

  tasks:
    - name: Create devops group
      group:
        name: devops
        state: present

    - name: Add ansible user to devops group
      user:
        name: ansible
        groups: devops
        append: yes

    - name: Allow passwordless sudo for devops group
      copy:
        dest: /etc/sudoers.d/devops
        content: "%devops ALL=(ALL) NOPASSWD:ALL\n"
        owner: root
        group: root
        mode: '0440'

    - name: Ensure ansible user's .ssh directory exists
      file:
        path: /home/ansible/.ssh
        state: directory
        owner: ansible
        group: ansible
        mode: '0700'

    - name: Add public key to ansible user's authorized_keys
      authorized_key:
        user: ansible
        key: "{{ ssh_public_key }}"
        state: present
```

---

## ▶️ Run the Playbook

First time (as `ubuntu` with `.pem` file):

```bash
ansible-playbook setup_ansible_user.yml \
  -i inventory.ini \
  -u ubuntu \
  --private-key ~/.ssh/yourkey.pem
```

Afterwards (as `ansible`, no `.pem`):

```bash
ansible-playbook setup_ansible_user.yml --ask-vault-pass
```

---

## ✅ Final Tests

1. **Ad hoc ping (no password):**

```bash
ansible all -m ping
```

2. **Manual SSH:**

```bash
ssh ansible@13.50.200.123   # web1
ssh ansible@13.50.200.124   # web2
```