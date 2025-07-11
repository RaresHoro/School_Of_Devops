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

