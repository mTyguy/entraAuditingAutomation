<#
Documentation: https://learn.microsoft.com/en-us/graph/api/domain-get?view=graph-rest-1.0
	https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-dkimsigningconfig
#>
function Test-DKIMCheck {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $entraDomains = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/domains").Value

  $exchangeDkimLookups = @()
  foreach ($_ in $entraDomains) {
    $exchangeDkimLookups += $domainsLoop = Get-DkimSigningConfig -Identity $_.id
  }

  $exchangeDkimRecords = @()
  foreach ($_ in $exchangeDkimLookups) {
    $exchangeDkimRecords += $CnameLoop = $exchangeDkimLookups | Where-Object {$_.Enabled -eq $true -and $_.Status -eq "Valid"}
  }

### Html Construction ###
 $PassFail = "Fail"

  if ($entraDomains.Count -eq $exchangeDkimRecords.Count) {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $exchangeDkimRecords) {
    $htmlConstruction += $resultArray = [ordered] @{
      'Domain Name' = $_.Domain
      'Enabled'     = $_.Enabled
      'Status'      = $_.Status
      'Selector 1'  = $_.Selector1CNAME
      'Selector 2'  = $_.Selector2CNAME
      }
    }

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "A DKIM Policy Shall be published for each domain." -Result "$PassFail" -Resolution "Review DKIM settings and records for each owned domain." -Controls "Use these technologies to remediate" -Citations "learn.microsoft.com/en-us/defender-office-365/email-authentication-dkim-configure" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.EXCHANGE.3.1 - A DKIM Policy Shall be published for each domain' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'DKIM Domains Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\DKIMCheck.html"
}
