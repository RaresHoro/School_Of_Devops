# Linux Fundamentals 

---

Test files live in `/tmp/lab` to keep your system tidy:

```bash
mkdir -p /tmp/lab && cd /tmp/lab
```

---

## 1 · Boot Process

| Stage      | Component          | What Happens                                  | Inspect / Troubleshoot            |                                   |
| ---------- | ------------------ | --------------------------------------------- | --------------------------------- | --------------------------------- |
| Firmware   | BIOS / UEFI        | Hardware init, POST, choose boot device       | \`dmesg -T                        | head\` (shows early kernel lines) |
| Bootloader | GRUB 2             | Presents menu, loads kernel + initrd          | `cat /boot/grub/grub.cfg`         |                                   |
| Kernel     | `vmlinuz`          | Detects hardware, mounts initrd, starts PID 1 | `uname -a` for running kernel     |                                   |
| init       | `systemd` (modern) | Parses unit files, mounts FS, starts targets  | `systemd-analyze plot > boot.svg` |                                   |

**Common issue**: stuck at GRUB prompt ⇒ corrupted `/boot/grub`.

---

## 2 · Basic Commands Recap

| Task         | Command                   | Notes                              |         |                      |
| ------------ | ------------------------- | ---------------------------------- | ------- | -------------------- |
| File listing | `ls -la`                  | `-h` for human sizes               |         |                      |
| Disk usage   | `df -h`, `du -hs *`       | \`du -ah                           | sort -h | tail\` biggest files |
| Process list | `ps aux`, `top`, `htop`   | `htop` interactive (needs package) |         |                      |
| Network      | `ip a`, `ss -tulnp`       | `ss -s` summary                    |         |                      |
| Help         | `man <cmd>`, `cmd --help` | `man tldr` after installing `tldr` |         |                      |

---

## 3 · Reading from Files

```bash
head -n 5 syslog      # first 5 lines
less /var/log/syslog   # scroll with / search, q to quit
awk '{print $1,$5}' /etc/passwd | column -t
```

`less` vs `more`: less supports backward search (`?pattern`).

---

## 4 · Using **sed** to Edit Files

| Goal                         | Command                              | Explanation                                 |
| ---------------------------- | ------------------------------------ | ------------------------------------------- |
| In‑place replace `foo`→`bar` | `sed -i 's/foo/bar/g' file.txt`      | `-i` writes back; keep backup with `-i.bak` |
| Delete empty lines           | `sed -i '/^$/d' file.txt`            | regex anchors `^$`                          |
| Append line after match      | `sed '/Pattern/a New line' file.txt` | `a` = append                                |

**Tip**: test without `-i` first (`sed '...' file`).

---

## 5 · Comparing Files

| Tool        | Use‑case       | Example                             |
| ----------- | -------------- | ----------------------------------- |
| `diff`      | Text diff      | `diff -u old.txt new.txt` (unified) |
| `colordiff` | Colorized diff | `sudo apt install colordiff`        |
| `cmp`       | Binary compare | `cmp file1.img file2.img`           |

---

## 6 · Finding Files (`find`, `locate`)

```bash
# by name case‑insensitive
a) find /etc -iname '*.conf' | head
# by size > 100 MiB
b) sudo find / type f -size +100M -print
# fast DB search (must updatedb once)
locate authorized_keys | head
```

Pitfall: default `locate` DB updates daily; run `sudo updatedb` after creating many new files.

---

## 7 · Piping & Redirection

| Operator | Purpose               | Example              |          |              |
| -------- | --------------------- | -------------------- | -------- | ------------ |
| \`       | \`                    | pipe stdout → stdin  | \`ps aux | grep nginx\` |
| `>`      | overwrite file        | `echo hi > out.txt`  |          |              |
| `>>`     | append                | `date >> log.txt`    |          |              |
| `2>`     | redirect stderr       | `cmd 2> err.log`     |          |              |
| `&>`     | stdout + stderr       | `make &> build.log`  |          |              |
| `2>&1`   | merge stderr → stdout | `cmd > all.log 2>&1` |          |              |
| `<<EOF`  | here‑doc              | see earlier example  |          |              |

---

## 8 · Archiving & Compression

```bash
tar czf project.tar.gz project/    # create gzip tarball
tar xvf project.tar.gz              # extract
zip -r archive.zip dir/             # zip
```

Useful flags: `-v` verbose, `-C` change dir.

---

## 9 · Working with File Permissions

```bash
chmod 644 file        # rw-r--r--
chmod u+x script.sh   # add execute for owner
chown user:group file # change owner
```

Special bits: **suid (4)**, **sgid (2)**, **sticky (1)**.

---

## 10 · Recording Terminal Sessions

| Tool               | Start                                | Stop   | Replay                                |
| ------------------ | ------------------------------------ | ------ | ------------------------------------- |
| `script`           | `script session.log`                 | `exit` | `scriptreplay session.log`            |
| `script` w/ timing | `script -t 2>timing.log session.log` | `exit` | `scriptreplay timing.log session.log` |

---

## 11 · **screen** (terminal multiplexer)

| Action        | Command                 |
| ------------- | ----------------------- |
| Start session | `screen`                |
| Detach        | `Ctrl‑A D`              |
| List sessions | `screen ‑ls`            |
| Re‑attach     | `screen ‑r <id>`        |
| Split window  | `Ctrl‑A S` (horizontal) |
| New window    | `Ctrl‑A C`              |

Alt: `tmux` (modern).

---

## 12 · Crontab (Scheduled Tasks)

Edit user cron:

```bash
crontab -e
```

Example entry (run backup daily at 02:30):

```
30 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
```

View jobs:

```bash
crontab -l
```

System‑wide: `/etc/crontab`, `/etc/cron.*` directories.

---

## 13 · Bash Scripting Essentials

| Concept    | Snippet                              |
| ---------- | ------------------------------------ |
| Shebang    | `#!/usr/bin/env bash`                |
| Arguments  | `$1`, `$@`                           |
| Arrays     | `arr=(a b c)`                        |
| Loops      | `for f in *.txt; do echo "$f"; done` |
| Functions  | `func() { echo hi; }`                |
| Exit codes | `if cmd; then ...; fi`               |

