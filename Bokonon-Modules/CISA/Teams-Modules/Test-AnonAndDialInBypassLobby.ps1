<#
Documentation: https://learn.microsoft.com/en-us/microsoftteams/settings-policies-reference?WT.mc_id=TeamsAdminCenterCSH#meeting-join--lobby
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-AnonAndDialInBypassLobby {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsMeetingsPolicies = Get-CsTeamsMeetingPolicy

  $teamsAnonDialinWaitInLobby = $teamsMeetingsPolicies | Where-Object {$_.AllowPSTNUsersToBypassLobby -eq $true -and $_.AutoAdmittedUsers -eq "Everyone"}

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsAnonDialinWaitInLobby.Count -eq "0") {
    $PassFail = "Pass"
  } elseif ($teamsAnonDialinWaitInLobby.Count -ge "1") {
      $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Policies' = "None"
      'Result'   = "No policies allow Anonymous and Dial-in Users to bypass lobby."
    }
  } elseif ($PassFail -eq "Fail") {
      $htmlConstruction += $globalPolicy = [ordered] @{
        'Policy Name'                    = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).Identity
        'Dial-In Users Can bypass lobby' = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).AllowPSTNUsersToBypassLobby
        'Who Can bypass the lobby'       = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).AutoAdmittedUsers
      }
    foreach ($_ in $teamsAnonDialinWaitInLobby) {
      if ($_.AllowPSTNUsersToBypassLobby -eq $true -and $_.AutoAdmittedUsers -eq "Everyone" -and $_.Identity -ne "Global") {
        $htmlConstruction += $policyLoop = [ordered] @{
          'Policy Name'                    = $_.Identity
          'Dial-In Users Can bypass lobby' = $_.AllowPSTNUsersToBypassLobby
          'Who Can bypass the lobby'       = $_.AutoAdmittedUsers
          }
        }
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Anonymous and Dial-in Users Should Not be admitted automatically." -Result "$PassFail" -Resolution "Ensure Anon and Dial-in users must wait in lobby to be admitted to meetings." -Controls "The Global policy is the default. If a user has a policy assigned to them, that takes policy takes precedent." -Citations "https://learn.microsoft.com/en-us/microsoftteams/settings-policies-reference?WT.mc_id=TeamsAdminCenterCSH#meeting-join--lobby" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.1.3 - Anonymous and Dial-in Users Should Not be admitted automatically.' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global & Non-compliant policies regarding Anonymous & Dial-In Users Meetings Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.TEAMS.1.3_AnonAndDialInBypassLobby.html"
}
