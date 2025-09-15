#!/bin/bash

ES_URL="http://localhost:9200"
INDEX="metricbeat-*"
NEW_INDEX="devops-$(date +%Y-%m-%d)"

echo "1. ✅ Check cluster health"
curl -X GET "$ES_URL/_cluster/health?pretty"

echo
echo "2. ✅ List indices"
curl -X GET "$ES_URL/_cat/indices?v"

echo
echo "3. ✅ Count documents in $INDEX"
curl -X GET "$ES_URL/$INDEX/_count?pretty"

echo
echo "4. ✅ Example queries on $INDEX"
# AND query
curl -X GET "$ES_URL/$INDEX/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        { "match": { "host.hostname": "docker-desktop" }},
        { "match": { "event.module": "system" }}
      ]
    }
  },
  "size": 2
}'

# OR query
curl -X GET "$ES_URL/$INDEX/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "should": [
        { "match": { "event.dataset": "system.cpu" }},
        { "match": { "event.dataset": "system.memory" }}
      ]
    }
  },
  "size": 2
}'

# NOT query
curl -X GET "$ES_URL/$INDEX/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "event.module": "system" }}
      ]
    }
  },
  "size": 2
}'

echo
echo "5. ✅ Create a new index and add documents"
curl -X POST "$ES_URL/$NEW_INDEX/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "service": "prometheus",
  "status": "running",
  "timestamp": "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'"
}'

curl -X POST "$ES_URL/$NEW_INDEX/_doc?pretty" -H 'Content-Type: application/json' -d'
{
  "service": "grafana",
  "status": "stopped",
  "timestamp": "'"$(date -u +"%Y-%m-%dT%H:%M:%SZ")"'"
}'

echo
echo "6. ✅ Query documents from $NEW_INDEX"
curl -X GET "$ES_URL/$NEW_INDEX/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  }
}'

echo
echo "7. ✅ Delete index $NEW_INDEX"
curl -X DELETE "$ES_URL/$NEW_INDEX?pretty"
