param(
    [Parameter(Mandatory=$true)]
    [string]$InstanceId,

    [Parameter(Mandatory=$false)]
    [string]$LogPath = ".\mockIISLog.txt"
)

Write-Host "Instance ID: $InstanceId"
Write-Host "Log Path: $LogPath"

if
([string]::IsNullOrWhiteSpace($InstanceId)) {
    throw "InstanceId is required."
}

if (-not (Test-Path $LogPath)) {
    throw "Log file not found at path: $LogPath"
}

