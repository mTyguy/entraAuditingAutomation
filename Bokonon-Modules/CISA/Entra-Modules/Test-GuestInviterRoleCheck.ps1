<#
Documentation: https://learn.microsoft.com/en-us/graph/api/authorizationpolicy-get
Least Privilege Delegated = Policy.Read.All
Least Privilege Application = Policy.Read.All
#>
function Test-GuestInviterRoleCheck {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $guestInviterRolePolicy = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authorizationPolicy").allowInvitesFrom

# Set default to Fail

  $PassFail = "Fail"

  if ($guestInviterRolePolicy -eq "adminsAndGuestInviters" -or $guestInviterRolePolicy -eq "none") {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($guestInviterRolePolicy -eq "everyone") {
      $htmlConstruction = [ordered] @{
        'Current Setting' = $guestInviterRolePolicy
        'Description'     = "Anyone in the organization, including other guests, can invite guests into the tenant."
      }
    } elseif ($guestInviterRolePolicy -eq "adminsGuestInvitersAndAllMembers") {
      $htmlConstruction = [ordered] @{
        'Current Setting' = $guestInviterRolePolicy
        'Description'     = "Only member users can invite guests into the tenant."
      }
    } elseif ($guestInviterRolePolicy -eq "adminsAndGuestInviters") {
      $htmlConstruction = [ordered] @{
        'Current Setting' = $guestInviterRolePolicy
        'Description'     = "Only Member users with specific admin roles can invite guests into the tenant."
      }
    } elseif ($guestInviterRolePolicy -eq "none") {
      $htmlConstruction = [ordered] @{
        'Current Setting' = $guestInviterRolePolicy
        'Description'     = "Guests cannot be invited into the tenant."
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Only Administrators and users with Guest Inviter role Should be able to invite guests." -Result "$PassFail" -Resolution "Set that only users assigned to specific admin roles can invite guest users in External Collaboration settings." -Controls "https://learn.microsoft.com/en-us/microsoft-365/solutions/limit-who-can-invite-guests?view=o365-worldwide" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.8.2 - Only Administrators and users with Guest Inviter role Should be able to invite guests' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Guest Invite Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\GuestInviterRoleCheck.html"
}
