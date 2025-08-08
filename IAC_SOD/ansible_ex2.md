# 📦 Ansible Project: Apache + User Management with Ansible

This project sets up a real-world Ansible environment that:
- Uses an **Ansible Galaxy role** to install Apache
- Implements a **custom `user_management` role**
- Secures **SSH keys using Ansible Vault**
- Serves a **dynamic HTML page using Jinja2**
- Configures **Apache to run as a non-privileged user (`webuser`)** on port `8080`

---

## 🧱 Environment Overview

| Component  | Description                       |
|------------|-----------------------------------|
| Controller | Local WSL (Ansible control node)  |
| Target 1   | EC2 Instance 1 (`web1`)           |
| Target 2   | EC2 Instance 2 (`web2`)           |

---

## 📁 Project Structure

```
ansible-apache-project/
├── ansible.cfg
├── inventory.ini
├── site.yml
├── vault_ssh_keys.yml         # Encrypted with Ansible Vault
├── templates/
│   └── index.html.j2
├── roles/
│   ├── geerlingguy.apache/    # Downloaded from Ansible Galaxy
│   └── user_management/
│       ├── defaults/main.yml
│       └── tasks/main.yml
```

---

## 🔧 Ansible Config

### `ansible.cfg`
```ini
[defaults]
inventory = ./inventory.ini
remote_user = ansible
host_key_checking = False
```

---

## 📋 Inventory File

### `inventory.ini`
```ini
[web]
web1 ansible_host=13.50.200.123
web2 ansible_host=13.50.200.124
```

---

## 🌍 Install Galaxy Role

```bash
ansible-galaxy install geerlingguy.apache -p roles/
```

---

## 👥 Custom Role: `user_management`

### `roles/user_management/defaults/main.yml`
```yaml
users:
  - name: "rares"
    groups: ["sudo"]
    is_admin: true
    ssh_key: "{{ rares_pub_key }}"
  - name: "webuser"
    groups: ["www-data"]
    is_admin: false
    ssh_key: "{{ webuser_pub_key }}"
```

### `roles/user_management/tasks/main.yml`
```yaml
- name: Ensure groups exist
  group:
    name: "{{ item }}"
    state: present
  loop: "{{ users | map(attribute='groups') | flatten | unique }}"

- name: Create users and assign groups
  user:
    name: "{{ item.name }}"
    groups: "{{ item.groups | join(',') }}"
    append: yes
    shell: /bin/bash
  loop: "{{ users }}"

- name: Grant sudo access to admins
  copy:
    dest: "/etc/sudoers.d/{{ item.name }}"
    content: "{{ item.name }} ALL=(ALL) NOPASSWD:ALL"
    mode: "0440"
  when: item.is_admin
  loop: "{{ users }}"

- name: Add authorized SSH key
  authorized_key:
    user: "{{ item.name }}"
    key: "{{ item.ssh_key }}"
  loop: "{{ users }}"
```

---

## 🔐 Encrypted Vault for Public Keys

### `vault_ssh_keys.yml` (Encrypted with `ansible-vault`)
```yaml
rares_pub_key: "ssh-rsa AAAAB3Nza... rares@controller"
webuser_pub_key: "ssh-rsa AAAAB3Nza... webuser@controller"
```

Create with:

```bash
ansible-vault create vault_ssh_keys.yml
```

---

## 📜 HTML Template with Jinja2

### `templates/index.html.j2`
```html
<html>
  <head><title>Welcome {{ inventory_hostname }}</title></head>
  <body>
    <h1>Welcome from {{ ansible_hostname }}</h1>
    <ul>
      {% for user in users %}
      <li>{{ user.name }} — Groups: {{ user.groups | join(', ') }}</li>
      {% endfor %}
    </ul>
  </body>
</html>
```

---

## 🧾 Main Playbook: `site.yml`

```yaml
- name: Setup users and Apache
  hosts: web
  become: true

  vars_files:
    - vault_ssh_keys.yml

  roles:
    - user_management
    - geerlingguy.apache

  tasks:
    - name: Change Apache to run as webuser
      lineinfile:
        path: /etc/apache2/envvars
        regexp: '^export APACHE_RUN_USER='
        line: 'export APACHE_RUN_USER=webuser'

    - name: Change Apache group to webuser
      lineinfile:
        path: /etc/apache2/envvars
        regexp: '^export APACHE_RUN_GROUP='
        line: 'export APACHE_RUN_GROUP=webuser'

    - name: Change Apache port to 8080
      lineinfile:
        path: /etc/apache2/ports.conf
        regexp: '^Listen '
        line: 'Listen 8080'

    - name: Generate HTML file from template
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html
        owner: webuser
        group: webuser
        mode: "0644"

    - name: Restart Apache
      service:
        name: apache2
        state: restarted
        enabled: true
```

---

## ▶️ Run the Playbook

### First-time (bootstrap with ubuntu user):
```bash
ansible-playbook site.yml \
  -i inventory.ini \
  -u ubuntu \
  --private-key ~/.ssh/mykey.pem \
  --ask-vault-pass
```

### Future runs (as ansible):
```bash
ansible-playbook site.yml --ask-vault-pass
```

---

## ✅ Verify Everything Works

1. SSH into your servers:
   ```bash
   ssh ansible@13.50.200.123
   ```

2. Check Apache is running:
   ```bash
   ps aux | grep apache2
   ```

3. Verify it's running as `webuser`

4. View the page:
   ```bash
   curl http://<your-public-ip>:8080
   ```

---

## ✅ Summary

| Task                             | Outcome                                             |
|----------------------------------|-----------------------------------------------------|
| Apache via Galaxy                | Service installed + running on port 8080           |
| Custom role                      | Users, groups, sudo access, and SSH keys           |
| Vault                            | Keeps public keys secure                           |
| Jinja2 template                  | Generates a dynamic HTML page                      |
| Apache runs as non-root user     | Uses `webuser`, safer deployment                   |

---

Let me know if you want this turned into a Git repo or ZIP structure!
