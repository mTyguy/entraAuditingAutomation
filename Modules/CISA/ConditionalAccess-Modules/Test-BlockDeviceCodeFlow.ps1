<#
Documentation: https://learn.microsoft.com/en-us/graph/api/conditionalaccessroot-list-policies
Least Privilege Delegated   = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-BlockDeviceCodeFlow {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $conditionalAccessPolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies").Value

# Set default to Fail
  $PassFail = "Fail"

  foreach ($_ in $conditionalAccessPolicies) {
    if ($_.conditions.authenticationFlows.values -eq "deviceCodeFlow" -and $_.conditions.users.includeUsers -eq "All" -and $_.conditions.clientAppTypes -eq "all" -and $_.state -eq "enabled") {
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
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Device Code Flow Should be blocked." -Result "$PassFail" -Resolution "Ensure there is a Conditional Access policy that prevents authentication via Device Code Flow." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-authentication-flows" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $conditionalAccessPolicies) {
    if ($_.conditions.authenticationFlows.values -eq "deviceCodeFlow" -and $_.conditions.users.includeUsers -eq "All" -and $_.conditions.clientAppTypes -eq "all" -and $_.state -eq "enabled") {
      $htmlConstruction += $resultArray = [ordered] @{
        'Display Name'            = $_.displayName
        'CAP GUID'                = $_.id
        'State'                   = $_.state
        'Included Users'          = ($_.conditions.users.includeUsers) -join ", "
        'Included Groups'         = ($_.conditions.users.includeGroups) -join ", "
        'Excluded Users'          = ($_.conditions.users.excludeUsers) -join ", "
        'Excluded Groups'         = ($_.conditions.users.excludeGroups) -join ", "
        'Controls'                = ($_.grantControls.builtInControls) -join ", "
        'Authentication Flows'    = [string]$_.conditions.authenticationFlows.values
      }
    }
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.3.9 - Device Code Flow Should be blocked' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Enabled CAPs that block Device Code Flow' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.3.9_BlockDeviceCodeFlow.html"
}
