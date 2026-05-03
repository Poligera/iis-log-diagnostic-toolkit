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