# 📝 Notes on Elasticsearch + Kibana + Metricbeat Setup

## 1. What You Set Up

* **Elasticsearch**

  * A distributed search and analytics engine.
  * Stores your data (logs, metrics, documents) in **indices**.
  * Provides a REST API for CRUD (Create, Read, Update, Delete) operations.

* **Kibana**

  * The UI/visualization tool for Elasticsearch.
  * Lets you query, explore, and visualize data using charts, dashboards, and Discover view.
  * Provides **Dev Tools (Console)** for running Elasticsearch queries interactively.

* **Metricbeat**

  * A lightweight shipper that collects **system and service metrics** (CPU, memory, disk, network, Docker stats, etc.).
  * Sends them to Elasticsearch on a fixed interval (e.g., every 10s).
  * Kibana visualizes those metrics automatically (`metricbeat-*` indices).

---

## 2. Data Flow

1. Metricbeat collects metrics from your host/containers.
2. Sends them to **Elasticsearch** (`http://localhost:9200`).
3. Elasticsearch indexes them in `metricbeat-*` indices.
4. Kibana reads those indices and displays them in dashboards/visualizations.

---

## 3. Working with Documents in Elasticsearch

Elasticsearch documents are stored as JSON inside indices.
You can **post new documents, update existing ones, query them, and delete them**.

### 🔹 Create (POST)

Add a new document (auto-generated ID):

```http
POST /myindex/_doc
{
  "service": "grafana",
  "status": "running",
  "timestamp": "2025-09-16T12:34:56Z"
}
```

Or specify your own ID:

```http
PUT /myindex/_doc/1
{
  "service": "prometheus",
  "status": "stopped"
}
```

---

### 🔹 Read (GET/Search)

Get by ID:

```http
GET /myindex/_doc/1
```

Search all docs:

```http
GET /myindex/_search
{
  "query": {
    "match_all": {}
  }
}
```

Filter with conditions:

```http
GET /myindex/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "service": "grafana" }},
        { "match": { "status": "running" }}
      ]
    }
  }
}
```

---

### 🔹 Update

Update part of a document:

```http
POST /myindex/_doc/1/_update
{
  "doc": {
    "status": "running",
    "version": 2
  }
}
```

---

### 🔹 Delete

Delete one document:

```http
DELETE /myindex/_doc/1
```

Delete an index:

```http
DELETE /myindex
```

---

## 4. Searching and Queries

* **Simple search**:

  ```
  GET /myindex/_search?q=grafana
  ```
* **Match query** (full-text):

  ```
  GET /myindex/_search
  {
    "query": { "match": { "summary": "search engine" } }
  }
  ```
* **Boolean queries**: combine `must` (AND), `should` (OR), `must_not` (NOT).
* **Boosting**: increase importance of certain fields, e.g. `summary^2`.
* **Aggregations**: group and summarize data, e.g., count docs per `publisher`.

---

## 5. Kibana Tips

* Use **Discover** to browse documents (`metricbeat-*`, `winlogbeat-*`, or your own index).
* Use **Visualize/Lens** to create charts.
* Use **Dev Tools → Console** for testing Elasticsearch queries directly.
* For dashboards: Metricbeat comes with built-in dashboards you can load into Kibana.

---

## 6. How Logs Work

If you were shipping logs instead of metrics (with Filebeat/Winlogbeat):

* Logs would also be indexed into Elasticsearch (`filebeat-*`, `winlogbeat-*`).
* You could **search logs** in Kibana Discover or **post custom logs** into your own index.
* Example (posting a log manually):

  ```http
  POST /logs-2025-09-16/_doc
  {
    "level": "ERROR",
    "service": "api",
    "message": "Database connection failed",
    "timestamp": "2025-09-16T10:15:00Z"
  }
  ```

---

## ✅ Key Takeaways

* **Metricbeat** continuously ships metrics → you didn’t “run commands” for the charts, it’s automated data ingestion.
* **Elasticsearch** is where all data is stored; you can query and manipulate it with the REST API.
* **Kibana** is the UI: use it for queries, dashboards, and visualizations.
* CRUD on docs = `POST`, `GET`, `POST _update`, `DELETE`.
* Queries let you slice, dice, and rank your data.

