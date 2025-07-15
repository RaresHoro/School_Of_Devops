# Network Diagnostics Cheat‑Sheet (Tasks 1‑10)



---



## 1 · Identify the IP address of **endava.com**

| Command                      | Explanation                                                                                                         |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `$ dig +short endava.com`    | `dig` queries DNS directly; `+short` prints only the A/AAAA records. Useful to script or copy‑paste.                |
| `$ getent ahosts endava.com` | Uses system resolver (accounts for `/etc/hosts`, DNS‑over‑TLS, etc.). Shows cached answers + address family. |


---

\## 2 · Check if **[www.google.com](http://www.google.com)** is alive
\| Quick ICMP | `$ ping -c4 www.google.com` – four echo requests. Look for `0% packet loss`. |
\| HTTP layer | `$ curl -I https://www.google.com --max-time 5` – `-I` fetches headers only; a `200 OK` or 30x redirect confirms the web service works and TLS handshake succeeded. |
\| Troubleshooting | DNS fails? Use the IP (e.g. `curl -I https://142.250.190.132`) to isolate name‑resolution vs connectivity issues. |

---

\## 3 · Discover the network path to **amazon.com**

| Tool         | Command                    | Why use it                                                                                                                    |
| ------------ | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `traceroute` | `$ traceroute amazon.com`  | Classic hop‑by‑hop route (UDP >33434 by default).                                                                             |

*Interpretation:* latency jumps reveal long WAN hops; asterisks (`* * *`) mean ICMP blocked or rate‑limited.

---

\## 4 · Verify **no packet‑loss** to **[www.cisco.com](http://www.cisco.com)**

```bash
$ mtr -rzb www.cisco.com
```

* `-z`  remove duplicate hostnames
* `-b`  show both names & IPs
* Look at the `Loss%` column – should be **0.0** for every hop; occasional 1‑2 % on intermediate routers is fine if final hop is 0 %. 

---

\## 5 · Round‑trip time (RTT) to **[www.facebook.com](http://www.facebook.com)**

| Layer            | Command                                                | Metric to read                                                                                         |
| ---------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| ICMP             | `$ ping -c5 www.facebook.com`                          | Read `avg` in `rtt min/avg/max/mdev` – e.g. `42.3 ms`.                                                 |
| TCP + TLS + HTTP | `$ time curl -o /dev/null -s https://www.facebook.com` | `real` time from `time` measures full GET including SSL handshake – useful for user‑perceived latency. |

---

\## 6 · Identify applications currently using the Internet

| Tool      | Command           | Notes                                                                              |
| --------- | ----------------- | ---------------------------------------------------------------------------------- |
| `lsof`    | `# lsof -i -n -P` | Lists every open socket; `-n -P` disables DNS & service‑name resolution for speed. |
| `nethogs` | `# nethogs`       | Live per‑process bandwidth; install via `sudo apt install nethogs`.                |
| `ss`      | `$ ss -tunap`     | Modern replacement for `netstat`; shows PID mapping to sockets.                    |

---

\## 7 · Find DNS resolver(s) configured on this PC
\| Systemd | `$ resolvectl status` – look at *DNS Servers* and *DNSSEC mode*. |
\| Legacy  | `$ cat /etc/resolv.conf | grep nameserver` – lines like `nameserver 192.168.1.1`. |
\| Windows (PowerShell) | `Get-DnsClientServerAddress` |

---

\## 8 · Show MAC address of an interface

```bash
$ ip link show eth0  
$ arp -a 
```

Look for `link/ether 08:00:27:a1:b2:c3`.


```


---

\## 9 · Capture packets during a DNS test (interface **eth0**)

```bash
# 1. Start capture
sudo tcpdump -i eth0 -w dns_test.pcap udp port 53 &
CAP_PID=$!

# 2. Trigger DNS query from another shell
$ dig www.gnu.org @8.8.8.8

# 3. Stop capture
sudo kill $CAP_PID

# 4. Analyse
wireshark dns_test.pcap   # GUI
# or
tshark -r dns_test.pcap -Y dns
```

*Find a packet with `Standard query A www.gnu.org` – note ID field and your source port.*

---

\## 10 · Download a web page via CLI

| Tool     | Command                                                   | Extras                                                    |
| -------- | --------------------------------------------------------- | --------------------------------------------------------- |
| `curl`   | `$ curl -O https://example.com/index.html`                | `-O` keeps remote filename; add `-L` to follow redirects. |
| `wget`   | `$ wget -q --show-progress https://example.com/page.html` | `-q` quiet + progress bar.                                |
---
# Advanced Network Tasks (11‑14)

