# Kubernetes Architecture (In Depth)

Kubernetes follows a **master-worker architecture**, also called the **control plane vs. data plane** model.
The **control plane** makes global decisions and manages the cluster’s state, while **nodes** actually run the workloads (containers).

---

## High-Level Overview

1. **User/API clients** interact with Kubernetes via `kubectl` or other REST clients.
2. **API Server** processes requests and persists desired state in **etcd**.
3. **Controllers** and **Scheduler** ensure the desired state matches the actual state.
4. **Nodes** execute workloads (Pods) with the help of **kubelet**, **kube-proxy**, and a container runtime.

---

## Control Plane Components

### API Server
- Acts as the **front door** to the cluster.
- Exposes the Kubernetes REST API (all communication goes through it).
- Validates and processes API requests.
- Stores data in **etcd**.
- Implements watch/notify pattern for cluster state changes.

### etcd
- **Highly-available, distributed key-value store**.
- Stores entire cluster state (Pods, ConfigMaps, Secrets, events, etc.).
- Strongly consistent (uses the Raft consensus algorithm).
- Backup and recovery of etcd is critical for cluster disaster recovery.

### Scheduler
- Assigns Pods to suitable Nodes.
- Considers:
  - Resource requests/limits (CPU, memory).
  - Node taints/tolerations.
  - Affinity/anti-affinity rules.
  - Pod topology constraints.
- Ensures workloads are balanced and efficient.

### Controller Manager
- Runs multiple controllers as loops.
- Key controllers:
  - **Node Controller**: Detects node failures.
  - **Replication Controller**: Ensures desired number of Pods.
  - **Endpoint Controller**: Manages Service endpoints.
  - **Job Controller**: Manages batch Jobs.

### Cloud Controller Manager (Optional)
- Integrates with cloud provider APIs.
- Handles:
  - Node lifecycle (e.g., detect VM termination).
  - Load balancer provisioning.
  - Persistent volume management.
  - Route configuration.

---

## Node Components

### Kubelet
- Agent running on each Node.
- Registers Node with the API server.
- Ensures containers in Pods are running as expected.
- Interacts with the container runtime through the **Container Runtime Interface (CRI)**.

### Kube-proxy
- Maintains network rules on Nodes.
- Implements Service discovery and load balancing.
- Manages **iptables**, **ipvs**, or **eBPF** rules for traffic routing.

### Container Runtime
- Software that actually runs containers.
- Must implement the **CRI**.
- Common runtimes:
  - **containerd** (default in many distros).
  - **CRI-O** (Kubernetes-native runtime).
  - **Docker** (legacy, deprecated as direct runtime).

---

## Add-ons

- **DNS (CoreDNS)**: Provides internal DNS resolution for Services and Pods.
- **Metrics Server**: Collects resource usage data (CPU/memory).
- **Ingress Controller**: Manages external HTTP/HTTPS access to Services.
- **Dashboard**: Web UI for cluster management.

---

## Data Flow in Kubernetes

### Example: Creating a Pod
1. User applies a Pod manifest:
   ```bash
   kubectl apply -f pod.yaml
   ```

2. `kubectl` sends the request to the **API Server**.
3. API Server validates and stores Pod spec in **etcd**.
4. **Scheduler** sees an unscheduled Pod, picks a Node.
5. **API Server** updates Pod’s Node assignment in etcd.
6. **Kubelet** on the chosen Node sees the assignment, pulls the container image, and runs the container.
7. **Kube-proxy** updates networking rules so the Pod is reachable.
8. Pod status is updated in **etcd**, visible to users via `kubectl get pods`.

---

## Cluster Networking Model

* Each Pod gets its **own IP address**.
* Pods on different Nodes can communicate directly (flat network).
* Services provide a stable DNS name + IP.
* Network plugins (CNI) implement the underlying model:

  * **Calico**
  * **Flannel**
  * **Weave**
  * **Cilium**

---

## Security in the Architecture

* **API Server Authentication**: Certificates, bearer tokens, OIDC.
* **Authorization**: Role-Based Access Control (RBAC).
* **Admission Controllers**: Intercept API requests (e.g., enforce policies).
* **NetworkPolicies**: Restrict Pod-to-Pod communication.

---

## Summary

* **Control Plane** manages the cluster state, schedules workloads, and provides the API.
* **Nodes** execute workloads, handle networking, and interact with the runtime.
* **etcd** is the single source of truth.
* **Extensible add-ons** provide DNS, monitoring, and ingress.
* The architecture is designed for **resilience, scalability, and portability**.


