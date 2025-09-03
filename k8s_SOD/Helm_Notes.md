# Helm Charts — A Practical Guide

## What is Helm?
**Helm** is the package manager for Kubernetes. It bundles Kubernetes manifests and related metadata into a **Chart** that can be versioned, templatized, and installed/updated on a cluster with a single command (`helm install/upgrade`).
A Helm **Release** is a running instance of a chart in a cluster (tracked by the Helm release name and namespace).

---

## Why Should You Use Helm?

### Benefits
- **Reusability & DRY**: Parameterize manifests using templates and `values.yaml`.
- **Versioned Deployments**: Chart and app versions tracked via `Chart.yaml`.
- **Idempotent Upgrades & Rollbacks**: `helm upgrade --install`, `helm rollback`.
- **Dependency Management**: Manage subcharts (DBs, ingress controllers, etc.).
- **Repeatability & CI/CD**: Works well with GitOps tools (Argo CD, Flux).
- **Distribution**: Host charts via Helm repos or OCI registries (ACR, ECR, GCR).
- **Security & Policy**: Sign and verify provenance; validate values with schemas.

### When Helm Shines
- You deploy the **same app to many environments** (dev/tst/stg/prod).
- You need **configurable installs** (different resource limits, secrets, ingress).
- You want **zero-downtime rollouts** and quick **rollbacks**.

---

## Helm Primer: Key Concepts

- **Chart**: A directory with templates, metadata, and default values.
- **Release**: One installed instance of a chart.
- **Repository**: A place to publish charts (HTTP index or OCI registry).
- **Subcharts**: Charts used as dependencies of other charts.
- **Library Charts**: Share template helpers across charts; not installed alone.
- **Values**: Configuration inputs merged at install/upgrade time.

---

## How to Create a Helm Chart

### 1) Scaffold a Chart
```bash
helm create myapp
tree myapp
````

Typical structure:

```
myapp/
  Chart.yaml          # name, version, appVersion, dependencies
  values.yaml         # default values
  values.schema.json  # (optional) validate input values
  charts/             # dependencies (subcharts)
  templates/          # manifest templates (YAML + Go templates)
    _helpers.tpl      # template helpers/partials
    deployment.yaml
    service.yaml
    ingress.yaml
    hpa.yaml
    NOTES.txt         # post-install messages
  .helmignore         # ignore patterns when packaging
```

### 2) Edit `Chart.yaml`

```yaml
apiVersion: v2
name: myapp
description: A demo web application
type: application
version: 0.1.0          # chart version (SemVer)
appVersion: "1.0.3"     # your app image tag/version (freeform, often SemVer)
dependencies: []        # e.g., ingress-nginx, redis, etc.
```

### 3) Add/Refine Templates

Example `templates/deployment.yaml` snippet:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.port }}
          readinessProbe:
            httpGet:
              path: {{ .Values.probes.readiness.path }}
              port: http
            initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds }}
          livenessProbe:
            httpGet:
              path: {{ .Values.probes.liveness.path }}
              port: http
            initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          envFrom:
            - configMapRef:
                name: {{ include "myapp.fullname" . }}
            - secretRef:
                name: {{ include "myapp.fullname" . }}
```

### 4) Customize `values.yaml`

```yaml
replicaCount: 2

image:
  repository: ghcr.io/example/myapp
  tag: ""          # default: appVersion
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts: [myapp.example.com]

probes:
  readiness:
    path: /healthz
    initialDelaySeconds: 10
  liveness:
    path: /livez
    initialDelaySeconds: 20

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
```

### 5) Optional: Validate Values with a Schema

Create `values.schema.json`:

```json
{
  "$schema": "https://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "replicaCount": { "type": "integer", "minimum": 1 },
    "image": {
      "type": "object",
      "properties": {
        "repository": { "type": "string", "minLength": 1 },
        "tag": { "type": "string" }
      },
      "required": ["repository"]
    }
  },
  "required": ["replicaCount", "image"]
}
```

### 6) Lint & Template Locally

```bash
helm lint myapp/
helm template myapp/ --values myapp/values.yaml
```

### 7) Install / Upgrade / Rollback

```bash
# install
helm install myapp ./myapp -n demo --create-namespace

# upgrade (idempotent)
helm upgrade myapp ./myapp -n demo --values values-prod.yaml

# diff (plugin)
helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade myapp ./myapp -n demo -f values-prod.yaml

# rollback to previous revision
helm rollback myapp 1 -n demo

# uninstall
helm uninstall myapp -n demo
```

---

## Chart Best Practices

* Keep **images immutable** (unique tags, not `latest`).
* Add **readiness/liveness probes**; expose **resource requests/limits** in values.
* Provide **NOTES.txt** with helpful post-install info (URLs, credentials workflow).
* Use **helpers** (`_helpers.tpl`) to standardize names/labels:

  ```tpl
  {{- define "myapp.fullname" -}}
  {{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
  ```
* Separate environment configs using **values files**: `values-dev.yaml`, `values-prod.yaml`.
* Use **values.schema.json** to fail-fast on invalid inputs.
* For shared snippets, prefer **library charts**.

---

## Dependencies & Subcharts

### Declare Dependencies

In `Chart.yaml`:

