<#
Documentation: https://learn.microsoft.com/en-us/graph/api/rbacapplication-list-roleassignments
Least Privilege Delegated = RoleManagement.Read.Directory
Least Privilege Application = RoleManagement.Read.Directory
#>
function Test-GlobalAdminApprovalRequired {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
    
  $globalAdminActivationSettings = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/roleManagementPolicyAssignments?`$filter=scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '62e90394-69f5-4237-9190-012177145e10'&`$expand=policy(`$expand=rules)").Value

  $userRoleAssignmentsArray = @()

  $globalAdminApprovalArray = $globalAdminActivationSettings | Where-Object { $_.policy.rules.'@odata.type' -eq '#microsoft.graph.unifiedRoleManagementPolicyApprovalRule'}

# Set default to Fail

  $PassFail = "Fail"

  if ($globalAdminApprovalArray.policy.rules.setting.isApprovalRequired -eq $true) {
    $PassFail = "Pass"
  } elseif ($globalAdminApprovalArray.policy.rules.setting.isApprovalRequired -eq $false) {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  $htmlConstruction = [ordered] @{
    'Role Name'            = "Global Administrator"
    'Role Guid'            = $globalAdminApprovalArray.roleDefinitionId
    'Scope'                = $globalAdminApprovalArray.scopeType
    'Scope ID'             = $globalAdminApprovalArray.scopeId
    'Is Approval Required' = $globalAdminApprovalArray.policy.rules.setting.isApprovalRequired
    'Is Requester Justification Required' = $globalAdminApprovalArray.policy.rules.setting.isRequestorJustificationRequired
  }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Activation of Global Administrator Rule Shall require Approval." -Result "$PassFail" -Resolution "Set the activation of Global Administrator role in PIM to require approval." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-configure-security-alerts" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.7.6 - Activation of Global Administrator Rule Shall require Approval' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'PIM Global Administrator Approval Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\GlobalAdminApprovalRequired.html"
}
