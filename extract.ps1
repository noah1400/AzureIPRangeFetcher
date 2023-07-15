param (
    [string]$Path = '.\'
)

$directoryName = 'AzureIPRanges'

# Ensure trailing slash in Path
$Path = [IO.Path]::Combine($Path, $directoryName)

# Check if the path exists, if not, create it
if (!(Test-Path -Path $Path)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

# URL to json download page
$url = 'https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519'

# Get the page and parse for JSON url
try {
    $pageContent = Invoke-WebRequest -Uri $url
}
catch {
    Write-Error "Error while fetching the page: $_"
    exit 1
}

# Find the JSON url using regex
if ($pageContent.Content -match 'data-bi-id="downloadretry" href="(?<url>.*\.json?)"') {
    $jsonUrl = $matches['url']
}
else {
    Write-Error "Could not find JSON url"
    exit 1
}

$console = [System.Console]::Out
$bufferWidth = [System.Console]::BufferWidth
$bufferWidth = if ($bufferWidth -le 0 -or $bufferWidth -gt 80) { 80 } else { $bufferWidth }

# Download the JSON file
try {
    $jsonContent = Invoke-RestMethod -Uri $jsonUrl
}
catch {
    Write-Error "Error while fetching the JSON file: $_"
    exit 1
}

# Check if "values" array exists
if ($jsonContent.values) {
    $totalFiles = $jsonContent.values.length
    $currentCount = 0

    foreach ($item in $jsonContent.values) {
        $progressMessage = "( $currentCount / $totalFiles )"
        $processMessage = "Processing $($item.name)"

        # Calculate the spaces needed
        $spacesCount = $bufferWidth - $progressMessage.Length - $processMessage.Length - 1
        $spaces = " " * $spacesCount

        # Create the message
        $message = "$processMessage$spaces$progressMessage"
        
        [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop)
        $console.Write($message)

        if ($item.properties.addressPrefixes) {
            $fileName = "$($item.name).txt"

            $ipList = New-Object System.Collections.Generic.List[System.Object]

            foreach ($ip in $item.properties.addressPrefixes) {
                $ipList.Add($ip)
            }

            # Check if the file exists, if so, remove it
            $fileFullPath = Join-Path -Path $Path -ChildPath $fileName
            if (Test-Path $fileFullPath) {
                Remove-Item $fileFullPath
            }

            $ipList | Out-File -FilePath $fileFullPath
            $currentCount++
        }
    }
    $console.Write([Environment]::NewLine)
}
else {
    Write-Error "Could not find 'values' array"
    exit 1
}
