# Blackbox vs Whitebox Monitoring

## TL;DR

* **Blackbox** = outside-in, synthetic checks against your endpoints (HTTP/TCP/ICMP/browser). Tells you **“can users reach it?”**
* **Whitebox** = inside-out, instrumentation from your app & infra (metrics/logs/traces). Tells you **“what’s happening & why?”**
  Use **both**: blackbox to page on user impact; whitebox to diagnose and fix.

---

## Blackbox Monitoring (Outside-In)

**What it is:** Probes your system like a user would—from outside the stack.
**Signals:** Availability, TLS/DNS/route health, end-to-end latency, content checks.

**Strengths**

* Catches issues that users actually feel: DNS failures, TLS expiry, CDN/WAF misroutes, BGP/ISP blips.
* Independent of your app—works even when *everything inside* is down.
* Excellent for **SLO availability** & burn-rate alerting (fast “is it up?” answers).

**Limitations**

* Little root-cause context: says *it’s broken*, not *why*.
* Risk of false noise from the probe’s own network.
* If probes run inside the same cluster/region, they can **miss egress/edge issues**—use multiple vantage points.

**Typical tools**

* Prometheus **blackbox\_exporter**, Grafana Synthetic Monitoring, Pingdom/UptimeRobot, Datadog Synthetics, k6/browser.

**Prometheus example**

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]      # Decide HTTP/TCP/ICMP/browser modules in blackbox_exporter
    static_configs:
      - targets:
          - https://api.example.com/health
          - https://app.example.com/
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - target_label: __address__
        replacement: blackbox-exporter:9115
      - source_labels: [__param_target]
        target_label: instance
```

Alert on `probe_success == 0` and high `probe_duration_seconds`.

---

## Whitebox Monitoring (Inside-Out)

**What it is:** Telemetry emitted by your services & infra.
**Signals:** Business and technical metrics (RED/USE/golden signals), detailed logs, distributed traces, health of dependencies.

**Strengths**

* Deep **root-cause** context (“which handler/db call slowed down?”, “which tenant fails?”).
* Rich KPIs: latency histograms, error classes, queue depth, cache hit rate, etc.
* Drives **capacity planning**, performance tuning, and reliability engineering.

**Limitations**

* Requires instrumentation + discipline (cardinality, sampling, log noise).
* Can be blind to edge problems (DNS/TLS/CDN) because it assumes you’ve already reached the app.

**Typical tools**

* **Metrics:** OpenTelemetry → Prometheus → Alertmanager/Grafana
* **Logs:** Loki/ELK
* **Traces:** OpenTelemetry → Jaeger/Tempo/Zipkin

**OTel metrics sketch**

```python
from opentelemetry import metrics
meter = metrics.get_meter("checkout")
reqs = meter.create_counter("http_requests_total")
lat  = meter.create_histogram("http_server_duration_ms")

def handle_request():
    reqs.add(1, {"route": "/pay", "status": "200"})
    lat.record(237, {"route": "/pay"})
