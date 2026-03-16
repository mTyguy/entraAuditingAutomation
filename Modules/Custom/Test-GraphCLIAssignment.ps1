<#
Documentation: https://learn.microsoft.com/en-us/graph/api/serviceprincipal-get
Least Privilege Delegated   = Application.Read.All
Least Privilege Application = Application.Read.All
#>
function Test-GraphCLIAssignment {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $graphCommandLineTools = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals(appID='14d82eec-204b-4c2f-b7e8-296a70dab67e')"

# Set default to Fail
  $PassFail = "Fail"

    if ($graphCommandLineTools.appRoleAssignmentRequired -eq $true) {
      $PassFail = "Pass"
    } elseif ($graphCommandLineTools.Count -le 1) {
      $PassFail = "Fail"
      $appRegistered = $false
    } else {
      $PassFail = "Fail"
      $appRegistered = $true
    }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Graph Command Line Tools access Should be restricted." -Result "$PassFail" -Resolution "Ensure this Enterprise Application is registered and access is restricted" -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/assign-user-or-group-access-portal" -Framework "Custom Rule"

# Environment Data Array
  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Display Name'        = $graphCommandLineTools.appDisplayName
      'App ID'              = $graphCommandLineTools.appId
      'Requires Assignment' = $graphCommandLineTools.appRoleAssignmentRequired
      'Registered Date'     = $graphCommandLineTools.createdDateTime
      'Result'              = "Graph Command Line tools is registered and restricted"
    }
  } elseif ($PassFail -eq "Fail" -and $appRegistered -eq $true) {
      $htmlConstruction = [ordered] @{
        'Display Name'        = $graphCommandLineTools.appDisplayName
        'App ID'              = $graphCommandLineTools.appId
        'Requires Assignment' = $graphCommandLineTools.appRoleAssignmentRequired
        'Registered Date'     = $graphCommandLineTools.createdDateTime
        'Result'              = "Graph Command Line tools is registered, but not restricted"
        'Remediation'         = "It is recommended you restrict access to it"
      }
    } elseif ($PassFail -eq "Fail" -and $appRegistered -eq $false) {
      $htmlConstruction = [ordered] @{
        'Result'      = "Graph Command Line tools is not registered"
        'Remediation' = "It is recommended you register this application and then restrict access to it"
      }
    }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'Custom.Entra.Apps.1.01 - Graph Command Line Tools Access Should be restricted' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Results' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\Custom.Entra.Apps.1.01_GraphCLIAssignment.html"
}
