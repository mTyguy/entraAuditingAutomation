<#
Documentation: https://learn.microsoft.com/en-us/microsoftteams/settings-policies-reference?WT.mc_id=TeamsAdminCenterCSH#meeting-join--lobby
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-AnonUsersStartMeeting {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsMeetingsPolicies = Get-CsTeamsMeetingPolicy

  $teamsAnonUserStartMeetingPolicies = $teamsMeetingsPolicies | Where-Object {$_.AllowAnonymousUsersToStartMeeting -eq $true}

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsAnonUserStartMeetingPolicies.Count -eq "0") {
    $PassFail = "Pass"
  } elseif ($teamsAnonUserStartMeetingPolicies.Count -ge "1") {
      $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Policies' = "None"
      'Result'   = "No policies allow Anonymous Users to start meetings."
    }
  } elseif ($PassFail -eq "Fail") {
      $htmlConstruction += $globalPolicy = [ordered] @{
        'Policy Name'                        = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).Identity
        'Anonymous Users Can Start Meetings' = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).AllowAnonymousUsersToStartMeeting
      }
    foreach ($_ in $teamsAnonUserStartMeetingPolicies) {
      if ($_.AllowAnonymousUsersToStartMeeting -eq $true -and $_.Identity -ne "Global") {
        $htmlConstruction += $policyLoop = [ordered] @{
          'Policy Name'                        = $_.Identity
          'Anonymous Users Can Start Meetings' = $_.AllowAnonymousUsersToStartMeeting
          }
        }
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Anonymous Users Shall Not be allowed to start meetings." -Result "$PassFail" -Resolution "Ensure each Meetings Policy does not allow Anonymous Users to start meetings." -Controls "The Global policy is the default. If a user has a policy assigned to them, that takes policy takes precedent." -Citations "https://learn.microsoft.com/en-us/microsoftteams/settings-policies-reference?WT.mc_id=TeamsAdminCenterCSH#meeting-join--lobby" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.1.2 - Anonymous Users Shall Not be allowed to start meetings.' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global & Non-compliant policies regarding Anonymous Users Meetings Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.TEAMS.1.2_AnonUsersStartMeeting.html"
}