> **Scope** – Practical, cross‑platform instructions (Linux & Windows) for each task: capturing a browser request & replaying it via CLI, generating a CSR, local hostname mapping, and configuring NICs with `netsh`.

---

## 11 · Copy a Browser Web‑Request & Replay via CLI

| Step                  | Chrome / Edge GUI                                 | CLI equivalent                                              |
| --------------------- | ------------------------------------------------- | ----------------------------------------------------------- |
| **1**                 | Press <kbd>F12</kbd> → Network tab                | –                                                           |
| **2**                 | Check *Preserve log* → Reload page                | –                                                           |
| **3**                 | Right‑click desired row → *Copy → cURL (bash)*    | Copies a full `curl` command incl. headers, cookies, method |
| **4**                 | Paste into a terminal:                            | \`\$ curl '<URL>' \\                                        |
| -H 'User-Agent: …' \\ |                                                   |                                                             |
| -H 'Accept: …'  …\`   |                                                   |                                                             |
| **5**                 | Add `-o response.html` if you want to save output | `$ curl … -o resp.html`                                     |

**Firefox:** right‑click request → *Copy → as cURL* (Linux) or *Copy → cURL (POSIX)* (Win).

> **Why it matters** – Lets you reproduce API calls, debug auth headers, and automate tests without the browser. Works identically on macOS, Linux, WSL, or Git Bash on Windows.

---

## 12 · Generate a CSR (Certificate Signing Request)

### a) Create private key (2048‑bit RSA)

```bash
openssl genrsa -out site.key 2048
```

### b) Generate CSR interactively

```bash
openssl req -new -key site.key -out site.csr
```

You’ll be prompted for **CN (Common Name)**, Org, etc.
`site.csr` is what you upload to the CA (Let’s Encrypt, DigiCert, etc.).

### c) Non‑interactive One‑liner

```bash
openssl req -new -key site.key \
  -subj "/C=RO/ST=Bucharest/L=Bucharest/O=Endava/OU=DevOps/CN=example.com" \
  -out site.csr
```

Validate:

```bash
openssl req -noout -text -in site.csr
```

---

## 13 · Define & Use Hostnames between Machines

### Linux / macOS stub editing

```bash
sudo nano /etc/hosts
```

Add a line:

```
192.168.1.100   app.internal  app
```

Now `$ ping app` resolves to that IP.

### Windows

```powershell
notepad C:\Windows\System32\drivers\etc\hosts
```

Add the same mapping. Flush DNS cache if needed:

```powershell
ipconfig /flushdns
```

### DNS zone (recommended for > few hosts)

* On your DNS server (BIND, Windows DNS, Cloud‑provider) add an *A* record `app.internal` → `192.168.1.100`.
* All clients using that DNS will resolve automatically—no per‑host edits.

---

## 14 · Configure Network Interfaces with **`netsh`** (Windows CLI)

List interfaces:

```cmd
netsh interface ipv4 show interfaces
```

Assume `Ethernet0` has idx = 12.

### a) Set static IPv4 address

```cmd
netsh interface ip set address "Ethernet0" static 172.16.123.110 255.255.254.0 172.16.122.1
```

Syntax: `static <IP> <Netmask> <Gateway>`

### b) Set DNS servers

```cmd
netsh interface ip set dns "Ethernet0" static 8.8.8.8 primary
netsh interface ip add dns "Ethernet0" 1.1.1.1 index=2
```

### c) Revert to DHCP

```cmd
netsh interface ip set address "Ethernet0" dhcp
netsh interface ip set dns "Ethernet0" dhcp
```

Validate:

```cmd
ipconfig /all
```

> **Tip** – Use `netsh -c interface ipv4 dump` to emit a script containing the current settings. Save it before changes to allow easy rollback.

---

### Quick‑fire Summary Table

| Task                   | Command (Linux)                      | Command (Windows)                        |
| ---------------------- | ------------------------------------ | ---------------------------------------- |
| Repeat browser request | Chrome DevTools → *Copy as cURL*     | Same (Edge/Chrome)                       |
| Generate CSR           | `openssl genrsa && openssl req -new` | Same via Git Bash / WSL                  |
| Local hostname         | edit `/etc/hosts`                    | edit `C:\…\hosts` + `ipconfig /flushdns` |
| Net config             | `ip addr`, `nmcli`, `netplan`        | `netsh interface ip …`, `ipconfig`       |


