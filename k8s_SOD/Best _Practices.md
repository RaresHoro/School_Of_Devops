# Kubernetes Best Practices

This document outlines key best practices for managing and securing Kubernetes clusters effectively.

---

## 1. Use Namespaces
Namespaces provide logical partitions within your cluster for improved organization and security.

- **Organize by environment** (e.g., `dev`, `test`, `prod`).
- **Apply Resource Quotas** to avoid resource starvation.
- **Use RBAC** to apply fine-grained permissions.
- **Standardize naming conventions** for consistency.
- **Monitor and label** resources for visibility and governance.

---

## 2. Use Readiness and Liveness Probes

- **Readiness Probes**: Ensure traffic is only routed to a Pod when it is ready.
  Example: If a Pod takes 20s to start and no readiness probe exists, traffic will fail during startup.

- **Liveness Probes**: Detect unresponsive applications. If a probe fails, the kubelet restarts the container automatically.
  Example: Restarting a web app if a health endpoint stops responding.

---

## 3. Use Autoscaling
Leverage Kubernetes autoscaling mechanisms to adapt dynamically to demand:

- **Horizontal Pod Autoscaler (HPA)**: Scales Pods based on CPU/memory usage or custom metrics.
- **Vertical Pod Autoscaler (VPA)**: Adjusts resource requests/limits of Pods automatically.
- **Cluster Autoscaler**: Adds or removes cluster nodes based on scheduling needs.

---

## 4. Use Resource Requests and Limits
Always define **requests** (minimum resources) and **limits** (maximum resources) for containers.

- Prevents scheduling Pods without required resources.
- Ensures one container cannot monopolize Node resources.

> ⚠️ Note: Exceeding memory limits causes process termination. Exceeding CPU limits throttles performance.

---

## 5. Deploy Pods with Higher-Level Controllers
Do not deploy standalone Pods. Instead, use controllers for resilience and scalability:

- **Deployment**
- **ReplicaSet**
- **StatefulSet**
- **DaemonSet**

---

## 6. Use Multiple Nodes
Run workloads across multiple nodes for **fault tolerance** and **high availability**.
A single-node cluster introduces a **single point of failure**.

---

## 7. Use Role-Based Access Control (RBAC)
Implement **RBAC policies** to enforce the principle of least privilege:

- Grant only necessary permissions.
- Bind Roles/ClusterRoles to ServiceAccounts and users appropriately.
- Audit and review permissions regularly.

---

## 8. Host Clusters Externally (Cloud-Managed Services)
Prefer managed Kubernetes services like **AKS**, **EKS**, or **GKE**:

- Simplifies management and upgrades.
- Provides enterprise-grade SLAs and integrations.
- Reduces operational burden.

---

## 9. Upgrade Your Kubernetes Version
Stay up-to-date with Kubernetes releases:

- Gain access to new features and performance improvements.
- Ensure security vulnerabilities are patched.
- Test upgrades in non-production environments before rollout.

---

## 10. Monitor Cluster Resources and Audit Policy Logs
Monitoring is crucial for visibility and reliability.

- **Prometheus**: Standard tool for collecting metrics from Kubernetes components.
- **Logging**:
  - Azure Monitor (AKS)
  - CloudWatch (EKS)
  - Third-party (Datadog, Dynatrace, ELK stack)
- Define **log retention** (30–45 days recommended).
- Continuously review **audit logs** for security events.

---

## 11. Use a Version Control System
Maintain manifests, Helm charts, and configs in Git or another VCS.

- Provides history and traceability.
- Simplifies collaboration and code reviews.

---

## 12. Adopt GitOps Workflows
Use **Git as the single source of truth** for infrastructure and workloads.

- CI/CD pipelines deploy manifests automatically.
- Enables **automation, audit trails, and rollback**.
- Tools: ArgoCD, Flux, Spacelift.

---

## 13. Reduce Container Image Sizes
Smaller images = faster deployments + lower resource usage.

- Use lightweight base images (e.g., **Alpine**).
- Remove unnecessary packages and layers.
- Regularly scan images for vulnerabilities.

---

## 14. Organize with Labels
Labels help organize and track resources effectively.

- Recommended labels:
  - `app.kubernetes.io/name`
  - `app.kubernetes.io/instance`
  - `app.kubernetes.io/version`
  - `app.kubernetes.io/component`
  - `app.kubernetes.io/part-of`
  - `app.kubernetes.io/managed-by`

- Extend with security/compliance labels where required.

---

## 15. Use Network Policies
Restrict communication between Pods for security.

- Deny all traffic by default.
- Explicitly allow required Pod-to-Pod communication.
- Similar to **security groups** in cloud environments.

---

## 16. Use a Firewall
Secure the cluster perimeter.

- Restrict external access to the **API Server**.
- Whitelist trusted IP addresses only.
- Minimize open ports.

---

## 17. Use Declarative Configuration
Adopt declarative manifests (YAML/JSON) for cluster resources.

- Ensures idempotency — repeated applies yield the same state.
- Enables reproducibility and versioning.
- Example:
  ```bash
  kubectl apply -f deployment.yaml
