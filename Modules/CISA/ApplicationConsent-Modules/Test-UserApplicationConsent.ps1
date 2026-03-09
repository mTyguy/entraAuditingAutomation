<#
Documentation: https://learn.microsoft.com/en-us/graph/api/authorizationpolicy-get
Least Privilege Delegated    = Policy.Read.All
Least Privileges Application = Policy.Read.All
#>
function Test-UserApplicationConsent {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $tenantAuthorizationPolicies = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy"

# Verify policy to our liking

# Set default to Fail
  $PassFail = "Fail"

  $userConsentSettings = @()

  foreach ($_ in $tenantAuthorizationPolicies.defaultUserRolePermissions.permissionGrantPoliciesAssigned) {
    if ($_ -match "ManagePermissionGrantsForSelf") {
      $userConsentSettings += $resultArray = [ordered] @{
        'Consent Settings' = $_
      }
    }
  }

  if ($userConsentSettings.count -eq "0") {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Only Administrators Shall be able to consent to Applications" -Result "$PassFail" -Resolution "Do not allow user consent within User Consent Settings." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/user-admin-consent-overview" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  if ($userConsentSettings.count -ne "0") {
    $htmlConstruction = [ordered] @{
      'Consent Settings'  = [string]$userConsentSettings[0].values
      'Microsoft Managed' = [string]$userConsentSettings[1].values
    } 
  } elseif ($userConsentSettings.count -eq "0") {
      $htmlConstruction = [ordered] @{
        'Description'      = "Tenant User Application Consent Settings"
        'Consent Settings' = "Do not allow user consent"
    }
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.5.2 - Verifying that Users cannot give consent to Applications' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'User Application Consent Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.5.2_UserApplicationConsent.html"
}
