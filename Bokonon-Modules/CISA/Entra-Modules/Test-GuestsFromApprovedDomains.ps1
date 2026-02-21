<#
Documentation: https://learn.microsoft.com/en-us/graph/api/crosstenantaccesspolicy-get
	https://learn.microsoft.com/en-us/graph/api/resources/crosstenantaccesspolicy?view=graph-rest-1.0
	https://learn.microsoft.com/en-us/graph/api/resources/crosstenantaccesspolicytargetconfiguration?view=graph-rest-1.0
Least Privilege Delegated = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-GuestsFromApprovedDomains {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $guestUserCrossAccessPolicy = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/default"

# Set default to Fail

  $PassFail = "Fail"

  if ($guestUserCrossAccessPolicy.b2bCollaborationInbound.usersAndGroups.accessType -ne "allowed") {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($guestUserCrossAccessPolicy.b2bCollaborationInbound.usersAndGroups.accessType -eq "allowed") {
    $htmlConstruction = [ordered] @{
      'Current Setting' = $guestUserCrossAccessPolicy.b2bCollaborationInbound.usersAndGroups.accessType
      'Description'     = "Guest users can originate from any domain."
    }
  } elseif ($guestUserCrossAccessPolicy.b2bCollaborationInbound.usersAndGroups.accessType -ne "allowed") {
    $htmlConstruction = [ordered] @{
      'Current Setting' = $guestUserCrossAccessPolicy.b2bCollaborationInbound.usersAndGroups.accessType
      'Description'     = "Guest users can only originate from the following listed domains."
      'Guest Domains'   = ((Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/partners").Value)
    }
  }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Guest Users should only originate from approved Domains." -Result "$PassFail" -Resolution "Set that guest users have limited access in External Collaboration Settings." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/microsoft-365/solutions/limit-invitations-from-specific-organization?view=o365-worldwide" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.8.3 - Guest Users should only originate from approved Domains' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Guest Access Inbound Domain Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\GuestsFromApprovedDomains.html"
}
