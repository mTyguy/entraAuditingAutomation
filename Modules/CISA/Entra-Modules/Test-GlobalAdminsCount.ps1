<#
Documentation: https://learn.microsoft.com/en-us/graph/api/rbacapplication-list-roleassignments
Least Privilege Delegated = RoleManagement.Read.Directory
Least Privilege Application = RoleManagement.Read.Directory
#>
function Test-GlobalAdminsCount {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $globalAdmins = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$filter=roleDefinitionId eq '62e90394-69f5-4237-9190-012177145e10'&`$expand=principal").Value

# Output for Pester
  Write-Output $globalAdmins.Count

  if ($globalAdmins.Count -ge 2 -and $globalAdmins.Count -le 8) {
    $PassFail = "Pass"
  } else {
      $PassFail = "Fail"
  }

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "There Shall be between 2 and 8 Global Administrators." -Result "$PassFail" -Resolution "Review the current Global Administrators and determine if they require this access." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/microsoft-365/admin/add-users/about-admin-roles?view=o365-worldwide#security-guidelines-for-assigning-roles" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $globalAdmins) {
    $htmlConstruction += $resultArray = [ordered] @{
      'Display Name'            = $_.principal.displayName
      'User Principal Name'     = $_.principal.userPrincipalName
      'Object GUID'             = $_.principal.id
      'Account Enabled'         = $_.principal.accountEnabled
      'User Type'               = $_.principal.userType
      'Last Interactive Signin' = (Get-MgUSer -UserId "$($_.principal.id)" -Property SignInActivity).SignInActivity.LastSignInDateTime
    }
  }

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.7.1 - There Shall be between 2 and 8 Global Administrators In Tenant' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global Administrators Information' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.7.1_GlobalAdminsCount.html"
}
