<#
Documentation: https://learn.microsoft.com/en-us/graph/api/domain-get?view=graph-rest-1.0
#>
function Test-SPFCheck {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $entraDomains = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/domains").Value

  $exchangeSPFLookups = @()
  foreach ($_ in $entraDomains) {
    $exchangeSPFLookups += $domainsLoop = Resolve-Dns $_.id txt
  }

  $exchangeTXTRecords = @()
  foreach ($_ in $exchangeSPFLookups) {
    $exchangeTXTRecords += $txtLoop = $_.AllRecords | Where-Object {$_.RecordType -eq "TXT"}
  }

### Html Construction ###
 $PassFail = "Fail"

  if ($entraDomains.Count -eq $exchangeTXTRecords.Count) {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $txtLoop) {
    $htmlConstruction += $resultArray = [ordered] @{
      'Record Type' = $_.RecordType
      'Domain Name' = $_.DomainName
      'SPF Record'  = ($_.Text) -join ""
      }
    }

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "An SPF Policy Shall be published for each domain." -Result "$PassFail" -Resolution "Review SPF settings and records for each owned domain." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/defender-office-365/email-authentication-spf-configure" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.EXCHANGE.2.2 - An SPF Policy Shall be published for each domain' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'SPF Domains Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\SPFCheck.html"
}
