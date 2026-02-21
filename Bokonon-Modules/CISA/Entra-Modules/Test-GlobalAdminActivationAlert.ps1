<#
Documentation: https://learn.microsoft.com/en-us/graph/api/policyroot-list-rolemanagementpolicyassignments
Least Privilege Delegated = RoleManagementPolicy.Read.Directory
Least Privilege Application = RoleManagementPolicy.Read.Directory
#>
function Test-GlobalAdminActivationAlert {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
 
  $cisaPrivilegedRoles = $cisa = Write-CISAHighlyPrivilegedRoles
  $cisaPrivilegedRoles.Remove('Global Administrator')

  $globalAdminRolePolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/roleManagementPolicyAssignments?`$filter=scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '62e90394-69f5-4237-9190-012177145e10'&`$expand=policy(`$expand=rules)").Value

# Set default to Fail

  $PassFail = "Fail"

  if (($globalAdminRolePolicies | Where-Object {$_.policy.rules.id -eq "Notification_Admin_EndUser_Assignment" -and $_.policy.rules.notificationRecipients -ne $null}) -eq $null) {
    $PassFail = "Fail"
  } else {
    $PassFail = "Pass"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
      $htmlConstruction = [ordered] @{
        'Role Name'                    = "Global Administrator"
        'Role Guid'                    = $globalAdminRolePolicies.roleDefinitionId
        'Scope'                        = $globalAdminRolePolicies.scopeType
        'Scope ID'                     = $globalAdminRolePolicies.scopeId
        'Admins that receive an alert' = $globalAdminRolePolicies.policy.rules[14].notificationRecipients
        }
    } elseif ($PassFail -eq "Fail") {
      $htmlConstruction = @{
        'Title'       = "Global Administrator Activation Alert Settings"
        'Description' = "Alerting is not configured for the Global Administrator Role"
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Activation of Global Admin Role via PIM Shall trigger an Alert." -Result "$PassFail" -Resolution "Set the activation of Global Admin Role in PIM to generate an alert." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.7.8 - Activation of Global Admin Role via PIM Shall trigger an Alert' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global Admin Role Alert Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\GlobalAdminActivationAlert.html"
}
