A span is just a record of a single operation or step in your system.

Example

Imagine a user clicks “Checkout” in your app:

Frontend receives request → Span A

Backend calls payment service → Span B

Payment service queries database → Span C

All these spans are connected into one trace (the whole journey of the request).


Resource
A resource is a set of static attributes that help us identify the source (and location) that captured a piece of telemetry. Right now, the span’s resource field only contains basic information about the SDK itself, as well as an unknown service.name

However, the four golden signals of observability often provide a good starting point:

Traffic: volume of requests handled by the system
Errors: rate of failed requests
Latency: the amount of time it takes to serve a request
Saturation: how much of a resource is being consumed at a given time


OpenTelemetry Logging
In OpenTelemetry, every piece of data that is neither a part of a distributed trace nor a metric is considered a log. For example, events are just specialized log entries

Logging in OpenTelemetry differs a little from the other signals. Logging is not implemented from the ground up, like traces and metrics, which are exposed in newly built APIs and implemented in SDKs. It uses existing logging functionality from programming languages or existing logging libraries to integrate into. However, this is not necessarily a permanent approach - user-facing logging APIs might be developed in the OpenTelemetry specification, though the bridge method with existing logging systems will continue to be supported. To accomplish that, OpenTelemetry exposes a Logs Bridge API that combines the existing logging solution with traces and metrics collected by OpenTelemetry or other components of OpenTelemetry. Application developers should not use this API, as it should be provided by the logging solution. The logging solution should be configured to send log entries, also called LogRecord, into a LogRecordExporter. The logging solution can use the LoggerProvider factory to create new Logger instances that are initialized once and match the application's lifecycle. The created logger is responsible for creating log entries. When logs are created, LogRecordExporters is responsible for sending the log entries to a collector like the OpenTelemetry Collector. The log entry, which is of type LogRecord, consists of multiple fields like timestamp, traceId, spanId, severityText, body, and others that will be discussed in the exercise for this chapter.


The Benefits of Collectors
Deploying a Collector has many advantages. Most importantly, it allows for a cleaner separation of concerns. Developers shouldn’t have to care about what happens to telemetry after it has been generated. With a Collector, operators can control the telemetry configuration without modifying the application code. Additionally, consolidating these concerns in a central location streamlines maintenance. In an SDK-based approach, the configuration of where telemetry is going, what format it needs to be in, and how it should be processed is spread across various codebases managed by separate teams. However, telemetry pipelines are rarely specific to individual applications. Without a Collector, adjusting the configuration and keeping it consistent across applications can get tricky.


Architecture of a Collector Pipeline

The pipeline for a telemetry signal consists of a combination of receivers, processors, and exporters.

A receiver is how data gets from a source (i.e. the application) to the OpenTelemetry collector. This mechanism can either be pull- or push-based. Out-of-the-box, the Collector supports an OTLPReceiver for receiving traces, metrics, and logs in OpenTelemetry’s native format. The collector-contrib repository includes a range of receivers to ingest telemetry data encoded in various protocols. For example, there is a ZipkinReceiver for traces, StatsdReceiver and PrometheusReceiver and much more. Once data has been imported, receivers convert telemetry into an internal representation. Then, receivers pass the collected telemetry to a chain of processors.

Processors
A processor provides a mechanism to pre-process telemetry before sending it to a backend. There are two categories of processors, some apply to all signals, while others are specific to a particular type of telemetry. Broadly speaking, processing telemetry is generally motivated by several reasons:

To improve the data quality
add, delete, rename, transform attributes
create new telemetry based on existing data
convert an older version of a data source into one that matches the current dashboards and queries used by the backend
For governance and compliance reasons
use attributes to route data to specific backends
To reduce cost
drop unwanted telemetry via allow and deny lists
tail-based sampling
Security
scrubbing data to prevent sensitive information from being stored (and potentially leaked) in a backend
To influence how data flows through the pipeline
batch
retry
memory limit
By connecting processors into a sequential hierarchy, we can process telemetry in complex ways. Since data is passed from one processor to the next, the order in which processors are specified matters.


Finally, the last processor in a chain hands its output to an exporter. The exporter takes the data, converts the internal representation into a protocol of choice, and forwards it to one (or more) destination. Similar to receivers, the collector ships with built-in exporters for OTLP. As previously mentioned, many open source or commercial observability backends are built around custom data formats. Even though OpenTelemetry is becoming more popular, your current backend might not yet (or is in the early stages) support OTLP. To solve this, the collector-contrib repository includes exporters for many telemetry protocols.


After declaring the components, we can finally combine them to form telemetry pipelines. A valid pipeline requires at least one receiver and exporter. In addition, all components must support the data type specified by the pipeline. Note that a component may support one or more data types. For instance, we’ve defined a single OTLP Receiver for logs, metrics, and traces. Placing these components in a pipeline provides the necessary context for how they are used. If we add an OTLP Receiver to a traces pipeline, its role is to receive spans. Conversely, a Prometheus receiver is inherently limited to metrics data. Therefore, it can only be placed in a corresponding pipeline.