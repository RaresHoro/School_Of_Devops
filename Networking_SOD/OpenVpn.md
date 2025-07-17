````md
# 🔐 Private VM Access via OpenVPN Gateway on Azure

A single guide that:

1. **Builds infrastructure** (resource group, VNet, subnets, NSGs, VMs).  
2. **Turns `vm-bastion` into an OpenVPN server**.  
3. **Lets your laptop connect via VPN** and reach `vm-hidden` directly.

---

## 1 · Infrastructure Summary (already created)

| Item | Value |
|------|-------|
| Resource Group | **aks-light-rg** |
| VNet | **vnet-demo** |
| Subnets | **snet-hidden** → 10.10.1.0/27 • **snet-bastion** → 10.10.2.0/27 |
| VMs | **vm-hidden** (private) • **vm-bastion** (public IP) |
| NSGs | **vmhidden-nsg** (ports 22 / 80 / 8080 from *VirtualNetwork*) • **bastion-nsg** (SSH 22 from *your IP*) |
| SSH | Key-based login enabled for user **azureuser** |

---

## 2 · Install & Configure OpenVPN on `vm-bastion`

### 2.1 SSH into bastion

```bash
ssh azureuser@<bastion-public-ip>
````

### 2.2 Install packages

```bash
sudo apt update
sudo apt install -y openvpn easy-rsa
```

### 2.3 Enable IP forwarding

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-openvpn.conf
sudo sysctl --system
```

### 2.4 Build PKI (certs & keys)

```bash
make-cadir ~/easy-rsa
cd ~/easy-rsa
cp vars.example vars

./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full server nopass
./easyrsa build-client-full laptop nopass
./easyrsa gen-dh
openvpn --genkey --secret ta.key
```

### 2.5 Move keys to `/etc/openvpn/`

```bash
sudo mkdir -p /etc/openvpn/pki
sudo cp ~/easy-rsa/pki/ca.crt               /etc/openvpn/pki/
sudo cp ~/easy-rsa/pki/issued/server.crt    /etc/openvpn/pki/
sudo cp ~/easy-rsa/pki/private/server.key   /etc/openvpn/pki/
sudo cp ~/easy-rsa/pki/dh.pem               /etc/openvpn/pki/
sudo cp ~/easy-rsa/ta.key                   /etc/openvpn/
sudo chmod 600 /etc/openvpn/pki/server.key /etc/openvpn/ta.key
```

### 2.6 Create server config

```bash
sudo tee /etc/openvpn/server.conf <<'EOF'
port 1194
proto udp
dev tun
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/server.crt
key /etc/openvpn/pki/server.key
dh /etc/openvpn/pki/dh.pem
tls-auth /etc/openvpn/ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
push "route 10.10.1.0 255.255.255.224"
keepalive 10 120
persist-key
persist-tun
cipher AES-256-GCM
user nobody
group nogroup
EOF
```

### 2.7 NAT traffic from VPN → VNet

```bash
IF=$(ip route get 1.1.1.1 | awk '{print $5;exit}')
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$IF" -j MASQUERADE
sudo sh -c 'iptables-save > /etc/iptables.rules'
echo 'pre-up iptables-restore < /etc/iptables.rules' | sudo tee -a /etc/network/interfaces
```

### 2.8 Start OpenVPN

```bash
sudo systemctl enable --now openvpn@server
sudo systemctl status openvpn@server         # ↳ should be “active (running)”
```

---

## 3 · Open UDP 1194 in **bastion-nsg**

Run **locally** (Azure CLI):

```bash
MYIP=$(curl -s https://ifconfig.me)/32

az network nsg rule create \
  --resource-group aks-light-rg \
  --nsg-name bastion-nsg \
  --name Allow-VPN \
  --priority 120 \
  --direction Inbound --access Allow --protocol Udp \
  --source-address-prefixes $MYIP \
  --destination-port-ranges 1194
```

---

## 4 · Generate client profile (`laptop.ovpn`)

Run **on bastion**:

```bash
cat > ~/laptop.ovpn <<EOF
client
dev tun
proto udp
remote <bastion-public-ip> 1194
resolv-retry infinite
nobind
persist-key
persist-tun
cipher AES-256-GCM
topology subnet
remote-cert-tls server
<ca>
$(cat /etc/openvpn/pki/ca.crt)
</ca>
<cert>
$(cat ~/easy-rsa/pki/issued/laptop.crt)
</cert>
<key>
$(cat ~/easy-rsa/pki/private/laptop.key)
</key>
<tls-auth>
$(cat /etc/openvpn/ta.key)
</tls-auth>
key-direction 1
EOF
```

---

## 5 · Download profile to your laptop

```bash
scp azureuser@<bastion-public-ip>:~/laptop.ovpn .
```

---

## 6 · Connect via VPN

### Windows / macOS

1. Install **OpenVPN Connect** or **Tunnelblick**.
2. Import `laptop.ovpn`, click **Connect**.

### Linux

```bash
sudo apt install openvpn -y
sudo openvpn --config ~/laptop.ovpn
```

---

## 7 · Test access to `vm-hidden`

```bash
ssh azureuser@10.10.1.4
curl http://10.10.1.4:8080
```

You can now reach the hidden VM directly whenever the VPN is connected, without SSH hopping through bastion.

```
```

