<#
Documentation: https://learn.microsoft.com/en-us/graph/api/rbacapplication-list-roleassignments
Least Privilege Delegated = RoleManagement.Read.Directory
Least Privilege Application = RoleManagement.Read.Directory
#>
function Test-CloudOnlyAdmins {
  [Cmdletbinding()]
  Param(
  )

# Grab required data from environment
    
  $userRoleLookup = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$expand=principal").Value

  $userRoleArray = @()

  foreach ($_ in $userRoleLookup) {
    if ($_.principal.servicePrincipalType -ne "Application") {
      $userRoleArray += $loopresults = [ordered] @{
        'Display Name'          = $_.principal.displayName
        'User Principal Name'   = $_.principal.userPrincipalName
        'User Guid'             = $_.principal.id
        'Role Guid'             = $_.roleDefinitionId
	'Role Display Name'     = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions/$($_.roleDefinitionId)").displayName
	 'Is Cloud Only Account' = if (((Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$($_.principalId)?`$select=OnPremisesImmutableId").OnPremisesImmutableId) -eq $null){"True"}else{"False"}
      }
    }
  }

# Set default to Fail

  $PassFail = "Fail"

  foreach ($_ in $userRoleArray) {
    if($_.'Is Cloud Only Account' -eq "True") {
      $PassFail = "Pass"
    } else {
      $PassFail = "Fail"
    }
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  foreach ($_ in $userRoleArray) {
    if ($_.'Is Cloud Only Account' -ne "True") {
      $htmlConstruction += $nonAdminsLoop = $_
    }
  }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Privileged Users Shall be provisioned Cloud only accounts." -Result "$PassFail" -Resolution "Provision Cloud only accounts for Administrators." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-planning#ensure-separate-user-accounts-and-mail-forwarding-for-global-administrator-accounts" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.7.3 - Auditing for Cloud Only Privileged Accounts' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Non-Cloud Only Accounts' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.7.3_CloudOnlyAdmins.html"
}
