<#
Documentation: https://learn.microsoft.com/en-us/microsoftteams/who-can-bypass-meeting-lobby
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-DialInBypassLobby {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsMeetingsPolicies = Get-CsTeamsMeetingPolicy

  $teamsDialinWaitInLobby = $teamsMeetingsPolicies | Where-Object {$_.AllowPSTNUsersToBypassLobby -eq $true}

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsDialinWaitInLobby.Count -eq "0") {
    $PassFail = "Pass"
  } elseif ($teamsDialinWaitInLobby.Count -ge "1") {
      $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Policies' = "None"
      'Result'   = "No policies allow Dial-In users to bypass the lobby."
    }
  } elseif ($PassFail -eq "Fail") {
      $htmlConstruction += $globalPolicy = [ordered] @{
        'Global Policy'                  = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).Identity
        'Dial-In Users Can bypass lobby' = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).AllowPSTNUsersToBypassLobby
        'Who Can bypass the lobby'       = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).AutoAdmittedUsers
        '-----------------------'        = "-----------------------"
      }
    foreach ($_ in $teamsDialinWaitInLobby) {
      if ($_.AllowPSTNUsersToBypassLobby -eq $true) {
        $htmlConstruction += $policyLoop = [ordered] @{
          'Policy Name'                    = $_.Identity
          'Dial-In Users Can bypass lobby' = $_.AllowPSTNUsersToBypassLobby
          'Who Can bypass the lobby'       = $_.AutoAdmittedUsers
          }
        }
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Dial-in Users Should Not be able to bypass the lobby." -Result "$PassFail" -Resolution "Ensure Dial-in users must wait in lobby to be admitted to meetings." -Controls "The Global policy is the default. If a user has a policy assigned to them that takes precedent." -Citations "https://learn.microsoft.com/en-us/microsoftteams/who-can-bypass-meeting-lobby" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.1.5 - Dial-in Users Should Not be able to bypass the lobby.' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global & Non-compliant policies regarding Dial-In Users Meetings Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\DialInBypassLobby.html"
}