Debug with `bash -x script.sh`.

---

## 14 · Vi/Vim Quick Keys

| Mode   | Key              | Action           |
| ------ | ---------------- | ---------------- |
| Normal | `i`              | insert           |
|        | `:w`             | save             |
|        | `:q!`            | quit no save     |
|        | `yy`, `p`        | yank line, paste |
| Visual | `v`, select, `y` | yank selection   |

Leader cheat‑sheet: `:help` inside vim.

---

## 15 · Services (`systemd`)

```bash
sudo systemctl status ssh
sudo systemctl start/stop/restart ssh
sudo systemctl enable ssh    # auto‑start on boot
```

Create custom service:

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My App
After=network.target
[Service]
ExecStart=/opt/myapp/run.sh
Restart=on-failure
[Install]
WantedBy=multi-user.target
```

Then `sudo systemctl daemon-reload && sudo systemctl enable --now myapp`.

---

## 16 · Monitoring Basics

| Tool                            | Purpose                     |
| ------------------------------- | --------------------------- |
| `top` / `htop`                  | live CPU/mem/processes      |
| `vmstat 1`                      | system summary every second |
| `iostat -xz 1`                  | disk I/O                    |
| `netstat -tulnp` or `ss -tulnp` | listening sockets           |
| `dstat` / `glances`             | all‑in‑one (install)        |

---

## 17 · Managing Login Scripts

| File                               | Scope                                     |
| ---------------------------------- | ----------------------------------------- |
| `~/.bash_profile`, `~/.profile`    | executed for login shells                 |
| `~/.bashrc`                        | executed for interactive non‑login shells |
| `/etc/profile`, `/etc/bash.bashrc` | system‑wide                               |

Tip: source `~/.bashrc` inside `~/.bash_profile` to unify.

---

## 18 · Local Users Administration

```bash
sudo adduser alice          # interactive
sudo usermod -aG sudo alice # add to sudo group
sudo passwd -l bob          # lock account
sudo deluser bob            # remove user (keep files)
```

## 19 · Local Groups Administration

```bash
sudo groupadd devs
sudo usermod -aG devs User2
getent group devs           # list members
```

---

## 20 · `sudoers` File

Edit safely with `visudo` (syntax check):

```bash
sudo visudo
```

Examples:

```bash
user2 ALL=(ALL) NOPASSWD:ALL
# Allow web group to restart nginx
%web ALL=(root) /bin/systemctl restart nginx
```




