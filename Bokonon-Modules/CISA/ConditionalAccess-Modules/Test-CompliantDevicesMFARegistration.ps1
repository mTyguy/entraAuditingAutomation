<#
Documentation: https://learn.microsoft.com/en-us/graph/api/conditionalaccessroot-list-policies
Least Privilege Delegated   = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-CompliantDevicesMFARegistration {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $conditionalAccessPolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies").Value

# Set default to Fail
  $PassFail = "Fail"

  foreach ($_ in $conditionalAccessPolicies) {
    if ($_.grantControls.builtInControls -contains "compliantDevice" -and $_.grantControls.builtInControls -contains "domainJoinedDevice" -and $_.grantControls.operator -eq "OR" -and $_.conditions.applications.includeUserActions -eq "urn:user:registersecurityinfo" -and $_.conditions.users.includeUsers -eq "All" -and $_.state -eq "enabled") {
      $policyName = $_.displayName
      $PassFail = "Pass"
    } else {
      $PassFail = "Fail"
    }
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Manged Devices Should be required to register MFA." -Result "$PassFail" -Resolution "Ensure there is a Conditional Access policy that requires devices be compliant or hybrid joined for MFA to be registered." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/conditional-access/" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $conditionalAccessPolicies) {
    if ($_.grantControls.builtInControls -contains "compliantDevice" -and $_.grantControls.builtInControls -contains "domainJoinedDevice" -and $_.grantControls.operator -eq "OR" -and $_.conditions.applications.includeUserActions -eq "urn:user:registersecurityinfo" -and $_.conditions.users.includeUsers -eq "All" -and $_.state -eq "enabled") {
      $htmlConstruction += $resultArray = [ordered] @{
        'Display Name'               = $_.displayName
        'CAP GUID'                   = $_.id
        'State'                      = $_.state
        'User Action'                = $_.conditions.applications.includeUserActions[0]
        'Included Users'             = ($_.conditions.users.includeUsers) -join ", "
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
    New-HtmlSection -HeaderText 'MS.AAD.3.8 - Manged Devices Should be required to register MFA' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Manage Device conditional access policies to register MFA' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\CompliantDevicesMFARegistration.html"
}
