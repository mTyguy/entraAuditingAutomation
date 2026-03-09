<#
Documentation: https://learn.microsoft.com/en-us/graph/api/rbacapplication-list-roleassignmentschedules
Least Privilege Delegated = RoleAssignmentSchedule.Read.Directory
Least Privilege Application = RoleAssignmentSchedule.Read.Directory
#>
function Test-PermActivePrivRoles {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
    
  $roleAssignments = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignmentSchedules/").Value

  $privilegedRoles = Write-CISAHighlyPrivilegedRoles

  $userRoleAssignmentsArray = @()

  foreach ($_ in $roleAssignments) {
    if ($privilegedRoles.Values -contains $_.roleDefinitionId) {
      $userRoleAssignmentsArray += $loopresults = [ordered] @{
        'Display Name'          = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$($_.principalId)").DisplayName
        'User Principal Name'   = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$($_.principalId)").UserPrincipalName
        'User Guid'             = $_.principalId
        'Role Guid'             = $_.roleDefinitionId
	'Role Display Name'     = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions/$($_.roleDefinitionId)").displayName
	'Role Expiration'       = $_.scheduleInfo.expiration.type
      }
    }
  }

# Set default to Fail

  $PassFail = "Fail"

  $permAssignedUsers = @()

  foreach ($_ in $userRoleAssignmentsArray) {
    if ($_.'Role Expiration' -eq "noExpiration") {
      $permAssignedUsers += $loop = $_
      $PassFail = "Fail"
    } else {
      $PassFail = "Pass"
    }
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = $permAssignedUsers

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Permanently Active roles Shall not be assigned for privileged roles." -Result "$PassFail" -Resolution "Utilize PIM or some other method for assigning privileged roles." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.7.4 - Permanently Active roles Shall not be assigned for privileged roles' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Accounts with Permanently Active Privileged Roles' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.7.4_PermActivePrivRoles.html"
}
