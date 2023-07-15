# AzureIPRangeFetcher
This PowerShell script retrieves, parses, and writes the Azure IP address ranges to local files.

The default directory is './AzureIPRanges' but this can be customized by passing a different directory path as the $Path argument when running the script.

**Please note: Error handling is incorporated throughout the script to manage potential issues such as failed web requests or unexpected data structures in the retrieved JSON.**

Usage
The script can be run as follows:

```powershell
.\script.ps1 -Path 'path/to/directory'
```
If the -Path argument is omitted, the script will use './AzureIPRanges' as the default directory.

## Prerequisites
The script requires PowerShell to be installed and running on your machine. It doesn't require any additional modules to be installed.

## Limitations
The script assumes the structure of the Azure IP ranges JSON file and the URL to download it will not change. If they do, the script might not work as expected.
The script overwrites files if they already exist in the specified directory and have the same name as the new files being created.
The script does not manage permissions, so you'll need to ensure you have the necessary permissions to create and write to the directory you specify.
