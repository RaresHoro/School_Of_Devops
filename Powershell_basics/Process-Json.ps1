param(
    [Parameter(Mandatory = $true)]
    [string] $InputPath,

    [Parameter(Mandatory = $true)]
    [string] $OutputPath
)

# Read JSON file into objects
$documents = Get-Content -Raw -Path $InputPath | ConvertFrom-Json

# Define allowed tags
$allowedTags = @("labore", "ipsum", "ullamco")

# Filter docs
$filtered = $documents | Where-Object {
    $_.isActive -eq $true -and ($_.tags | Where-Object { $allowedTags -contains $_ })
}

# Export back to JSON
$filtered | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath

Write-Host "Filtered JSON written to $OutputPath"