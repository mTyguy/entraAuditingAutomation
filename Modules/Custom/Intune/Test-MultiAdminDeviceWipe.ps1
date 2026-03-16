<#
Documentation: https://learn.microsoft.com/en-us/graph/api/intune-rbac-operationapprovalpolicy-list?view=graph-rest-beta
Least Privilege Delegated   = DeviceManagementRBAC.Read.All
Least Privilege Application = DeviceManagementRBAC.Read.All
#>
function Test-MultiAdminDeviceWipe {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $intuneMultiAdminApprovalPolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/operationApprovalPolicies").Value

# Set default to Fail
  $PassFail = "Fail"

  foreach ($_ in $intuneMultiAdminApprovalPolicies) {
    if ($_.policyType -eq "deviceWipe") {
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
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Multiple Admins Should be required to Wipe a device." -Result "$PassFail" -Resolution "Ensure multiple admins are required to Wipe a device" -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/multi-admin-approval" -Framework "Custom Rule"

# Environment Data Array
  $htmlConstruction = @()

  if ($PassFail -eq "Fail") {
    $htmlConstruction = [ordered] @{
      'Result'      = "Multiple Administrators are not required to Wipe a device"
      'Remediation' = "Create an Access Policy to require an additional approver"
      }
    } elseif ($PassFail = "Pass") {
      foreach ($_ in $intuneMultiAdminApprovalPolicies) {
        if ($_.policyType -eq "deviceWipe") {
          $htmlConstruction += $loop = [ordered] @{
            'Display Name' = $_.displayName
            'Policy Type'  = $_.policyType
            'Description'  = $_.description
            'Result'       = "Multiple Administrators are required to Wipe a device"
            }
          }
        }
      }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'Custom.Intune.Devices.1.03 - Multiple Admins Should be required to Wipe a device' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Results' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\Custom.Intune.Devices.1.03_MultiAdminDeviceWipe.html"
}