```

---

## When to Use Which

| Scenario                         | Use Blackbox               | Use Whitebox                       |
| -------------------------------- | -------------------------- | ---------------------------------- |
| TLS cert expired / DNS misconfig | ✅ Catches immediately      | ❌ Often blind                      |
| Internal bug in checkout logic   | ⚠️ May still be 200 OK     | ✅ Shows error rate, failing span   |
| Regional network flap            | ✅ From multi-region probes | ⚠️ Only if you ingest edge metrics |
| SLO paging (user impact)         | ✅ Primary pager signal     | ⚠️ Secondary                       |
| Root-cause analysis              | ❌ Minimal context          | ✅ Deep context                     |

---

## Alerting Strategy (What pages vs what informs)

* **Page on blackbox SLO symptoms** (e.g., `probe_success == 0` for critical endpoints across 2+ regions).
* **Investigate with whitebox**: jump to service dashboards, logs, traces.
* **Burn-rate alerts**: combine blackbox availability with SLO windows (e.g., 2h/6h) to catch fast regressions without flapping.
* **Reduce noise**: whitebox alerts can stay at lower severity unless they directly map to user impact.

---

## Common Pitfalls & How to Avoid Them

* **Probes only from inside the cluster:** add **external vantage points** (different regions/ISPs).
* **Health endpoints that lie:** `/health` must exercise critical dependencies (DB/cache) or expose a “degraded” state.
* **Metric cardinality explosions:** avoid per-user labels; push those to logs/traces instead.
* **Over-alerting on internals:** page the team when users are impacted; keep internal saturation alerts actionable, not noisy.

---

## Putting It Together (Playbook)

1. **Detect:** Blackbox probe fails or latency spikes → page.
2. **Triage:** Check status page/dashboards for region, DNS, TLS, CDN.
3. **Diagnose:** Use whitebox metrics → drill to traces/logs → identify the slow/failing span or dependency.
4. **Resolve:** Roll back, scale, fix config, rotate certs.
5. **Improve:** Add/adjust probes, refine SLOs, tighten health checks, reduce telemetry noise.

---
# Log Levels and Structured Logging

## Why Logging Matters

Logs are often the first place engineers look during an incident. Good logging helps you **understand what happened, when, and why**. Poor logging, on the other hand, can drown you in noise or miss the critical detail you need. Two key practices make logs useful in observability: **log levels** and **structured logging**.

---

## Log Levels

Log levels let you control the **importance and verbosity** of log messages. They provide a way to separate routine events from urgent issues.

### Common Log Levels

* **DEBUG**

  * Fine-grained details for developers.
  * Example: request payloads, variable states, SQL queries.
  * Use in dev/test environments, but avoid spamming in production.

* **INFO**

  * High-level confirmation that things are working as expected.
  * Example: “User 1234 logged in successfully”, “Started background job”.

* **WARNING**

  * Something unexpected happened, but the system can still continue.
  * Example: “Retrying API call after timeout”.

* **ERROR**

  * A serious problem that caused part of the system to fail.
  * Example: “Payment processing failed for order 5678”.

* **CRITICAL / FATAL**

  * System-wide failure or unrecoverable issue.
  * Example: “Database unreachable — shutting down service”.

### Why Log Levels Matter

* Let you **filter logs**: only show `ERROR`+ in alerts, but keep `DEBUG` available in dev.
* Prevent **noise** in production logs.
* Allow dynamic control — many frameworks let you change log level without redeploying.

---

## Structured Logging

Traditional logs are free-form text:

```
2025-09-12 13:22:11 INFO User 1234 logged in
```

This is readable by humans, but hard for machines to search/filter reliably.

**Structured logging** outputs logs in a **machine-parsable format**, usually JSON:

```json
{
  "timestamp": "2025-09-12T13:22:11Z",
  "level": "INFO",
  "event": "user_login",
  "user_id": 1234,
  "ip": "192.168.1.5"
}
```

### Benefits

* **Searchability**: Easily query logs for `user_id=1234` or `event=user_login`.
* **Consistency**: Every log has the same fields (`timestamp`, `level`, `service`, `trace_id`, etc.).
* **Correlation**: Works well with distributed tracing — include `trace_id` or `span_id` in every log.
* **Integration**: Tools like ELK (Elasticsearch/Kibana), Loki, or Splunk can index and filter structured logs quickly.

---

## Best Practices

* **Always include context**: user ID, request ID, correlation/trace IDs.
* **Avoid sensitive data**: never log passwords, tokens, or PII. Use redaction if necessary.
* **Log at the right level**: don’t flood production logs with `DEBUG`.
* **Use structured formats**: JSON or key-value pairs are best for observability pipelines.
* **Keep messages concise**: logs are not stack traces (those belong at `ERROR`/`DEBUG`, not every log).

---

## Example in Python

```python
import logging
import json

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": self.formatTime(record, "%Y-%m-%dT%H:%M:%S"),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name
        }
        return json.dumps(log_record)

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
logger = logging.getLogger("app")
logger.setLevel(logging.INFO)
logger.addHandler(handler)

