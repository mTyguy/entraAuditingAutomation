<#
Documentation: https://learn.microsoft.com/en-us/graph/api/authorizationpolicy-get
Least Privilege Delegated = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-GuestUserAccess {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $guestUserPermissions = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy").guestUserRoleId

# Set default to Fail

  $PassFail = "Fail"

  if ($guestUserPermissions -eq "10dae51f-b6af-4016-8d66-8c2a99b929b3" -or $guestUserPermissions -eq "2af84b1e-32c8-42b7-82bc-daa82404023b") {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($guestUserPermissions -eq "a0b1b346-4d3e-4e8b-98f8-753987be4970") {
      $htmlConstruction = [ordered] @{
        'Current Setting' = $guestUserPermissions
        'Description'     = "Guest users have the same access as Member users (most inclusive)."
      }
    } elseif ($guestUserPermissions -eq "10dae51f-b6af-4016-8d66-8c2a99b929b3") {
      $htmlConstruction = [ordered] @{
        'Current Setting' = $guestUserPermissions
        'Description'     = "Guest users have limited access to properties and memberships of directory objects (middle road)."
      }
    } elseif ($guestUserPermissions -eq "2af84b1e-32c8-42b7-82bc-daa82404023b") {
      $htmlConstruction = [ordered] @{
        'Current Setting' = $guestUserPermissions
        'Description'     = "Guest users access is restricted to properties and memberships of their own directory objects (most restrictive)."
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Guest users Should have limited access to directory objects." -Result "$PassFail" -Resolution "Set that guest users have limited access in External Collaboration Settings." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/users/users-restrict-guest-permissions" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.8.1 - Guest users Should have limited access to directory objects' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Guest Access Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.8.1_GuestUserAccess.html"
}
