<#
Documentation: https://learn.microsoft.com/en-us/graph/api/authorizationpolicy-get
Least Privilege Delegated   = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-UserApplicationRegistration {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $tenantAuthorizationPolicies = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy"

# Verify policy to our liking

# Set default to Fail
  $PassFail = "Fail"

  $userApplicationRegistration = $tenantAuthorizationPolicies.defaultUserRolePermissions.allowedToCreateApps

  if ($tenantAuthorizationPolicies.defaultUserRolePermissions.allowedToCreateApps -eq $false) {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Only Administrators Shall be allowed to register applications." -Result "$PassFail" -Resolution "Verifying that users cannot register applications." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/delegate-app-roles" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  $htmlConstruction = [ordered] @{
    'Description'                    = "Boolean value regarding user application registration"
    'User can Register Applications' = $tenantAuthorizationPolicies.defaultUserRolePermissions.allowedToCreateApps
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.5.1 - Verifying that Users cannot Register Applications' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'User Application Registration Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\UserApplicationRegistration.html"
}
