# Elasticsearch Console Examples with Comments

This document contains example Elasticsearch queries with explanations.
You can paste these into Kibana’s **Dev Tools Console** (`GET _cat/indices?v`, etc.).

---

## 🔹 Cluster and Index Health

```http
# Check cluster health
GET _cluster/health

# List indices with details (status, health, docs count, size)
GET _cat/indices?v
````

---

## 🔹 Basic metricbeat queries

```http
# Count all documents in indices starting with "metricbeat-"
GET metricbeat-*/_count

# Get first 5 docs from metricbeat indices
GET metricbeat-*/_search
{
  "query": { "match_all": {} },
  "size": 5
}

# Search CPU data for host "docker-desktop"
GET metricbeat-*/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "event.dataset": "system.cpu" }},
        { "match": { "host.hostname": "docker-desktop" }}
      ]
    }
  }
}

# Search CPU or memory events (should = OR)
GET metricbeat-*/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "event.dataset": "system.cpu" }},
        { "match": { "event.dataset": "system.memory" }}
      ]
    }
  }
}

# Exclude docs where module = system
GET metricbeat-*/_search
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "event.module": "system" }}
      ]
    }
  }
}

# Find high CPU usage (≥ 0.8 = 80%), return 5 docs
GET metricbeat-*/_search
{
  "query": {
    "range": {
      "system.cpu.total.pct": { "gte": 0.8 }
    }
  },
  "size": 5
}
```

---

## 🔹 Create a custom book index and bulk insert

```http
# Create a new index called bookdb_index
PUT /bookdb_index
{
  "settings": { "number_of_shards": 1 }
}

# Bulk insert 3 book docs
POST /bookdb_index/_bulk
{ "index": { "_id": 1 } }
{ "title": "Elasticsearch: The Definitive Guide", "authors": ["clinton gormley", "zachary tong"], "summary": "A distributed real-time search and analytics engine", "publish_date": "2015-02-07", "num_reviews": 20, "publisher": "oreilly" }
{ "index": { "_id": 2 } }
{ "title": "Taming Text: How to Find, Organize, and Manipulate It", "authors": ["grant ingersoll", "thomas morton", "drew farris"], "summary": "organize text using approaches such as full-text search, proper name recognition, clustering, tagging, information extraction, and summarization", "publish_date": "2013-01-24", "num_reviews": 12, "publisher": "manning" }
{ "index": { "_id": 3 } }
{ "title": "Elasticsearch in Action", "authors": ["radu gheorge", "matthew lee hinman", "roy russo"], "summary": "build scalable search applications using Elasticsearch without having to do complex low-level programming or understand advanced data science algorithms", "publish_date": "2015-12-03", "num_reviews": 18, "publisher": "manning" }
{ "index": { "_id": 4 } }
```

---

## 🔹 Simple search examples

```http
# Search by title (full-text match)
GET bookdb_index/_search
{
  "query": { "match": { "title": "guide" }}
}

# Simple query string (q=)
GET bookdb_index/_search?q=guide

# Field-specific query
GET bookdb_index/_search?q=title:in action

# Match with highlighting (highlight title matches)
POST /bookdb_index/_search
{
  "query": { "match" : { "title" : "in action" }},
  "size": 2,
  "from": 0,
  "_source": [ "title", "summary", "publish_date" ],
  "highlight": { "fields" : { "title" : {} }}
}
```

---

## 🔹 Multi-field search

```http
# Search multiple fields, weight summary higher (^3)
POST /bookdb_index/_search
{
  "query": {
    "multi_match" : {
      "query" : "elasticsearch guide",
      "fields": ["title", "summary^3"]
    }
  },
  "_source": ["title", "summary", "publish_date"]
}

# Boolean must/should/must_not
POST /bookdb_index/_search
{
  "query": {
    "bool": {
      "must": {
        "bool" : {
          "should": [
            { "match": { "title": "Elasticsearch" }},
            { "match": { "title": "Solr" }}
          ],
          "must": { "match": { "authors": "clinton gormely" }}
        }
      },
      "must_not": { "match": {"authors": "radu gheorge" }}
    }
  }
}
```

---

## 🔹 Wildcard, regex, and fuzzy

```http
# Wildcard search (authors starting with t)
POST /bookdb_index/_search
{
  "query": { "wildcard" : { "authors" : "t*" }},
  "_source": ["title", "authors"],
  "highlight": { "fields" : { "authors" : {} }}
}

