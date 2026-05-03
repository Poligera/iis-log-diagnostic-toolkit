param(
    [Parameter(Mandatory=$true)]
    [string]$InstanceId,

    [Parameter(Mandatory=$false)]
    [string]$LogPath = ".\mockIISLog.txt"
)

function Get-MockInstanceState {
    param(
        [string]$InstanceId
    )

    return "running"
}

function Invoke-MockLogDownload {
    param(
        [string]$InstanceId
    )

    Write-Host "Simuating IIS log retrieval from S3 for instance: $InstanceId..."
}

Write-Host "Instance ID: $InstanceId"
Write-Host "Log Path: $LogPath"

if
([string]::IsNullOrWhiteSpace($InstanceId)) {
    throw "InstanceId is required."
}

if (-not (Test-Path $LogPath)) {
    throw "Log file not found at path: $LogPath"
}

$lines = Get-Content $LogPath
Write-Host "Loaded $($lines.Count) lines from log file."

$fieldLine = $lines | Where-Object { $_ -like "#Fields:*" } | Select-Object -First 1
if (-not $fieldLine) {
    throw "Could not find IIS #Fields header in log file."
}

$fields = ($fieldLine -replace "#Fields:\s*", "") -split "\s+"

$statusIndex = $fields.IndexOf("sc-status")
if ($statusIndex -lt 0) {
    throw "Could not find 'sc-status' field in IIS log header."
}

$serverErrors = @()
$malformedLines = @()

foreach ($line in $lines) {
    if ($line -like "#*" -or [string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    $parts = $line -split "\s+"
    if ($parts.Count -ne $fields.Count) {
        $malformedLines += $line
        continue
    }

    $statusCode = $parts[$statusIndex]
    if ($statusCode -eq "500") {
        $serverErrors += @{
            Timestamp = $parts[0] + " " + $parts[1]
            StatusCode = $statusCode
            Method = $parts[fields.IndexOf("cs-method")]
            Path = $parts[fields.IndexOf("cs-uri-stem")]
        }
    }
}
