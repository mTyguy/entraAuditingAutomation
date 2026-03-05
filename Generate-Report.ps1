#to do:
#accept multiple tags, right now you can only exclude or include a single tag
#more preflight checks
<#
Version 0.0.1
.SYNOPSIS
Main command that will Invoke-Pester with parameters and generate report

.DESCRIPTION
Be sure to login to Mg-Graph module before running ./Generate-Report.ps1
#>

########################
# Create script Params #
param(
  [string[]]$Tags,
  [string[]]$SkipTags
)

#################
#PreFlight Checks
# Check for Pester Version 5 or greater
# https://pester.dev/docs/introduction/installation
if ((Get-InstalledModule -Name Pester).Version -lt 5) {
  Write-Host "Pester Version 5 or greater is not installed, exiting"
  Write-Host "https://pester.dev/docs/introduction/installation"
  exit
  }

# Check if Mg-Graph module is installed
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation
if (-not (Get-InstalledModule -Name Microsoft.Graph)) {
  Write-Host "Microsoft Graph PowerShell SDK is not installed, exiting"
  Write-Host "https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation"
  exit
  }

##################
# Import Modules #
$modulePath = ".\Bokonon-Modules\Bokonon-Modules.psm1"
Import-Module -Name $modulePath -Force

################
# Start Script

### Logic to create new folder to hold our reports ###
# Get date time
$timestamp = Get-Date -Format "yyyy-MM-dd--HH-mm-ss"
# Create folder
New-Item -Path ".\Reports\$timestamp" -ItemType Directory | Out-Null
# Create HTML folder path
New-Item -Path ".\Reports\$timestamp\HtmlReports" -ItemType Directory | Out-Null

# Report folder path
$reportPath = ".\Reports\$timestamp\"


# Invoke Pester #
$pesterOutput = Invoke-Pester -PassThru -TagFilter $Tags -ExcludeTagFilter $SkipTags

$pesterOutput | ConvertTo-Json -Depth 3 -WarningAction SilentlyContinue | Out-File -FilePath "$($reportPath)auditReport.json"


# Merge into 1 html report #
Write-Host "Merging Reports..." -ForegroundColor DarkCyan

$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

$filesDir = ".\Reports\$CurrentReportFolderName\HtmlReports"
$outputFile = ".\Reports\$CurrentReportFolderName\mergedReport.html"

$htmlFiles = Get-ChildItem -Path $filesDir -Filter *.html | Sort-Object Name

foreach ($file in $htmlFiles) {
    # You may need to remove the <html>, <head>, and <body> tags from the individual 
    # files to form a valid single HTML document, depending on how they were generated.
    $content = Get-Content -Path $file.FullName -Raw
    $combinedHtml += $content
}

$combinedHtml | Out-File -FilePath $outputFile -Encoding UTF8

# Complete #
Write-Host "Done!" -ForegroundColor DarkCyan