# Regex search (authors matching t[a-z]*y)
POST /bookdb_index/_search
{
  "query": { "regexp" : { "authors" : "t[a-z]*y" }},
  "_source": ["title", "authors"],
  "highlight": { "fields" : { "authors" : {} }}
}
```

---

## 🔹 Phrase queries

```http
# Phrase query with slop
POST /bookdb_index/_search
{
  "query": {
    "multi_match" : {
      "query": "search engine",
      "fields": ["title", "summary"],
      "type": "phrase",
      "slop": 3
    }
  },
  "_source": [ "title", "summary", "publish_date" ]
}

# Phrase prefix query
POST /bookdb_index/_search
{
  "query": {
    "match_phrase_prefix" : {
      "summary": {
        "query": "search en",
        "slop": 3,
        "max_expansions": 10
      }
    }
  },
  "_source": [ "title", "summary", "publish_date" ]
}
```

---

## 🔹 Advanced query strings

```http
# Query string with fuzziness (~1 = edit distance)
POST /bookdb_index/_search
{
  "query": {
    "query_string" : {
      "query": "(search~1 algorithm~1) AND (grant ingersoll)  OR (tom morton)",
      "fields": ["title", "authors" , "summary^2"]
    }
  },
  "_source": [ "title", "summary", "authors" ],
  "highlight": { "fields" : { "summary" : {} }}
}

# Simple query string (similar but forgiving syntax)
POST /bookdb_index/_search
{
  "query": {
    "simple_query_string" : {
      "query": "(saerch~1 algorithm~1) + (grant ingersoll)  | (tom morton)",
      "fields": ["title", "authors" , "summary^2"]
    }
  },
  "_source": [ "title", "summary", "authors" ],
  "highlight": { "fields" : { "summary" : {} }}
}
```

---

## 🔹 Term, sorting, and ranges

```http
# Term query (exact value match)
POST /bookdb_index/_search
{
  "query": { "term" : { "publisher": "manning" }},
  "_source" : ["title","publish_date","publisher"]
}

# Term + sorting by publish_date (desc)
POST /bookdb_index/_search
{
  "query": { "term" : { "publisher": "manning" }},
  "_source" : ["title","publish_date","publisher"],
  "sort": [{ "publish_date": {"order":"desc"}}]
}

# Range query on publish_date
POST /bookdb_index/_search
{
  "query": {
    "range" : {
      "publish_date": { "gte": "2015-01-01", "lte": "2015-12-31" }
    }
  },
  "_source" : ["title","publish_date","publisher"]
}
```

---

## 🔹 Filters

```http
# Filtered query with review count >= 20
POST /bookdb_index/_search
{
  "query": {
    "filtered": {
      "query" : {
        "multi_match": { "query": "elasticsearch", "fields": ["title","summary"] }
      },
      "filter": {
        "range" : { "num_reviews": { "gte": 20 }}
      }
    }
  },
  "_source" : ["title","summary","publisher", "num_reviews"]
}
```

---

## 🔹 Function score queries

```http
# Score boosting by num_reviews (log1p)
POST /bookdb_index/_search
{
  "query": {
    "function_score": {
      "query": {
        "multi_match" : { "query" : "search engine", "fields": ["title", "summary"] }
      },
      "field_value_factor": {
        "field" : "num_reviews",
        "modifier": "log1p",
        "factor" : 2
      }
    }
  },
  "_source": ["title", "summary", "publish_date", "num_reviews"]
}

# Time-decay scoring function (newer books boosted)
POST /bookdb_index/_search
{
  "query": {
    "function_score": {
      "query": {
        "multi_match" : { "query" : "search engine", "fields": ["title", "summary"] }
      },
      "functions": [
        {
          "exp": {
            "publish_date" : {
              "origin": "2014-06-15",
              "offset": "7d",
              "scale" : "30d"
            }
          }
        }
      ],
      "boost_mode" : "replace"
    }
  },
  "_source": ["title", "summary", "publish_date", "num_reviews"]
}

# Scripted scoring function (custom logic)
POST /bookdb_index/_search
{
  "query": {
    "function_score": {
      "query": {
        "multi_match": { "query": "search engine", "fields": ["title", "summary"] }
      },
      "functions": [
        {
          "script_score": {
            "script": {
              "params": { "threshold": "2015-07-30" },
              "source": """
                def publish_date = doc['publish_date'].value.toInstant().toEpochMilli();
                def thresholdDate = ZonedDateTime.parse(params.threshold + "T00:00:00Z").toInstant().toEpochMilli();
                def num_reviews = doc['num_reviews'].value;
                if (publish_date > thresholdDate) {
                  return Math.log(2.5 + num_reviews);
                } else {
                  return Math.log(1 + num_reviews);
                }
              """
            }
          }
        }
      ]
    }
  },
  "_source": ["title", "summary", "publish_date", "num_reviews"]
}
```
---
