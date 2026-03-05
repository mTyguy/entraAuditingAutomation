<#
Documentation: https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/authenticated-client-smtp-submission
	https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-transportconfig
#>
function Test-SmtpDisabled {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $exchangeSmtpAuthDisabled = (Get-TransportConfig).SmtpClientAuthenticationDisabled

### Html Construction ###
 $PassFail = "Fail"

  if ($exchangeSmtpAuthDisabled -eq $true) {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

# Environment Data Array
  $htmlConstruction = @()

  $htmlConstruction = [ordered] @{
      'SMTP Auth is Disabled' = $exchangeSmtpAuthDisabled
      'Description'           = "SMTP Auth Settings"
    }

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "SMTP Auth Shall be Disabled." -Result "$PassFail" -Resolution "Review SMTP Authentication Settings." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/authenticated-client-smtp-submission" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.EXCHANGE.5.1 - SMTP Auth Shall be Disabled' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'SMTP Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.EXCHANGE.5.1_SmtpDisabled.html"
}
