
# Introduction to Kubernetes

## General Overview
Kubernetes (often abbreviated as **K8s**) is an open-source platform designed to **automate the deployment, scaling, and operation of containerized applications**.
Instead of managing individual containers, Kubernetes abstracts them into logical units and provides a unified API to manage them at scale.

Key benefits:
- **Portability**: Works across cloud providers, on-premises, or hybrid setups.
- **Scalability**: Scale applications up or down automatically.
- **Self-healing**: Restart crashed containers, replace failed nodes, reschedule workloads automatically.
- **Declarative Configuration**: Define your desired state, and Kubernetes continuously reconciles it.
- **Extensibility**: Extend core capabilities with operators and CRDs.

---

## Architecture
Kubernetes follows a **master-worker (control plane vs. nodes)** architecture.

- **Control Plane**: Decides *what* should run.
- **Nodes (Workers)**: Actually run the workloads.


### High-Level Flow
1. User submits a **manifest** to the **API Server**.
2. The **Scheduler** picks an appropriate Node.
3. **Kubelet** on the Node ensures the Pod is running.
4. **Controllers** keep the system in the desired state.
5. **etcd** stores the cluster’s state persistently.

---

## Manifests
- Kubernetes objects are declared using **YAML** or **JSON** manifests.
- They follow the structure:
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: mypod
  spec:
    containers:
    - name: mycontainer
      image: nginx
    ````

Applied with:

  ```bash
  kubectl apply -f manifest.yaml
  ```
* Common fields:

  * **apiVersion**: Which API group/version the object belongs to.
  * **kind**: Type of object (Pod, Deployment, etc.).
  * **metadata**: Name, labels, annotations.
  * **spec**: Desired state.
  * **status**: Current state (added by Kubernetes).

---

## Cluster Components

### Control Plane

* **API Server**: Central management hub; exposes REST API; all components talk to it.
* **etcd**: Highly available key-value store; holds entire cluster state.
* **Scheduler**: Decides on which Node Pods should run, based on resources, affinity, taints/tolerations.
* **Controller Manager**: Runs background loops (controllers) to maintain desired state (e.g., ReplicaSet, Node lifecycle).

### Nodes

* **Kubelet**: Node agent ensuring containers run as instructed.
* **Kube-proxy**: Maintains network rules and load-balances Services to Pods.
* **Container Runtime**: Responsible for pulling images and running containers (containerd, CRI-O, Docker).

---

## Labels, Selectors & Annotations

* **Labels**: Key-value pairs attached to objects; used for grouping/filtering.

  ```yaml
  labels:
    app: frontend
  ```
* **Selectors**: Queries that match labels (used in Services, Deployments).

  ```yaml
  selector:
    matchLabels:
      app: frontend
  ```
* **Annotations**: Arbitrary metadata (non-identifying) for tooling/automation.

  ```yaml
  annotations:
    prometheus.io/scrape: "true"
  ```

---

## Installation

### Kubernetes

* **Managed Kubernetes**: GKE, AKS, EKS (most common).
* **Local development**:

  * **Minikube**: Runs Kubernetes locally in VMs/containers.
  * **Kind** (Kubernetes-in-Docker): Lightweight clusters inside Docker.
  * **k3s**: Lightweight distribution for edge/IoT.

### Kubectl

* Command-line tool for managing Kubernetes.
* Examples:

  ```bash
  kubectl get pods
  kubectl describe node <nodename>
  ```

### Kubeconfig

* File storing cluster credentials, API endpoints, contexts.
* Default path: `~/.kube/config`.
* Supports multiple clusters and users:

  ```bash
  kubectl config get-contexts
  kubectl config use-context my-cluster
  ```

---

## Namespace

* Logical partition of cluster resources.
* Default namespaces: `default`, `kube-system`, `kube-public`.
* Useful for:

  * Multi-tenancy
  * Resource quotas
  * Network policies

Example:

```bash
kubectl create namespace staging
kubectl get pods -n staging
```

---

## Authorization (RBAC)

### Roles & ClusterRoles

* **Role**: Defines permissions within a namespace.
* **ClusterRole**: Defines permissions across the cluster.

Example Role:

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: dev
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

### ServiceAccounts

* Provide identity to Pods for API access.
* Mounted as tokens in Pod filesystem.

### RoleBindings & ClusterRoleBindings

* **RoleBinding**: Assigns a Role to a user/ServiceAccount within a namespace.
* **ClusterRoleBinding**: Assigns a ClusterRole across the cluster.

---

## Workloads

### Pod

* Smallest deployable unit.
* Encapsulates one or more tightly coupled containers.