logger.info("User logged in", extra={"user_id": 1234})
```

Output:

```json
{"timestamp": "2025-09-12T13:40:00", "level": "INFO", "message": "User logged in", "logger": "app"}
```

---

## In Summary

* **Log levels** keep noise down and highlight what’s important.
* **Structured logging** makes logs usable for machines as well as humans.
* Together, they turn logs into a powerful observability signal — not just a text dump.

---

# Correlation IDs: Connecting Logs, Metrics, and Traces

## Why Correlation Matters

Metrics, logs, and traces are powerful individually, but they truly shine when you can **connect them around a single request or transaction**. That’s what correlation IDs (or trace IDs) do: they let you follow an event **end-to-end** across your observability data.

Without correlation:

* You see a latency spike in metrics,
* You dig through logs manually for the same timeframe,
* You open traces separately,
  👉 It’s slow, error-prone, and often misses the real cause.

With correlation IDs:

* Metrics show *“this request was slow”*,
* Logs show *“here’s the detailed error for that request”*,
* Traces show *“here’s the whole journey across services”*,
  👉 You instantly connect the dots.

---

## What is a Correlation ID?

A **Correlation ID** is a unique identifier (often a UUID or trace ID) attached to a single request or transaction.

* Generated at the **entry point** (e.g., API gateway, frontend).
* Propagated across all services involved in handling that request.
* Logged and exported alongside metrics and traces.

In distributed tracing (OpenTelemetry, Zipkin, Jaeger, etc.), this usually takes the form of:

* **trace\_id** → identifies the whole request/trace.
* **span\_id** → identifies a single operation within the trace.

---

## How It Ties Logs, Metrics, and Traces

### Logs

Every log entry for a request should include the correlation ID:

```json
{
  "timestamp": "2025-09-12T13:45:00Z",
  "level": "ERROR",
  "message": "Payment service timeout",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "user_id": "1234"
}
```

### Metrics

High-cardinality metrics shouldn’t tag *every request* with its ID, but they can link back to traces:

* Instead of storing trace\_id on every metric, record aggregate metrics (latency, error count).
* Provide a way to drill into slow/error samples and fetch related traces/logs.
* Example: Grafana shows “99th percentile latency spike” → click → opens Jaeger trace with correlation ID.

### Traces

Spans automatically carry `trace_id` and `span_id`. When logs include these, you can jump from a log line → trace viewer.

---

## Workflow Example

1. **Metric alert fires**: “Checkout latency > 1s for 5% of requests.”
2. **Trace sample**: pick a slow request trace with ID `4bf92f3577b34da6a3ce929d0e0e4736`.
3. **Logs**: query log backend for `trace_id=4bf92f3577b34da6a3ce929d0e0e4736`.
4. **Result**: see exactly which DB query or downstream API timed out.

---

## Best Practices

* **Generate correlation IDs at the edge**: API gateway, frontend, or load balancer.
* **Propagate via headers**: e.g., `traceparent` (W3C Trace Context) or `X-Correlation-ID`.
* **Enrich logs automatically**: use middleware/interceptors to inject IDs into every log entry.
* **Don’t overload metrics**: avoid trace\_id as a label (explodes cardinality). Instead, link to traces/logs via UI.
* **Standardize across teams**: use the same ID format and headers across all services.

---

## Tools & Ecosystem

* **OpenTelemetry**: handles propagation of trace/span IDs automatically.
* **Grafana/Loki/Tempo**: logs with `trace_id` link directly to traces in Tempo.
* **Elastic Stack**: APM trace IDs included in log entries, cross-linked in Kibana.
* **Cloud vendors** (AWS X-Ray, GCP Cloud Trace, Azure Monitor): same pattern—trace IDs in logs for cross-navigation.

---

## In Summary

* **Correlation ID** = request fingerprint.
* **Logs** = narrative tied to that ID.
* **Metrics** = trends & anomalies that point you to traces.
* **Traces** = timeline showing where the request failed.

👉 Together, they let you jump seamlessly from “something’s wrong” → “this request” → “this exact log line” → “this root cause”.

---

# Distributed Tracing

## What It Is

Distributed tracing is a method to **track a single request as it travels through a distributed system** — across microservices, databases, caches, queues, and external APIs.

Instead of seeing just “something is slow,” distributed tracing shows you **where** in the chain the slowdown happens, and how each component contributes to latency.

---

## Key Concepts

* **Trace** → The end-to-end record of a request.
* **Span** → A single operation within a trace (e.g., “API handler,” “DB query”).
* **Trace ID** → Unique ID for the entire request.
* **Span ID** → Unique ID for each span.
* **Parent/Child Relationship** → Shows which spans triggered others (timeline).

A trace is essentially a tree (or DAG) of spans, with timing and metadata.

---

## Why It Matters

In modern systems:

* A request to `checkout` may hit 10+ services.
* Metrics might show high latency, but *where*?
* Logs show local details, but not cross-service flow.

Distributed tracing answers:

* **Where is the bottleneck?** (slow database, external API, network hop)
* **Which services are impacted?**
* **How much time is spent in each step?**
* **Is the system behaving consistently across requests?**

---

## Workflow Example

User requests `/checkout`:

1. **Frontend** → Span A (receives request).
2. **Backend API** → Span B (parent span).

   * Calls **Payment Service** → Span C.
   * Calls **Inventory Service** → Span D.

     * DB query → Span E.

Trace timeline:

```
TraceID: 1234abcd
└── Span A (Frontend)        10ms
    └── Span B (Backend API) 250ms
        ├── Span C (Payment) 200ms
        └── Span D (Inventory)
            └── Span E (DB)  30ms
