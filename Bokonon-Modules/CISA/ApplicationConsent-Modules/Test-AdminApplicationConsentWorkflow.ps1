<#
Documentation: https://learn.microsoft.com/en-us/graph/api/adminconsentrequestpolicy-get
Least Privilege Delegated   = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-AdminApplicationConsentWorkflow {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $tenantAuthorizationPolicies = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy"

# Verify policy to our liking

# Set default to Fail
  $PassFail = "Fail"

  $userApplicationRegistration = $tenantAuthorizationPolicies.defaultUserRolePermissions.allowedToCreateApps

  if ($tenantAuthorizationPolicies.isEnabled -eq $true -and $tenantAuthorizationPolicies.notifyReviewers -eq $true -and $tenantAuthorizationPolicies.reviewers.Count -ge "1") {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Administrator Application Consent Workflow Shall be enabled and configured." -Result "$PassFail" -Resolution "Enabled Admin Consent Workflow, there are administrators configured to review consent request, and that those administrators receive a notification when consent is requested." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/user-admin-consent-overview" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  $htmlConstruction = [ordered] @{
    'Is Admin Consent Enabled' = $tenantAuthorizationPolicies.isEnabled
    'Are Reviewers Notified'   = $tenantAuthorizationPolicies.notifyReviewers
    'Reviewers'                = ($tenantAuthorizationPolicies.reviewers.query) -replace "/v1.0/users/", "" -join ", "
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.5.3 - Verify that Admin Applications Workflow is enabled & configured' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Admin Applications Consent Workflow Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\AdminApplicationConsentWorkflow.html"
}
