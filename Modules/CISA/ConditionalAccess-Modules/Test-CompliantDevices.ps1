<#
Documentation: https://learn.microsoft.com/en-us/graph/api/conditionalaccessroot-list-policies
Least Privilege Delegated   = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-CompliantDevices {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $conditionalAccessPolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies").Value

# Set default to Fail
  $PassFail = "Fail"

  foreach ($_ in $conditionalAccessPolicies) {
    if ($_.grantControls.builtInControls -contains "compliantDevice" -and $_.grantControls.builtInControls -contains "domainJoinedDevice" -and $_.grantControls.operator -eq "OR" -and $_.conditions.users.includeUsers -eq "All" -and $_.conditions.clientAppTypes -eq "all" -and $_.state -eq "enabled") {
      $PassFail = "Pass"
      break
    } else {
      $PassFail = "Fail"
    }
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Managed Devices Should be required for Authentication." -Result "$PassFail" -Resolution "Ensure there is a Conditional Access policy that requires devices be compliant or hybrid joined." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-device-compliance" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $conditionalAccessPolicies) {
    if ($_.grantControls.builtInControls -contains "compliantDevice" -and $_.grantControls.builtInControls -contains "domainJoinedDevice" -and $_.grantControls.operator -eq "OR" -and $_.conditions.users.includeUsers -eq "All" -and $_.conditions.clientAppTypes -eq "all" -and $_.state -eq "enabled") {
      $htmlConstruction += $resultArray = [ordered] @{
        'Display Name'               = $_.displayName
        'CAP GUID'                   = $_.id
        'State'                      = $_.state
        'Included Applications'      = ($_.conditions.applications.includeApplications) -join ", "
        'Excluded Applications'      = ($_.conditions.applications.excludeApplications) -join ", "
        'Included Users'             = ($_.conditions.users.includeUsers) -join ", "
        'Included Roles'             = ($_.conditions.users.includeRoles) -join ", "
        'Included Groups'            = ($_.conditions.users.includeGroups) -join ", "
        'Excluded Users'             = ($_.conditions.users.excludeUsers) -join ", "
        'Excluded Groups'            = ($_.conditions.users.excludeGroups) -join ", "
        'Controls'                   = ($_.grantControls.builtInControls) -join ", "
        'Operator'                   = $_.grantControls.operator
      }
    }
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.3.7 - Managed Devices Should be required for Authentication' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Manage Device Conditional Access Policies' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.3.7_CompliantDevices.html"
}
