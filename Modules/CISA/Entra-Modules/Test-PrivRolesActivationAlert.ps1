<#
Documentation: https://learn.microsoft.com/en-us/graph/api/policyroot-list-rolemanagementpolicyassignments
Least Privilege Delegated =  RoleManagementPolicy.Read.Directory
Least Privilege Application = RoleManagementPolicy.Read.Directory
#>
function Test-PrivRolesActivationAlert {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
 
  $cisaPrivilegedRoles = $cisa = Write-CISAHighlyPrivilegedRoles
  $cisaPrivilegedRoles.Remove('Global Administrator')

  $directoryRoles = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/roleManagementPolicyAssignments?`$filter=scopeId eq '/' and scopeType eq 'DirectoryRole'&`$expand=policy(`$expand=rules)").Value

  $privilegedRolesPolicies = $directoryRoles | Where-Object {$_.roleDefinitionId -in $cisaPrivilegedRoles.Values}
  
  $notifyPoliciesWithRecipients = $privilegedRolesPolicies | Where-Object {$_.policy.rules.id -eq "Notification_Admin_EndUser_Assignment" -and $_.policy.rules.notificationRecipients -ne $null}

# Set default to Fail

  $PassFail = "Fail"

  if ($notifyPoliciesWithRecipients.Count -lt $notifyPoliciesWithRecipients.Count) {
    $PassFail = "Fail"
  } elseif ($cisaPrivilegedRoles.Values.Count -eq $notifyPoliciesWithRecipients.Count) {
    $PassFail = "Pass"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    foreach ($_ in $notifyPoliciesWithRecipients) {
      $htmlConstruction += $loop = [ordered] @{
        'Role Guid'            = $_.roleDefinitionId
        'Scope'                = $_.scopeType
        'Scope ID'             = $_.scopeId
        'Is Approval Required' = $_.policy.rules[14].notificationRecipients
        }
      }
    } elseif ($PassFail -eq "Fail") {
      $htmlConstruction = @{
        'Title'       = "Privileged Roles Alert Settings"
        'Description' = "Alerting is not configured for the following roles: Privileged Role Administrator, User Administrator, SharePoint Administrator, Exchange Administrator, Hybrid Identity Administrator, Application Administrator, Cloud Application Administrator"
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Activation of Highly Privileged Roles via PIM Shall trigger an Alert." -Result "$PassFail" -Resolution "Set the activation of Highly Privileged roles in PIM to generate an alert." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-configure-security-alerts" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.7.7 - Activation of Highly Privileged Roles via PIM Shall trigger an Alert' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Privileged Roles Alert Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.7.7_PrivRolesActivationAlert.html"
}
