# IIS Log Diagnostics Toolkit
 
A small PowerShell utility for summarising IIS web traffic errors during initial infrastructure diagnostics.
 
## Purpose
 
This script accepts an EC2 instance ID, simulates checking the instance state, simulates retrieving a zipped IIS log file from an S3 bucket, and reports HTTP 500 errors from the logs.

## Edge Cases and Known Limitations

This is a lightweight diagnostic script intended for an initial support investigation. It intentionally focuses on clarity and resilience over full production completeness.

Current limitations:

- It does not call real AWS APIs.
- EC2 instance state lookup is mocked.
- S3 log retrieval is mocked.
- It does not actually download, unzip, or clean up log archives.
- It processes one local IIS log file at a time.
- It assumes the IIS log contains a valid `#Fields:` header and doesn not dynamically adapt to missing or non-standard schemas.
- It skips malformed log lines rather than attempting to repair or reconstruct them.
- It does not handle multi-line corrupted log entries.
- It does not correlate CPU spike timestamps with log timestamps.
- It does not support CloudWatch Logs.
- It does not include automated Pester tests.
- It does not produce machine-readable JSON/CSV output.

## Possible Future Improvements
 
- Replace mocked AWS steps with AWS Tools for PowerShell or AWS CLI calls.
- Download and extract zipped IIS logs from S3.
- Support multiple log files.
- Add filtering by time range.
- Add grouping by endpoint, client IP, and user agent to identify error patterns and potential sources of failures.
- Add JSON/CSV output for automation pipelines.
- Add Pester tests for parsing and error handling.
- Correlate CloudWatch CPU metrics with IIS error timestamps
 
## How to run
 
```powershell
.\Get-IisDiagnostics.ps1 -InstanceId "i-0123456789abcdef0" -LogPath ".\mockIISLog.txt"