```yaml
dependencies:
  - name: redis
    version: 17.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
```

In `values.yaml`:

```yaml
redis:
  enabled: true
  architecture: standalone
```

Then:

```bash
helm dependency update myapp/
```

Subcharts expose their own values under their chart name (`redis.*`).
You can enable/disable via `condition`, or **import values** using `alias`/`tags`.

---

## Hooks & Lifecycle

**Helm hooks** allow tasks before/after install/upgrade (e.g., DB migrations):

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ include "myapp.fullname" . }}-migrate"
  annotations:
    "helm.sh/hook": pre-upgrade,pre-install
    "helm.sh/hook-weight": "0"
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec: ...
```

Use sparingly; keep hooks **idempotent** and observable.

---

## Testing Charts

* **Unit-style**: Render templates with fake values; assert with tools (helm-unittest).
* **Lint**: `helm lint`.
* **Smoke/E2E**: Install into ephemeral clusters (kind/minikube) in CI, run health checks.
* **Chart Testing**: GitHub Action `helm/chart-testing` automates lint+install tests.

---

## Security & Supply Chain

* **Sign and verify charts**:

  ```bash
  helm package myapp/ --sign --key "Your GPG Key ID" --keyring ~/.gnupg/pubring.gpg
  helm verify myapp-0.1.0.tgz
  ```
* Scan container images (Trivy, Grype) in CI.
* Avoid putting secrets in `values.yaml`; use **external secrets** or encrypted values (e.g., Sealed Secrets, External Secrets Operator).

---

## How to Host a Helm Chart

Helm supports **classic repositories** (static HTTP + `index.yaml`) and **OCI registries**.

### Option A: Host via GitHub Pages (Classic Helm Repo)

1. **Package**:

   ```bash
   helm package myapp/
   ```
2. **Create/Update index**:

   ```bash
   mkdir -p charts
   mv myapp-0.1.0.tgz charts/
   helm repo index charts/ --url https://<user>.github.io/<repo>/charts
   ```
3. **Publish** `charts/` to your repo’s `gh-pages` branch.
4. **Consume**:

   ```bash
   helm repo add myrepo https://<user>.github.io/<repo>/charts
   helm repo update
   helm install myapp myrepo/myapp
   ```

### Option B: Host via ChartMuseum (Self-Hosted)

* Run **ChartMuseum** (container or Helm chart).
* Push:

  ```bash
  helm plugin install https://github.com/chartmuseum/helm-push
  helm cm-push myapp-0.1.0.tgz http://chartmuseum.company.local
  ```
* Add repo & install:

  ```bash
  helm repo add corp http://chartmuseum.company.local
  helm install myapp corp/myapp
  ```

### Option C: Host in an OCI Registry (Recommended)

Modern Helm supports OCI (v3.8+). Use any OCI registry (e.g., **Azure Container Registry (ACR)**, ECR, GCR, GHCR).

**Login**:

```bash
helm registry login myregistry.azurecr.io
```

**Package & Push**:

```bash
helm package myapp/
helm push myapp-0.1.0.tgz oci://myregistry.azurecr.io/helm
```

**Pull & Install**:

```bash
helm pull oci://myregistry.azurecr.io/helm/myapp --version 0.1.0
helm install myapp oci://myregistry.azurecr.io/helm/myapp --version 0.1.0 -n demo
```

> Tip: For AKS + ACR, grant the AKS node’s managed identity **AcrPull** role.

---

## CI/CD & GitOps Integration

* **GitHub Actions** (example):

  * Lint chart on PRs.
  * Test-install in kind.
  * Package & push to OCI on `main` tag.
* **Argo CD / Flux**:

  * Track a chart (repo or OCI) + specific version/range.
  * Sync desired state automatically from Git (values in separate repo encouraged).
* **Helmfile**: Declaratively manage many releases/envs:

  ```yaml
  releases:
    - name: myapp
      chart: oci://myregistry.azurecr.io/helm/myapp
      version: 0.1.0
      namespace: prod
      values: [values-prod.yaml]
  ```

---

## Troubleshooting

* **Render locally**: `helm template` with `-f values.yaml` and `--debug`.
* **Dry-run upgrades**: `helm upgrade --dry-run --debug`.
* **Diff preview**: `helm diff upgrade` (plugin).
* **Release history**: `helm history myapp -n demo`; rollback if needed.
* **Common pitfalls**:

  * Missing RBAC/PSP (or PodSecurity) settings.
  * Immutable fields changed (roll Deployment instead).
  * Using mutable image tags (breaks rollbacks/traceability).

---

## FAQ

**Q: Chart `version` vs `appVersion`?**

* `version` is the chart’s SemVer (affects packaging and dependency resolution).
* `appVersion` is informational (often the container image tag).

**Q: Should I store secrets in values?**
Prefer external secret managers (ESO, Sealed Secrets, cloud KMS). If unavoidable, keep secrets out of Git or use encryption.

**Q: Multiple environments?**
Keep one chart, use env-specific values files; wire through Helmfile, Argo CD, or Flux.

---

## Summary

Helm charts make Kubernetes deployments **repeatable**, **configurable**, and **auditable**.
Adopt OCI-based hosting, strict versioning, values schemas, and CI testing to build a robust, scalable delivery pipeline for your applications.