```

👉 You can immediately see **Payment** caused most of the latency.

---

## How It Works (Under the Hood)

* **Instrumentation**: Libraries (OpenTelemetry, Zipkin, Jaeger clients) wrap your code to start spans and propagate trace context.
* **Propagation**: Trace context is passed via headers (e.g., `traceparent` in W3C Trace Context, `x-b3-traceid` in Zipkin).
* **Collectors/Exporters**: Traces are exported to a backend (Jaeger, Tempo, Zipkin, Datadog, etc.).
* **Visualization**: Traces are viewed in dashboards, showing timeline waterfalls and dependency graphs.

---

## Tools & Ecosystem

* **OpenTelemetry (OTel)** → Standard for generating and exporting traces, metrics, logs.
* **Jaeger (CNCF)** → Visualization + storage for traces.
* **Zipkin** → Early tracing system, still widely used.
* **Grafana Tempo** → Scalable trace backend, integrates with Grafana + Loki.
* **Vendor APMs** (Datadog, New Relic, Dynatrace) → End-to-end tracing built-in.

---

## Best Practices

* **Start at the edge**: Generate a trace ID at the first entry point (API gateway, frontend).
* **Propagate consistently**: Make sure every service passes along trace headers.
* **Add meaningful attributes**: service name, endpoint, user ID (careful: no sensitive data).
* **Sample wisely**: Don’t trace every request in high-volume systems — use head/tail/adaptive sampling.
* **Correlate with logs/metrics**: Include `trace_id` in logs, link from metrics dashboards to traces.
* **Keep spans focused**: One span per logical operation (DB query, API call), not giant spans.

---

## Common Pitfalls

* **Partial traces**: If one service drops the headers, you lose continuity.
* **Overhead**: Full tracing can add cost and overhead — use sampling.
* **Too little detail**: Only tracing at the service entry/exit means missing inner bottlenecks.
* **Data explosion**: Traces generate lots of data — ensure retention/cost policies.

---

## Putting It Into DevOps Workflow

1. **Detect**: Metrics show high latency in checkout.
2. **Trace**: Open a trace in Jaeger → see slow `Payment` span.
3. **Logs**: Search logs for that trace ID → see connection timeout to external API.
4. **Resolve**: Add retries/caching or fix external dependency.
5. **Improve**: Add new span instrumentation to narrow future issues.

---

 **In one sentence:** Distributed tracing gives you the **timeline view of a request across services**, turning a “black box” of microservices into an **open book** for debugging and performance tuning.

---

# SLOs, SLIs, and Error Budgets

## Why They Matter

Uptime and performance goals are easy to over- or under-shoot. Without structure, teams either:

* Aim for **100% reliability** → which is costly, unrealistic, and slows innovation.
* Or set no goals at all → leaving users frustrated with outages and degraded performance.

SLOs, SLIs, and error budgets give you a **measurable framework** to define “good enough” reliability, balance **speed vs. stability**, and keep engineers and business aligned.

---

## Service Level Indicators (SLIs)

**Definition:**
An SLI is a **quantitative measurement** of some aspect of service performance **from the user’s perspective**.

**Examples:**

* **Availability**: % of successful HTTP 200 responses.
* **Latency**: % of requests completed in < 300ms.
* **Durability**: % of data stored without corruption.
* **Correctness**: % of queries returning accurate results.

**Rule of thumb:** SLIs must be:

* **User-centric** (measures what the user experiences).
* **Automated** (measured by monitoring systems, not guesswork).
* **Simple** (focus on a handful of meaningful metrics).

---

## Service Level Objectives (SLOs)

**Definition:**
An SLO is the **target or threshold** you set for an SLI. It defines what “good enough” reliability looks like.

**Examples:**

* Availability: **99.9%** of checkout requests succeed per month.
* Latency: **99%** of requests served in < 300ms.
* Error Rate: **< 0.1%** of requests return 5xx errors.

**Key idea:** SLOs balance user expectations with operational cost.

* Too strict (e.g., 99.999%) → very costly and slows down innovation.
* Too loose (e.g., 95%) → users churn due to bad experience.

---

## Error Budgets

**Definition:**
The **allowable margin of failure** derived from your SLO. It tells you how much unreliability you can afford before breaching your objective.

**Formula:**

```
Error Budget = 100% – SLO
```

**Example:**

* If SLO = 99.9% uptime per month → Error Budget = 0.1% downtime.
* In minutes: 0.1% of 30 days ≈ **43 minutes/month**.
  → You can afford \~43 minutes of downtime per month without violating your SLO.

**How it’s used:**

* If you’re **within budget** → you can take risks, ship new features faster.
* If you’ve **burned the budget** (too many errors/outages) → freeze risky deployments, focus on reliability.

---

## Putting It All Together

| Term             | Definition         | Example                        |
| ---------------- | ------------------ | ------------------------------ |
| **SLI**          | Metric you measure | % of HTTP 200 responses        |
| **SLO**          | Target you aim for | 99.9% availability per month   |
| **Error Budget** | Allowed failure    | 0.1% downtime (\~43 min/month) |

---

## DevOps & SRE Workflow

1. **Define SLIs** that reflect user experience (availability, latency, correctness).
2. **Set SLOs** with stakeholders (product + engineering) that balance cost vs. reliability.
3. **Track error budgets**: monitor how much budget you burn over time.
4. **Use error budgets for decisions**:

   * Budget healthy → innovate faster.
   * Budget nearly spent → prioritize reliability fixes, slow deployments.
5. **Review & adjust** SLOs regularly as product and user needs evolve.

---

## Example in Practice

* **SLI:** 99% of requests return < 200ms.
* **SLO:** Over 30 days, meet this for at least 99% of requests.
* **Error Budget:** 1% of requests may exceed 200ms.

If a deployment causes latency spikes that consume 80% of the error budget in a week → freeze new releases, fix latency issues, then resume.

---

✅ **Bottom line:**

* **SLIs = measurements**
* **SLOs = goals**
* **Error budgets = your margin for failure**

Together, they give you a structured way to align reliability with business goals, while preventing endless “chase for 100% uptime.”

---

# Logs Enrichment

## What It Is

**Log enrichment** is the process of adding **extra context** to log entries beyond the basic message and timestamp. Instead of just “something happened,” enriched logs tell you **who, what, where, and why** — which is critical when you need to correlate logs with metrics, traces, or business events.

---

## Why It Matters

* **Faster debugging**: You don’t have to guess which user, request, or service was involved.
* **Better correlation**: Enriched logs can carry `trace_id`, `span_id`, or `request_id` to link with distributed traces and metrics.
* **Deeper insights**: Business context (order ID, tenant, region) lets you analyze issues by customer impact.
* **Efficient searching**: With structured/enriched logs, you can query precisely in tools like Loki, Elasticsearch, or Splunk.

---

## Common Enrichment Fields

### Technical Context

* **trace\_id / span\_id** → ties logs to distributed traces.
* **request\_id** → links all logs from one HTTP request.
* **service\_name** → which microservice wrote the log.
* **host / pod / container ID** → origin for infra debugging.
* **log level** → severity (INFO, WARN, ERROR).

### Business Context

* **user\_id / tenant\_id** → which customer was affected.
* **order\_id / transaction\_id** → business transaction reference.
* **region / datacenter** → where the request was handled.

### Security Context

* **actor** → who triggered the action.
* **permissions/role** → what access level was in play.

---

## Examples

### Without Enrichment (hard to debug)

```
2025-09-12 13:55:01 ERROR Payment failed
```

### With Enrichment (easy to trace & correlate)

```json
{
  "timestamp": "2025-09-12T13:55:01Z",
  "level": "ERROR",
  "message": "Payment failed",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "service": "checkout",
  "user_id": "12345",
  "order_id": "67890",
  "region": "us-east-1"
}
```

Now you can:

* Click the `trace_id` to see the full trace in Jaeger/Tempo.
* Search logs by `user_id=12345` to see all activity.
* Filter by `region` if only one datacenter had issues.

---

## How to Implement

### 1. Middleware / Interceptors

Enrich logs automatically at the request level. For example in Python (Flask/FastAPI middleware):

```python
from opentelemetry import trace
import logging

