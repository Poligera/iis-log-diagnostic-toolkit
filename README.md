# IIS Log Diagnostics Toolkit
 
A small PowerShell utility for summarising IIS web traffic errors during initial infrastructure diagnostics.
 
## Purpose
 
This script accepts an EC2 instance ID, simulates checking the instance state, simulates retrieving a zipped IIS log file from an S3 bucket, and reports HTTP 500 errors from the log. Mocked AWS interactions are intentional to keep the tool self-contained and safe to run without credentials.

## Edge Cases and Known Limitations

This is a lightweight diagnostic script intended for an initial support investigation. It intentionally focuses on clarity and resilience over full production completeness.

Current limitations:

- It does not call real AWS APIs.
- EC2 instance state lookup is mocked.
- S3 log retrieval is mocked.
- It does not actually download, unzip, or clean up log archives.
- It processes one local IIS log file at a time.
- It requires a valid `#Fields:` header and fails fast if required fields are missing.
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
```

## Example Output

```text
Loaded 14 lines from log file.
Retrieving IIS log from S3 for instance i-0d79fe9169fb369f9...

===== IIS Diagnostic Summary =====
Instance ID: i-0d79fe9169fb369f9
Instance State: running
Total HTTP 500 Errors: 3

HTTP 500 Error Timestamps:
- 2026-02-20 04:08:15 [GET] /api/v1/users/list
- 2026-02-20 04:11:45 [GET] /api/v1/reports/generate
- 2026-02-20 04:12:33 [POST] /api/v1/data/sync

WARNING: 2 malformed log line(s) were skipped.
```