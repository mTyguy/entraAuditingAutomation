<#
Documentation: https://learn.microsoft.com/en-us/graph/api/conditionalaccessroot-list-policies
Least Privilege Delegated   = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-BlockLegacyAuthN {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $conditionalAccessPolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies").Value

# Set default to Fail
  $PassFail = "Fail"

  foreach ($_ in $conditionalAccessPolicies) {
    if ($_.conditions.clientAppTypes -contains "exchangeActiveSync"-and $_.conditions.clientAppTypes -contains "other" -and $_.grantControls.builtInControls -eq "block" -and $_.state -eq "enabled") {
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
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Legacy Authentication Shall be Blocked." -Result "$PassFail" -Resolution "Looking for a Conditional Access policy that blocks legacy authentication methods." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-legacy-authentication" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $conditionalAccessPolicies) {
    if ($_.conditions.clientAppTypes -contains "exchangeActiveSync"-and $_.conditions.clientAppTypes -contains "other" -and $_.grantControls.builtInControls -eq "block" -and $_.state -eq "enabled") {
      $htmlConstruction += $resultArray = [ordered] @{
        'Display Name'            = $_.displayName
        'CAP GUID'                = $_.id
        'State'                   = $_.state
        'Included Applications'   = ($_.conditions.applications.includeApplications) -join ", "
        'Excluded Applications'   = ($_.conditions.applications.excludeApplications) -join ", "
        'Included Users'          = ($_.conditions.users.includeUsers) -join ", "
        'Included Groups'         = ($_.conditions.users.includeGroups) -join ", "
        'Excluded Users'          = ($_.conditions.users.excludeUsers) -join ", "
        'Excluded Groups'         = ($_.conditions.users.excludeGroups) -join ", "
        'Controls'                = ($_.grantControls.builtInControls) -join ", "
      }
    }
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.1.1 - Legacy Authentication Shall be Blocked' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Enabled CAPs blocking Legacy Authentication' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.1.1_BlockLegacyAuthN.html"
}
