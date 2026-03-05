<#
Documentation: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-remotedomain
#>
function Test-AutoForwardingExternal {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $exchangeRemoteDomainsPolicies = Get-RemoteDomain

### Html Construction ###
 $PassFail = "Fail"

  $defaultRemoteDomainForwarding = $exchangeRemoteDomainsPolicies | Where-Object {$_.Identity -eq "Default" -and $_.AutoForwardEnabled -eq $false}

  if ($defaultRemoteDomainForwarding.Count -eq 1) {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $exchangeRemoteDomainsPolicies) {
    $htmlConstruction += $resultArray = [ordered] @{
      'Display Name'                   = $_.Identity
      'Is External Forwarding Allowed' = $_.AutoForwardEnabled
      }
    }

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Automatic forwarding to External Domains Shall be Disabled." -Result "$PassFail" -Resolution "Review Remote Domains settings in Exchange Online." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/defender-office-365/outbound-spam-policies-external-email-forwarding" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.EXCHANGE.1.1 - Automatic forwarding to External Domains Shall be Disabled' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Remote Domains Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.EXCHANGE.1.1_AutoForwardingExternal.html"
}