### ReplicaSet

* Ensures a set number of identical Pods are always running.

### StatefulSet

* For stateful apps (databases).
* Provides stable identities and persistent volumes.

### DaemonSet

* Ensures a Pod runs on all (or selected) Nodes.
* Example: logging agents, monitoring agents.

### Deployment

* Manages ReplicaSets and Pods.
* Supports rolling updates, rollbacks.
* Most common way to run stateless apps.

### Jobs & CronJobs

* **Job**: Runs a task to completion (e.g., batch job).
* **CronJob**: Schedules Jobs periodically (like cron).

---

## Network

### Service

* Stable endpoint for Pods.
* Types:

  * **ClusterIP**: Internal-only access.
  * **NodePort**: Exposes Pod on each Node’s IP\:port.
  * **LoadBalancer**: Integrates with cloud load balancers.
  * **ExternalName**: Maps to DNS name.

### NetworkPolicies

* Define which Pods/services can communicate.
* Work like firewalls at the Pod level.

---

## Configuration

### Secret

* Stores sensitive info (passwords, API keys).
* Encoded in Base64.

### ConfigMap

* Stores configuration values.
* Can be mounted as files or environment variables.

---

## Storage

### PersistentVolume (PV)

* Abstraction for physical storage.
* Backed by cloud disks, NFS, iSCSI, etc.

### PersistentVolumeClaim (PVC)

* Request for storage by a user.

### emptyDir

* Temporary storage per Pod.
* Lives as long as Pod runs.

---

## CRD (Custom Resource Definition)

* Extend Kubernetes API with new objects.
* Example: define a `Database` CRD to provision DB instances.
* Basis for Kubernetes **Operators** (controllers for custom resources).

---

## Summary

Kubernetes is a robust system for container orchestration, offering:

* Declarative APIs
* Self-healing, scalability, and portability
* Extensible ecosystem with CRDs and operators


# Kubernetes Persistent Volumes (PVs) and Persistent Volume Claims (PVCs)

## Persistent Volume Claims (PVCs)

- **Reservation of PVs**
  - A PVC reserves a Persistent Volume (PV).
  - Once a PV is bound to a claim, it **cannot be bound to another claim**.

- **Capacity mismatch**
  - A PV can have extra unused capacity.
  - Example: if PVC requests 1 Gi and PV provides 10 Gi, then 9 Gi remain unused (for static provisioning).

- **Reclamation policies** (what happens when a PVC is deleted):
  - `Retain`: the volume and its data are kept, admin must clean up manually.
  - `Delete`: the underlying storage is deleted when the PVC is released.

- **Access Modes**
  - **ReadWriteOnce (RWO)**: Volume can be mounted as read-write by a single node.
  - **ReadOnlyMany (ROX)**: Volume can be mounted read-only by many nodes.
  - **ReadWriteMany (RWX)**: Volume can be mounted as read-write by many nodes.
  - **ReadWriteOncePod (RWOP)**: Volume can be mounted read-write by a single Pod (newer mode).

---

## Provisioning

- **Static provisioning**
  - Admin creates PVs beforehand.
  - PVCs are bound by best-effort match based on access mode and size requests.

- **Dynamic provisioning**
  - A StorageClass provisions storage dynamically.
  - The PVC is created first, and then a matching PV is provisioned automatically.

---

## Shared vs. Per-Pod Storage

- **Deployments**
  - Can use a **single PVC shared** by all Pods.
  - Good for:
    - Logs
    - Shared caches
    - File uploads

- **StatefulSets**
  - Optimized for **per-Pod PVCs**.
  - Suitable for:
    - Databases (MySQL, PostgreSQL, MongoDB)
    - Message brokers (Kafka, RabbitMQ)
    - Distributed storage systems

---

## Choosing Between Deployment + PVC vs StatefulSet

- **Use PV + PVC with a Deployment when**:
  - You want simple persistence for an otherwise stateless app (e.g., file uploads, shared cache).
  - Multiple Pods can mount the same volume (RWX).
  - Stable Pod names are not important.

- **Use StatefulSet (with PVCs) when**:
  - Each Pod needs its own dedicated storage (e.g., DB replicas, Kafka).
  - The app depends on **stable network identity**.

---

## Key Insight

- **Not all apps are stateful**:
  Many workloads (e.g., web apps, APIs, workers) don’t need per-Pod identity or stable storage. For these, a **Deployment + PVC** (shared or single) is simpler.

- **Overhead**:
  StatefulSets add complexity (ordered rollouts, stable Pod names).
  If you just want persistence for a stateless app (like an Nginx serving static files), using a **D
