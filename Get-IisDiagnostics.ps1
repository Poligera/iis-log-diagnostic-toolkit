param(
    [Parameter(Mandatory=$true)]
    [string]$InstanceId,

    [Parameter(Mandatory=$false)]
    [string]$LogPath = ".\mockIISLog.txt"
)

function Get-MockInstanceState {
    param([string]$InstanceId)
    return "running"
}

function Invoke-MockLogDownload {
    param([string]$InstanceId)
    return "Retrieving IIS log from S3 for instance $InstanceId..."
}

try {
    # Ensure non-terminating errors are catchable by the top-level try/catch
    $ErrorActionPreference = 'Stop'

    # Use the Information stream so messages show without polluting pipeline output
    $InformationPreference = 'Continue'

    if ([string]::IsNullOrWhiteSpace($InstanceId)) {
        throw "InstanceId is required."
    }

    if (-not (Test-Path $LogPath)) {
        throw "Log file not found at path: $LogPath"
    }

    # Load IIS log
    $lines = Get-Content $LogPath
    Write-Information "Loaded $($lines.Count) lines from log file."

    $fieldLine = $lines | Where-Object { $_ -like "#Fields:*" } | Select-Object -First 1
    if (-not $fieldLine) {
        throw "Could not find IIS #Fields header in log file."
    }

    # Field positions are determined dynamically to avoid hard-coded assumptions
    $fields = ($fieldLine -replace "#Fields:\s*", "") -split "\s+"

    $statusIndex = $fields.IndexOf("sc-status")
    if ($statusIndex -lt 0) {
        throw "Could not find 'sc-status' field in IIS log header."
    }

    $methodIndex = $fields.IndexOf("cs-method")
    if ($methodIndex -lt 0) {
        throw "Could not find 'cs-method' field in IIS log header."
    }

    $pathIndex = $fields.IndexOf("cs-uri-stem")
    if ($pathIndex -lt 0) {
        throw "Could not find 'cs-uri-stem' field in IIS log header."
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
            $serverErrors += [PSCustomObject]@{
                Timestamp = "$($parts[0]) $($parts[1])"
                StatusCode = "500"
                Method = $parts[$methodIndex]
                Path = $parts[$pathIndex]
            }
        }
    }

    $instanceState = Get-MockInstanceState -InstanceId $InstanceId

    Write-Information (Invoke-MockLogDownload -InstanceId $InstanceId)
    Write-Information ""
    Write-Information "===== IIS Diagnostic Summary ====="
    Write-Information "Instance ID: $InstanceId"
    Write-Information "Instance State: $instanceState"
    Write-Information "Total HTTP 500 Errors: $($serverErrors.Count)"
    Write-Information ""
    
    if ($serverErrors.Count) {
        Write-Information "HTTP 500 Error Timestamps:"
        foreach ($error in $serverErrors) {
            Write-Information "- $($error.Timestamp) [$($error.Method)] $($error.Path)"
        }
    }
    else {
        Write-Information "No HTTP 500 errors found."
    }
    
    if ($malformedLines.Count) {
        Write-Information ""
        Write-Warning "$($malformedLines.Count) malformed log line(s) were skipped."
    }
}
catch {
    Write-Error "IIS diagnostic failed: $($_.Exception.Message)"
    throw
}