def enrich_logs(request):
    trace_id = trace.get_current_span().get_span_context().trace_id
    logging.info("Request received", extra={
        "trace_id": format(trace_id, 'x'),
        "user_id": request.headers.get("X-User-ID")
    })
```

### 2. Logging Libraries with Context

* Python: `structlog`, `logging` with `extra` dict.
* Java: SLF4J/Logback with MDC (Mapped Diagnostic Context).
* Go: `zap` or `logrus` with fields.

### 3. Observability Integration

* Use OpenTelemetry log exporters to automatically inject `trace_id`/`span_id`.
* Configure Fluentd/Fluent Bit to enrich logs with pod metadata (namespace, labels).

---

## Best Practices

* **Standardize fields** across services (e.g., always call it `trace_id`, not `traceId`).
* **Avoid sensitive data** (passwords, tokens, PII) — use masking/redaction.
* **Automate enrichment** at middleware/logging framework level, not manually in every log line.
* **Keep it lightweight** — don’t overload logs with every detail (metrics and traces cover performance).
* **Correlate with metrics/traces** — always include correlation IDs.

---

## In Summary

* **Log enrichment** transforms raw logs into **actionable observability data**.
* Adds **technical, business, and security context**.
* Makes it easy to jump between **logs ↔ metrics ↔ traces**.
* Reduces mean-time-to-detect (MTTD) and mean-time-to-resolve (MTTR).
