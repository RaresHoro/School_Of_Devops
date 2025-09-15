# Elasticsearch URL
$ES_URL = "http://localhost:9200"

# Today's index name (devops-YYYY-MM-DD)
$today = Get-Date -Format "yyyy-MM-dd"
$NEW_INDEX = "devops-$today"

Write-Host "1. ✅ Check cluster health"
Invoke-RestMethod -Method Get -Uri "$ES_URL/_cluster/health?pretty"

Write-Host "`n2. ✅ List indices"
Invoke-RestMethod -Method Get -Uri "$ES_URL/_cat/indices?v"

Write-Host "`n3. ✅ Count documents in metricbeat-*"
Invoke-RestMethod -Method Get -Uri "$ES_URL/metricbeat-*/_count?pretty"

Write-Host "`n4. ✅ Example queries on metricbeat-*"

# AND query
Invoke-RestMethod -Method Get -Uri "$ES_URL/metricbeat-*/_search?pretty" -ContentType "application/json" -Body @'
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
}
'@

# OR query
Invoke-RestMethod -Method Get -Uri "$ES_URL/metricbeat-*/_search?pretty" -ContentType "application/json" -Body @'
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
}
'@

# NOT query
Invoke-RestMethod -Method Get -Uri "$ES_URL/metricbeat-*/_search?pretty" -ContentType "application/json" -Body @'
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "event.module": "system" }}
      ]
    }
  },
  "size": 2
}
'@

Write-Host "`n5. ✅ Create a new index and add documents"

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

Invoke-RestMethod -Method Post -Uri "$ES_URL/$NEW_INDEX/_doc?pretty" -ContentType "application/json" -Body (@"
{
  "service": "prometheus",
  "status": "running",
  "timestamp": "$timestamp"
}
"@)

Invoke-RestMethod -Method Post -Uri "$ES_URL/$NEW_INDEX/_doc?pretty" -ContentType "application/json" -Body (@"
{
  "service": "grafana",
  "status": "stopped",
  "timestamp": "$timestamp"
}
"@)

Write-Host "`n6. ✅ Query documents from $NEW_INDEX"
Invoke-RestMethod -Method Get -Uri "$ES_URL/$NEW_INDEX/_search?pretty" -ContentType "application/json" -Body @'
{
  "query": {
    "match_all": {}
  }
}
'@

Write-Host "`n7. ✅ Delete index $NEW_INDEX"
Invoke-RestMethod -Method Delete -Uri "$($ES_URL)/$($NEW_INDEX)?pretty"
