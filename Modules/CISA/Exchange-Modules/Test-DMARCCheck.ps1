<#
Documentation: https://learn.microsoft.com/en-us/graph/api/domain-get?view=graph-rest-1.0
	https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-dkimsigningconfig
#>
function Test-DMARCCheck {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $entraDomains = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/domains").Value

  $exchangeDmarcLookups = @()
  foreach ($_ in $entraDomains) {
    $exchangeDmarcLookups += $domainsLoop = (Resolve-Dns _dmarc.$_.com txt).AllRecords
  }

  $exchangeDmarcRecords = @()
  foreach ($_ in $exchangeDmarcLookups) {
    $exchangeDmarcRecords += $CnameLoop = $exchangeDmarcLookups | Where-Object {$_.EscapatedText -match "v=DMARC"}
  }

### Html Construction ###
 $PassFail = "Fail"

  if ($entraDomains.Count -eq $exchangeDmarcRecords.Count) {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

# Environment Data Array
  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    foreach ($_ in $exchangeDmarcRecords) {
      $htmlConstruction += $resultArray = [ordered] @{
        'Domain Name' = $_.Domain
        'Enabled'     = $_.Enabled
        'Status'      = $_.Status
        }
      }
    } elseif ($PassFail -eq "Fail" -and $exchangeDmarcRecords.Count -ge "1") {
        foreach ($_ in $exchangeDmarcRecords) {
          $htmlConstruction += $resultArray = [ordered] @{
            'Domain Name' = $_.Domain
            'Enabled'     = $_.EscapedText -replace "; ", " "
            'Status'      = $_.Status
          }
        }
      } elseif ($PassFail -eq "Fail" -and $exchangeDmarcRecords.Count -eq "0") {
        $htmlConstruction += $resultArray = [ordered] @{
            'Domains' = ($entraDomains.id) -join ", "
            'Result'  = "Could not verify DMARC records for these domains"
          }
      }

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "A DMARC Record Shall be published for each domain." -Result "$PassFail" -Resolution "Review DMARC settings and records for each owned domain." -Controls "Use these technologies to remediate" -Citations "learn.microsoft.com/en-us/defender-office-365/email-authentication-dkim-configure" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.EXCHANGE.4.1 - A DMARC Policy Shall be published for each domain' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'DMARC Domains Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.EXCHANGE.4.1_DMARCCheck.html"
}
