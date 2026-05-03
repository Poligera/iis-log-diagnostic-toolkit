param(
    [Parameter(Mandatory=$true)]
    [string]$InstanceId,

    [Parameter(Mandatory=$false)]
    [string]$LogPath = ".\mockIISLog.txt"
)

Write-Host "Instance ID: $InstanceId"
Write-Host "Log Path: $LogPath"