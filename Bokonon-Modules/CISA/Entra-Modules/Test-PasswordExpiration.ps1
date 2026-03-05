<#
Documentation: https://learn.microsoft.com/en-us/graph/api/domain-get
Least Privilege Delegated = Domain.Read.All
Least Privilege Application = Domain.Read.All
#>
function Test-PasswordExpiration {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $tenants = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/domains").Value

  foreach ($_ in $tenants.id) {
    $passwordValidityPeriodInDays = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/domains/$_").passwordValidityPeriodInDays
  }

# Set default to Fail
  $PassFail = "Fail"

  if ($passwordValidityPeriodInDays -ge "3500") {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail


### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Password Shall not expire." -Result "$PassFail" -Resolution "Set user password to never expire." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/microsoft-365/admin/manage/set-password-expiration-policy?view=o365-worldwide" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  $htmlConstruction = [ordered] @{
    'Tenant ID'                  = $tenants.id
    'Tenant Authentication Type' = $tenants.authenticationType
    'Is Default'                 = $tenants.isDefault
    'Passwords Expire in X Days' = $passwordValidityPeriodInDays
  }

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.6.1 - Password Shall not expire' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Password Policy' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.6.1_PasswordExpiration.html"
}
