param(
    [Parameter(Mandatory = $true)]
    [string] $InputPath,

    [Parameter(Mandatory = $true)]
    [string] $OutputDirectory
)

$documents = Get-Content -Raw -Path $InputPath | ConvertFrom-Json

$departments = @("Marketing","Development","Accounting","Research")

# Ensure output directory exists
if (-not (Test-Path -Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
}

foreach($dept in $departments){
    $filtered = $documents | Where-Object {
    $_.isActive -eq $true -and $_.department -eq $dept
}

   $output = $filtered | ForEach-Object{

    #split name
    $firstName,$lastName = $_.name -split ' ',2

    $tagsString = ($_.tags -join ",")

    [PSCustomObject]@{
        id = $_._id
        firstName = $firstName
        lastname = $lastName
        department = $_.department
        tags = $tagsString
    }
   }

  $csvPath = Join-Path $OutputDirectory "$dept.csv"
  $output | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
  Write-Host "Exported $dept records to $csvPath"
}


# ((Get-Content -Path $pathToJsonFile) | ConvertFrom-Json).results |
#   Export-CSV $pathToOutputFile -NoTypeInformation