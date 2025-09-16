# ./Resolve-PowershellTask3A.ps1
# Task 3.A. Work with Parameters
# STEP 1: Create a script, ./Resolve-PowershellTask3A.ps1, which requires the following parameters:
# - ParameterWithoutType - can accept any type of value, may it be string, bool, array, or any other available type of data.
# - ParameterWithType - if provided, it represents a string.
# - RequiredParameter - the script can not run if this parameter is not provided.
# - MessageWithDefaultValue - if the user does not provide a value, it uses the default string 'I love DevOps!'
# - Message5to15 - if provided, the length of the string must be between 5 and 15 characters.
# - MessageWithSoD - if provided, the value must contain 'SoD' (case insensitive).
# - DateFrom - if provided, any date/time value, the dafault value is 7 days ago.
# - DateTo - any date but not older than DateFrom parameter
# - EndavaPurposeAndValues - a mandatory parameter which accepts only the following values: "Smart", "Thoughtful", "Open", "Adaptable", "Trusted".
# - OutputPath - if provided, it represents the path to an existing folder. Note - the folder must exists. Hint: use a validation script for that.
# - MessageFromPipeline - this parameter may be provided through pipeline by it's name.
[CmdletBinding()]
param(

    $ParameterWithoutType,

    [Parameter()]
    [string] $ParameterWithType,

    [Parameter(Mandatory = $true)]
    [object] $RequiredParameter,


    [Parameter(Mandatory = $false)]
    [string] $MessageWithDefaultValue = "I love DevOps!",

    [Parameter()]
    [ValidateLength(5, 15)] $Message5to15,

    [Parameter()]
    [ValidatePattern(".*SoD.*", Options="IgnoreCase")] $MessageWithSoD,

    [Parameter()]
    [datetime] $DateFrom = (Get-Date).AddDays(-7),

    # If you use ValidateScript, you can't pass a $null value to the parameter.

    # [Parameter())]
    # [ValidateScript(
    #     {$_ -ge (Get-Date)},
    #     ErrorMessage = "{0} isn't a future date. Specify a later date."
    # )]
    # [datetime]$EventDate

    [Parameter()]
    [ValidateScript({
        if ($_ -lt $DateFrom) {
            throw "DateTo ($_) must not be earlier than DateFrom ($DateFrom)."
        }
        return $true
    })]
    [datetime] $DateTo,

    [Parameter(Mandatory = $true)]
    [ValidateSet ("Smart", "Thoughtful", "Open", "Adaptable", "Trusted")]
    [string] $EndavaPurposeAndValues,

    # [Parameter()]
    # [ValidateNotNullOrWhiteSpace()]
    # [string[]]$UserName

#     param(
#     [ValidateDrive("C", "D", "Variable", "Function")]
#     [string]$Path
#    )

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        if (-not (Test-Path -Path $_ -PathType Container)) {
            throw "OutputPath ($_) must be an existing folder."
        }
        return $true
    })]
    [string] $OutputPath,

    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string] $MessageFromPipeline

)

Write-Host "###Parameter Values Passed to Script ###"
Write-Host "ParameterWithoutType   : $ParameterWithoutType"
Write-Host "ParameterWithType      : $ParameterWithType"
Write-Host "RequiredParameter      : $RequiredParameter"
Write-Host "Your message is `"$MessageWithDefaultValue`". Cheers!"
Write-Host "Message5to15           : $Message5to15"
Write-Host "DateFrom               : $DateFrom"
Write-Host "DateTo                 : $DateTo"
Write-Host "EndavaPurposeAndValues : $EndavaPurposeAndValues"
Write-Host "OutputPath             : $OutputPath"
Write-Host "MessageFromPipeline    : $MessageFromPipeline"


